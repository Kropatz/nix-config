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
    gitea@kopatz.dev:{CRYPT}$2y$05$FU60i8/H6I0ZI1MH20.tyuImrIsxiKt.h4aoSDAKYJUiQWAxhENyq:5000:5000::/home/gitea";
  '';
  email-domain = "kopatz.dev";
in
{
  # 25 = stmp -> postfix
  # 143 = imap -> dovecot
  # 587 = submission -> postfix
  networking.firewall.allowedTCPPorts = [
    25
    143
    587
  ];
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
  };
  services.postfix = {
    enable = true;
    settings = {
      master = {
        submission = {
          type = "inet";
          private = false;
          command = "smtpd";
          args = [
            "-o syslog_name=postfix/submission"
            "-o smtpd_tls_security_level=encrypt"
            "-o smtpd_sasl_auth_enable=yes"
            "-o smtpd_client_restrictions=permit_sasl_authenticated,reject"
            # TODO: look into check_sender_access hash:/etc/postfix/sender_access
            # reject_unknown_sender_domain blocks internal git from evolit
            #"-o smtpd_sender_restrictions="
            "-o smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject"
            "-o smtpd_relay_restrictions=permit_sasl_authenticated,reject"
            "-o milter_macro_daemon_name=ORIGINATING"
          ];
        };
      };
      main = {
        myhostname = "${email-domain}";
        mydomain = "${email-domain}";
        #myorigin = "$mydomain";
        mynetworks = [
          "127.0.0.0/8"
          "192.168.0.0/24"
          "192.168.2.0/24"
        ];
        mydestination = [
          "localhost.$mydomain"
          "localhost"
        ];
        message_size_limit = 25600000; # 25MB
        recipient_delimiter = "+";
        virtual_mailbox_domains = [ "${email-domain}" ];
        virtual_mailbox_base = "/data/vmail";
        virtual_mailbox_maps = "hash:/etc/postfix/virtual-map";
        virtual_uid_maps = "static:${toString config.users.users.vmail.uid}";
        virtual_gid_maps = "static:${toString config.users.groups.vmail.gid}";
        virtual_transport = "virtual";
        local_transport = "virtual";
        local_recipient_maps = "$virtual_mailbox_maps";
        # TLS settings
        # server settings / SMTP TLS configuration for inbound connections
        smtpd_tls_security_level = "may";
        smtpd_tls_chain_files = [
          "/var/lib/acme/${email-domain}/key.pem "
          "/var/lib/acme/${email-domain}/fullchain.pem "
        ];
        smtpd_tls_received_header = "yes";
        smtpd_tls_auth_only = "yes"; # disable AUTH over non-encrypted connections
        smtpd_tls_ciphers = "high"; # ciphers used in opportunistic TLS
        smtpd_tls_exclude_ciphers = "aNULL, MD5, DES"; # exclude weak ciphers
        smtpd_tls_protocols = ">=TLSv1.2";
        #client settings / SMTP TLS configuration for outbound connections
        smtp_tls_chain_files = [
          "/var/lib/acme/${email-domain}/key.pem "
          "/var/lib/acme/${email-domain}/fullchain.pem "
        ]; # private key followed by cert chain
        smtp_tls_security_level = "may"; # opportunistic TLS
        smtp_tls_ciphers = "high"; # ciphers used in opportunistic TLS
        smtp_tls_exclude_ciphers = "aNULL, MD5, DES"; # exclude weak ciphers
        smtp_tls_protocols = ">=TLSv1.2";
        smtp_tls_note_starttls_offer = "yes"; # log the hostname of remote servers that offer STARTTLS
        # TLS logging
        smtpd_tls_loglevel = 1;
        smtp_tls_loglevel = 1;
        # SASL authentication with dovecot
        smtpd_sasl_auth_enable = "yes";
        smtpd_sasl_type = "dovecot";
        smtpd_sasl_path = "private/auth";
        smtpd_sasl_security_options = "noanonymous";
        smtpd_sasl_local_domain = "$myhostname";
        #smtpd_client_restrictions = "permit_sasl_authenticated,reject";
        # reject_unknown_sender_domain blocks internal git from evolit
        #smtpd_sender_restrictions = "reject_unknown_sender_domain";
        # https://www.postfix.org/SMTPD_ACCESS_README.html
        smtpd_recipient_restrictions = "reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject_unauth_destination";
        smtpd_relay_restrictions = "permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination";
        # For DKIM (milter = mail filter)
        smtpd_milters = [ "unix:/run/opendkim/opendkim.sock" ];
        non_smtpd_milters = [ "unix:/run/opendkim/opendkim.sock" ];
        milter_default_action = "accept";
      };
    };
    virtual = ''
      root@${email-domain} lukas@${email-domain}
      git@${email-domain} lukas@${email-domain}
      mailer-daemon@${email-domain} lukas@${email-domain}
      postmaster@${email-domain} lukas@${email-domain}
      nobody@${email-domain} lukas@${email-domain}
      hostmaster@${email-domain} lukas@${email-domain}
      usenet@${email-domain} lukas@${email-domain}
      news@${email-domain} lukas@${email-domain}
      webmaster@${email-domain} lukas@${email-domain}
      www@${email-domain} lukas@${email-domain}
      ftp@${email-domain} lukas@${email-domain}
      abuse@${email-domain} lukas@${email-domain}
      dmarcreports@${email-domain} lukas@${email-domain}
      rat@${email-domain} spam@${email-domain}
      acc1@${email-domain} spam@${email-domain}
      acc2@${email-domain} spam@${email-domain}
      acc3@${email-domain} spam@${email-domain}
      acc4@${email-domain} spam@${email-domain}
      acc5@${email-domain} spam@${email-domain}
    '';
    mapFiles = {
      "virtual-map" = pkgs.writeText "postfix-virtual" ''
        lukas@${email-domain} ${email-domain}/lukas/
        work@${email-domain} ${email-domain}/work/
        school@${email-domain} ${email-domain}/school/
        test@${email-domain} ${email-domain}/test/
        spam@${email-domain} ${email-domain}/spam/
        gitea@${email-domain} ${email-domain}/gitea/
      '';
    };
  };
  services.opendkim = {
    enable = true;
    user = "postfix";
    group = "postfix";
    domains = "csl:${email-domain}";
    selector = "mail";
    socket = "local:/run/opendkim/opendkim.sock";
  };
  nixpkgs.config.permittedInsecurePackages = [
    "opendkim-2.11.0-Beta2"
  ];
  services.rspamd = {
    enable = true;
    package = pkgs.rspamd;
    postfix.enable = true;
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
      passdb passwd-file {
        default_password_scheme = CRYPT
        driver = passwd-file
        passwd_file_path = /etc/dovecot-users
        auth_username_format = %{user}
      }

      userdb passwd-file {
        driver = passwd-file
        passwd_file_path = /etc/dovecot-users
        auth_username_format = %{user}

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
      protocols = imap

      auth_allow_cleartext = no
      auth_mechanisms = plain
      ssl = required
      ssl_cipher_list = HIGH
      ssl_server {
        cert_file = /var/lib/acme/${email-domain}/cert.pem
        key_file = /var/lib/acme/${email-domain}/key.pem
        prefer_ciphers = server
      }

      service auth {
        user = root

        unix_listener /var/lib/postfix/queue/private/auth {
          group = postfix
          mode = 0660
          user = postfix
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
