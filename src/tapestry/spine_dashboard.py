# --- Self-Observing Dashboard with Spine Projections ---
# Monitors coherence via spine run projections (κ, β, D, ρ)

import os, csv, time, random, datetime
import sys
from pathlib import Path

# Add parent for imports
sys.path.insert(0, str(Path(__file__).parent))

import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.graph_objs as go
from collections import deque
from flask import jsonify

# Import spine projection
from spine.projection import ProjectionReader, project_to_dashboard_format
from spine.redaction import Redactor, safe_project

# Global state
buffer = deque(maxlen=300)
projection_reader = ProjectionReader()

# Demo mode flag
SAFE_DEMO = os.environ.get("TAPESTRY_SAFE_DEMO", "0") == "1"

app = dash.Dash(__name__)
app.title = "Spine Projection Dashboard | UOS"

def sample_from_projection():
    """Sample coherence from latest spine projection."""
    proj = projection_reader.get_latest_projection()
    if proj:
        # Use mean coherence from projection
        return proj.mean_coherence
    # Fallback to placeholder if no runs
    return 0.75 + 0.1 * random.random()

def sample_kappa():
    """Sample kappa from latest spine projection."""
    proj = projection_reader.get_latest_projection()
    if proj:
        return proj.kappa_final
    return 0.5 + 0.2 * random.random()

def sample_rho():
    """Sample rho from latest spine projection."""
    proj = projection_reader.get_latest_projection()
    if proj:
        return proj.rho_final
    return 1.0 + 0.3 * random.random()

def sample_beta():
    """Sample beta from latest spine projection."""
    proj = projection_reader.get_latest_projection()
    if proj:
        return proj.beta
    return 0.7 + 0.2 * random.random()

def sample_D():
    """Sample D (disturbance) from latest spine projection."""
    proj = projection_reader.get_latest_projection()
    if proj:
        return proj.D
    return 0.02 + 0.01 * random.random()

def now_ts():
    """Current timestamp"""
    return datetime.datetime.now()

def add_sample():
    """Append new sample from projection to buffer"""
    val = sample_from_projection()
    ts = now_ts()
    buffer.append((ts, val))

def to_trace():
    """Convert buffer to Plotly trace"""
    if not buffer:
        return go.Scatter(x=[], y=[], mode="lines+markers", name="Coherence")
    xs = [t.strftime("%H:%M:%S") for (t, v) in buffer]
    ys = [v for (t, v) in buffer]
    return go.Scatter(x=xs, y=ys, mode="lines+markers", name="Coherence C(t)")

def to_kappa_trace():
    """Convert kappa from projections to trace"""
    projs = projection_reader.get_all_projections()
    if not projs:
        return go.Scatter(x=[], y=[], mode="lines+markers", name="κ (kappa)")
    xs = [p.timestamp for p in projs]
    ys = [p.kappa_final for p in projs]
    return go.Scatter(x=xs, y=ys, mode="lines+markers", name="κ (kappa)")

def save_csv(path):
    """Save current buffer to CSV file"""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["timestamp", "coherence"])
        for ts, v in buffer:
            w.writerow([ts.isoformat(), f"{v:.6f}"])

# Layout
app.layout = html.Div([
    html.H2("⬢ Universal Operating System Console", 
            style={"textAlign":"center", "color":"#764ba2"}),
    html.Div("Spine Projection Dashboard | κ-Stability Monitoring", 
             style={"textAlign":"center", "marginBottom":"20px", "color":"#666"}),

    # Metrics display
    html.Div([
        html.Div(id="kappa-metric", style={"display":"inline-block", "margin":"0 20px", "fontSize":"24px", "fontWeight":"bold", "color":"#333"}),
        html.Div(id="rho-metric", style={"display":"inline-block", "margin":"0 20px", "fontSize":"24px", "fontWeight":"bold", "color":"#333"}),
        html.Div(id="beta-metric", style={"display":"inline-block", "margin":"0 20px", "fontSize":"24px", "fontWeight":"bold", "color":"#333"}),
        html.Div(id="D-metric", style={"display":"inline-block", "margin":"0 20px", "fontSize":"24px", "fontWeight":"bold", "color":"#333"}),
    ], style={"textAlign":"center", "marginBottom":"20px"}),

    dcc.Graph(id="coherence-graph"),
    dcc.Graph(id="kappa-graph"),

    html.Div([
        html.Button("▶ Start", id="btn-start", n_clicks=0, 
                   style={"marginRight":"8px", "padding":"8px 16px"}),
        html.Button("⏸ Stop", id="btn-stop", n_clicks=0, 
                   style={"marginRight":"16px", "padding":"8px 16px"}),
        html.Button("💾 Save CSV", id="btn-save", n_clicks=0,
                   style={"padding":"8px 16px"}),
        html.Span(id="save-status", 
                 style={"marginLeft":"12px", "color":"#888", "fontStyle":"italic"})
    ], style={"textAlign":"center", "margin":"20px 0"}),

    html.Div([
        html.Span(f"Buffer size: {len(buffer)}", id="buffer-info",
                 style={"fontSize":"14px", "color":"#666"}),
        html.Br(),
        html.Span(f"Safe Demo Mode: {'ON' if SAFE_DEMO else 'OFF'}", 
                 style={"fontSize":"12px", "color":"#888"}),
        html.Br(),
        html.A("JSON Endpoint", href="/snapshot.json", target="_blank",
              style={"fontSize":"14px", "color":"#071C4D"})
    ], style={"textAlign":"center", "marginTop":"10px"}),

    # Interval tick
    dcc.Interval(id="tick", interval=1000, n_intervals=0, disabled=True),
], style={"maxWidth":"1200px", "margin":"0 auto", "padding":"20px"})


