#!/bin/bash
# 暖服机地图

sudo apt install p7zip-full p7zip-rar -y
sudo apt install aria2 -y
base_url="http://sp2.0721play.icu/d/L4D2相关/MOD/战役图/"
file_list=(
    '深埋v1.8.rar' '广州增城v7.3.7z' '城市航班.rar' '再见了晨茗.rar' '白森林.rar' '阴暗森林v1.8(可能引起不适).rar'
    )
for file in "${file_list[@]}"
do
    if [ ! -f "fin_$file" ]; then # 如果文件不存在
        echo "正在下载 $file"
        aria2c -x 16 -s 16 -k 1M "$base_url$file"
        7z x -o+ "$file" 
        rm "$file"
        touch "fin_$file"
    fi
    echo "已完成 $file"
done