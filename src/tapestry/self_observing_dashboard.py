# --- Self-Observing Dashboard (UOS Console) ---
# Monitors coherence in real-time, provides JSON endpoint for Obsidian integration

import os, csv, time, random, datetime
import dash
from dash import dcc, html
from dash.dependencies import Input, Output
import plotly.graph_objs as go
from collections import deque
from flask import jsonify

# Global ring buffer for coherence samples
buffer = deque(maxlen=300)

app = dash.Dash(__name__)
app.title = "Self-Observing Dashboard | UOS"

def sample_coherence():
    """
    Generate simulated coherence value.
    TODO: Replace with real metric from system
    Target: β < β* (1.6), PLV > 0.85
    """
    return 0.55 + 0.35 * random.random()

def now_ts():
    """Current timestamp"""
    return datetime.datetime.now()

def add_sample():
    """Append new coherence sample to buffer"""
    val = sample_coherence()
    ts = now_ts()
    buffer.append((ts, val))

def to_trace():
    """Convert buffer to Plotly trace"""
    if not buffer:
        return go.Scatter(x=[], y=[], mode="lines+markers", name="Coherence")
    xs = [t.strftime("%H:%M:%S") for (t, v) in buffer]
    ys = [v for (t, v) in buffer]
    return go.Scatter(x=xs, y=ys, mode="lines+markers", name="Coherence C(t)")

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
    html.Div("Real-time Coherence Monitoring | Star Mother Lattice", 
             style={"textAlign":"center", "marginBottom":"20px", "color":"#666"}),

    dcc.Graph(id="coherence-graph"),

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
        html.A("JSON Endpoint", href="/snapshot.json", target="_blank",
              style={"fontSize":"14px", "color":"#071C4D"})
    ], style={"textAlign":"center", "marginTop":"10px"}),

    # Interval tick (disabled until Start is pressed)
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
    return trig != "btn-start"   # disabled=False when Start triggered


@app.callback(
    Output("coherence-graph", "figure"),
    Output("buffer-info", "children"),
    Input("tick", "n_intervals"),
)
def update_graph(_):
    """Update graph with new sample on each tick"""
    # Add new sample to buffer
    add_sample()
    
    # Build figure
    fig = go.Figure(data=[to_trace()])
    fig.update_layout(
        yaxis_title="Coherence C(t)",
        xaxis_title="Time",
        template="plotly_white",
        margin=dict(l=40, r=20, t=40, b=40),
        height=500,
        yaxis=dict(range=[0, 1.0])  # Coherence bounded 0-1
    )
    
    buffer_text = f"Buffer: {len(buffer)}/{buffer.maxlen} samples"
    return fig, buffer_text


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
    return f"✅ Saved {len(buffer)} samples to {path}"


# JSON Endpoint for Obsidian Integration
@app.server.route("/snapshot.json")
def snapshot_json():
    """
    Serve latest coherence data as JSON for Obsidian ingestion.
    Called by PowerShell script every 30 minutes.
    """
    return jsonify([
        {"t": ts.isoformat(), "c": float(v)}
        for (ts, v) in buffer
    ])


if __name__ == "__main__":
    print("\nStarting Universal Operating System Console...")
    print("Dashboard: http://localhost:5055")
    print("JSON feed: http://localhost:5055/snapshot.json")
    print("\nPress Ctrl+C to stop\n")
    app.run(debug=True, port=5055, host='127.0.0.1')
