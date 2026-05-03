## 1、DNF5 仓库管理

看来你正在深入探索 DNF5 的新特性！这份帮助信息揭示了 `config-manager` 的核心架构——它不再只是简单的“增删改”，而是把操作分成了 **仓库管理** 和 **配置管理** 两个维度。

基于你提供的输出，我为你翻译并整理了这份 DNF5 `config-manager` 的完整功能指南。

---

### 📖 帮助信息翻译与核心概念

**用法：**
`dnf5 [全局选项] config-manager <命令> ...`

**描述：**
管理主配置和仓库配置、变量，并添加新仓库。

**可用命令详解：**

| 命令           | 翻译             | 功能解析                                                     |
| :------------- | :--------------- | :----------------------------------------------------------- |
| **`addrepo`**  | **添加仓库**     | 从指定的配置文件添加仓库，或使用用户选项定义一个新仓库。（这是你之前看到的） |
| **`setopt`**   | **设置选项**     | 设置配置项和仓库选项（例如：启用/禁用仓库、修改 `gpgcheck` 等）。 |
| **`unsetopt`** | **取消设置**     | 取消设置/移除配置项和仓库选项（恢复默认或移除特定设置）。    |
| **`setvar`**   | **设置变量**     | 设置 DNF 变量（例如 `$releasever`, `$basearch` 等）。        |
| **`unsetvar`** | **取消设置变量** | 取消设置/移除 DNF 变量。                                     |

---

### 🛠️ 核心功能实战整理

根据这个帮助信息，DNF5 的管理逻辑变得非常清晰，主要分为 **仓库管理** 和 **配置/变量管理**。

#### 1. 仓库管理 (添加、删除)

这是最常用的功能，对应 `addrepo`。

- **用途**：添加第三方的 `.repo` 文件，或者手动创建一个新仓库。
- **命令**：
    ```bash
    # 在 Fedora 添加或移除软件源
    # https://docs.fedoraproject.org/zh_Hans/quick-docs/adding-or-removing-software-repositories-in-fedora/#_for_fedora_41_or_later_dnf_5
    
    # 从文件添加
    sudo dnf config-manager addrepo --from-repofile=./google-chrome.repo
    sudo dnf config-manager addrepo --from-repofile=/tmp/fedora_extras.repo
    
    # DNF5 命令创建
    # 使用 sudo dnf config-manager addrepo 改写
    # 综合参考示例，可参考： 
    # ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora.repo
    # ls /etc/yum.repos.d && cat /etc/yum.repos.d/google-chrome.repo
    sudo dnf config-manager addrepo \
      --id=vscode \
      --save-filename=vscode.repo \
      --set=name="Visual Studio Code" \
      --set=baseurl="https://packages.microsoft.com/yumrepos/vscode" \
      --set=enabled=1 \
      --set=metadata_expire=7d \
      --set=type=rpm-md \
      --set=gpgcheck=1 \
      --set=gpgkey="https://packages.microsoft.com/keys/microsoft.asc" \
      --set=repo_gpgcheck=0 \
      --set=skip_if_unavailable=True \
      --overwrite
    # ls /etc/yum.repos.d && cat /etc/yum.repos.d/vscode.repo
    sudo dnf update
    sudo dnf install -y code
      
    # 显示出所有仓库
    dnf repolist --all
    # 显示出所有已启用的仓库（默认）等效 dnf repolist
    dnf repolist --enabled
    # 显示出已禁用的仓库
    dnf repolist --disabled
    
    # 删除仓库
    # 如果你知道仓库的 ID，但不确定它属于哪个 .repo，你可以执行以下命令
    grep -E “^\[.*]” /etc/yum.repos.d/*
    # 它会打印与每个 Yum 仓库关联的仓库 ID 列表。
    rm -f /etc/yum.repos.d/google-chrome.repo
    ```

#### 2. 仓库配置选项管理 (修改)

这是你之前问到的 `setopt` 所属的类别。在 DNF5 中，它被明确为一个独立的子命令。

- **用途**：修改现有仓库的属性，或者修改全局配置。
- **常见场景**：
    - **禁用/启用仓库**：
      
        ```bash
        # 显示出所有仓库
        dnf repolist --all
        # 显示出所有已启用的仓库（默认）等效 dnf repolist
        dnf repolist --enabled
        # 显示出已禁用的仓库
        dnf repolist --disabled
        
        # 禁用仓库 (对应之前的 enabled=0)
        sudo dnf config-manager setopt google-chrome.enabled=0
        
        # 启用仓库
        sudo dnf config-manager setopt google-chrome.enabled=1
        ```
    - **修改其他属性**：
      
        ```bash
        # 修改指定仓库中的属性，例如：关闭 GPG 检查
        sudo dnf config-manager setopt google-chrome.gpgcheck=0
        
        # 把某个选项恢复到配置文件中的默认状态
        sudo dnf config-manager unsetopt google-chrome.gpgcheck
        ```
    
