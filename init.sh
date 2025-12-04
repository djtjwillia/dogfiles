#!/bin/bash
set -euo pipefail

ensure_brew() {
    if command -v brew >/dev/null 2>&1; then
        echo "[init] Homebrew already installed"
        return
    fi

    echo "[init] Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_task() {
    if command -v task >/dev/null 2>&1; then
        echo "[init] go-task already installed"
        return
    fi

    echo "[init] Installing go-task"
    ensure_brew
    brew install go-task/tap/go-task
}

ensure_task

if [ ! -f Taskfile.yml ]; then
    echo "[init] Taskfile.yml not found; please run from repo root"
    exit 1
fi

echo "[init] Running task init"
task init "$@"
