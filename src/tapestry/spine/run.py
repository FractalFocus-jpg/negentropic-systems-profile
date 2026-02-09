"""
Spine simulation runner - CLI entry point
"""

import argparse
import sys
from pathlib import Path
from datetime import datetime

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from tapestry.spine.lattice import Lattice, SpineParams


def run_simulation(
    steps: int = 80,
    n: int = 32,
    seed: int = 1,
    coupling: float = 0.8,
    noise: float = 0.02,
    return_ramp: float = 0.01,
    save: bool = True
) -> Path:
    """Run a spine simulation with given parameters."""
    
    print(f"[SPINE] Initializing lattice...")
    print(f"        steps={steps}, n={n}, seed={seed}")
    print(f"        coupling={coupling}, noise={noise}, return_ramp={return_ramp}")
    
    # Create parameters
    params = SpineParams(
        steps=steps,
        n=n,
        seed=seed,
        coupling=coupling,
        noise=noise,
        return_ramp=return_ramp
    )
    
    # Initialize and run lattice
    lattice = Lattice(params)
    print(f"[SPINE] Running simulation...")
    
    history = lattice.run()
    
    # Summary
    final_kappa = lattice.compute_kappa()
    final_state = history[-1]
    
    print(f"\n[SPINE] Simulation complete:")
    print(f"        Final kappa: {final_kappa:.4f}")
    print(f"        Final rho: {lattice.rho:.4f}")
    print(f"        Stable: {final_kappa < 1.0}")
    print(f"        Mean coherence: {float(final_state.C.mean()):.4f}")
    
    # Save artifacts
    if save:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        run_dir = Path("src/tapestry/runs") / f"spine_{timestamp}"
        lattice.save_artifacts(run_dir)
        print(f"\n[SPINE] Artifacts saved to: {run_dir}")
        return run_dir
    
    return None


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Run Tapestry Spine coherence simulation"
    )
    
    parser.add_argument("--steps", type=int, default=80,
                        help="Number of simulation steps")
    parser.add_argument("--n", type=int, default=32,
                        help="Lattice size (nxn)")
    parser.add_argument("--seed", type=int, default=1,
                        help="Random seed")
    parser.add_argument("--coupling", type=float, default=0.8,
                        help="Coupling/amplification (β)")
    parser.add_argument("--noise", type=float, default=0.02,
                        help="Noise/disturbance level (D)")
    parser.add_argument("--return_ramp", type=float, default=0.01,
                        help="Return authority growth rate (ρ ramp)")
    
    args = parser.parse_args()
    
    run_dir = run_simulation(
        steps=args.steps,
        n=args.n,
        seed=args.seed,
        coupling=args.coupling,
        noise=args.noise,
        return_ramp=args.return_ramp
    )
    
    if run_dir:
        print(f"\n[OK] Run complete: {run_dir}")


if __name__ == "__main__":
    main()
