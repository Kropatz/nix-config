{
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        settings.PermitRootLogin = "no";
    };

    users.users.anon.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb14svyGa2WprTNrtaI5yRl9KP+wzmLueFsHQww0Y6D2CZ5ZEEwoGFg7PrjWzVa/tXYn5AO1ng5eMCRbZPjtX03of448HTAEV8B0BFV9BuemoIBf14TRZ6lhGfQvD7BlTVZ5jKGUUJBfRdf0CZ8Ed5dk77u0xGV8+p3dYAQXowOmOyYFiDg6baKQcLM5Pz2zVxK1GySehEJ4n7GYNjyv7hJhfWMbaE10rIB0V0TuM8yeYvBvIxfGfMzlm4izOHbuSYR1v6RCuQKn1JOQiYqAkYCsXG/4XssMXpl2KxGvp67OJNotIHzap8zRDr7KH8Sk8jHuBFCnqbxDEqzs72Qtan Kopatz@Kopatz-PC"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsicFT8H/XHR3c0nN6f3dmChxLlkIYalUEQPqP2qROkX7Na6cMXoFiRvegvVPBCgR+DKagp7G2fttZVZ51yBBZ4G/rzDMgKIFgTDNaDeyGWx2n2zCHM5/wletoqTU6ezOUKOEvOfpsZnpcUqVmYtxlrMpakItrtSO+5mawlTKiDTqtazxLfFuyQFzlXVfVcJacxEupd+Ilmp8Y/e8pp6+jGYZ9asNuQKuGDaCepkhsPEGq/cK9AqaATdx/F81H1metV+kf6A3eDlcyzZy+x41GSofiR6HFgUzYafe5uddMVtL7JIKHHPQVpMMqPxkD3tphozh0fq3C9v8aThcqkvoU9eFD7PcN+8U6guA6Qf7cysGXb3pnvrfSeKGlxxpUAxLcpHlJnP66c7/TVRe2buAYFQqykrmRmJfLwqpY2UHoshpcGTwULslEHCMC5/wgc3BPgVGUB148d7F36bS1jTJlRGqwzf712CKnwW122xTZawgybrr8A5Q/bSRFtpz5wys= kopatz@Kopatz-PC2"
    ];
}
