#!/bin/bash
# Git commit and push script for Windows (run via Git Bash)

cd /c/Users/alexl/Desktop/tapestry-codex-starter

echo "⬢ COMMITTING TAPESTRY CODEX INTEGRATION..."

# Stage all changes
git add .

# Commit with comprehensive message
git commit -m "feat: integrate Self-Observing Dashboard with Obsidian vault

- Add comprehensive system documentation
- Link JSON endpoint to vault runs/ folder
- Configure PowerShell snapshot automation
- Update .gitignore for better coverage
- Establish Dataview auto-indexing
- Integrate with Star Mother 13-sphere lattice (Sphere 5)
- Create inference-engine-prime system docs
- Add coherence-index dashboard with queries
- Reference SCMS research library
- Complete full alignment with Living Tapestry vault

Integration complete. System self-observing. ⬢"

# Push to GitHub
echo ""
echo "📤 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ GitHub sync complete!"
