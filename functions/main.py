from typing import Dict, Any
import json

from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app

from routing import (
    fetch_vertices,
    fetch_edges,
    find_nearest_vertex_id,
    find_nearest_edge_id,
    build_graph,
    shortest_path,
    build_route_response,
    save_accessibility_report,
    fetch_accessibility_reports,
    build_reports_by_edge,
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

        reports = fetch_accessibility_reports()
        reports_by_edge = build_reports_by_edge(reports)

        result = shortest_path(start_id, end_id, graph, prefs, reports_by_edge)

        if result is None:
            return https_fn.Response(
                json.dumps({"error": "No valid route found"}),
                status=404,
                content_type="application/json",
            )

        path, total_duration_seconds = result

        max_route_time_minutes = prefs.get("max_route_time_minutes")
        if max_route_time_minutes is not None:
            try:
                max_duration_seconds = float(max_route_time_minutes) * 60.0
            except (TypeError, ValueError):
                return https_fn.Response(
                    json.dumps({"error": "max_route_time_minutes must be a number"}),
                    status=400,
                    content_type="application/json",
                )

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
            reports_by_edge=reports_by_edge,
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


@https_fn.on_request()
def report_accessibility_feature(req: https_fn.Request) -> https_fn.Response:
    try:
        data: Dict[str, Any] = req.get_json(silent=True) or {}
        report = data.get("feature")

        if not report:
            return https_fn.Response(
                json.dumps({"error": "Missing feature"}),
                status=400,
                content_type="application/json",
            )

        if "type" not in report or "lat" not in report or "lng" not in report:
            return https_fn.Response(
                json.dumps({"error": "Feature must include type, lat, and lng"}),
                status=400,
                content_type="application/json",
            )

        vertices = fetch_vertices()
        edges = fetch_edges()
        edge_id = find_nearest_edge_id(edges, vertices, report)
        report_id = save_accessibility_report(report, edge_id)

        return https_fn.Response(
            json.dumps(
                {
                    "message": "Accessibility feature reported successfully",
                    "reportId": report_id,
                    "matchedEdgeId": edge_id,
                }
            ),
            status=200,
            content_type="application/json",
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({"error": str(e)}),
            status=500,
            content_type="application/json",
        )