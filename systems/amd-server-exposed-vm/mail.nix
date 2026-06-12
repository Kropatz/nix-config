{
  config,
  lib,
  pkgs,
  ...
}:
let
  email-domain = "kopatz.dev";
  # dovecot lives on the main (secure) VM; postfix reaches it over the LAN.
  mainVmIp = config.custom.vars.serverIp;
  dovecotLmtpPort = 24;
  dovecotAuthPort = 12345;
in
{
  # 25 = smtp -> postfix (inbound from internet)
  # 587 = submission -> postfix
  networking.firewall.allowedTCPPorts = [
    25
    587
  ];

  # ACME cert for the mail domain via DNS-01 (cloudflare). There is no nginx on
  # this host, so the "nginx" group the acme-cloudflare module assigns does not
  # exist; postfix (running smtpd as root) reads the cert regardless of group.
  security.acme.certs."${email-domain}".group = lib.mkForce "postfix";

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

        # Inbound mail for our domain is handed to dovecot on the main VM via
        # LMTP over the LAN; the maps below are only used to validate/reject
        # unknown recipients at SMTP time (dovecot's static userdb accepts any
        # address it is given, so postfix must do the gatekeeping here).
        virtual_mailbox_domains = [ "${email-domain}" ];
        virtual_mailbox_maps = "hash:/etc/postfix/virtual-map";
        virtual_transport = "lmtp:inet:${mainVmIp}:${toString dovecotLmtpPort}";
        local_transport = "lmtp:inet:${mainVmIp}:${toString dovecotLmtpPort}";
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
        # SASL authentication with dovecot on the main VM over TCP
        smtpd_sasl_auth_enable = "yes";
        smtpd_sasl_type = "dovecot";
        smtpd_sasl_path = "inet:${mainVmIp}:${toString dovecotAuthPort}";
        smtpd_sasl_security_options = "noanonymous";
        smtpd_sasl_local_domain = "$myhostname";
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
        robot@${email-domain} ${email-domain}/robot/
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
}
