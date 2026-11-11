{
  config,
  lib,
  pkgs,
  ...
}:
let
  # create hash -> dovecot -O pw
  dovecot_passwords = ''
    lukas:{CRYPT}$2y$05$jqBkvhJ0e439J0PLhef4leOGc3GACGH83kSDCrvmAcsdz68tELkA6:5000:5000::/home/lukas";
    work:{CRYPT}$2y$05$bEpY1WJ4j/QovgUv0Pxak.vKcSC/o.0T9OHxaekUpI1GK5mAY6vQS:5000:5000::/home/work";
    school:{CRYPT}$2y$05$RRIjDak/PWhHITKMvGJ9b.MSMrsduUXjLJOfuXQ0k.pQX24shAsq2:5000:5000::/home/school";
    spam:{CRYPT}$2y$05$jkoR3nro0ux19Q7eupvvWetRXLazjuQuLUK0V0E7nRY8wwEwMBmoK:5000:5000::/home/spam";
    gitea:{CRYPT}$2y$05$FU60i8/H6I0ZI1MH20.tyuImrIsxiKt.h4aoSDAKYJUiQWAxhENyq:5000:5000::/home/gitea";
    robot:{CRYPT}$2y$05$kyMJFlbsdjxCSjkP6EHvyOvsvJE0kaO7a7GsaoqsSH56RNo510tpi:5000:5000::/home/robot";
    test:{CRYPT}*:5000:5000::/home/test";
  '';
  email-domain = "kopatz.dev";
in
{
  # 143 = imap -> dovecot (smtp/submission now live on the exposed VM)
  networking.firewall.allowedTCPPorts = [
    143
  ];

  systemd.services.sync-acme-kopatz = {
    description = "Sync kopatz.dev ACME certs to exposedvm";
    after = [ "acme-kopatz.dev.service" "adguardhome.service" ];
    wants = [ "acme-kopatz.dev.service" "adguardhome.service" ];
    wantedBy = [ "acme-kopatz.dev.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "sync-acme-kopatz" ''
          ${pkgs.coreutils}/bin/sleep 5 && ${pkgs.openssh}/bin/scp -r \
          -i /etc/ssh/ssh_host_ed25519_key \
          -o StrictHostKeyChecking=accept-new \
          /var/lib/acme/kopatz.dev \
          synccert@exposedvm.kopatz.dev:/var/lib/acme/
      '';
    };
  };
  # Let the exposed VM's postfix deliver via LMTP (24) and authenticate
  # submission users against dovecot's SASL service (12345). Nothing else on
  # the LAN/internet may reach these.
  networking.firewall.extraInputRules = ''
    ip saddr ${config.custom.vars.exposedServerIp} tcp dport { 24, 12345 } counter accept comment "mail lmtp+auth from exposed vm"
  '';
  users = {
    users = {
      vmail = {
        isSystemUser = true;
        description = "Virtual mail user";
        home = "/data/vmail";
        uid = 5000;
        group = "vmail";
      };
    };
    groups = {
      vmail = {
        gid = 5000;
      };
    };
  };
  systemd.tmpfiles.rules = [ "d /data/vmail 0700 vmail vmail -" ];
  services.nginx.virtualHosts."${email-domain}" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''if ($reject_br) { return 415; }'';
  };
  services.dovecot2 = {
    package = pkgs.dovecot_2_4;
    enable = true;
    enablePAM = false;
    settings = {
      dovecot_config_version = "2.4.2";
      dovecot_storage_version = "2.4.0";
    };
    # TODO: upgrade to 2.4 https://doc.dovecot.org/2.4.3/installation/upgrade/2.3-to-2.4.html
    configFile = pkgs.writeText "dovecot.conf" ''
      dovecot_config_version=${config.services.dovecot2.settings.dovecot_config_version}
      dovecot_storage_version=${config.services.dovecot2.settings.dovecot_storage_version}
      # Strip the domain so a login or LMTP recipient of "lukas@kopatz.dev"
      # resolves to the bare key "lukas" in the passwd file. dovecot's LMTP
      # validates recipients against the passdb, so every deliverable address
      # must map here (the passwd file is keyed by bare local part for all
      # accounts; clients may still log in with or without the @domain).
      passdb passwd-file {
        default_password_scheme = CRYPT
        driver = passwd-file
        passwd_file_path = /etc/dovecot-users
        auth_username_format = %{user | username}
      }

      # Static userdb: every account maps to the same vmail uid/gid, and the
      # per-user maildir comes from mail_path (which strips the domain). The
      # passdb above is what gates which users/recipients exist.
      userdb static {
        driver = static
        fields {
          gid = vmail
          home = /home/vmail/%{user}
          uid = vmail
        }
      }
      default_internal_group = ${config.services.dovecot2.settings.default_internal_group}
      default_internal_user = ${config.services.dovecot2.settings.default_internal_user}
      mail_driver = maildir
      mail_path = /data/vmail/${email-domain}/%{user | username}
      protocols = imap lmtp

      auth_allow_cleartext = no
      auth_mechanisms = plain
      ssl = required
      ssl_cipher_list = HIGH
      ssl_server {
        cert_file = /var/lib/acme/${email-domain}/cert.pem
        key_file = /var/lib/acme/${email-domain}/key.pem
        prefer_ciphers = server
      }

      # SASL auth for the exposed VM's postfix submission service, over TCP.
      # Reachable only from the exposed VM (firewall-restricted).
      service auth {
        user = root

        inet_listener auth {
          port = 12345
        }
      }

      # LMTP delivery endpoint the exposed VM's postfix hands inbound mail to.
      # Reachable only from the exposed VM (firewall-restricted).
      service lmtp {
        inet_listener lmtp {
          port = 24
        }
      }

      namespace inbox {
        inbox = yes

        mailbox Drafts {
          special_use = \Drafts
          auto = subscribe
        }
        mailbox Sent {
          special_use = \Sent
          auto = subscribe
        }
        mailbox Junk {
          special_use = \Junk
          auto = subscribe
        }
        mailbox Trash {
          special_use = \Trash
          auto = subscribe
        }
      }
      # Warnings during conversion:
      # - pruned default: inbox prefix = ' '
    '';
  };
  environment.etc."dovecot-users".text = dovecot_passwords;
}
