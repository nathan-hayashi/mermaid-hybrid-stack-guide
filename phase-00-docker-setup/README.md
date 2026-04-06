# Phase 0: Docker Desktop WSL 2 Backend Verification

**Time estimate: 10 minutes**

## Why Docker First?

Docker Desktop provides the cleanest path for running `mmdc` (Mermaid CLI) inside
WSL 2. Mermaid CLI depends on Puppeteer, which needs Chromium, which needs roughly
15 system libraries to run in a headless Linux environment. Tracking down those
dependencies manually is fragile and version-sensitive. The Docker image ships with
all of them pre-installed and pre-configured -- one pull and it works.

Before anything else, Docker must be running and its WSL 2 backend must be active.
This phase confirms that.

## Steps

1. **Open Docker Desktop on Windows** (not in WSL -- it runs on the Windows side).
   If you do not have it installed, download it from https://www.docker.com/products/docker-desktop/

2. **Enable the WSL 2 backend** [WINDOWS]:
   Docker Desktop Settings → General → check "Use the WSL 2 based engine"

3. **Enable Ubuntu distro integration** [WINDOWS]:
   Docker Desktop Settings → Resources → WSL Integration → toggle on your Ubuntu distro

4. **Apply & Restart** Docker Desktop after changing settings [WINDOWS].

5. **Open your WSL 2 terminal** and run the verification script:
   ```bash
   bash phase-00-docker-setup/verify-docker.sh
   ```

## Gate / PASS Criteria

All three checks must print [PASS]:
- `docker --version` returns a version string
- `docker run --rm hello-world` prints "Hello from Docker!"
- `docker compose version` returns a version string

If any check prints [FAIL], the script exits with code 1 and tells you what to fix.

---

> Tested with Docker 24+, Node v20+, mermaid-cli 11+. Tool versions may change -- adapt as needed.
