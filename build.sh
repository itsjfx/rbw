#!/usr/bin/env bash

set -eu -o pipefail

# based off https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=rbw-git

cd "$(dirname "$0")"

cargo test --release --locked

cargo build --release --locked
mkdir -p pkg/completions
for completion in bash fish zsh; do
    cargo run --frozen --release --bin rbw -- gen-completions "$completion" > "pkg/completions/$completion-completions"
    chmod 644 "pkg/completions/$completion-completions"
done

install -Dm 755 target/release/rbw -t "pkg/"
install -Dm 755 target/release/rbw-agent -t "pkg/"

file="rbw_"$(cargo metadata --no-deps --format-version 1 | jq -re '.packages[0].version')"_linux_amd64.tar.gz"
tar -czvf pkg/"$file" -C pkg/ rbw rbw-agent completions/
