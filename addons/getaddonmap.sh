#!/bin/bash
# 这是一个脚本，用curl命令从http://sp2.0721play.icu/d/L4D2相关/MOD/战役图/ 下载文件
# 请在你的addons文件夹中放置并执行该脚本
# 地图可在 http://sp2.0721play.icu/L4D2相关/MOD/战役图/ 获取
# .fin文件表示该mod下载完成，以后的下载将会跳过该文件
sudo apt install unrar -y
sudo apt install aria2 -y
base_url="http://sp2.0721play.icu/d/L4D2相关/MOD/战役图/"
file_list=('B计划.rar' 'CEDA狂热.rar' 'F18之路.rar' 'ZMB13.rar' 'ZPTZ.rar' 
    '七小时后.rar' '万里.rar' '不再有工业区v4.7.rar' 
    '不寒而栗v1.rar' '丧尸侵袭.rar' '乐高运动.rar' '乡村之旅.rar' '二零一九周年纪念版.rar' '亡灵区.rar' '传送门2地下.rar' 
    '佩萨罗.rar' '佩萨罗2.rar' '停电的地下室.rar' '八四区.rar' '公路杀手.rar' '关键时刻v1.rar' '再见了南宁v5.3.rar' 
    '再见了晨茗.rar' '冬日低语.rar' '冰点.rar' '别掉下去圣诞版.rar' '北卡罗来纳州的公路修复版.rar' '北极.rar' '十七号城市.rar' 
    '午夜油井(单章节).rar' '午夜铁路.rar' '半条命2十七号公路.rar' '去年夏天.rar' '古墓亡影.rar' '只此一路.rar' '可乐之塔.rar' 
    '命中注定v1.rar' '回到学校完整版v1.06.rar' '地狱之路.rar' '地狱城市.rar' '坠入死亡.rar' '城市中心启示录扩展版.rar' 
    '城市航班.rar' '城郊惊魂.rar' '夜惊.rar' '大坝.rar' '大坝2导演剪辑版.rar' '大坝的使命修复版.rar' '大阪感染2.rar' 
    '天堂可待2.rar' '天堂可待2修复版v16.rar' '太平间v8.rar' '奥本计划2.rar' '完美逃脱2.rar' '实验室024(V1.4).rar' '封锁.rar' 
    '尻名山.rar' '巴塞罗那.rar' '巷战.rar' '市中心v3.0.rar' '市区用餐.rar' '布宜诺斯艾利斯.rar' '幽灵船2.rar' 
    '广州增城v7.3.rar' '开路.rar' '异度神召(解谜&附解谜流程).rar' '恐怖之旅.rar' '惩罚者(阴间图).rar' '感染之城(长图).rar' 
    '感染之城2(长图).rar' '感染源.rar' '我们不去莱温霍姆.rar' '我们共同的梦魇.rar' '我的世界2.rar' '我讨厌山2.rar' 
    '拯救降临.rar' '摩天大厦.rar' '摩耶山危机v6(不能提前拿油桶).rar' '救赎2.rar' '断手.rar' '旅行日.rar' 
    '无名的僵尸 电影v6.rar' '无声警告.rar' '无连续性.rar' '星际之门2.rar' '暴毙峡谷.rar' '最后一程.rar' 
    '最后时刻.rar' '最后的电伏.rar' '梦想计划(阴间图).rar' '橙色冲击.rar' '橙色豁免.rar' '欢迎来到地狱.rar' 
    '此路不通.rar' '此路不通2.rar' ' 死亡中心好结局.rar' '死亡之城.rar' '死亡之城2.rar' '死亡之夏.rar' '死亡军团2.rar' 
    '死亡县城.rar' '死亡商场.rar' '死亡回声2修复版.rar' '死亡回声2原版.rar' '死亡地带.rar' '死亡尖叫2.rar' '死亡度假.rar' 
    '死亡森林.rar' '死亡狂奔v7.rar' '死亡目的地v3.rar' '死亡竞技场2.rar' '死亡缠绕2.rar' '死亡蓝旗2.rar' '死亡逃脱.rar' 
    '死亡陷阱.rar' '死亡高校.rar' '死囚区.rar' '死期将至.rar' '死神天降.rar' '死胡同.rar' '死里逃生.rar' '汽油狂热.rar' 
    '治愈.rar' '治愈2.rar' '活死人黎明导演剪辑版v7.rar' '活死人黎明未剪辑版.rar' '流浪者营地(单章节).rar' '浴室.rar' 
    '海岸救援.rar' '深埋.rar' '深埋v1.8.rar' '漆黑的台面.rar' '激流.rar' '灰色.rar' '燃烧之下.rar' '狂热的梦v2.1.rar' 
    '玛雅遗址v3.rar' ' 玩具世界.rar' '生还之锋重制版.rar' '痛苦列车v3(单章节).rar' '瘟疫传说(新版).rar' '白森林.rar' 
    '盐井地狱公园.rar' '真方氏.rar' '稀释v1.rar' '红色城市.rar' '终生监禁.rar' '绝境逢生.rar' '绝对零度.rar' 
    '绝对零度结局.rar' '绝望.rar' '绝非宿命2_v1.rar' '维也纳的呼唤.rar' '维也纳的呼唤2.rar' '维修站.rar' '能源危机.rar' 
    '脱轨.rar' '自由通行v1.2.rar' '至小玉(单章节).rar' '致命派遣.rar' '致命货运站重制版.rar' '节日度假(单章节略掉帧).rar' 
    '英尼斯路障.rar' '英尼斯路障圣诞版.rar' '莱温霍姆.rar' '蓝色天堂v11.rar' '蓝色天堂v45.rar' '虚幻.rar' 
    '蜂巢(部分关卡炸服).rar' '血之轨迹.rar' '血森林启示录2.rar' '血腥煤矿2.rar' '血腥荒野.rar' '血色星期天.rar' 
    '血证.rar' '赤潮.rar' '赶尽杀绝.rar' '起源v1(单章节).rar' '超速感染.rar' '跨越边境.rar' '轮回墓穴v1.rar' 
    '迂回前进.rar' '连续死亡v5.rar' '逃往山丘.rar' '逃离外太空.rar' '逃离多伦多.rar' '逃离普里皮亚季.rar' 
    '逃离瓦伦西亚.rar' '逃离马拉巴v7.rar' '逃脱v1(蒸汽波风格).rar' '邪恶双眸.rar' '闪电突袭2.rar' 
    '阴暗森林v1.8(可能引起不适).rar' '阴霾降至.rar' '雪窝.rar' '音讯全无重制版.rar' '颤栗森林.rar' 
    '风暴挽歌(单章节).rar' '飞溅山之旅.rar' '马里奥探险.rar' '魔鬼山.rar' '黄金眼.rar' '黄金眼之007.rar' 
    '黎明.rar' '黑暗之塔枪手.rar' '黑暗水域v1.rar' '黑血2.rar'
    )
for file in "${file_list[@]}"
do
    if [ ! -f "$file" ]; then # 如果文件不存在
        echo "正在下载 $file"
        aria2c -x 16 -s 16 "$base_url$file"
        unrar x -o+ "$file" 
        rm "$file"
        touch "$file"
    fi
    echo "已完成 $file"
done