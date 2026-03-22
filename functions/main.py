from typing import Dict, Any
import json

from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app

from routing import (
    fetch_vertices,
    fetch_edges,
    find_nearest_vertex_id,
    build_graph,
    shortest_path,
    build_route_response,
)

set_global_options(max_instances=10)
initialize_app()


@https_fn.on_request()
def route(req: https_fn.Request) -> https_fn.Response:
    try:
        data: Dict[str, Any] = req.get_json(silent=True) or {}

        source = data.get("source")
        destination = data.get("destination")
        prefs = data.get("preferences", {})

        if not source or not destination:
            return https_fn.Response(
                json.dumps({"error": "Missing source or destination"}),
                status=400,
                content_type="application/json",
            )

        if "lat" not in source or "lng" not in source:
            return https_fn.Response(
                json.dumps({"error": "Source must include lat and lng"}),
                status=400,
                content_type="application/json",
            )

        if "lat" not in destination or "lng" not in destination:
            return https_fn.Response(
                json.dumps({"error": "Destination must include lat and lng"}),
                status=400,
                content_type="application/json",
            )

        vertices = fetch_vertices()
        edges = fetch_edges()
        graph = build_graph(edges)

        start_id = find_nearest_vertex_id(vertices, source)
        end_id = find_nearest_vertex_id(vertices, destination)

        result = shortest_path(start_id, end_id, graph, prefs)

        if result is None:
            return https_fn.Response(
                json.dumps({"error": "No valid route found"}),
                status=404,
                content_type="application/json",
            )

        path, total_duration_seconds = result

        max_route_time_minutes = prefs.get("max_route_time_minutes")
        if max_route_time_minutes is not None:
            max_duration_seconds = float(max_route_time_minutes) * 60.0
            if total_duration_seconds > max_duration_seconds:
                return https_fn.Response(
                    json.dumps({"error": "No valid route found within time limit"}),
                    status=404,
                    content_type="application/json",
                )

        response_data = build_route_response(
            path=path,
            total_duration_seconds=total_duration_seconds,
            vertices=vertices,
            graph=graph,
            prefs=prefs,
        )

        return https_fn.Response(
            json.dumps(response_data),
            status=200,
            content_type="application/json",
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({"error": str(e)}),
            status=500,
            content_type="application/json",
        )