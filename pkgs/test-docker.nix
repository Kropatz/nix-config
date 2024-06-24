{ dockerTools, hello }:
dockerTools.buildLayeredImage {
  name = "hello";
  tag = "latest";

  contents = [ hello ];

  config.Cmd = [ "/bin/hello" ];
}
