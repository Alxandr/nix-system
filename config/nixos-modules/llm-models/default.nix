{ pkgs, ... }:
let
  models = pkgs.callPackage ./models { };
in
{
  _module.args = {
    llm-models = models;
  };
}
