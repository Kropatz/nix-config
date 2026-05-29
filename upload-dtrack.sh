#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq
source .env
JWT=$(
  curl -k -s -X POST \
    "https://dtrack.nestlerlabs.at/api/v1/user/login" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=${DTRACK_PASSWORD}"
)
curl -k -X POST \
  "https://dtrack.nestlerlabs.at/api/v1/bom" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: multipart/form-data" \
  -F "projectName=kop-nix-server-host" \
  -F "bom=@./sbom/amd-server/sbom.cdx.json"
curl -k -X POST \
  "https://dtrack.nestlerlabs.at/api/v1/bom" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: multipart/form-data" \
  -F "projectName=kop-nix-server-vm" \
  -F "bom=@./sbom/server-vm/sbom.cdx.json"
curl -k -X POST \
  "https://dtrack.nestlerlabs.at/api/v1/bom" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: multipart/form-data" \
  -F "projectName=kop-nix-server-vpn-vm" \
  -F "bom=@./sbom/amd-server-vpn-vm/sbom.cdx.json"
curl -k -X POST \
  "https://dtrack.nestlerlabs.at/api/v1/bom" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: multipart/form-data" \
  -F "projectName=kop-nix-server-exposed-vm" \
  -F "bom=@./sbom/amd-server-exposed-vm/sbom.cdx.json"
