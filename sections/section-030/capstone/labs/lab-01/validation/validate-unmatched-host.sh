#!/usr/bin/env bash
# Check: a request for another host name returns 404.
set -uo pipefail
certificate="$(kubectl -n starfleet get secret portal-tls -o jsonpath='{.data.tls\.crt}' 2>/dev/null)"
script='import base64,socket,ssl,sys
context=ssl.create_default_context(cadata=base64.b64decode(sys.argv[1]).decode())
with context.wrap_socket(socket.create_connection(("traefik.ingress-system.svc",443),timeout=5),server_hostname="portal.local") as stream:
    stream.sendall(b"GET / HTTP/1.1\r\nHost: other.local\r\nConnection: close\r\n\r\n")
    response=b""
    while True:
        data=stream.recv(65536)
        if not data: break
        response+=data
    print(response.split(b" ")[1].decode())'
out="$(kubectl -n starfleet exec deployment/probe -- python -c "$script" "$certificate" 2>&1)"
if [ "$out" = "404" ]; then
  echo "PASS: unmatched host returns 404"
else
  echo "FAIL: unmatched host must return 404, got: $out"
  exit 1
fi
