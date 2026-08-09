# 项目部署
丑话说在前面，这个项目主要是为我的服务器深度定制的插件，虽然如果你直接拿来用也没多大问题就是了...

教程以[Zonemod](https://github.com/PencilMario/L4D2-Competitive-Rework/tree/master/Dedicated%20Server%20Install%20Guide)基础上进行修改的

> 写教程时，Zonemod的作者Sir疑似被标记为spam，导致只能引用我自己存储库的链接

## 推荐方案：使用 l4d2_control_panel

如果你不想长期通过 SSH、`screen`、`cron` 和启动脚本维护服务器，推荐使用
[l4d2_control_panel](https://github.com/PencilMario/l4d2_control_panel)。它会把本项目的 GitHub 发布包作为插件包管理，
并通过网页完成游戏实例、插件更新、游戏控制台、玩家、日志和计划任务的管理。

下面的方案与后面的默认手工方案二选一即可。不要让两套更新脚本同时管理同一个游戏实例目录，否则更新结果可能互相覆盖。

### 环境要求

- Linux x86-64 主机。
- Debian 或 Ubuntu 可以由面板部署脚本自动安装 Docker Engine 和 Compose 插件；其他发行版请先自行安装 Docker。
- 面板默认使用 `18081` 端口，游戏端口、SourceTV 端口和插件端口请使用其他端口。
- 正式公网服应在面板前配置 HTTPS 反向代理。部署脚本不会自动配置 TLS、防火墙、DNS 或反向代理。

### 1. 安装面板

在全新的 Debian 或 Ubuntu 主机上执行：

```sh
curl -fsSL https://raw.githubusercontent.com/PencilMario/l4d2_control_panel/main/deploy.sh | sudo bash
```

部署脚本会自动安装依赖、克隆面板、生成管理员密码并启动服务。请立即保存终端输出的管理员密码。

- 默认访问地址：`http://服务器IP:18081`
- 默认安装目录：`/opt/l4d2-control-panel`
- 默认持久化数据目录：`/srv/l4d2-panel`
- 后续更新命令：`sudo /opt/l4d2-control-panel/deploy.sh`

面板默认配置中的 `L4D2_PANEL_GAME_HOST` 应保持为 `host.docker.internal`，不要改成 `127.0.0.1`，否则面板通常无法正确查询游戏实例的 A2S 状态。

### 2. 添加本项目的 GitHub 发布源

登录面板，进入“内容仓库” > “GitHub 发布源”，添加以下源：

```text
源名称：Not0721Here Coop 插件
GitHub 仓库：PencilMario/L4D2-Not0721Here-CoopSvPlugins
资源匹配规则：^L4D2-Not0721Here-CoopSvPlugins-compiled[.]zip$
```

保存后点击“检查最新”。本项目的 GitHub Actions 会在插件编译产物发生变化时创建发布版本，并上传
`L4D2-Not0721Here-CoopSvPlugins-compiled.zip`。面板会下载、校验并登记这个 ZIP，不需要手工解压到游戏目录。

如果仓库暂时没有可用的发布版本，先从仓库的 GitHub Releases 页面下载同名 `compiled.zip`，再到“内容仓库” > “插件包”上传。
不要使用 GitHub 的“Code > Download ZIP”代替发布包。

### 3. 初始化游戏本体并创建实例

1. 在“内容仓库”中初始化或更新共享游戏本体。首次安装需要 SteamCMD 下载游戏文件，请预留足够磁盘空间。
2. 进入“游戏实例”并创建实例，设置实例名称、游戏端口、启动地图、游戏模式、Tickrate、玩家上限以及 SourceTV/插件端口。
3. 在插件包选项中选择刚刚同步的 `L4D2-Not0721Here-CoopSvPlugins-compiled.zip`。
4. 创建完成后启动实例，在总览中确认 A2S、玩家数量、游戏控制台和游戏日志均可正常读取。

### 4. 设置后续更新

面板中的“GitHub 发布源”与“插件完整更新”是两个不同动作：

- **仅同步 GitHub 源**：检查最新发布版本并下载到内容仓库，不会停止或更新游戏实例。
- **GitHub Release 完整更新**：检查实例当前插件来源的最新版本；发现新版本后，根据在线玩家策略停止实例、部署插件包、重新应用私有文件，再按更新前状态启动。

可以在“计划任务”中分别安排这两类任务。完整更新可能导致玩家断线，但面板会记录后台任务和详细日志；部署或重启失败时会尝试回滚并恢复更新前状态。

## 面板方案相对默认教程的优势

| 对比项 | `l4d2_control_panel` | 默认手工教程 |
| --- | --- | --- |
| 安装方式 | 一条部署命令安装 Docker、面板和运行环境 | 手工创建用户、安装 SteamCMD、配置目录和启动脚本 |
| 日常运维 | 浏览器查看状态，操作启动、停止、重启、控制台、玩家和日志 | 主要依赖 SSH、`screen`、服务器日志和命令行 |
| 插件更新 | 按 GitHub 发布版本检查、下载、校验和登记，版本状态集中可见 | 依赖 `git pull` 和更新脚本，更新结果主要通过日志确认 |
| 更新安全性 | 支持在线玩家策略、后台任务进度、详细日志；完整更新失败时尝试回滚 | `cron` 到时直接执行，完整更新会导致服务器崩溃重启 |
| 多实例管理 | 共享游戏本体，每个实例独立配置、插件包和私有文件 | 需要自行维护实例目录、端口和多个启动进程 |
| 数据与权限 | 游戏实例以非特权用户运行，面板和实例数据持久化保存 | 需要自行规划进程权限、备份和日志保留 |

面板方案的代价是需要额外运行 Docker 和面板服务，并且当前插件发布更新以完整更新为主，可能停止实例。
如果你需要直接编辑所有文件、自己控制启动脚本，或希望继续使用默认教程中的 `update.sh` 热更新，可以使用下面的手工方案。

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