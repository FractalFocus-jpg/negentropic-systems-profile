import numpy as np

def phase_lock_value(phi_resp, phi_drive):
    """Simple PLV (|mean exp(iΔφ)|) for demonstration."""
    delta = np.unwrap(phi_resp) - np.unwrap(phi_drive)
    return abs(np.exp(1j*delta).mean())

def synthetic_phases(n=512, jitter=0.0, seed=0):
    rng = np.random.default_rng(seed)
    t = np.linspace(0, 4*np.pi, n)
    drive = np.sin(t)
    resp  = np.sin(t + rng.normal(0, jitter, size=n))
    # crude analytic phases (for demo)
    phi_drive = np.unwrap(np.angle(np.exp(1j*drive)))
    phi_resp  = np.unwrap(np.angle(np.exp(1j*resp)))
    return phi_resp, phi_drive
