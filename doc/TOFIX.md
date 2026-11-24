# TOFIX

Findings from a code scan on 2026-10-04.

## High

- `yocto_docker/Dockerfile:8` - `locales` is installed but no locale is ever generated or set, so bitbake's sanity check ("Your system needs to support the en_US.UTF-8 locale") fails inside this container. Add `RUN locale-gen en_US.UTF-8` (as root, before `USER yocto`) and `ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`.
- `yocto_docker/run.sh:2` - the container runs with no volume, so a multi-hour, tens-of-GB `bitbake core-image-minimal` build (and the poky clone) is lost when the container exits. Mount a host directory on `/home/yocto` (or at least on `poky/build` plus `downloads`/`sstate-cache`) and pass `--rm`.

## Medium

- `yocto_docker/Dockerfile:3` - `apt-get update` is its own layer, separate from `apt-get install` on line 4, so a cached update layer can pair with a later-edited install list and fetch stale indexes; and `rm -rf /var/lib/apt/lists/*` on line 9 is a separate layer, so it does not shrink the image. Merge lines 3, 4 and 9 into one `RUN apt-get update && apt-get install -y --no-install-recommends ... && rm -rf /var/lib/apt/lists/*`.
- `yocto_docker/Dockerfile:17` - the build step is commented out and, as written, would not run anyway (`build-yocto.sh` is not on PATH; it needs `./build-yocto.sh`). Either delete the dead comment or document in the README that the build is run by hand inside `run.sh`.
- `yocto_docker/build-yocto.sh:6` - the script is not re-runnable: a second run dies on `git clone` because `poky` already exists, and line 12 appends the `local.conf` settings again on every run. Guard the clone with `[ -d poky ] ||` and write the settings only if absent (e.g. `grep -q 'MACHINE = "qemuarm64"' conf/local.conf ||`).
- `README.md:2` - the README is a single sentence: it does not say how to use `yocto_docker/` (run `build.sh` from inside `yocto_docker/` since it uses `.` as build context, then `run.sh`, then `./build-yocto.sh`), nor the disk/time requirements. Add a usage section.
- Repo has shell scripts and a Dockerfile but no `rsconstruct.toml` / `.github/workflows/build.yml`, so nothing ever runs shellcheck or hadolint on them (the hadolint findings above would have been caught). Add the standard fleet build config with shellcheck and hadolint processors and `src_dirs = ["yocto_docker"]`.

## Low

- `yocto_docker/build-yocto.sh:6` - `git://git.yoctoproject.org/poky` uses the unauthenticated git protocol, often blocked by firewalls; use `https://git.yoctoproject.org/poky`.
- `yocto_docker/build-yocto.sh:2` - uses `set -e` while the sibling scripts use `#!/bin/bash -eu`; make it `set -eu` for consistency (`source oe-init-build-env` may need `set +u` around it).
- `yocto_docker/build.sh:2` - image is tagged `yocto-aarch64` but the build targets `qemuarm64` on an x86 host image; the tag name suggests an aarch64 container. Rename to e.g. `yocto-builder`.
