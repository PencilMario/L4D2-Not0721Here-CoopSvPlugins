#!/bin/bash

echo "Get Plugin updates";
cd /home/steam/L4D2-Not0721Here-CoopSvPlugins/;
git reset --hard;
git pull --rebase;
git status;

directories=("/home/steam/Steam/steamapps/common/l4d2coop/left4dead2")

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir/addons/sourcemod/" \
            ! -path "$dir/addons/sourcemod/logs*" \
            ! -path "$dir/addons/sourcemod/configs/sourcebans*" \
            ! -path "$dir/addons/sourcemod/configs/databases.cfg" \
            -type f -delete        

        rm -rf "$dir/addons/metamod/"*
        rm -rf "$dir/addons/l4dtoolz/"*
        rm -rf "$dir/addons/stripper/"*
        rm -rf "$dir/scripts/vscripts/"*
        rm -rf "$dir/models/player/custom_player/"*
        rm -rf "$dir/sound/kodua/fortnite_emotes/"*
        # 剩下三个cfg应该不会被删除
        find "$dir/cfg/cfgogl/" \
            -type f -delete  
        rm -rf "$dir/cfg/sourcemod/"*

        rm -f "$dir/l4dtoolz.dll"
        rm -f "$dir/l4dtoolz.so"
        rm -f "$dir/l4dtoolz.vdf"
        rm -f "$dir/metamod.vdf"

        \cp -rp /home/steam/L4D2-Not0721Here-CoopSvPlugins/* "$dir/";
        chmod 777 "$dir/"

        echo "Updated | $dir"
    else
        echo "Unexist | $dir "
    fi
done
echo "File Copy Success";

echo "==================当前commit=================="
git log -1
echo "================== 运行结束 =================="

