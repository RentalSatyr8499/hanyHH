from typing import Dict, Any
import json

from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app

from routing import (
    fetch_vertices,
    fetch_edges,
    build_graph,
    shortest_path,
    build_route_response,
)

set_global_options(max_instances=10)

initialize_app()


@https_fn.on_request()
def get_route(req: https_fn.Request) -> https_fn.Response:
    try:
        data: Dict[str, Any] = req.get_json(silent=True) or {}

        start_id = data.get("startVertexId")
        end_id = data.get("endVertexId")
        prefs = data.get("preferences", {})

        if not start_id or not end_id:
            return https_fn.Response(
                json.dumps({"error": "Missing startVertexId or endVertexId"}),
                status=400,
                content_type="application/json",
            )

        vertices = fetch_vertices()
        edges = fetch_edges()
        graph = build_graph(edges)

        result = shortest_path(start_id, end_id, graph, prefs)

        if result is None:
            return https_fn.Response(
                json.dumps({"error": "No valid route found"}),
                status=404,
                content_type="application/json",
            )

        path, total_cost = result
        response_data = build_route_response(path, total_cost, vertices)

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