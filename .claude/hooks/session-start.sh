#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote) environments.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install uv (fast Python package/dependency manager) if it isn't already present.
# Used for packages that ship Python code, e.g. packages/lambda-python.
if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

UV_BIN="$HOME/.local/bin"
export PATH="$UV_BIN:$PATH"

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$UV_BIN:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Set up the Python virtual environment for @remotion/lambda-python so its
# tests and linters (pytest, mypy) can run.
LAMBDA_PYTHON_DIR="$CLAUDE_PROJECT_DIR/packages/lambda-python"
if [ -d "$LAMBDA_PYTHON_DIR" ]; then
  cd "$LAMBDA_PYTHON_DIR"
  uv venv --allow-existing .venv
  uv pip install --python .venv -r requirements.txt -r dev-requirements.txt
fi