@app.callback(
    Output("tick", "disabled"),
    Input("btn-start", "n_clicks"),
    Input("btn-stop", "n_clicks"),
    prevent_initial_call=True,
)
def control_timer(n_start, n_stop):
    """Start/Stop the sampling timer"""
    ctx = dash.callback_context
    if not ctx.triggered:
        return True
    trig = ctx.triggered[0]["prop_id"].split(".")[0]
    return trig != "btn-start"


@app.callback(
    Output("coherence-graph", "figure"),
    Output("kappa-graph", "figure"),
    Output("buffer-info", "children"),
    Output("kappa-metric", "children"),
    Output("rho-metric", "children"),
    Output("beta-metric", "children"),
    Output("D-metric", "children"),
    Input("tick", "n_intervals"),
)
def update_graphs(_):
    """Update graphs with new samples from projections"""
    # Add new sample to buffer
    add_sample()
    
    # Get latest projection for metrics
    proj = projection_reader.get_latest_projection()
    
    # Build coherence figure
    fig_coherence = go.Figure(data=[to_trace()])
    fig_coherence.update_layout(
        title="Coherence C(t) from Spine Projections",
        yaxis_title="Coherence",
        xaxis_title="Time",
        template="plotly_white",
        margin=dict(l=40, r=20, t=60, b=40),
        height=400,
        yaxis=dict(range=[0, 1.0])
    )
    
    # Build kappa figure
    fig_kappa = go.Figure(data=[to_kappa_trace()])
    fig_kappa.add_hline(y=1.0, line_dash="dash", line_color="red", 
                        annotation_text="κ = 1 (stability threshold)")
    fig_kappa.update_layout(
        title="κ-Stability Over Runs",
        yaxis_title="κ (kappa)",
        xaxis_title="Run",
        template="plotly_white",
        margin=dict(l=40, r=20, t=60, b=40),
        height=400,
    )
    
    buffer_text = f"Buffer: {len(buffer)}/{buffer.maxlen} samples"
    
    # Metrics
    kappa_text = f"κ: {proj.kappa_final:.4f}" if proj else "κ: --"
    rho_text = f"ρ: {proj.rho_final:.2f}" if proj else "ρ: --"
    beta_text = f"β: {proj.beta:.2f}" if proj else "β: --"
    D_text = f"D: {proj.D:.4f}" if proj else "D: --"
    
    return fig_coherence, fig_kappa, buffer_text, kappa_text, rho_text, beta_text, D_text


@app.callback(
    Output("save-status", "children"),
    Input("btn-save", "n_clicks"),
    prevent_initial_call=True
)
def save_run(_):
    """Save current buffer to timestamped CSV"""
    if not buffer:
        return "⚠️ Buffer empty - start sampling first"
    
    stamp = time.strftime("%Y-%m-%d_%H-%M-%S")
    path = os.path.join("runs", f"coherence_{stamp}.csv")
    save_csv(path)
    
    if SAFE_DEMO:
        path = "[PATH]"
    return f"✅ Saved {len(buffer)} samples to {path}"


# JSON Endpoint for Obsidian Integration
@app.server.route("/snapshot.json")
def snapshot_json():
    """Serve latest spine projection data as JSON."""
    proj = projection_reader.get_latest_projection()
    if proj:
        data = project_to_dashboard_format(proj, redact=SAFE_DEMO)
        return jsonify(safe_project(data))
    return jsonify({"error": "No spine runs found"})


# Stability summary endpoint
@app.server.route("/stability.json")
def stability_json():
    """Serve aggregate stability metrics."""
    summary = projection_reader.get_stability_summary()
    return jsonify(safe_project(summary))


if __name__ == "__main__":
    print("\nStarting Universal Operating System Console...")
    print("Dashboard: http://localhost:5055")
    print("JSON feed: http://localhost:5055/snapshot.json")
    print(f"Safe Demo Mode: {'ON' if SAFE_DEMO else 'OFF'}")
    print("\nSpine Projections Active: κ, β, D, ρ monitoring")
    print("\nPress Ctrl+C to stop\n")
    app.run(debug=True, port=5055, host='127.0.0.1')