- **`unsetopt` 的作用**：
  
    - 如果你想把某个选项恢复到配置文件中的默认状态，或者移除通过命令行设置的临时选项，可以使用它。
    - 例如：`sudo dnf config-manager unsetopt google-chrome.gpgcheck`

#### 3. 仓库变量管理

这是 DNF5 新增或强化的功能，用于管理 `$releasever` (系统版本) 或 `$basearch` (架构) 等变量。

- **用途**：自定义 DNF 在解析 URL 时使用的变量值。
- **命令**：
    ```bash
    # 设置变量
    sudo dnf config-manager setvar my_custom_var=39
    
    # 移除变量设置
    sudo dnf config-manager unsetvar my_custom_var
    ```

---

### 📌 总结：DNF5 命令速查表

结合你之前的提问和现在的帮助信息，这里是 Fedora (DNF5) 的完整操作速查

| 你的需求   | DNF5 命令                                  | 备注                   |
| :--------- | :----------------------------------------- | :--------------------- |
| **添加源** | `dnf config-manager addrepo ...`           | 支持从文件或命令行添加 |
| **禁用源** | `dnf config-manager setopt <ID>.enabled=0` | 修改配置项             |
| **启用源** | `dnf config-manager setopt <ID>.enabled=1` | 修改配置项             |



## 2、更好地驾驭 Fedora 的新包管理器 DNF5

看来你的 Fedora 已经升级到使用 **DNF5** 了！这可是个大版本更新，命令逻辑和以前（DNF4）确实有很大不同。

根据你提供的 `dnf5 config-manager addrepo --help` 输出，我为你整理了在 DNF5 环境下添加和移除软件源的完整指南。

---

### 📝 帮助信息翻译与解析

首先，把你提供的 `addrepo` 帮助信息翻译并梳理如下：

**用法：**
`dnf5 [全局选项] config-manager addrepo [选项]`

**描述：**
从指定的配置文件添加仓库，或使用用户选项定义一个新仓库。

**选项详解：**
- `--from-repofile=<文件路径>`：从指定的配置文件（通常是 `.repo` 文件）中读取并添加仓库。
- `--id=<仓库ID>`：为新创建的仓库指定一个唯一的 ID。
- `--set=<选项>=<值>`：在创建新仓库时，设置特定的配置项（例如 `--set=enabled=1`）。
- `--add-or-replace`：允许添加或替换现有配置文件中的仓库。
- `--create-missing-dir`：允许创建缺失的目录。
- `--overwrite`：允许覆盖已存在的仓库配置文件。
- `--save-filename=<文件名>`：指定保存仓库配置的 filename（如果不加后缀，会自动补全 `.repo`）。

---

### 🛠️ 如何在 DNF5 中添加软件源

在 DNF5 中，添加源主要有两种方式：一种是**从文件添加**（最常用，比如下载了 Fedora 的 `.repo` 文件），另一种是**命令行创建**。

#### 1. 从 .repo 文件添加（推荐）
如果你下载了一个第三方的 `.repo` 文件（例如 VS Code 或 Docker 的源文件），可以使用 `--from-repofile`。

```bash
# 假设你下载了一个 example.repo 文件
sudo dnf config-manager addrepo --from-repofile=./example.repo
```

#### 2. 通过命令行手动创建
如果你想手动添加一个源，可以使用 `--id` 和 `--set` 组合。

```bash
# 语法结构
sudo dnf config-manager addrepo --id=<仓库ID> --set=baseurl=<URL> --set=enabled=1 ...

# 示例：添加一个虚构的仓库
sudo dnf config-manager addrepo \
  --id=my-custom-repo \
  --set=baseurl=https://example.com/fedora/$releasever \
  --set=enabled=1 \
  --set=gpgcheck=0 \
  --save-filename=my-custom.repo
```

---

### 🗑️ 如何在 DNF5 中移除软件源

虽然你提供的帮助信息是关于 `addrepo` 的，但在 DNF5 的 `config-manager` 插件中，移除源通常使用 `rm` 命令直接删除对应的仓库文件即可。

**基本语法：**
`sudo rm -f /etc/yum.repos.d/vscode.repo`

**操作示例：**
如果你想移除之前提到的 PyCharm 仓库：

