from typing import Dict, List, Optional, Tuple
import heapq
import math

from firebase_admin import firestore


def fetch_vertices() -> Dict[str, dict]:
    db = firestore.client()
    docs = db.collection("vertices").stream()
    vertices: Dict[str, dict] = {}

    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        vertices[doc.id] = data

    return vertices


def fetch_edges() -> List[dict]:
    db = firestore.client()
    docs = db.collection("edges").stream()
    edges: List[dict] = []

    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        edges.append(data)

    return edges


def fetch_accessibility_reports() -> List[dict]:
    db = firestore.client()
    docs = db.collection("accessibility_reports").where("status", "==", "active").stream()

    reports: List[dict] = []
    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        reports.append(data)

    return reports


def save_accessibility_report(report: dict, edge_id: str) -> str:
    db = firestore.client()
    doc_ref = db.collection("accessibility_reports").document()

    doc_ref.set({
        "edgeId": edge_id,
        "type": report["type"],
        "lat": float(report["lat"]),
        "lng": float(report["lng"]),
        "description": report.get("description", ""),
        "status": "active",
        "createdAt": firestore.SERVER_TIMESTAMP,
    })

    return doc_ref.id


def build_reports_by_edge(reports: List[dict]) -> Dict[str, List[dict]]:
    reports_by_edge: Dict[str, List[dict]] = {}

    for report in reports:
        edge_id = report.get("edgeId")
        if not edge_id:
            continue
        reports_by_edge.setdefault(edge_id, []).append(report)

    return reports_by_edge


