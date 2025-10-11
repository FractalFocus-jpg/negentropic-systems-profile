"""
Toy coherence model:
    dC/dt = alpha * C * (1 - beta * D)

We treat beta*D as a "stability load". Non-destructive region: beta*D < 1.
This is intentionally simple so Codex can extend it (noise, coupling, etc.).
"""
from dataclasses import dataclass

@dataclass
class Params:
    alpha: float = 0.2   # growth / regeneration
    beta:  float = 0.8   # sensitivity to disruption
    D:     float = 0.9   # disruption / goal pressure

def step(C: float, p: Params, dt: float) -> float:
    dC = p.alpha * C * (1.0 - p.beta * p.D)
    return max(0.0, min(1.0, C + dC * dt))

def stable(p: Params) -> bool:
    """Non-destructive gate."""
    return (p.beta * p.D) < 1.0
