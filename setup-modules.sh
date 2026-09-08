#!/usr/bin/env bash
set -euo pipefail

modules=(
  "mod-playerbots|https://github.com/mod-playerbots/mod-playerbots.git|master"
  "mod-ah-bot|https://github.com/azerothcore/mod-ah-bot.git|master"
  "mod-arac|https://github.com/heyitsbench/mod-arac.git|master"
  "mod-transmog|https://github.com/azerothcore/mod-transmog.git|master"
  "mod-mounts-on-account|https://github.com/pangolp/mod-mounts-on-account.git|master"
  "mod-no-hearthstone-cooldown|https://github.com/BytesGalore/mod-no-hearthstone-cooldown.git|main"
  "mod-flying-mounts-everywhere|https://github.com/Dochoppy/mod-flying-mounts-everywhere.git|main"
)

mkdir -p modules

for spec in "${modules[@]}"; do
    IFS='|' read -r name repo branch <<< "$spec"
    path="modules/$name"

    if [ -d "$path/.git" ]; then
        echo "[OK] $name already exists"
    elif [ -e "$path" ]; then
        echo "[ERROR] $path exists but is not a Git repository"
        exit 1
    else
        echo "[CLONE] $name"
        git clone --branch "$branch" --single-branch "$repo" "$path"
    fi
done

flying="modules/mod-flying-mounts-everywhere"
patch="patches/flying-playerbot.patch"

if git -C "$flying" apply --check "../../$patch" 2>/dev/null; then
    git -C "$flying" apply "../../$patch"
    echo "[PATCHED] Flying mounts module for Playerbot core"
elif git -C "$flying" apply --reverse --check "../../$patch" 2>/dev/null; then
    echo "[OK] Flying mounts compatibility patch already applied"
else
    echo "[ERROR] Flying mounts compatibility patch cannot be applied"
    exit 1
fi

echo
echo "Module setup complete."