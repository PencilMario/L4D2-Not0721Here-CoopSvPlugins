#!/bin/bash
echo "==================本次执行时间=================="
TZ=UTC-8 date
echo "==================开始执行=================="

gitrep=L4D2-Not0721Here-CoopSvPlugins
repo_owner="PencilMario"
release_dir="/tmp/l4d2_coop_release"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo iptables -F
sudo iptables -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

echo "Downloading latest release..."
cd /tmp || exit 1

rm -rf "$release_dir"
mkdir -p "$release_dir"

if command -v jq &> /dev/null; then
    latest_release=$(curl -s "https://api.github.com/repos/$repo_owner/$gitrep/releases/latest" | jq -r '.assets[0].browser_download_url')
elif command -v python3 &> /dev/null; then
    latest_release=$(curl -s "https://api.github.com/repos/$repo_owner/$gitrep/releases/latest" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['assets'][0]['browser_download_url'] if data.get('assets') else '')")
else
    latest_release=$(curl -s "https://api.github.com/repos/$repo_owner/$gitrep/releases/latest" | grep -o '"browser_download_url": "[^"]*"' | head -1 | cut -d '"' -f 4)
fi

if [ -z "$latest_release" ] || [ "$latest_release" == "null" ]; then
    echo "Failed to get latest release URL"
    exit 1
fi

echo "Downloading from: $latest_release"
wget -q -O "$release_dir/release.zip" "https://releases.0721play.top/$latest_release"

if [ ! -f "$release_dir/release.zip" ]; then
    echo "Failed to download release"
    exit 1
fi

echo "Extracting release..."

if command -v unzip &> /dev/null; then
    unzip -q "$release_dir/release.zip" -d "$release_dir/"
elif command -v python3 &> /dev/null; then
    python3 << 'EOF'
import zipfile
import sys
try:
    with zipfile.ZipFile("/tmp/l4d2_coop_release/release.zip", 'r') as zip_ref:
        zip_ref.extractall("/tmp/l4d2_coop_release/")
    print("Extraction completed")
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
else
    echo "Error: Neither unzip nor python3 found. Cannot extract release."
    exit 1
fi

project_path=$(find "$release_dir" -maxdepth 1 -type d -name "$gitrep" | head -1)

if [ -z "$project_path" ]; then
    echo "Failed to find project directory in release"
    exit 1
fi

directories=("/home/steam/Steam/steamapps/common/l4d2coop/left4dead2")

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        sudo timedatectl set-timezone Asia/Shanghai
        cd ~ || exit 1
        ./steamcmd.sh +force_install_dir "${dir%/left4dead2}" +login anonymous +app_update 222860 validate +quit

        echo ""
        find "$dir/addons/" -type f -delete
        find "$dir/addons/" -type d -empty -delete

        cp -rp "$project_path/"* "$dir/"
        chmod 777 "$dir/"

        if [ -f "$HOME/custom_config.sh" ]; then
            bash "$HOME/custom_config.sh"
        elif [ -f "$script_dir/custom_config.sh" ]; then
            bash "$script_dir/custom_config.sh"
        elif [ -f "$project_path/custom_config.sh" ]; then
            bash "$project_path/custom_config.sh"
        else
            echo "Warning: custom_config.sh does not exist"
        fi

        echo "Updated | $dir"
    else
        echo "Unexist | $dir "
    fi
done

echo "File Copy Success"

echo "==================清理临时文件=================="
rm -rf "$release_dir"

echo "==================Release 信息=================="
echo "Latest Release: $latest_release"

echo "================== 运行结束 =================="
