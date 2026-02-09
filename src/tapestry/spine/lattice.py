"""
Tapestry Spine - Coherence Simulation Engine
Simulates κ-stability dynamics in multi-agent lattices.
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional
from pathlib import Path
import json
from datetime import datetime


@dataclass
class SpineParams:
    """Parameters for spine simulation."""
    steps: int = 80
    n: int = 32  # lattice size
    seed: int = 1
    coupling: float = 0.8  # β
    noise: float = 0.02    # D
    return_ramp: float = 0.01  # ρ growth rate
    alpha: float = 0.2     # coherence regeneration


@dataclass
class LatticeState:
    """State of the coherence lattice at time t."""
    step: int
    C: np.ndarray          # coherence field
    kappa: float           # κ = (β·D)/ρ
    beta: float            # amplification
    D: float               # disturbance/noise
    rho: float             # return authority
    
    def to_dict(self) -> Dict:
        return {
            "step": self.step,
            "kappa_mean": float(np.mean(self.kappa)),
            "beta": float(self.beta),
            "D": float(self.D),
            "rho": float(self.rho),
            "C_mean": float(np.mean(self.C)),
            "C_std": float(np.std(self.C))
        }


class Lattice:
    """N-dimensional coherence lattice with κ-stability dynamics."""
    
    def __init__(self, params: SpineParams):
        self.params = params
        self.rng = np.random.default_rng(params.seed)
        
        # Initialize coherence field
        self.C = np.ones((params.n, params.n)) * 0.5
        
        # Initial parameters
        self.beta = params.coupling
        self.D = params.noise
        self.rho = 0.5  # starts below threshold
        
        # History for analysis
        self.history: List[LatticeState] = []
        
    def compute_kappa(self) -> float:
        """Compute κ = (β · D) / ρ"""
        if self.rho < 1e-10:
            return float('inf')
        return (self.beta * self.D) / self.rho
    
    def step(self) -> LatticeState:
        """Evolve lattice one time step."""
        # Compute laplacian (diffusion)
        laplacian = (
            np.roll(self.C, 1, axis=0) + np.roll(self.C, -1, axis=0) +
            np.roll(self.C, 1, axis=1) + np.roll(self.C, -1, axis=1) -
            4 * self.C
        )
        
        # Coherence dynamics: dC/dt = α·C·(1 - κ) + diffusion
        kappa = self.compute_kappa()
        growth = self.params.alpha * self.C * (1.0 - kappa)
        diffusion = 0.1 * laplacian
        noise = self.rng.normal(0, self.D, self.C.shape)
        
        # Update coherence
        self.C += growth + diffusion + noise
        self.C = np.clip(self.C, 0.0, 1.0)
        
        # Increase return authority over time (ramp)
        self.rho += self.params.return_ramp
        self.rho = min(self.rho, 2.0)  # cap at 2.0
        
        # Record state
        state = LatticeState(
            step=len(self.history),
            C=self.C.copy(),
            kappa=kappa,
            beta=self.beta,
            D=self.D,
            rho=self.rho
        )
        self.history.append(state)
        
        return state
    
    def run(self) -> List[LatticeState]:
        """Run full simulation."""
        for _ in range(self.params.steps):
            self.step()
        return self.history
    
    def save_artifacts(self, run_dir: Path):
        """Save simulation artifacts."""
        run_dir.mkdir(parents=True, exist_ok=True)
        
        # Save parameters
        params_file = run_dir / "params.json"
        params_file.write_text(json.dumps({
            "steps": self.params.steps,
            "n": self.params.n,
            "seed": self.params.seed,
            "coupling": self.params.coupling,
            "noise": self.params.noise,
            "return_ramp": self.params.return_ramp,
            "alpha": self.params.alpha
        }, indent=2))
        
        # Save time series
        timeseries_file = run_dir / "timeseries.csv"
        with open(timeseries_file, 'w') as f:
            f.write("step,kappa,beta,D,rho,C_mean,C_std\n")
            for state in self.history:
                d = state.to_dict()
                f.write(f"{d['step']},{d['kappa_mean']},{d['beta']},{d['D']},{d['rho']},{d['C_mean']},{d['C_std']}\n")
        
        # Save final state
        final_file = run_dir / "final_state.json"
        final_file.write_text(json.dumps({
            "final_kappa": float(self.compute_kappa()),
            "final_rho": float(self.rho),
            "mean_coherence": float(np.mean(self.C)),
            "stable": self.compute_kappa() < 1.0
        }, indent=2))
        
        return run_dir