def haversine_meters(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    r = 6371000.0

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lng2 - lng1)

    a = (
        math.sin(dphi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return r * c


def point_to_segment_distance_meters(
    px: float, py: float,
    ax: float, ay: float,
    bx: float, by: float,
) -> float:
    abx = bx - ax
    aby = by - ay
    apx = px - ax
    apy = py - ay

    ab_len_sq = abx * abx + aby * aby

    if ab_len_sq == 0:
        return haversine_meters(py, px, ay, ax)

    t = (apx * abx + apy * aby) / ab_len_sq
    t = max(0.0, min(1.0, t))

    closest_x = ax + t * abx
    closest_y = ay + t * aby

    return haversine_meters(py, px, closest_y, closest_x)


def find_nearest_vertex_id(vertices: Dict[str, dict], point: dict) -> str:
    target_lat = float(point["lat"])
    target_lng = float(point["lng"])

    best_id = None
    best_dist = float("inf")

    for vertex_id, vertex in vertices.items():
        lat = float(vertex["latitude"])
        lng = float(vertex["longitude"])
        dist = haversine_meters(target_lat, target_lng, lat, lng)

        if dist < best_dist:
            best_dist = dist
            best_id = vertex_id

    if best_id is None:
        raise ValueError("No vertices available in database.")

    return best_id


def find_nearest_edge_id(
    edges: List[dict],
    vertices: Dict[str, dict],
    point: dict,
) -> str:
    target_lat = float(point["lat"])
    target_lng = float(point["lng"])

    best_edge_id = None
    best_dist = float("inf")

    for edge in edges:
        from_id = edge.get("fromVertexId")
        to_id = edge.get("toVertexId")

        if from_id not in vertices or to_id not in vertices:
            continue

        from_v = vertices[from_id]
        to_v = vertices[to_id]

        ax = float(from_v["longitude"])
        ay = float(from_v["latitude"])
        bx = float(to_v["longitude"])
        by = float(to_v["latitude"])

        dist = point_to_segment_distance_meters(
            target_lng, target_lat,
            ax, ay,
            bx, by,
        )

        if dist < best_dist:
            best_dist = dist
            best_edge_id = edge["id"]

    if best_edge_id is None:
        raise ValueError("No edges available in database.")

    return best_edge_id


def build_graph(edges: List[dict]) -> Dict[str, List[dict]]:
    graph: Dict[str, List[dict]] = {}

    for edge in edges:
        if not edge.get("routePossible", True):
            continue

        if "fromVertexId" not in edge or "toVertexId" not in edge:
            raise ValueError(f"Edge document missing fromVertexId or toVertexId: {edge}")

        from_id = edge["fromVertexId"]
        to_id = edge["toVertexId"]

        graph.setdefault(from_id, []).append(edge)

        if edge.get("bidirectional", True):
            reverse_edge = edge.copy()
            reverse_edge["id"] = f"{edge['id']}_reverse"
            reverse_edge["fromVertexId"] = to_id
            reverse_edge["toVertexId"] = from_id
            graph.setdefault(to_id, []).append(reverse_edge)

    return graph


def effective_edge(edge: dict, reports_by_edge: Dict[str, List[dict]]) -> dict:
    modified = edge.copy()
    base_edge_id = edge["id"].replace("_reverse", "")
    reports = reports_by_edge.get(base_edge_id, [])

    for report in reports:
        report_type = report.get("type")

        if report_type == "ramp":
            modified["hasStairs"] = False
            modified["isAccessible"] = True

        elif report_type == "bench":
            modified["hasBench"] = True

        elif report_type == "elevator":
            modified["isAccessible"] = True

        elif report_type == "broken_elevator":
            modified["isAccessible"] = False

    return modified


def edge_cost(edge: dict, prefs: dict, reports_by_edge: Dict[str, List[dict]]) -> float:
    edge = effective_edge(edge, reports_by_edge)

    if not edge.get("routePossible", True):
        return float("inf")

    if prefs.get("avoid_stairs", False) and edge.get("hasStairs", False):
        return float("inf")

    if prefs.get("wheelchair_only", False) and not edge.get("isAccessible", True):
        return float("inf")

    if prefs.get("indoor_only", False) and not edge.get("isIndoor", False):
        return float("inf")

    if prefs.get("need_benches", False) and not edge.get("hasBench", False):
        return float("inf")

    if prefs.get("hasHill", False) and float(edge.get("slopeLevel", 0)) <= 0:
        return float("inf")

    return float(edge.get("timeSeconds", 0))


def shortest_path(
    start_id: str,
    end_id: str,
    graph: Dict[str, List[dict]],
    prefs: dict,
    reports_by_edge: Dict[str, List[dict]],
) -> Optional[Tuple[List[str], float]]:
    pq: List[Tuple[float, str]] = [(0.0, start_id)]
    distances: Dict[str, float] = {start_id: 0.0}
    previous: Dict[str, Optional[str]] = {start_id: None}
    visited = set()

    while pq:
        current_dist, current = heapq.heappop(pq)

        if current in visited:
            continue
        visited.add(current)

        if current == end_id:
            break

        for edge in graph.get(current, []):
            next_vertex = edge["toVertexId"]
            cost = edge_cost(edge, prefs, reports_by_edge)

            if cost == float("inf"):
                continue

            new_dist = current_dist + cost

            if new_dist < distances.get(next_vertex, float("inf")):
                distances[next_vertex] = new_dist
                previous[next_vertex] = current
                heapq.heappush(pq, (new_dist, next_vertex))

    if end_id not in distances:
        return None

    path: List[str] = []
    cur: Optional[str] = end_id

    while cur is not None:
        path.append(cur)
        cur = previous.get(cur)

    path.reverse()
    return path, distances[end_id]


def find_edge_between(graph: Dict[str, List[dict]], from_id: str, to_id: str) -> Optional[dict]:
    for edge in graph.get(from_id, []):
        if edge["toVertexId"] == to_id:
            return edge
    return None


def build_route_response(
    path: List[str],
    total_duration_seconds: float,
    vertices: Dict[str, dict],
    graph: Dict[str, List[dict]],
    prefs: dict,
    reports_by_edge: Dict[str, List[dict]],
) -> dict:
    coordinates: List[List[float]] = []
    steps: List[dict] = []
    accessibility_notes: List[dict] = []
    total_distance_meters = 0.0

    for vertex_id in path:
        v = vertices[vertex_id]
        lat = float(v["latitude"])
        lng = float(v["longitude"])
        coordinates.append([lng, lat])

    for i in range(len(path) - 1):
        from_id = path[i]
        to_id = path[i + 1]

        from_v = vertices[from_id]
        to_v = vertices[to_id]

        from_lat = float(from_v["latitude"])
        from_lng = float(from_v["longitude"])
        to_lat = float(to_v["latitude"])
        to_lng = float(to_v["longitude"])

        step_distance = haversine_meters(from_lat, from_lng, to_lat, to_lng)
        total_distance_meters += step_distance

        edge = find_edge_between(graph, from_id, to_id)
        step_duration = float(edge.get("timeSeconds", 0)) if edge else 0.0

        if edge:
            edge = effective_edge(edge, reports_by_edge)

        steps.append({
            "instruction": f"Go from {from_v.get('name', from_id)} to {to_v.get('name', to_id)}",
            "distance_meters": round(step_distance, 1),
            "duration_seconds": round(step_duration, 1),
            "geometry": {
                "type": "LineString",
                "coordinates": [
                    [from_lng, from_lat],
                    [to_lng, to_lat]
                ]
            }
        })

        if edge:
            if edge.get("isIndoor", False):
                accessibility_notes.append({
                    "type": "indoor_segment",
                    "description": f"Indoor segment between {from_v.get('name', from_id)} and {to_v.get('name', to_id)}",
                    "location": {
                        "lat": from_lat,
                        "lng": from_lng
                    }
                })

            if edge.get("hasBench", False):
                accessibility_notes.append({
                    "type": "bench",
                    "description": f"Bench available near segment from {from_v.get('name', from_id)} to {to_v.get('name', to_id)}",
                    "location": {
                        "lat": from_lat,
                        "lng": from_lng
                    }
                })

            base_edge_id = edge["id"].replace("_reverse", "")
            reports = reports_by_edge.get(base_edge_id, [])
            for report in reports:
                accessibility_notes.append({
                    "type": report.get("type", "reported_feature"),
                    "description": report.get("description", f"Reported {report.get('type', 'feature')} near this segment"),
                    "location": {
                        "lat": float(report.get("lat", from_lat)),
                        "lng": float(report.get("lng", from_lng))
                    }
                })

    if prefs.get("wheelchair_only", False):
        accessibility_notes.append({
            "type": "wheelchair_route",
            "description": "Route was filtered to wheelchair-accessible edges only.",
            "location": {
                "lat": float(vertices[path[0]]["latitude"]),
                "lng": float(vertices[path[0]]["longitude"])
            }
        })

    if prefs.get("avoid_stairs", False):
        accessibility_notes.append({
            "type": "stairs_avoided",
            "description": "Route was computed to avoid stairs.",
            "location": {
                "lat": float(vertices[path[0]]["latitude"]),
                "lng": float(vertices[path[0]]["longitude"])
            }
        })

    if prefs.get("need_benches", False):
        accessibility_notes.append({
            "type": "bench_required",
            "description": "Route was filtered to segments with benches only.",
            "location": {
                "lat": float(vertices[path[0]]["latitude"]),
                "lng": float(vertices[path[0]]["longitude"])
            }
        })

    if prefs.get("indoor_only", False):
        accessibility_notes.append({
            "type": "indoor_only",
            "description": "Route was filtered to indoor edges only.",
            "location": {
                "lat": float(vertices[path[0]]["latitude"]),
                "lng": float(vertices[path[0]]["longitude"])
            }
        })

    if prefs.get("hasHill", False):
        accessibility_notes.append({
            "type": "hill_required",
            "description": "Route was filtered to segments with slope greater than 0 only.",
            "location": {
                "lat": float(vertices[path[0]]["latitude"]),
                "lng": float(vertices[path[0]]["longitude"])
            }
        })

    return {
        "route": {
            "distance_meters": round(total_distance_meters, 1),
            "duration_seconds": round(total_duration_seconds, 1),
            "geometry": {
                "type": "LineString",
                "coordinates": coordinates
            },
            "steps": steps,
            "accessibility_notes": accessibility_notes
        }
    }