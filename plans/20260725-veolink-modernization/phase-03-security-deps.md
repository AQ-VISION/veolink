# Phase 03 — Security-Critical Dependency Upgrades

## Goal
Replace EOL/vulnerable libraries that touch the network or untrusted input.

## Order of work (each step independently buildable)
1. **OpenSSL 1.0.2k → 3.x LTS** (`3rdparty/openssl`, `3rdparty/openssl-win`)
   - API breaks: 1.0.x init/cleanup calls, direct struct access. Audit users: curl, live555 (RTSPS), civetweb, velib.
2. **curl 7.43.0 → current** (`3rdparty/curl`) — build against new OpenSSL.
3. **civetweb 1.8 → current** (`3rdparty/civetweb`)
   - Verify `mg_modify_passwords_file` and callback API still match usage in [vecvr/main/main.cpp](../../vecvr/main/main.cpp); re-apply local patch noted in `3rdparty/changes.txt` (websocket read timeout) or use upstream option.
4. **FFmpeg 3.x → 6.x/7.x LTS** (`3rdparty/ffmpeg`, `3rdparty/ffmpeg-win`)
   - Major API churn: `avcodec_decode_video2` → send/receive API; audit `velib` (vplay) decode paths.
5. **live555 2016 → current** (`3rdparty/live555`)
   - Frequent RTSP parser CVEs; check `veuilib`/`velib` RTSP client integration.

## Alternative (recommended to evaluate first)
Stop vendoring: use system/distro packages or a package manager (Conan/vcpkg) for openssl, curl, civetweb, protobuf. Keeps CVE patching to `apt upgrade`. Vendor only truly patched libs (civetweb patch, ffmpeg config).

## Validation
- Full build + smoke test: add ONVIF camera, live view, record, playback, web UI login over HTTPS.

## Risks / rollback
- FFmpeg port is the largest item; isolate in its own branch. Rollback = revert submodule/source drop per library.
