# Copyright (c) 2025 Alexander Liantonio.
# All rights reserved. Licensed under dual terms — see LICENSES/

#!/usr/bin/env python3
"""
Star Mother Lattice - Phase 7 Prototype
========================================

3D visualization of coherence data mapped to sacred geometry.
Connects to live dashboard feed and renders 13-sphere lattice structure.

USAGE:
    python star_mother_lattice.py

REQUIRES:
    - Dashboard running at http://localhost:5055
    - At least 30 seconds of sampled data
    - Plotly, requests installed

"""

import json
import time
import requests
import plotly.graph_objects as go
from datetime import datetime

# Configuration
FEED_URL = "http://localhost:5055/snapshot.json"
TIMEOUT = 5

def load_samples():
    """
    Load coherence samples from live dashboard.
    
    Returns:
        list: Array of {"t": timestamp, "c": coherence} dicts
    """
    try:
        r = requests.get(FEED_URL, timeout=TIMEOUT)
        r.raise_for_status()
        data = r.json()
        print(f"✅ Loaded {len(data)} samples from dashboard")
        return data
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to connect to dashboard: {e}")
        print(f"   Ensure dashboard is running at {FEED_URL}")
        return []

def render_lattice_2d(samples):
    """
    Render basic 2D time series as proof of concept.
    
    Args:
        samples: List of coherence samples
    """
    if not samples:
        print("⚠️  No data to visualize")
        return
    
    # Extract time and coherence values
    timestamps = [s["t"] for s in samples]
    coherence = [s["c"] for s in samples]
    
    # Create figure
    fig = go.Figure()
    
    # Add trace
    fig.add_trace(go.Scatter(
        x=timestamps,
        y=coherence,
        mode='lines+markers',
        name='Coherence C(t)',
        line=dict(color='#764ba2', width=2),
        marker=dict(size=4)
    ))
    
    # Layout
    fig.update_layout(
        title="⬢ Star Mother Coherence Feed — 2D Proto",
        xaxis_title="Time",
        yaxis_title="Coherence C(t)",
        template="plotly_white",
        height=600,
        yaxis=dict(range=[0, 1.0])
    )
    
    print("📊 Rendering 2D visualization...")
    fig.show()

def render_lattice_3d(samples):
    """
    Render 3D lattice structure (stub for Phase 7).
    
    TODO Phase 7:
        - Map time series to 13-sphere Metatron's Cube geometry
        - Color by coherence level (Perfect/Healthy/Monitor/Warning)
        - Add sphere connections (edges)
        - Animate through time
        - Add interactivity
    
    Args:
        samples: List of coherence samples
    """
    if not samples:
        print("⚠️  No data to visualize")
        return
    
    # For now: Simple 3D scatter with time as spiral
    import math
    
    xs = []
    ys = []
    zs = []
    colors = []
    
    for i, s in enumerate(samples):
        t = i / len(samples) * 2 * math.pi * 3  # 3 spirals
        r = s["c"]  # Radius based on coherence
        
        xs.append(r * math.cos(t))
        ys.append(r * math.sin(t))
        zs.append(i / len(samples))  # Vertical time axis
        colors.append(s["c"])
    
    fig = go.Figure()
    
    fig.add_trace(go.Scatter3d(
        x=xs,
        y=ys,
        z=zs,
        mode='lines+markers',
        marker=dict(
            size=4,
            color=colors,
            colorscale='Viridis',
            showscale=True,
            colorbar=dict(title="Coherence")
        ),
        line=dict(color='#764ba2', width=2),
        name='Coherence Helix'
    ))
    
    fig.update_layout(
        title="⬢ Star Mother Lattice — 3D Proto (Helix)",
        scene=dict(
            xaxis_title="X (cos spiral)",
            yaxis_title="Y (sin spiral)",
            zaxis_title="Time (normalized)"
        ),
        template="plotly_white",
        height=700
    )
    
    print("📊 Rendering 3D visualization...")
    fig.show()

def main():
    """Main entry point."""
    print("\n⬢ STAR MOTHER LATTICE VISUALIZATION")
    print("=" * 50)
    print(f"Dashboard: {FEED_URL}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Load data
    samples = load_samples()
    
    if not samples:
        print("\n❌ No data available")
        print("   1. Start dashboard: START_DASHBOARD.bat")
        print("   2. Click 'Start' button in browser")
        print("   3. Wait 30 seconds for samples")
        print("   4. Run this script again")
        return
    
    # Render visualizations
    print("\n🎨 Generating visualizations...")
    render_lattice_2d(samples)
    render_lattice_3d(samples)
    
    print("\n✅ Visualization complete!")
    print("   Phase 7 TODO: Map to 13-sphere sacred geometry")
    print("⬢\n")

if __name__ == "__main__":
    main()
