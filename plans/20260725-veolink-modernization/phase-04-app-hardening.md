# Phase 04 — Application Security Hardening

## Goal
Fix application-level weaknesses independent of library versions.

## Items
1. **Default credentials**: server writes `admin/admin` into `.htpasswd` on first run ([vecvr/main/main.cpp](../../vecvr/main/main.cpp)). Force password change on first login, or generate a random first-run password printed to console/log.
2. **SimpleCrypt password storage**: Qt SimpleCrypt is obfuscation. Replace stored-credential handling with a proper KDF (e.g. libsodium/argon2 or OpenSSL PBKDF2) for local secrets; keep camera credentials encrypted at rest with a machine key.
3. **TLS by default**: web UI should default to HTTPS; document cert provisioning (`gencertificate.*` scripts); reject weak protocols after OpenSSL 3 upgrade.
4. **HTTP digest realm migration**: realm is now `veolink.local`; add release note that pre-existing non-admin web users must be recreated.
5. **Input surfaces review**: ONVIF discovery XML string building in `onvif/onvifagent/include/onvifserverdiscover.hpp` and `veuilib/onvifcpplib/include/onvifserverdiscover.hpp` uses `snprintf` into fixed buffers — audit bounds; RTSP/ONVIF parsing fuzzing pass (optional, time-boxed).

## Validation
- First-run flow requires non-default password.
- Web login works over HTTPS; HTTP redirects or is disabled by config.

## Risks
- Breaking change for existing deployments — document in release notes.
