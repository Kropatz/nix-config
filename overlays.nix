# This file defines overlays
{ inputs, ... }:
let
  addPatches = pkg: patches:
    pkg.overrideAttrs
      (oldAttrs: { patches = (oldAttrs.patches or [ ]) ++ patches; });
  neotestPatch = '' diff --git a/tests/unit/client/strategies/integrated_spec.lua b/tests/unit/client/strategies/integrated_spec.lua
index 196c2e78..42a3df76 100644
--- a/tests/unit/client/strategies/integrated_spec.lua
+++ b/tests/unit/client/strategies/integrated_spec.lua
@@ -34,7 +34,7 @@ describe("integrated strategy", function()

   a.it("stops the job", function()
     local process = strategy({
-      command = { "bash", "-c", "sleep 1" },
+      command = { "bash", "-c", "sleep 10" },
       strategy = {
         height = 10,
         width = 10,
@@ -47,7 +47,7 @@ describe("integrated strategy", function()

   a.it("streams output", function()
     local process = strategy({
-      command = { "bash", "-c", "printf hello; sleep 0; printf world" },
+      command = { "bash", "-c", "printf hello; sleep 0.1; printf world" },
       strategy = {
         height = 10,
         width = 10,
  '';
  #TODO: sending keyboard stuff requires converting from keysym -> keycode. idk how to do that
  testing-patch = ''
diff --git i/src/portals/RemoteDesktop.cpp w/src/portals/RemoteDesktop.cpp
index 551550f..cc97d02 100644
--- i/src/portals/RemoteDesktop.cpp
+++ w/src/portals/RemoteDesktop.cpp
@@ -29,7 +29,7 @@ CRemoteDesktopPortal::CRemoteDesktopPortal() {
                     return onStart(o1, o2, s1, s2, m);
                 }),
             sdbus::registerMethod("NotifyPointerMotion")
-                .implementedAs([this](sdbus::ObjectPath o, double d1, double d2, std::unordered_map<std::string, sdbus::Variant> m) {
+                .implementedAs([this](sdbus::ObjectPath o, std::unordered_map<std::string, sdbus::Variant> m, double d1, double d2) {
                     return onNotifyPointerMotion(o, d1, d2, m);
                 }),
             sdbus::registerMethod("NotifyPointerMotionAbsolute")
@@ -37,11 +37,11 @@ CRemoteDesktopPortal::CRemoteDesktopPortal() {
                     return onNotifyPointerMotionAbsolute(o, u, d1, d2, m);
                 }),
             sdbus::registerMethod("NotifyPointerButton")
-                .implementedAs([this](sdbus::ObjectPath o, int i, unsigned int u, std::unordered_map<std::string, sdbus::Variant> m) {
+                .implementedAs([this](sdbus::ObjectPath o, std::unordered_map<std::string, sdbus::Variant> m, int i, unsigned int u) {
                     return onNotifyPointerButton(o, i, u, m);
                 }),
             sdbus::registerMethod("NotifyPointerAxis")
-                .implementedAs([this](sdbus::ObjectPath o, double d1, double d2, std::unordered_map<std::string, sdbus::Variant> m) {
+                .implementedAs([this](sdbus::ObjectPath o, std::unordered_map<std::string, sdbus::Variant> m, double d1, double d2) {
                     return onNotifyPointerAxis(o, d1, d2, m);
                 }),
             sdbus::registerMethod("NotifyPointerAxisDiscrete")
@@ -53,7 +53,7 @@ CRemoteDesktopPortal::CRemoteDesktopPortal() {
                     return onNotifyKeyboardKeycode(o, i, u, m);
                 }),
             sdbus::registerMethod("NotifyKeyboardKeysym")
-                .implementedAs([this](sdbus::ObjectPath o, int i, unsigned int u, std::unordered_map<std::string, sdbus::Variant> m) {
+                .implementedAs([this](sdbus::ObjectPath o, std::unordered_map<std::string, sdbus::Variant> m, int i, unsigned int u) {
                     return onNotifyKeyboardKeysym(o, i, u, m);
                 }),
             sdbus::registerMethod("NotifyTouchDown")
@@ -112,7 +112,7 @@ dbUasv CRemoteDesktopPortal::onCreateSession(sdbus::ObjectPath requestHandle, sd
     PSESSION->eis->setVirtualKeyboard(PSESSION->keyboard);
 
     m_mSessions.emplace(sessionHandle, PSESSION);
-    
+
     return {0, {}};
 }
 
@@ -137,8 +137,9 @@ dbUasv CRemoteDesktopPortal::onStart(sdbus::ObjectPath requestHandle, sdbus::Obj
 }
 
 dbUasv CRemoteDesktopPortal::onNotifyPointerMotion(sdbus::ObjectPath sessionHandle, double dx, double dy, std::unordered_map<std::string, sdbus::Variant> opts) {
+    Debug::log(LOG, "[remotedesktop] notify pointer motion: {} {}", dx, dy);
     const auto PSESSION = m_mSessions[sessionHandle];
-    PSESSION->pointer->sendMotion(0, dx, dy);
+    PSESSION->pointer->sendMotion(0, dx*20, dy*20);
     return {0, {}};
 }
 
@@ -149,6 +150,7 @@ dbUasv CRemoteDesktopPortal::onNotifyPointerMotionAbsolute(sdbus::ObjectPath ses
 }
 
 dbUasv CRemoteDesktopPortal::onNotifyPointerButton(sdbus::ObjectPath sessionHandle, int button, unsigned int state, std::unordered_map<std::string, sdbus::Variant> opts) {
+    Debug::log(LOG, "[remotedesktop] notify button {} {}", button, state);
     const auto PSESSION = m_mSessions[sessionHandle];
     PSESSION->pointer->sendButton(0, button, state);
     return {0, {}};
'';
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ./pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    discord-canary = prev.discord-canary.override { withVencord = true; };
    discord = prev.discord.override { withVencord = true; };
    tetrio-desktop = prev.tetrio-desktop.override { withTetrioPlus = true; };
    xrdp = (import inputs.nixpkgs-working-xrdp {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }).xrdp;

    #jetbrains = prev.jetbrains // {
    #  jdk = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk;
    #  jdk-no-jcef = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk-no-jcef;
    #  jdk-no-jcef-17 = (import inputs.nixpkgs-working-jetbrains {
    #    system = prev.stdenv.hostPlatform.system;
    #    config.allowUnfree = true;
    #  }).jetbrains.jdk-no-jcef-17;
    #};

    hyprshade = prev.hyprshade.overrideAttrs {
      version = "4.0.0";
      src = prev.fetchFromGitHub {
        owner = "loqusion";
        repo = "hyprshade";
        tag = "4.0.0";
        hash = "sha256-NnKhIgDAOKOdEqgHzgLq1MSHG3FDT2AVXJZ53Ozzioc=";
      };
    };

    luajitPackages = prev.luajitPackages // {
      neotest = prev.luajitPackages.neotest.overrideAttrs {
        patches = [ (prev.writeText "neotest-patch" neotestPatch) ];
      };
    };

    #hyprland = prev.hyprland.override {
    #  debug = true;
    #};
    #hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
    #xdg-desktop-portal-hyprland =
    #  inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;


    # to add input capture protocol support (needed for kde connect)
      #hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
      #  src = prev.fetchFromGitHub {
      #    owner = "3l0w";
      #    repo = "Hyprland";
      #    rev = "2464bfc318f83c093784561c6a0afca6871e119e";
      #    hash = "sha256-6MIA9wu9YW/eKsI0UEuP7CgDiribEv9apzr66dHzRME=";
      #    fetchSubmodules = true;
      #  };
      #});
      #hyprland-protocols = prev.hyprland-protocols.overrideAttrs (oldAttrs: {
      #  src = prev.fetchFromGitHub {
      #    owner = "3l0w";
      #    repo = "hyprland-protocols";
      #    rev = "d6bfa25be7b250dc417cbad89f13291efb0375d5";
      #    hash = "sha256-ULzGRSj18xOrTXnvWrkaaHUaMHaJWyXlmLDDw2jruLo=";
      #  };
      #});
      #xdg-desktop-portal-hyprland = prev.xdg-desktop-portal-hyprland.overrideAttrs (oldAttrs: {
      #  src = prev.fetchFromGitHub {
      #    #owner = "3l0w";
      #    #repo = "xdg-desktop-portal-hyprland";
      #    #rev = "436619a06641d7090e36416546d26b9aee2f0679";
      #    #hash = "sha256-OMv/8J2n2skwfVYFe1rY8pheL4T6rbWOTYYx/2u7ouk=";

      #    owner = "toneengo";
      #    repo = "xdg-desktop-portal-hyprland";
      #    rev = "f74a2278f78a5ec9167c945a40486d8999fefb9d";
      #    hash = "sha256-dH+NhC2Zz8v6MoTMaEK8qEZhHBpdCSI4818styWUFew=";
      #  };

      #  patches = [ (prev.writeText "testing-patch" testing-patch) ];
      #  buildInputs = oldAttrs.buildInputs ++ [ prev.libei ];
      #});

    #csharp-ls = prev.csharp-ls-8;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  #unstable-packages = final: _prev: {
  #  unstable = import inputs.nixpkgs-unstable {
  #    system = final.system;
  #    config.allowUnfree = true;
  #    config.permittedInsecurePackages = [ "electron-27.3.11" ];
  #  };
  #};
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
