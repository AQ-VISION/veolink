# Phase 05 — Remaining Dependency & Code Refresh

## Goal
Finish modernization: non-critical deps, translations, packaging, docs.

## Items
1. **Protobuf 3.2.0 → current 3.x/4.x** — regenerate `.pb.cc/.pb.h`; wire-compatible, API mostly stable.
2. **Poco 1.5.4 → 1.13.x** — used for files/paths/data (SQLite); moderate API churn.
3. **leveldb, sqlite, spdlog, miniupnpc** — bump to current; spdlog API changed significantly since 2017 (`xcmnlib/include/utility/debug.hpp` wrapper isolates most of it).
4. **Translations**: regenerate `client/src/main/translations/*.ts` with `lupdate` so old `rapidvms`/`OpenCVR` strings are replaced; review `vscabout.ui` (still shows legacy OpenCVR/"Pay Now" content) and redesign the About dialog for VeoLink CE.
5. **Service units**: add a systemd unit (`veolink.service`) — current scripts are sysvinit/upstart only (`output/linux/service/veolink-*`).
6. **Windows projects**: retarget solutions from VS2013 to a supported MSVC toolset; rename project files if desired (`vecvr.sln`, `veclient.sln` names are internal only).
7. **Docs**: refresh `doc/` build guides (currently reference EOL distros/toolchains); update screenshots/links in [Readme.md](../../Readme.md).
8. **Internal naming (optional)**: `OpenCVR*` class/function names (e.g. `ExitOpenCVR`) are internal legacy names — rename only if a wider refactor is undertaken; not user-visible.

## Validation
- Full build on all supported platforms; UI shows only VeoLink branding in every language.
