{ pkgs, ...}:
{
    services.minecraft-server = {
        enable = false;
        eula = true;
        openFirewall = true;
        package = pkgs.unstable.papermc;
        declarative = true;
        whitelist = {
            coolBayram = "514afd03-8ca2-4f60-abe4-4c2a365d223b";
            filipus098 = "a09fb009-be78-4e26-9f33-1534186e2228";
        };
        serverProperties = {
            allow-flight=true;
            allow-nether=true;
            broadcast-console-to-ops=true;
            broadcast-rcon-to-ops=true;
            debug=false;
            difficulty="hard";
            enable-command-block=false;
            enable-jmx-monitoring=false;
            enable-query=false;
            enable-rcon=false;
            enable-status=true;
            enforce-secure-profile=true;
            enforce-whitelist=false;
            entity-broadcast-range-percentage=100;
            force-gamemode=false;
            function-permission-level=2;
            gamemode="survival";
            generate-structures=true;
            hardcore=false;
            hide-online-players=false;
            initial-enabled-packs="vanilla";
            level-name="budak";
            level-type="minecraft\:normal";
            log-ips=true;
            max-chained-neighbor-updates=1000000;
            max-players=5;
            max-tick-time=60000;
            max-world-size=29999984;
            motd="A Minecraft Server";
            network-compression-threshold=256;
            online-mode=true;
            op-permission-level=4;
            player-idle-timeout=0;
            prevent-proxy-connections=false;
            pvp=true;
            "query.port"=25565;
            rate-limit=0;
            "rcon.password"="123asdadsqwe123123";
            "rcon.port"=25575;
            require-resource-pack=false;
            server-port=25565;
            simulation-distance=10;
            spawn-animals=true;
            spawn-monsters=true;
            spawn-npcs=true;
            spawn-protection=16;
            sync-chunk-writes=true;
            use-native-transport=true;
            view-distance=10;
            white-list=true;
        };
    };
}