```bash
# 直接移除指定 ID 的仓库
sudo rm -f /etc/yum.repos.d//etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
```

> **注意**：`removerepo` 命令通常会自动删除对应的 `.repo` 文件。

---

### 🔄 结合你之前的脚本需求（DNF5 适配版）

既然你在使用 DNF5，之前讨论的“判断存在再删除”的脚本逻辑依然成立，但底层的命令可以简化。

**DNF5 版本的清理脚本：**

```bash
REPO_ID="copr:copr.fedorainfracloud.org:phracek:PyCharm"
REPO_FILE="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo"

# 1. 在 DNF5 中，removerepo 本身就会处理禁用和删除
# 但为了稳妥，我们可以先检查是否存在

# 2. 检查仓库是否存在
if sudo dnf repolist all 2>/dev/null | grep -q "^$REPO_ID[[:space:]]"; then
    echo "ℹ️ 检测到仓库 '$REPO_ID'，正在移除..."
    
    # 3. 先尝试禁用仓库
    # 这样做是为了防止在删除文件瞬间，如果有其他 dnf 进程在运行会报错
    # 2>/dev/null 用于屏蔽 "Error: no matching repo to disable" 的提示
    sudo dnf config-manager setopt "$REPO_ID.enabled=0" 2>/dev/null
    
    # 4、直接移除指定 ID 的仓库文件
    sudo rm -f "$REPO_FILE"
    
    echo "✅ 仓库移除操作完成。"
else
    echo "✅ 仓库 '$REPO_ID' 不存在，无需处理。"
fi
```

## 2、fedora.repo 系统标准仓库详解

**ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora.repo**

```bash
[fedora]
name=Fedora $releasever - $basearch
baseurl=https://mirrors.ustc.edu.cn/fedora/releases/$releasever/Everything/$basearch/os/
#metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch
enabled=1
countme=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
skip_if_unavailable=False
```
这是一个非常专业的 DNF 仓库配置文件（`.repo` 文件）。

首先需要指出的是，你提供的配置中存在一个**关键错误**：`type=rpm`。根据你之前的提问和标准规范，这里应该是 **`type=rpm-md`**。`rpm-md` 代表 RPM 元数据格式，这是 Fedora 官方仓库的标准格式。如果写成 `rpm`，DNF 可能无法正确识别仓库结构。

以下是该配置文件中每个元素的详细作用解析，以及如何使用 `dnf config-manager` 命令等效改写。

### 📝 配置文件元素详解

| 元素                      | 值/含义                        | 详细说明                                                     |
| :------------------------ | :----------------------------- | :----------------------------------------------------------- |
| **`[fedora]`**            | **仓库 ID**                    | 方括号内的名称是仓库的唯一标识符，必须全局唯一。             |
| **`name`**                | Fedora $releasever - $basearch | 仓库的人类可读名称。`$releasever` (版本号) 和 `$basearch` (架构，如 x86_64) 是自动替换的变量。 |
| **`baseurl`**             | 镜像站 URL                     | 指向仓库实际 RPM 包和元数据所在的 URL。你这里使用的是中科大镜像源。 |
| **`metalink`**            | 注释掉的 URL                   | 一种动态选择镜像的机制。如果配置了 `metalink`，DNF 会自动下载镜像列表并选择最快的。你这里注释掉了，使用了固定的 `baseurl`。 |
| **`enabled`**             | 1                              | 开启（1）或禁用（0）此仓库。                                 |
| **`countme`**             | 1                              | **统计用途**。开启后，每次更新元数据时会向 Fedora 统计服务器发送请求，用于统计活跃用户数，帮助 Fedora 优化镜像带宽分配。 |
| **`metadata_expire`**     | 7d                             | 元数据过期时间。`7d` 代表 7 天。DNF 会缓存元数据，超过这个时间才会重新下载。 |
| **`repo_gpgcheck`**       | 0                              | 仓库元数据（repomd.xml）的 GPG 签名校验。0 为关闭，1 为开启。官方源通常设为 0 或使用 `repo_gpgcheck`。 |
| **`type`**                | **rpm-md** (修正后)            | **注意**：你原配置写的是 `rpm`，建议改为 `rpm-md`。这是标准的 RPM 仓库元数据格式。 |
| **`gpgcheck`**            | 1                              | 开启 RPM 包的 GPG 签名校验，确保下载的软件包未被篡改。       |
| **`gpgkey`**              | 密钥路径                       | GPG 公钥的路径，用于验证软件包签名。                         |
| **`skip_if_unavailable`** | False                          | 如果仓库不可用（如网络错误、404），是否跳过。设为 `False` 会导致如果镜像源挂了，`dnf` 命令直接报错退出。 |

