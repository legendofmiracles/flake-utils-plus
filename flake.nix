{
  description = "Pure Nix flake utility functions";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils }:
    rec {

      nixosModules.saneFlakeDefaults = import ./modules/saneFlakeDefaults.nix;

      devShell.x86_64-linux = import ./shell.nix { system = "x86_64-linux"; };

      lib = flake-utils.lib // {

        repl = ./repl.nix;
        systemFlake = import ./systemFlake.nix { flake-utils-plus = self; };

        builder = {
          packagesFromOverlaysBuilderConstructor = import ./packagesFromOverlaysBuilderConstructor.nix { flake-utils-plus = self; };
        };

        exporter = {
          overlaysFromChannelsExporter = import ./overlaysFromChannelsExporter.nix { flake-utils-plus = self; };
          modulesFromListExporter = import ./modulesFromListExporter.nix { flake-utils-plus = self; };
        };

        patchChannel = system: channel: patches:
          if patches == [ ] then channel else
          (import channel { inherit system; }).pkgs.applyPatches {
            name = "nixpkgs-patched-${channel.shortRev}";
            src = channel;
            patches = patches;
          };

      };
    };
}


