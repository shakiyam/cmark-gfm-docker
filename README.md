cmark-gfm-docker
================

[cmark-gfm](https://github.com/github/cmark-gfm) Docker Image

cmark-gfm-docker supports docker and podman on x86-64 and arm64.

Installation
------------

You can install by following these steps:

```console
curl -L# https://raw.githubusercontent.com/shakiyam/cmark-gfm-docker/main/cmark-gfm \
  | sudo tee /usr/local/bin/cmark-gfm >/dev/null
sudo chmod +x /usr/local/bin/cmark-gfm
"$(command -v docker || command -v podman)" pull ghcr.io/shakiyam/cmark-gfm
curl -L# https://raw.githubusercontent.com/github/cmark-gfm/master/man/man1/cmark-gfm.1 \
  | sudo tee /usr/local/share/man/man1/cmark-gfm.1 >/dev/null
```

Usage
-----

To get help with the command line:

```console
cmark-gfm --help
```

or

```console
cmark-gfm -h
```

Detailed instructions for the use the command line program can be found in man.

```console
man cmark-gfm
```

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
