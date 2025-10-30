{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "internex-cli";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "internxt";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fkn16ielYg4mMwWdqKLFYyIl0JDrktsq0PADOM8gi7g=";
  };

  # Tip: use diff <filea> <fileb> -ur to create patches
  patches = [ (pkgs.writeText "cli-patch" ''
diff --git i/src/services/auth.service.ts w/src/services/auth.service.ts
index dcc63bb..fae23b9 100644
--- i/src/services/auth.service.ts
+++ w/src/services/auth.service.ts
@@ -29,14 +29,14 @@ export class AuthService {
       tfaCode: twoFactorCode,
     };
 
-    const data = await authClient.loginAccess(loginDetails, CryptoService.cryptoProvider);
+    const data = await authClient.login(loginDetails, CryptoService.cryptoProvider);
     const { user, newToken } = data;
 
     const clearMnemonic = CryptoService.instance.decryptTextWithKey(user.mnemonic, password);
-    const clearUser: LoginCredentials['user'] = {
-      ...user,
+    const clearUser: LoginCredentials['user'] = Object.assign({}, user, {
+      createdAt: user.createdAt as any as string,
       mnemonic: clearMnemonic,
-    };
+    });
     return {
       user: clearUser,
       token: newToken,
  '') ];

  prePatch = ''
    cp  .env.template .env
  '';

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-cgIvT/OSlj3MCCMO1MKGECH6R0y+Zp2qhoe3lzWXG2c=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    # Needed for executing package.json scripts
    nodejs
  ];

  meta = {
    description = "Internxt CLI - Manage your Internxt account from the command line";
    homepage = "https://internxt.com/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
