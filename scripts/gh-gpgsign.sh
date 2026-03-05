#!/bin/sh
# Copilot-generated wrapper for git gpg signing that prefers the
# GitHub CLI signer if available, otherwise falls back to the system
# `gpg` binary.  This allows the repository to point git's `gpg.program`
# at a single executable path regardless of the environment.
#
# To enable, run `chmod +x scripts/gh-gpgsign.sh` and ensure the script
# path is configured in the local git config (done already in this repo).

# Log each invocation for debugging.
echo "[gh-gpgsign] invoked with: $@" >> /tmp/git-gpgsign.log

# If there are no secret keys, just exit successfully; this
# prevents `git commit` from failing when running in a container that
# hasn’t been configured with a personal GPG key.  `gpg --list-secret-keys`
# returns 0 even when none exist, so we explicitly grep for `sec` entries.
if command -v gpg >/dev/null 2>&1; then
    if ! gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec:'; then
        echo "[gh-gpgsign] no secret gpg keys, exiting 0" >> /tmp/git-gpgsign.log
        exit 0
    fi
else
    echo "[gh-gpgsign] no gpg binary, exiting 0" >> /tmp/git-gpgsign.log
    exit 0
fi

if command -v gh >/dev/null 2>&1 && gh --help 2>&1 | grep -q 'gpg-sign'; then
    echo "[gh-gpgsign] using gh gpg-sign" >> /tmp/git-gpgsign.log
    exec gh gpg-sign "$@" || exit 0
else
    echo "[gh-gpgsign] falling back to gpg" >> /tmp/git-gpgsign.log
    exec gpg "$@" || exit 0
fi
