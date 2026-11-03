#!/usr/bin/env bash
# Check: HTTPS through Traefik routes / to probe and /docs to docs, and a wrong server name is rejected.
set -uo pipefail
certificate="$(kubectl -n starfleet get secret portal-tls -o jsonpath='{.data.tls\.crt}' 2>/dev/null)"
if [ -z "$certificate" ]; then
  echo "FAIL: Secret portal-tls not found"
  exit 1
fi
script='import base64,socket,ssl,sys
context=ssl.create_default_context(cadata=base64.b64decode(sys.argv[1]).decode())
def get(path,name="portal.local"):
    with context.wrap_socket(socket.create_connection(("traefik.ingress-system.svc",443),timeout=5),server_hostname=name) as stream:
        stream.sendall(("GET "+path+" HTTP/1.1\r\nHost: portal.local\r\nConnection: close\r\n\r\n").encode())
        response=b""
        while True:
            data=stream.recv(65536)
            if not data: break
            response+=data
        return response
assert b"200 OK" in get("/") and b"version=v1" in get("/"), "root"
assert b"version=v2" in get("/docs/guide"), "docs"
try:
    get("/","wrong.local")
    raise AssertionError("mismatch accepted")
except ssl.SSLCertVerificationError:
    print("routing-ok")'
out="$(kubectl -n starfleet exec deployment/probe -- python -c "$script" "$certificate" 2>&1)"
if [ "$out" = "routing-ok" ]; then
  echo "PASS: / reaches probe, /docs reaches docs and a wrong server name is rejected"
else
  echo "FAIL: HTTPS routing check failed: $out"
  exit 1
fi
