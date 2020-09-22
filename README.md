## Generate GPU mining images via nixos


### Build
1. enter reproducible environment by executing `nix-shell`

2. generate kexec image:
```bash
nixos-generate -c configuration.nix --format-path format.nix -o result
```

### Run
1. copy the tar.gz file from ./result to the target machine
1. unpack the tar.gz file
1. create a symlinkg from `/nix` to `/nix` of the extracted dir
1. run the kexec script