---

### 🛠️ 使用 `sudo dnf config-manager --add-repo` 等效改写

`dnf config-manager --add-repo` 命令通常用于从一个 URL 创建一个新的 `.repo` 文件，但它**无法一次性设置所有的高级参数**（如 `metadata_expire`, `countme`, `repo_gpgcheck` 等）。它主要用于设置基础的 `baseurl` 和仓库 ID。

#### 1. 基础命令（仅创建骨架）
你可以使用以下命令创建一个基础的 repo 文件，然后手动编辑剩余参数：

```bash
# 使用 sudo dnf config-manager addrepo 改写，上面写法的等效替代
# 综合参考示例，可参考： 
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/fedora.repo
# ls /etc/yum.repos.d && cat /etc/yum.repos.d/vscode.repo
sudo dnf config-manager addrepo \
  --id=vscode \
  --save-filename=vscode.repo \
  --set=name="Visual Studio Code" \
  --set=baseurl="https://packages.microsoft.com/yumrepos/vscode" \
  --set=enabled=1 \
  --set=enabled_metadata=1 \
  --set=metadata_expire=7d \
  --set=type=rpm-md \
  --set=gpgcheck=1 \
  --set=gpgkey="https://packages.microsoft.com/keys/microsoft.asc" \
  --set=repo_gpgcheck=0 \
  --set=skip_if_unavailable=True \
  --overwrite
```

*   **结果**：这会创建一个名为 `mirrors.ustc.edu.cn_fedora_releases_$releasever_Everything_$basearch_os_.repo` 的文件。
*   **后续操作**：你需要手动打开这个文件，修改 `[repo-id]` 为 `[fedora]`，并手动添加 `countme=1`、`metadata_expire=7d` 等缺失的行。

#### 2. 最佳实践：直接编辑文件（推荐）
由于 `dnf config-manager` 无法通过命令行参数设置所有选项，对于像 Fedora 官方源这样复杂的配置，**直接编辑 `/etc/yum.repos.d/` 目录下的 `.repo` 文件是标准且最可靠的做法**。

如果你必须通过脚本来自动化这个过程，通常会使用 `cat` 或 `tee` 命令直接写入文件，而不是使用 `add-repo`：

```bash
cat << EOF | sudo tee /etc/yum.repos.d/fedora-mirror.repo
[fedora]
name=Fedora \$releasever - \$basearch
baseurl=https://mirrors.ustc.edu.cn/fedora/releases/\$releasever/Everything/\$basearch/os/
enabled=1
countme=1
metadata_expire=7d
repo_gpgcheck=0
type=rpm-md
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch
skip_if_unavailable=False
EOF
```

### ⚠️ 关键警告：关于 `baseurl` 的 404 错误

根据你提供的网页[2]解析内容，直接访问 `https://mirrors.ustc.edu.cn/fedora/releases/$releasever/Everything/$basearch/os/` 返回了 **404 Not Found**。

这意味着：
1.  **变量未替换**：`$releasever` 和 `$basearch` 是 DNF 的变量，直接在浏览器打开会当作普通文件夹名，自然找不到。
2.  **版本过旧或过新**：中科大镜像站可能尚未同步最新的 Fedora Rawhide 版本，或者已经归档了非常旧的版本。
3.  **路径变更**：Fedora 的仓库结构在不同版本间可能有变化。

