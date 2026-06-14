{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.custom.services.wireguard;
in
{
  config =
    let
      wireguardIp = cfg.ip;
      baseIp = lib.strings.concatStringsSep "." (
        lib.lists.take 3 (lib.strings.splitString "." wireguardIp)
      );
    in
    lib.mkIf cfg.enable {

      age.secrets.wireguard-private = {
        file = cfg.secretFile;
      };

      networking.nat.enable = true;
      networking.nat.externalInterface = cfg.externalInterface;
      networking.nat.internalInterfaces = [ "wg0" ];
      networking.firewall.allowedUDPPorts = [ 51820 ];

      #[Interface]
      #PrivateKey = <your private key here>
      #Address = 192.168.2.20/24
      #[Peer]
      #PublicKey = vyHNUy97R1cvqEvElznPpFQtoqm7WUHnT96UP6Dquwc=
      #AllowedIPs = 192.168.2.0/24
      #Endpoint = kopatz.dev:51820
      #PersistentKeepalive = 25
      networking.wg-quick.interfaces = {
        wg0 = {
          autostart = true;
          listenPort = 51820;
          address = [
            "${wireguardIp}/24"
          ];
          peers = [
            #pc
            {
              allowedIPs = [
                "${baseIp}.2/32"
              ];
              publicKey = "YgecbWSNRqOmylYqxr/V21LL3UpKEr5x42lXPAxriSc=";
            }
            {
              allowedIPs = [
                "${baseIp}.3/32"
              ];
              publicKey = "Eg5ZS3zN05mJ/gct6wJlwVAHTlXpkhxFfUd7yscANV0=";
            }
            # detschn pc
            {
              allowedIPs = [
                "${baseIp}.4/32"
              ];
              publicKey = "8Eigfs+k2k2WPaMn+SqDmlSHdMv+I+xcBr/2qhtpGzI=";
            }
            # detschn laptop
            {
              allowedIPs = [
                "${baseIp}.5/32"
              ];
              publicKey = "g5uTlA1IciXgtSbECjhVis0dajRAc53Oa7Hz6dUI+0Q=";
            }
            {
              allowedIPs = [
                "${baseIp}.6/32"
              ];
              publicKey = "5ClF2HcqndpXS7nVgDn2unWFUYcKo5fbudV6xX2OIVE=";
            }
            # handy
            {
              allowedIPs = [
                "${baseIp}.20/32"
              ];
              publicKey = "25u1RSfjsx3wb1DMeTm0pvUfUkG7zTjGaN+m0w6ZjCw=";
            }
            {
              allowedIPs = [
                "${baseIp}.21/32"
              ];
              publicKey = "S+8F+yxSQvjjoU44LRYqRv1YulqmOKumUtYo/YIh7X8=";
            }
            # laptop
            {
              allowedIPs = [
                "${baseIp}.22/32"
              ];
              publicKey = "/dIW7K49vB9HOghFeXvcY7wu2utQltuv6RfgCbxZwlk=";
            }
            {
              allowedIPs = [
                "${baseIp}.23/32"
              ];
              publicKey = "89rjQXNcyCRUCihqfqcOnctWmhiNR8snpRFF6dyHAmk=";
            }
            {
              allowedIPs = [
                "${baseIp}.24/32"
              ];
              publicKey = "adaWtboVz3UhpNBKFirs7slbU2+Y3GaV5yS2EoafwVU=";
            }
            # raphi
            {
              allowedIPs = [
                "${baseIp}.25/32"
              ];
              publicKey = "AGBWzMeSTxmB3jwNdROYHbyiqhhAVyofMV5Ku5JIE1A=";
            }
            # more keys
            # unused
            {
              allowedIPs = [
                "${baseIp}.100/32"
              ];
              publicKey = "Oj2IYrHgPhIvN+s2oi9kpqN48BXjkYMr4J/z6Baqv0Q=";
            }
          ];
          privateKeyFile = config.age.secrets.wireguard-private.path;
        };
      };
    };
}
