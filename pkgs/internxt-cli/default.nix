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
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "internxt";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-52mriM6rHpGX5yTAUnRW5n8dTEz62s3zneZyJco66lA=";
  };

  # Tip: use diff <filea> <fileb> -ur to create patches
  patches = [
    (pkgs.writeText "cli-patch" ''
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
    '')
  ];

  prePatch = ''
    cp  .env.template .env
  '';

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-YeQ2vmPL8YfrZKDynIlpI5kb1Srpy13JFc+29Vc//EY=";
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
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
