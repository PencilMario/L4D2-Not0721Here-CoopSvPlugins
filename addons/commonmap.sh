#!/bin/bash
# 这是一个脚本，用curl命令从http://sp2.0721play.icu/d/L4D2相关/MOD/战役图/ 下载文件
# 请在你的addons文件夹中放置并执行该脚本
# 地图可在 http://sp2.0721play.icu/L4D2相关/MOD/战役图/ 获取
# mod下载完成会创建一个空的.rar文件防止再次下载，以后的下载将会跳过该文件
# 使用指令 find . -name "*.rar" -exec rm -f {} \; 删除所有.rar文件

# 2023.7.28
# 移除 B计划/活死人黎明未剪辑版/二零一九周年纪念版 - 存在模式脚本

# 2023.8.2- (未实装)
# 新增 抢救黎明/生化危机3缩短版
# 移除 深埋 - 存在更新版本
sudo apt install p7zip-full p7zip-rar -y
sudo apt install aria2 -y
base_url="http://sp2.0721play.icu/d/L4D2相关/MOD/战役图/"
file_list=(
    '深埋v1.8.rar' '广州增城v7.3.rar' '城市航班.rar' '再见了晨茗.rar' '白森林.rar' '阴暗森林v1.8(可能引起不适).rar'
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