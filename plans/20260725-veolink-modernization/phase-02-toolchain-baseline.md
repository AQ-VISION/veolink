# Phase 02 — Toolchain & Build Baseline

## Goal
Get VeoLink CE building on a supported OS/toolchain before touching dependencies.

## Context
- Build currently targets CentOS 7 / Ubuntu 14.04 (`rules.mk`, committed qmake Makefiles in `*/prj_linux/Makefile`) and VS2013 + Qt 5.7.1 on Windows.
- Committed generated Makefiles are stale and reference old output names; qmake regenerates them.

## Requirements
1. Build succeeds on Ubuntu 22.04 or 24.04 (x86_64) with distro gcc.
2. Remove committed generated qmake Makefiles from `client/prj_linux/`, `vecvr/prj_linux/`, `veuilib/prj_linux/` (add to `.gitignore`); rely on `qmake` at build time.
3. Decide Qt track: minimum-change (Qt 5.15 LTS) vs modern (Qt 6.x — larger port, `QDesktopWidget` and other removed APIs are used). Recommend Qt 5.15 first.
4. Update `rules.mk` package lists in [Readme.md](../../Readme.md) for the new distro.

## Files
- Modify: `rules.mk`, `rules-macos.mk`, `rules-pi3.mk`, `Readme.md`, `.gitignore`
- Delete: generated `*/prj_linux/Makefile` files
- Verify: `common.mk`, top-level `Makefile`

## Validation
- `source ./rules.mk && make` completes; `output/<dir>/VeoLinkServer` and `VeoLinkClient` produced and start.

## Risks
- 3rdparty builds (ffmpeg, openssl 1.0.2) fail on modern gcc — expect to overlap with Phase 03; sequence: bump compiler-blocking deps first.
