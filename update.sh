#!/bin/bash

echo "upload demos"

#bash /home/steam/L4D2-Not0721Here-CoopSvPlugins/map_init.sh

echo "Get Plugin updates";
cd /home/steam/L4D2-Not0721Here-CoopSvPlugins/;
git reset --hard
git pull --rebase;
git status;

directories=("/home/steam/Steam/steamapps/common/l4d2coop/left4dead2")

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then

        # 可以热更新的内容
        # 其他文件残余内容短时间内应该不会影响 直接覆盖即可

        #rm -rf "$dir/addons/sourcemod/configs/"*
        #rm -rf "$dir/addons/sourcemod/data/"*
        #rm -rf "$dir/addons/sourcemod/gamedata/"*
        rm -rf "$dir/addons/sourcemod/plugins/"*
        #rm -rf "$dir/addons/sourcemod/translations/"*
        #rm -rf "$dir/scripts/vscripts/"*

        #rm -rf "$dir/cfg/cfgogl/"*
        #rm -rf "$dir/cfg/mixmap/"*
        #rm -rf "$dir/cfg/sourcemod/"*
        #rm -rf "$dir/cfg/stripper/"*
        
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/addons/sourcemod/configs/* "$dir/addons/sourcemod/configs/";
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/addons/sourcemod/data/* "$dir/addons/sourcemod/data/";
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/addons/sourcemod/gamedata/* "$dir/addons/sourcemod/gamedata/";
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/addons/sourcemod/plugins/* "$dir/addons/sourcemod/plugins/";
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/addons/sourcemod/translations/* "$dir/addons/sourcemod/translations/";
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/scripts/* "$dir/scripts/";
        \cp -r /home/steam/L4D2-Not0721Here-CoopSvPlugins/cfg/* "$dir/cfg/";
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