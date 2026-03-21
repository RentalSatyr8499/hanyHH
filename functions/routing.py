from typing import Dict, List, Optional, Tuple
import heapq

from firebase_admin import firestore

# Load all vertices from Firestore and return them as a dictionary:
def fetch_vertices() -> Dict[str, dict]:
    db = firestore.client()
    docs = db.collection("vertices").stream()
    vertices: Dict[str, dict] = {}

    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        vertices[doc.id] = data

    return vertices

# Load all edges from Firestore and return them as a list.
def fetch_edges() -> List[dict]:
    db = firestore.client()
    docs = db.collection("edges").stream()
    edges: List[dict] = []

    for doc in docs:
        data = doc.to_dict()
        data["id"] = doc.id
        edges.append(data)

    return edges

# Convert the list of Firestore edge documents into an adjacency list.
def build_graph(edges: List[dict]) -> Dict[str, List[dict]]:
    graph: Dict[str, List[dict]] = {}

    for edge in edges:
        if not edge.get("routePossible", True):
            continue

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


# Return the traversal cost for an edge. If the edge violates any user restriction, return infinity so Dijkstra will never use it. Cost is travel time in seconds.
def edge_cost(edge: dict, prefs: dict) -> float:
    if not edge.get("routePossible", True):
        return float("inf")

    if prefs.get("avoidStairs", False) and edge.get("hasStairs", False):
        return float("inf")

    if prefs.get("accessibleOnly", False) and not edge.get("isAccessible", True):
        return float("inf")

    if prefs.get("indoorOnly", False) and not edge.get("isIndoor", False):
        return float("inf")

    return float(edge.get("timeSeconds", 0))


# Use Dijkstra's algorithm to find minimum total time path from start to end node while considering constraints. Returns tuple with (path, total cost)
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

# Build the route that will be sent back to Flutter.
def build_route_response(
    path: List[str],
    total_cost: float,
    vertices: Dict[str, dict]
) -> dict:
    route_vertices = []

    for vertex_id in path:
        v = vertices.get(vertex_id, {})
        route_vertices.append({
            "id": vertex_id,
            "name": v.get("name", ""),
            "latitude": v.get("latitude"),
            "longitude": v.get("longitude"),
            "type": v.get("type", ""),
        })

    return {
        "vertexPath": path,
        "totalCost": total_cost,
        "vertices": route_vertices,
    }