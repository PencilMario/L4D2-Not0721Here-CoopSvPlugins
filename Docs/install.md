# 项目部署
丑话说在前面，这个项目主要是为我的服务器深度定制的插件，虽然如果你直接拿来用也没多大问题就是了...

教程以[Zonemod](https://github.com/PencilMario/L4D2-Competitive-Rework/tree/master/Dedicated%20Server%20Install%20Guide)基础上进行修改的

> 写教程时，Zonemod的作者Sir疑似被标记为spam，导致只能引用我自己存储库的链接

## 环境初始化

项目主要保证ubuntu的可行性，其他服务器系统咕咕    
初始化过程与Zonemod别无二致，这里仅仅大概复述一遍，如果你能找到Zonemod开服汉化版（或原版）对照参考，那是更好的
如果你再执行过程中与原版路径等有出入，将大概率安装失败

1. root用户

依次执行以下内容：
```
dpkg --add-architecture i386 && apt-get update && apt-get upgrade -y && apt-get install -y libc6:i386 lib32z1 screen

adduser steam
adduser steam sudo
login
```
2. steam用户
如非必要，建议用户名也别改了
```
wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
./steamcmd.sh
login anonymous
force_install_dir ./Steam/steamapps/common/l4d2coop
app_update 222860 validate
quit
```
请注意：对安装路径有硬性要求，除非你知道你在做什么

**从这里开始与Zonemod教程开始有差异，请以以下部分为主**

* 使用git clone本存储库到根目录
  
  如果失败，请尝试重试直到成功或者另寻github代理

```
cd ~
git clone https://github.com/PencilMario/L4D2-Not0721Here-CoopSvPlugins
```

* 运行更新脚本

```
cd L4D2-Not0721Here-CoopSvPlugins
bash update_full.sh
```

* 可选：设置自动更新

    * 热更新：设置计划任务，定期执行L4D2-Not0721Here-CoopSvPlugins/update.sh
    * 完整更新：L4D2-Not0721Here-CoopSvPlugins/update_full.sh
        > 完整更新会导致服务器崩溃重启

    示例代码：
    ```
    crontab -e

    添加两行
    30 * * * * bash /home/steam/L4D2-Not0721Here-CoopSvPlugins/update.sh
    0 3 * * * bash /home/steam/L4D2-Not0721Here-CoopSvPlugins/update_full.sh
    ```

**差异部分结束**

3. 设置启动脚本

就那个`/etc/init.d/srcds`，懒得打了，也许我以后还会认真整理一遍吧