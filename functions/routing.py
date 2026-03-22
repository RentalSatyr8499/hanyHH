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


def edge_cost(edge: dict, prefs: dict) -> float:
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

    cost = float(edge.get("timeSeconds", 0))
    return cost


def shortest_path(
    start_id: str,
    end_id: str,
    graph: Dict[str, List[dict]],
    prefs: dict,
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
            cost = edge_cost(edge, prefs)

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