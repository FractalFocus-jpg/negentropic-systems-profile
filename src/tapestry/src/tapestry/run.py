from .model import Params, step, stable
from .metrics import phase_lock_value, synthetic_phases

def main():
    p = Params(alpha=0.2, beta=0.8, D=0.9)
    C = 0.95; dt = 0.1
    for _ in range(100):
        C = step(C, p, dt)
    phi_r, phi_d = synthetic_phases(jitter=0.1)
    plv = phase_lock_value(phi_r, phi_d)
    print(f"Stable gate (βD<1)? {stable(p)} | Final C≈{C:.3f} | PLV≈{plv:.3f}")

if __name__ == "__main__":
    main()
