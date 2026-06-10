你遇到的这个问题非常常见。这是因为你的路由器默认开启了 **DHCP（动态主机配置协议）**，每次设备连接时，路由器会从地址池中随机分配一个可用的 IP 地址给你。

另外提醒一下，你提到的 `wld0` 应该是笔误，无线网卡的标准名称通常是 **`wlan0`**。

为了解决每次重启都要重新查 IP 的痛点，这里有 **3 种解决方案**，按**推荐程度从高到低**排列。对于手机上的 Ubuntu 环境，强烈推荐使用方法一或方法二。

---

### 方法一：在路由器端绑定 MAC 地址（🌟 最推荐，最稳定）
这是最安全、最不容易引起网络冲突的方法。原理是告诉路由器：“只要看到这个设备的 MAC 地址，就永远给它分配 `192.168.1.10`”。

**操作步骤：**
1. **获取手机的 MAC 地址**：
   在 Ubuntu 终端中输入以下命令：
   ```bash
   ip link show wlan0
   ```
   在输出结果中找到 `link/ether` 后面的那串字符（例如 `aa:bb:cc:dd:ee:ff`），这就是 MAC 地址。
2. **登录路由器管理后台**：
   在浏览器中输入路由器的管理地址（通常是 `192.168.1.1` 或 `192.168.0.1`，具体看路由器背面标签），输入管理员密码登录。
3. **找到静态 IP 分配设置**：
   不同品牌的路由器叫法不同，通常在：
    * `高级设置` -> `DHCP 服务器` -> `静态地址分配` / `IP 与 MAC 绑定` / `保留地址`
4. **添加绑定规则**：
   将你刚才查到的 MAC 地址和你想固定的 IP（如 `192.168.1.10`）填入并保存。
5. **重启手机 Ubuntu**，以后它永远都会是 `192.168.1.10`。

---

### 方法二：使用局域网域名连接（🌟 极客推荐，一劳永逸）
如果你不想折腾路由器，可以通过安装 `avahi-daemon` 服务，让你的 Ubuntu 拥有一个 `.local` 结尾的局域网域名。以后**完全不需要记 IP 地址**，直接用名字连接。

**操作步骤：**
1. **安装 Avahi 守护进程**：
   ```bash
   sudo apt update
   sudo apt install avahi-daemon
   ```
2. **启动并设置开机自启**：
   ```bash
   sudo systemctl enable --now avahi-daemon
   ```
3. **查看你的主机名**：
   输入 `hostname` 命令，假设输出是 `ubuntu`。
4. **如何连接**：
   以后在你的电脑上，无论手机 IP 怎么变，你只需要在终端或 SSH 软件（如 Xshell, PuTTY, Termius）中直接连接：
   ```bash
   ssh 用户名@ubuntu.local
   ```
   *(注：Windows 10/11、macOS 和 Linux 原生支持 `.local` 解析，非常方便。)*

---

### 方法三：在 Ubuntu 系统内配置静态 IP (Netplan)
如果你希望在系统层面强行写死 IP，可以修改 Ubuntu 的网络配置文件。**⚠️ 注意：** 如果你的 Ubuntu 是运行在 Termux (proot) 或 UserLAnd 等容器中，网络实际上是由 Android 系统接管的，此方法可能无效甚至导致断网。如果是原生刷机的 Linux 手机，则可以使用此方法。

**操作步骤：**
1. **查看当前的网络配置文件名**：
   ```bash
   ls /etc/netplan/
   ```
   （通常会看到类似 `01-network-manager-all.yaml` 或 `50-cloud-init.yaml` 的文件）
2. **备份原文件**（非常重要，防止配错断网）：
   ```bash
   sudo cp /etc/netplan/你的文件名.yaml /etc/netplan/你的文件名.yaml.bak
   ```
3. **编辑配置文件**：
   ```bash
   sudo nano /etc/netplan/你的文件名.yaml
   ```
4. **修改为以下内容**（**注意：YAML 格式对缩进要求极其严格，必须使用空格，不能用 Tab**）：
   ```yaml
   network:
     version: 2
     renderer: networkd
     wifis:
       wlan0:
         dhcp4: no
         addresses:
           - 192.168.1.10/24
         routes:
           - to: default
             via: 192.168.1.1   # 这里填写你的路由器网关 IP
         nameservers:
           addresses: [114.114.114.114, 8.8.8.8]
   ```
   *(如果你的网络是由 NetworkManager 管理的，请将 `renderer: networkd` 改为 `renderer: NetworkManager`)*
5. **应用配置**：
   ```bash
   sudo netplan apply
   ```
   如果没有报错，说明配置成功。你可以用 `ip addr show wlan0` 验证 IP 是否已变为 `192.168.1.10`。

---

### 💡 总结建议
* 如果你能登录路由器，**无脑选择【方法一】**，最省心。
* 如果你懒得查 IP，或者经常在不同路由器环境下切换，**强烈推荐【方法二】**，用 `xxx.local` 连接体验极佳。
* 【方法三】仅建议在你完全掌控该设备（非容器环境）且了解网络基础的情况下使用，且设置的静态 IP 最好避开路由器 DHCP 的自动分配范围，以防 IP 冲突。