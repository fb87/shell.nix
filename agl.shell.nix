let
  pkgs = import
    (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/nixos-24.11-small.tar.gz";
    })
    { };
in

with pkgs; (buildFHSEnv {
  name = "agl-build-env";

  targetPkgs = pkgs: with pkgs; [
    bash
    getopt
    hostname
    gcc

    git
    git-repo
    python3

    lz4
    chrpath
    diffstat
    wget
    cpio
    flock
    perl
    zstd
    which
    rpcsvc-proto
  ] ++ (with pkgs; [
    busybox # provides core-utils
  ]);

  extraOutputsToInstall = [ "dev" ];
  extraBuildCommands = ''
    ln -sf lz4 $out/usr/bin/lz4c
  '';

  profile = ''
    # Shared Yocto cache dirs
    export DL_DIR=$HOME/.cache/agl/downloads
    export SSTATE_DIR=$HOME/.cache/agl/sstates

    # pure env. require cert specified
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    export GIT_SSL_CAINFO="$SSL_CERT_FILE"
    export LANG=C.UTF-8

    # avoid locale issue
    export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
    export LOCALEARCHIVE=$LOCALE_ARCHIVE
    export BB_ENV_PASSTHROUGH_ADDITIONS="LOCALE_ARCHIVE LOCALEARCHIVE"

    # Git config for repo tool
    git config --global user.email "builder@localhost.localdomain"
    git config --global user.name "builder"
  '';

  runScript = "bash";
}).env

