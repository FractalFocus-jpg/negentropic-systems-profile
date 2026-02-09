"""
Spine Projection Module
Reads run artifacts and projects κ-stability metrics for dashboards.
Pure projections - no raw data exposure.
"""

import json
import csv
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime


@dataclass
class SpineProjection:
    """Projected view of a spine simulation run."""
    run_id: str
    timestamp: str
    kappa_final: float
    kappa_trajectory: List[float]  # κ over time
    rho_final: float
    beta: float
    D: float
    stable: bool
    mean_coherence: float
    steps: int
    n: int
    
    def to_dict(self, redact: bool = False) -> Dict:
        """Convert to dict, optionally redacting sensitive paths."""
        data = {
            "run_id": self.run_id if not redact else "[REDACTED]",
            "timestamp": self.timestamp,
            "kappa_final": round(self.kappa_final, 4),
            "kappa_trajectory": [round(k, 4) for k in self.kappa_trajectory],
            "rho_final": round(self.rho_final, 4),
            "beta": round(self.beta, 4),
            "D": round(self.D, 4),
            "stable": self.stable,
            "mean_coherence": round(self.mean_coherence, 4),
            "steps": self.steps,
            "n": self.n,
        }
        return data


class ProjectionReader:
    """Reads spine artifacts and creates projections."""
    
    def __init__(self, runs_dir: Path = None):
        if runs_dir is None:
            runs_dir = Path("src/tapestry/runs")
        self.runs_dir = runs_dir
    
    def list_runs(self) -> List[Path]:
        """List all spine run directories."""
        if not self.runs_dir.exists():
            return []
        return sorted([d for d in self.runs_dir.iterdir() 
                      if d.is_dir() and d.name.startswith("spine_")])
    
    def project_run(self, run_dir: Path) -> Optional[SpineProjection]:
        """Create projection from run artifacts."""
        try:
            # Read final state
            final_file = run_dir / "final_state.json"
            if not final_file.exists():
                return None
            
            final = json.loads(final_file.read_text())
            
            # Read params
            params_file = run_dir / "params.json"
            params = json.loads(params_file.read_text()) if params_file.exists() else {}
            
            # Read timeseries for trajectory
            timeseries_file = run_dir / "timeseries.csv"
            kappa_trajectory = []
            if timeseries_file.exists():
                with open(timeseries_file) as f:
                    reader = csv.DictReader(f)
                    for row in reader:
                        kappa_trajectory.append(float(row.get("kappa", 0)))
            
            # Parse run_id from directory name
            run_id = run_dir.name
            timestamp = datetime.now().isoformat()
            
            return SpineProjection(
                run_id=run_id,
                timestamp=timestamp,
                kappa_final=final.get("final_kappa", 0),
                kappa_trajectory=kappa_trajectory,
                rho_final=final.get("final_rho", 0),
                beta=params.get("coupling", 0),
                D=params.get("noise", 0),
                stable=final.get("stable", False),
                mean_coherence=final.get("mean_coherence", 0),
                steps=params.get("steps", 0),
                n=params.get("n", 0)
            )
        except Exception as e:
            print(f"[WARNING] Failed to project {run_dir}: {e}")
            return None
    
    def get_latest_projection(self) -> Optional[SpineProjection]:
        """Get projection of most recent run."""
        runs = self.list_runs()
        if not runs:
            return None
        return self.project_run(runs[-1])
    
    def get_all_projections(self) -> List[SpineProjection]:
        """Get projections of all runs."""
        runs = self.list_runs()
        projections = []
        for run_dir in runs:
            proj = self.project_run(run_dir)
            if proj:
                projections.append(proj)
        return projections
    
    def get_stability_summary(self) -> Dict:
        """Aggregate stability metrics across all runs."""
        projections = self.get_all_projections()
        if not projections:
            return {"error": "No runs found"}
        
        stable_count = sum(1 for p in projections if p.stable)
        total_count = len(projections)
        
        return {
            "total_runs": total_count,
            "stable_runs": stable_count,
            "stability_rate": round(stable_count / total_count, 2) if total_count > 0 else 0,
            "mean_kappa": round(sum(p.kappa_final for p in projections) / total_count, 4),
            "mean_rho": round(sum(p.rho_final for p in projections) / total_count, 4),
            "latest_stable": projections[-1].stable if projections else False,
        }


def project_to_dashboard_format(projection: SpineProjection, redact: bool = False) -> Dict:
    """Convert projection to dashboard-compatible format."""
    return {
        "metrics": {
            "kappa": projection.kappa_final,
            "rho": projection.rho_final,
            "beta": projection.beta,
            "D": projection.D,
            "coherence": projection.mean_coherence,
        },
        "status": {
            "stable": projection.stable,
            "steps": projection.steps,
            "lattice_size": projection.n,
        },
        "trajectory": projection.kappa_trajectory,
        "timestamp": projection.timestamp,
        "run_id": projection.run_id if not redact else "[DEMO]",
    }
