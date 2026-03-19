# Phase 1 – Git Workflow, Repository Organisation, and Linux Automation

## Overview

This directory contains all artefacts produced during Phase 1 of the mid-term project. Phase 1 establishes the foundational repository structure, enforces a professional collaborative Git workflow, and delivers a functional Linux automation script used to prepare the cloud server environment in Phase 2.

---

## Directory Contents

```
phase1/
└── screenshots/
    ├── Branch Protection.png           # Branch protection settings on main branch
    ├── chạy lệnh sudo .scriptsse... U  # Terminal output of setup.sh running on the cloud server
    ├── contributors-graph.png          # GitHub Insights → Contributors (both members)
    ├── pr-01-merged.png                # Pull Request #1 – approved and merged
    ├── pr-02-merged.png                # Pull Request #2 – approved and merged
    ├── pr-03-merged.png                # Pull Request #3 – approved and merged
    ├── Repository Structure.png        # Project repository structure
    └── Setup Completed Succes... U     # Final output confirming setup success
```

> The automation script itself is located at `scripts/setup.sh` in the repository root.

---

## Git Workflow Summary

All development in this project follows a strict feature-branch workflow:

1. Create a dedicated feature branch from `main` (e.g. `feature/automation-script`)
2. Develop and commit changes on the feature branch
3. Open a Pull Request with a clear title and description
4. At least one team member reviews and approves the PR
5. Merge into `main` only after approval — never direct commits

**Branch protection rules enforced on `main`:**
- Pull Request required before merging
- At least 1 reviewer approval required
- Direct commits and force-push are blocked

---

## Automation Script (`scripts/setup.sh`)

The script prepares a fresh Ubuntu 22.04 LTS server for Phase 2 deployment. It performs the following steps in order:

| Step | Action                                                                       |
|------|------------------------------------------------------------------------------|
| 1    | Update system packages (`apt-get update && upgrade`)                         |
| 2    | Install essential packages: `curl`, `git`, `build-essential`, `nginx`, `ufw` |
| 3    | Install Node.js 20.x via the official NodeSource distribution channel        |
| 4    | Install PM2 process manager globally via npm                                 |
| 5    | Create required application directories: `uploads/`, `logs/`, `data/`        |

**Usage on the cloud server:**

```bash
# Clone the repository onto the server
git clone [https://github.com/nanhthu215/midterm-deployment-project.git](https://github.com/nanhthu215/midterm-deployment-project.git)
cd midterm-deployment-project

# Grant execute permission and run
chmod +x scripts/setup.sh
sudo ./scripts/setup.sh
```

**Script safety:**
- Uses `set -e` — stops immediately if any command fails
- No hardcoded credentials, tokens, or sensitive values
- Each step prints a clear log message for traceability

---

## Evidence Checklist

The following screenshots are included in `phase1/screenshots/` as evidence for the technical report:

[x] Branch protection settings

[x] Pull Request #1 with reviewer approval badge

[x] Pull Request #2 with reviewer approval badge

[x] Pull Request #3 with reviewer approval badge

[x] GitHub Insights → Contributors (commit graph for both members)

[x] Project repository structure

[x] Terminal output of setup.sh running on the cloud server

---

## Team Contributions

| Member                        |              Contributions in Phase 1                              |
|-------------------------------|--------------------------------------------------------------------|
| Nguyen Anh Quan (523H0083)    | Automation script (`scripts/setup.sh`), `.gitignore` configuration |
| Nguyen Thi Anh Thu (523H0101) | Repository structure, `README.md`, `.env.example`                  |