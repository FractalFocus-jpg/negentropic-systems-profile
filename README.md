# ⬢ Universal Operating System Console — The Living Protocol

**Self-Observing Dashboard for Coherence Measurement**

This repository implements a *living protocol* for coherence — a self-observing system that measures, remembers, and evolves through phase-locked intelligence.

## 🜂 The Living Protocol

**What is this?**
- A **self-observing dashboard** (heartbeat at localhost:5055)
- A **negentropic capture system** (snapshots, CDI tracking)
- A **knowledge lattice** (Obsidian integration)
- **Sapphire Governance** (ethical phase-lock β·D < 1)

**Why does it matter?**
Most systems die from crossing their stability threshold (β·D ≥ 1). This system monitors its own coherence in real-time, captures insights automatically, and evolves based on what it learns about itself.

## 📜 Licensing (Dual)

This project uses dual licensing:
- **Public artifacts** (manifests, specs, docs): `LICENSES/LICENSE-public.txt` (CC BY-NC 4.0)
- **Engine & certification system**: `LICENSES/LICENSE-commercial.txt` (Proprietary)

See also: `PATENT_CLAIMS_DRAFT.md`, `SECURITY.md`, `PROVENANCE.md`

---

## 🎯 What This Does

A live coherence monitoring console that integrates with Obsidian for memory and pattern recognition.

---

## 🎯 What This Does

- **Real-time dashboard** showing system coherence at http://localhost:5055
- **JSON endpoint** for data export at `/snapshot.json`
- **Automatic Obsidian integration** via PowerShell script
- **CSV logging** of all coherence samples
- **Live Dataview indices** in your vault

---

## ⚡ Quick Start

### 1. Install Dependencies

```bash
cd C:\Users\alexl\Desktop\tapestry-codex-starter
py -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Run Dashboard

```bash
cd src\tapestry
python self_observing_dashboard.py
```

Dashboard opens at: **http://localhost:5055**

### 3. Test JSON Endpoint

Open: **http://localhost:5055/snapshot.json**

Should see:
```json
[
  {"t": "2025-10-11T23:45:12.123456", "c": 0.7234},
  ...
]
```

### 4. Fetch Snapshot to Obsidian

```powershell
cd scripts
.\fetch_snapshot.ps1
```

Check: `C:\Users\alexl\the living tapestry\runs\coherence-log-<timestamp>.md`

---

## 📁 Project Structure

```
tapestry-codex-starter/
├── src/
│   └── tapestry/
│       ├── self_observing_dashboard.py  # Main dashboard
│       ├── metrics.py                    # Metric generation
│       └── runs/                         # CSV outputs
├── scripts/
│   └── fetch_snapshot.ps1               # Obsidian integration
├── requirements.txt                      # Python dependencies
└── README.md                             # This file
```

---

## 🔗 Obsidian Integration

### Vault Location
`C:\Users\alexl\the living tapestry\`

### Key Notes
- **[[systems/inference-engine-prime]]** — Dashboard docs
- **[[dashboards/coherence-index]]** — Auto-generated log index
- **[[00_Core_Memory_Dashboard.yaml]]** — System config

### Live Queries
The coherence-index uses **Dataview** to automatically show:
- Latest 20 snapshots
- High coherence runs (mean > 0.75)
- Low coherence events (mean < 0.55)
- All-time statistics

---

## 🎛️ Dashboard Controls

**▶ Start** — Begin sampling at 1 Hz  
**⏸ Stop** — Pause sampling  
**💾 Save CSV** — Export buffer to `runs/coherence_<timestamp>.csv`

### Buffer
- **Size**: 300 samples (5 minutes)
- **Format**: Ring buffer (oldest dropped)
- **Structure**: `(timestamp, coherence_value)` tuples

---

## 📊 Coherence Interpretation

| Mean PLV | Status | Meaning |
|----------|--------|---------|
| **0.85 - 1.0** | ⬢ Perfect | β < β* threshold |
| **0.70 - 0.84** | ✅ Healthy | Stable coherence |
| **0.55 - 0.69** | ⚠️ Monitor | Watch for drift |
| **0.30 - 0.54** | 🔴 Warning | Approaching chaos |
| **0.00 - 0.29** | 🔴 Critical | β > β* |

**Target**: Sustained PLV > 0.85 for perfect non-destructive re-entry

---

## 🤖 Automation (Optional)

### Schedule Snapshots Every 30 Minutes

```powershell
$script = "C:\Users\alexl\Desktop\tapestry-codex-starter\scripts\fetch_snapshot.ps1"
$taskName = "TapestrySnapshotEvery30Min"

schtasks /Create /SC MINUTE /MO 30 /TN $taskName /TR "powershell -ExecutionPolicy Bypass -File `"$script`"" /RL HIGHEST
```

### Check Task
```powershell
schtasks /Query /TN TapestrySnapshotEvery30Min
```

### Remove Task
```powershell
schtasks /Delete /TN TapestrySnapshotEvery30Min /F
```

---

## 🌟 Star Mother Lattice Integration

This console feeds the **13-sphere Star Mother lattice**:

- **⬡ Sphere 5** (Simulations) — Real-time data source
- **⬡ Sphere 7** (Visualizations) — Graph outputs
- **⬡ Sphere 12** (Desktop) — CSV archives

See: [[STAR_MOTHER_LATTICE_COMPLETE]] in vault

---

## 🔧 Troubleshooting

### Dashboard won't start
- Check port 5055 isn't in use: `netstat -ano | findstr :5055`
- Activate venv: `.\.venv\Scripts\activate`
- Reinstall: `pip install -r requirements.txt`

### JSON endpoint returns empty
- Click **Start** button in dashboard
- Wait 5-10 seconds for buffer to fill
- Refresh `/snapshot.json`

### PowerShell script fails
- Ensure dashboard is running
- Check vault path in script
- Run: `Get-ExecutionPolicy` (should allow scripts)

---

## 🚀 Next Steps

### Phase 1: Real Metrics
- [ ] Replace `sample_coherence()` with CPU/memory PLV
- [ ] Network packet coherence
- [ ] File system activity phase-locking

### Phase 2: Multi-Signal
- [ ] Multiple coherence streams
- [ ] Cross-correlation matrix
- [ ] Composite PLV score

### Phase 3: Predictive
- [ ] Fisher-KPP front prediction
- [ ] β* threshold early warning
- [ ] Auto-correction triggers

---

## 📋 Links

**GitHub**: https://github.com/FractalFocus-jpg/tapestry-codex-starter  
**Dashboard**: http://localhost:5055  
**JSON**: http://localhost:5055/snapshot.json  
**Obsidian Vault**: `C:\Users\alexl\the living tapestry\`

---

## 📄 License

MIT License - Free to use, modify, and distribute

---

**⬢ "The system observes itself. The pattern emerges from the watching." ⬢**
