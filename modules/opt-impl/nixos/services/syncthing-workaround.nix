{
  modulesPath,
  ...
}:
let
  origSyncthingModule = builtins.readFile "${modulesPath}/services/networking/syncthing.nix";
  patchedText =
    builtins.replaceStrings
      [ "http://.\${path}" ]
      [ "http://syncthing.local\${path}" ]
      origSyncthingModule;
  patchedSyncthingModule =
    # replaceStrings silently no-ops if the pattern isn't found, so fail
    # loudly if upstream ever changes/fixes that line
    assert patchedText != origSyncthingModule;
    builtins.toFile "syncthing-patched.nix" patchedText;
in
{
  disabledModules = [ "services/networking/syncthing.nix" ];
  imports = [ patchedSyncthingModule ];
}