**建议**：
*   请确认你的 Fedora 版本号（`$releasever`）。
*   访问 [中科大 Fedora 镜像页](https://mirrors.ustc.edu.cn/status/fedora/) 查看支持的版本列表。
*   对于 Fedora 36+ 的版本，官方推荐的路径结构可能已经调整，通常建议使用 `metalink` 或 `mirrorlist` 而不是硬编码的 `baseurl`，以确保指向正确的镜像路径。



## 3、使用 DNF5 的命令 dnf config-manager addrepo 添加仓库

在 DNF5 中使用 `--set` 参数就像是填写一份仓库的“身份证”和“行为准则”。你可以使用所有标准的 `.repo` 文件配置项。

为了让你更清楚地了解有哪些选项可用，我整理了最常用的配置项，并将其分为**核心必填**、**安全校验**和**高级行为**三类。

### 🛠️ 常用配置项整理

#### 1. 核心必填项 (基础身份)
这些是定义一个仓库最基本的信息，通常必须设置。

| 配置项           | 作用                                                         | 示例值                                                       |
| :--------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **`baseurl`**    | **仓库地址**。告诉 DNF 去哪里下载软件包。可以是 HTTP/FTP 链接，也可以是本地文件路径 (`file://`)。 | `https://download.example.com/fedora/$releasever`            |
| **`name`**       | **仓库描述**。人类可读的名称，用于在 `dnf repolist` 中显示。 | `My Custom Repo`                                             |
| **`metalink`**   | **元链接**。类似于 baseurl，但提供一个包含多个镜像的列表，DNF 会自动选择最快的一个。 | `https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever` |
| **`mirrorlist`** | **镜像列表**。与 metalink 类似，用于指定镜像列表文件的 URL。 | `http://mirrors.example.com/list`                            |

#### 2. 安全与校验 (信任机制)
这些选项决定了 DNF 是否信任该仓库下载的软件包。

| 配置项              | 作用                                                         | 示例值                                    |
| :------------------ | :----------------------------------------------------------- | :---------------------------------------- |
| **`enabled`**       | **启用状态**。`1` 表示启用（默认），`0` 表示禁用。           | `1`                                       |
| **`gpgcheck`**      | **GPG 签名检查**。`1` 表示强制检查包的签名（推荐，更安全），`0` 表示不检查（不安全，仅用于内网或测试）。 | `1`                                       |
| **`gpgkey`**        | **公钥地址**。如果开启了 `gpgcheck`，这里指定用于验证签名的公钥 URL 或文件路径。 | `https://example.com/RPM-GPG-KEY-example` |
| **`repo_gpgcheck`** | **仓库元数据检查**。`1` 表示检查仓库元数据本身的签名，防止仓库被篡改。 | `0`                                       |

#### 3. 高级行为 (性能与策略)
这些选项用于微调 DNF 在该仓库上的行为。

| 配置项                | 作用                                                         | 示例值             |
| :-------------------- | :----------------------------------------------------------- | :----------------- |
| **`type`**            | **仓库类型**。通常为 `rpm-md`（标准 RPM 仓库），也可以是 `rpm`（旧式 flat 仓库）。 | `rpm-md`           |
| **`priority`**        | **优先级**。数字越小优先级越高。用于解决软件包冲突（需要安装 `dnf-plugins-core` 支持）。 | `99`               |
| **`includepkgs`**     | **包含列表**。只允许安装列表中指定的包，忽略其他包。         | `nginx, nginx-*`   |
| **`exclude`**         | **排除列表**。永远不从这个仓库安装列表中指定的包。           | `kernel, kernel-*` |
| **`cost`**            | **成本**。用于镜像选择，成本越低越优先。                     | `1000`             |
| **`module_hotfixes`** | **模块热修复**。允许从该仓库覆盖模块包的版本（通常用于提供比官方模块更新版本的包）。 | `1`                |

---

### 💡 综合参考示例

假设我们要手动添加一个名为 "Nginx Mainline" 的第三方仓库，并且希望强制开启 GPG 检查以确保安全。

我们可以组合使用 `--id`、`--set` 等参数。

#### 命令示例

```bash
sudo dnf config-manager addrepo \
  --id=nginx-mainline \
  --set=name="Nginx Mainline Repository" \
  --set=baseurl=https://nginx.org/packages/mainline/fedora/$releasever/$basearch \
  --set=enabled=1 \
  --set=gpgcheck=1 \
  --set=gpgkey=https://nginx.org/keys/nginx_signing.key \
  --set=type=rpm-md \
  --save-filename=nginx-mainline
```

#### 命令拆解说明

1.  **`--id=nginx-mainline`**
    *   设定仓库的唯一标识符（Repo ID）。
2.  **`--set=name="..."`**
    *   设定显示名称。
3.  **`--set=baseurl=...`**
    *   设定下载地址。注意这里使用了 `$releasever` 和 `$basearch` 变量，DNF 会自动替换为当前的系统版本和架构。
4.  **`--set=enabled=1`**
    *   明确启用该仓库。
5.  **`--set=gpgcheck=1`** 和 **`--set=gpgkey=...`**
    *   这是安全最佳实践。告诉 DNF：“只安装经过这个公钥签名的包”。
6.  **`--set=type=rpm-md`**
    *   指定仓库元数据类型，确保 DNF 能正确解析。
7.  **`--save-filename=nginx-mainline`**
    *   指定生成的配置文件名为 `nginx-mainline.repo`。如果不指定，DNF 可能会根据 ID 自动生成，或者在某些版本中行为不一致。

执行后，你可以在 `/etc/yum.repos.d/nginx-mainline.repo` 看到生成的配置，其内容等同于你手动用编辑器写出来的文件。
