{ mangal }:
let
  addPatches = pkg: patches:
    pkg.overrideAttrs
    (oldAttrs: { patches = (oldAttrs.patches or [ ]) ++ patches; });
in addPatches mangal [ ./mangal.diff ]
