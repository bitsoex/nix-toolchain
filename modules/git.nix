{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (pp: [ pp.requests ]);
in
{
  config = {
    shellHook = ''
      ${python}/bin/python ${./github_oauth.py}
    '';
  };
}
