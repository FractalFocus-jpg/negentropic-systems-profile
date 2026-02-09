"""
Spine sim.run - CLI entry point for running simulations
"""

import argparse
import sys
from pathlib import Path

# Add to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

from tapestry.spine.run import run_simulation


def main():
    """CLI: python -m src.tapestry.spine.sim.run"""
    parser = argparse.ArgumentParser(
        description="Spine Coherence Simulation"
    )
    
    parser.add_argument("--steps", type=int, default=80)
    parser.add_argument("--n", type=int, default=32)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--coupling", type=float, default=0.8)
    parser.add_argument("--noise", type=float, default=0.02)
    parser.add_argument("--return_ramp", type=float, default=0.01)
    
    args = parser.parse_args()
    
    run_dir = run_simulation(
        steps=args.steps,
        n=args.n,
        seed=args.seed,
        coupling=args.coupling,
        noise=args.noise,
        return_ramp=args.return_ramp
    )
    
    print(f"\n[OK] Artifacts written to: {run_dir}")


if __name__ == "__main__":
    main()
