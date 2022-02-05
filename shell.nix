{ pkgs ? import(
  builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/cb284f78dbcfae0a06e5a6d8a9cbed763cc83d5a.tar.gz"; # for ruby 2.7.4
  }) {}
}:
with pkgs;
let
app = bundlerEnv {
  name = "zammad";
  ruby = ruby;
  gemdir = ./.;
};
in
mkShell {
  name = "zammad-shell";
  buildInputs = [ ruby nodejs yarn imlib2 libmysqlclient postgresql ];
}
