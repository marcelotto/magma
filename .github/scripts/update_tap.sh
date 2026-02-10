#!/usr/bin/env bash
set -euo pipefail

# Required environment variables (passed from the workflow):
#   HOMEBREW_TAP_TOKEN  - PAT with Contents read/write for the tap repository
#   VERSION             - Release version without 'v' prefix (e.g., "0.3.0")
#   GITHUB_REPOSITORY   - Owner/repo (e.g., "marcelotto/magma")

REPO_OWNER="${GITHUB_REPOSITORY%%/*}"
TAG="v${VERSION}"
BASE_URL="https://github.com/${GITHUB_REPOSITORY}/releases/download/${TAG}"

BINARIES=("magma_macos_arm" "magma_macos_intel" "magma_linux_arm" "magma_linux_intel")
EMPTY_SHA="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

# Wait for release assets to be available (retry up to 5 times with 30s delay)
echo "Verifying release assets are available..."
for attempt in $(seq 1 5); do
  ALL_AVAILABLE=true
  for binary in "${BINARIES[@]}"; do
    STATUS=$(curl -sL -o /dev/null -w "%{http_code}" "${BASE_URL}/${binary}")
    if [[ "$STATUS" != "200" && "$STATUS" != "302" ]]; then
      echo "  Asset ${binary} not yet available (HTTP ${STATUS}), attempt ${attempt}/5"
      ALL_AVAILABLE=false
      break
    fi
  done
  if $ALL_AVAILABLE; then
    echo "All release assets are available."
    break
  fi
  if [[ $attempt -eq 5 ]]; then
    echo "ERROR: Release assets not available after 5 attempts"
    exit 1
  fi
  sleep 30
done

# Compute SHA256 hashes
declare -A SHAS
for binary in "${BINARIES[@]}"; do
  echo "Computing SHA256 for ${binary}..."
  SHA=$(curl -sL "${BASE_URL}/${binary}" | sha256sum | awk '{print $1}')
  if [[ -z "$SHA" || "$SHA" == "$EMPTY_SHA" ]]; then
    echo "ERROR: Empty or failed download for ${binary}"
    exit 1
  fi
  SHAS[$binary]="$SHA"
  echo "  ${binary}: ${SHA}"
done

# Generate the Homebrew formula
FORMULA=$(cat <<RUBY
class Magma < Formula
  desc "LLM-powered prompt development environment"
  homepage "https://github.com/${GITHUB_REPOSITORY}"
  version "${VERSION}"
  license "MIT"

  depends_on "pandoc"

  on_macos do
    if Hardware::CPU.arm?
      url "${BASE_URL}/magma_macos_arm"
      sha256 "${SHAS[magma_macos_arm]}"
    else
      url "${BASE_URL}/magma_macos_intel"
      sha256 "${SHAS[magma_macos_intel]}"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "${BASE_URL}/magma_linux_arm"
      sha256 "${SHAS[magma_linux_arm]}"
    else
      url "${BASE_URL}/magma_linux_intel"
      sha256 "${SHAS[magma_linux_intel]}"
    end
  end

  def install
    binary_name = stable.url.split("/").last
    bin.install binary_name => "magma"
  end

  test do
    assert_match "Magma v${VERSION}", shell_output("#{bin}/magma version")
  end
end
RUBY
)

# Clone tap repo and update formula (avoid PAT in initial clone URL)
CLONE_DIR=$(mktemp -d)
trap 'rm -rf "$CLONE_DIR"' EXIT

git clone --depth 1 "https://github.com/${REPO_OWNER}/homebrew-tap.git" "$CLONE_DIR"
cd "$CLONE_DIR"
git remote set-url origin "https://x-access-token:${HOMEBREW_TAP_TOKEN}@github.com/${REPO_OWNER}/homebrew-tap.git"

mkdir -p Formula
echo "$FORMULA" > Formula/magma.rb

git add Formula/magma.rb

# Check if there are changes (prevents error on rerun)
if git diff --staged --quiet; then
  echo "No changes detected. Formula already up to date."
else
  git config user.name "github-actions[bot]"
  git config user.email "github-actions[bot]@users.noreply.github.com"
  git commit -m "Update magma to ${VERSION}"
  git push origin main
  echo "Homebrew tap updated to version ${VERSION}"
fi