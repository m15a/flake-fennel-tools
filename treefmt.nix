{ pkgs, ... }:
{
  programs.nixfmt.enable = true;
  programs.statix.enable = true;
  programs.deadnix.enable = true;
  programs.deadnix.no-lambda-arg = true;
  programs.deadnix.no-lambda-pattern-names = true;
  settings.global.excludes = [
    "**/.gitignore"
    "*.fnl"
    "*.json"
    "*.md"
    "*.yml"
    "LICENSE"
  ];
  settings.formatter.nixfmt.options = [ "--width=80" ];
}
