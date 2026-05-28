#!/bin/bash
set -euo pipefail

repo_owner="${REPO_OWNER:-PencilMario}"
gitrep="${GIT_REPO:-L4D2-Not0721Here-CoopSvPlugins}"
branch="${BRANCH:-master}"
install_dir="${INSTALL_DIR:-$HOME}"
custom_data_dir="${CUSTOM_DATA_DIR:-$HOME/l4d2_custom_config}"

scripts=(
    "update_from_release.sh"
    "update_full_from_release.sh"
)

optional_scripts=(
    "custom_config.sh"
)

echo "==================初始化 Release 更新脚本=================="
echo "Repo: $repo_owner/$gitrep"
echo "Branch: $branch"
echo "Install dir: $install_dir"
echo ""

mkdir -p "$install_dir"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

download_file() {
    local filename="$1"
    local target="$2"
    local url="https://raw.githubusercontent.com/$repo_owner/$gitrep/$branch/$filename"

    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$target"
    elif command -v wget &> /dev/null; then
        wget -q -O "$target" "$url"
    else
        echo "Error: Neither curl nor wget found. Cannot download $filename."
        return 1
    fi
}

install_required_script() {
    local filename="$1"
    local source_path="$script_dir/$filename"
    local target_path="$install_dir/$filename"

    if [ -f "$source_path" ]; then
        cp -f "$source_path" "$target_path"
        echo "Installed from local repo: $target_path"
    else
        download_file "$filename" "$target_path"
        echo "Installed from GitHub raw: $target_path"
    fi

    chmod +x "$target_path"
}

install_optional_script_if_missing() {
    local filename="$1"
    local source_path="$script_dir/$filename"
    local target_path="$install_dir/$filename"

    if [ -f "$target_path" ]; then
        echo "Skipped existing optional script: $target_path"
        return 0
    fi

    if [ -f "$source_path" ]; then
        cp -f "$source_path" "$target_path"
        chmod +x "$target_path"
        echo "Installed optional script from local repo: $target_path"
        return 0
    fi

    if download_file "$filename" "$target_path"; then
        chmod +x "$target_path"
        echo "Installed optional script from GitHub raw: $target_path"
    else
        rm -f "$target_path"
        echo "Warning: Optional script $filename was not installed"
    fi
}

for script in "${scripts[@]}"; do
    install_required_script "$script"
done

for script in "${optional_scripts[@]}"; do
    install_optional_script_if_missing "$script"
done

mkdir -p "$custom_data_dir/addons" "$custom_data_dir/cfg" "$custom_data_dir/scripts" "$custom_data_dir/sound" "$custom_data_dir/models" "$custom_data_dir/logs"

echo ""
echo "==================初始化完成=================="
echo "可运行:"
echo "  bash $install_dir/update_from_release.sh"
echo "  bash $install_dir/update_full_from_release.sh"
echo ""
echo "自定义配置目录: $custom_data_dir"
echo "把需要保留/覆盖的私有文件放进该目录，custom_config.sh 会在更新后复制到游戏目录。"
