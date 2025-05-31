{ pkgs, lib, config, ... }:
let
  root_ca =
    ''
      -----BEGIN CERTIFICATE-----
      MIIBjTCCATKgAwIBAgIRAMVH2+JHZ3wm2fLUlKjTYDswCgYIKoZIzj0EAwIwJDEM
      MAoGA1UEChMDS29wMRQwEgYDVQQDEwtLb3AgUm9vdCBDQTAeFw0yMzEyMDgxNDUx
      MTZaFw0zMzEyMDUxNDUxMTZaMCQxDDAKBgNVBAoTA0tvcDEUMBIGA1UEAxMLS29w
      IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAATdZBOkNynShXipzhuX
      f6dUByD3chNupNWsagYC5AlPRJT9fAeHEIK/bxWkFwRtLBDopWvBu9lHahBgpHc7
      y7rTo0UwQzAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBATAdBgNV
      HQ4EFgQU9AVtwipW5HDBLfZRH1KZCnIKCfowCgYIKoZIzj0EAwIDSQAwRgIhAMHj
      AipNdhQKIYPvMt/h1uW4xP3NTkitnmshM09+rIasAiEAlSalGddXDkqJBHhPD+Fr
      gpuVkfVkA8gQCXNs5F9TnxA=
      -----END CERTIFICATE-----
    '';
  intermediate_ca =
    ''
      -----BEGIN CERTIFICATE-----
      MIIBtDCCAVqgAwIBAgIQbEVEV7LgtjVWO+qBrrmgETAKBggqhkjOPQQDAjAkMQww
      CgYDVQQKEwNLb3AxFDASBgNVBAMTC0tvcCBSb290IENBMB4XDTIzMTIwODE0NTEx
      N1oXDTMzMTIwNTE0NTExN1owLDEMMAoGA1UEChMDS29wMRwwGgYDVQQDExNLb3Ag
      SW50ZXJtZWRpYXRlIENBMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEmv7jg7Cs
      4L5v52+3yUmn79hZFS2vmm/5wwcUCL63dokEXQsHgbEjaRKsF/MW0yJDLTB6Sdhl
      pCvoNJqITWuEN6NmMGQwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8C
      AQAwHQYDVR0OBBYEFDgVolMCmdrhDIXhuIs4q/KwRKNLMB8GA1UdIwQYMBaAFPQF
      bcIqVuRwwS32UR9SmQpyCgn6MAoGCCqGSM49BAMCA0gAMEUCIQCQa01E+UvAJ8KR
      DFfDducZUpW4tZRN35lqoge7T9nM2QIgK4FFt1NqDqcjOSabAXPOQ68bvdxlHW0y
      AgN9qNc3Jbo=
      -----END CERTIFICATE-----
    '';

in
{
  security.pki.certificates = [ root_ca ];
  age.secrets.step-ca-pw = {
    file = ../../secrets/step-ca-pw.age;
    owner = "step-ca";
    group = "step-ca";
  };
  age.secrets.step-ca-key = {
    file = ../../secrets/step-ca-key.age;
    owner = "step-ca";
    group = "step-ca";
  };
  networking.firewall.allowedTCPPorts = [ 8443 ];
  services.step-ca = {
    enable = true;
    address = "";
    port = 8443;
    intermediatePasswordFile = config.age.secrets.step-ca-pw.path;
    settings = {
      dnsNames = [ "localhost" "127.0.0.1" "*.home.arpa" "192.168.0.10" ];
      root = pkgs.writeTextFile {
        name = "root.ca";
        text = root_ca;
      };
      crt = pkgs.writeTextFile {
        name = "intermediate.ca";
        text = intermediate_ca;
      };
      key = config.age.secrets.step-ca-key.path;
      db = {
        type = "badger";
        dataSource = "/var/lib/step-ca/db";
      };
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "72h";
          defaultTLSCertDuration = "72h";
        };
        provisioners = [
          {
            type = "ACME";
            name = "kop-acme";
            forceCN = true;
          }
        ];
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };
}
