通过 GitHub 仓库源代码安装 GNOME Shell 扩展比从 extensions.gnome.org 安装更复杂，因为 GitHub 仓库通常包含构建脚本、文档和源码，而不仅仅是可直接加载的扩展文件。

要实现**自动化安装 + 版本兼容性检验**，你需要编写一个 Shell 脚本，核心逻辑如下：

1.  **获取当前 GNOME Shell 版本**。
2.  **克隆/下载 GitHub 仓库**。
3.  **读取 `metadata.json`**（扩展的配置文件）。
4.  **解析 `shell-version` 字段**，判断当前版本是否支持。
5.  **如果兼容**，将扩展文件复制到正确目录并启用。
6.  **如果不兼容**，终止脚本并报错。

---

### ✅ 完整自动化脚本示例

这个脚本使用 `jq` 来处理 JSON，使用 `git` 来下载代码。

**前置依赖：**
```bash
sudo apt update
sudo apt install -y git jq gnome-shell-extensions gnome-shell-extension-manager
```

**脚本内容 (`install-github-extension.sh`)：**

```bash
#!/bin/bash

# ================= 配置区域 =================
# GitHub 仓库地址 (HTTPS)
REPO_URL="https://gitlab.gnome.org/jrahmatzadeh/just-perfection.git"
# 分支或 Tag (建议指定 Tag 以保证稳定，如 "v14.0"，留空则为默认分支)
GIT_BRANCH="" 
# ===========================================

set -e # 遇到错误立即退出

echo ">>> 开始从 GitHub 安装扩展..."

# 1. 获取当前 GNOME Shell 主版本 (例如：45.0 -> 45)
SHELL_VERSION_FULL=$(gnome-shell --version | awk '{print $3}')
SHELL_VERSION_MAJOR=$(echo "$SHELL_VERSION_FULL" | cut -d'.' -f1)
echo "检测到当前 GNOME Shell 版本：$SHELL_VERSION_FULL (主版本：$SHELL_VERSION_MAJOR)"

# 2. 克隆仓库到临时目录
TEMP_DIR=$(mktemp -d)
echo "正在克隆仓库到临时目录：$TEMP_DIR"
git clone --depth 1 ${GIT_BRANCH:+-b $GIT_BRANCH} "$REPO_URL" "$TEMP_DIR/repo"

# 3. 查找 metadata.json
# 有些仓库在根目录，有些在子目录 (如 extension/, dist/)
METADATA_FILE=$(find "$TEMP_DIR/repo" -name "metadata.json" -type f | head -n 1)

if [ -z "$METADATA_FILE" ]; then
    echo "❌ 错误：在仓库中找不到 metadata.json 文件。"
    echo "   该仓库可能不是直接的扩展源码，或者需要编译构建。"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "找到 metadata.json: $METADATA_FILE"

# 4. 解析 UUID 和 支持的 Shell 版本
EXT_UUID=$(jq -r '.uuid' "$METADATA_FILE")
# 获取 shell-version 数组，例如 ["45", "46"]
SUPPORTED_VERSIONS=$(jq -r '.["shell-version"][]' "$METADATA_FILE")

if [ -z "$EXT_UUID" ]; then
    echo "❌ 错误：metadata.json 中缺少 uuid 字段。"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "扩展 UUID: $EXT_UUID"
echo "支持的 Shell 版本：$(echo $SUPPORTED_VERSIONS | tr '\n' ' ')"

# 5. 版本兼容性检查
IS_COMPATIBLE=false
for ver in $SUPPORTED_VERSIONS; do
    # 处理版本号可能带不带引号的情况，jq 已经处理了
    if [ "$ver" == "$SHELL_VERSION_MAJOR" ]; then
        IS_COMPATIBLE=true
        break
    fi
done

if [ "$IS_COMPATIBLE" == false ]; then
    echo "❌ 兼容性检查失败！"
    echo "   当前版本：$SHELL_VERSION_MAJOR"
    echo "   支持版本：$SUPPORTED_VERSIONS"
    echo "   强制安装可能导致 GNOME Shell 崩溃或扩展无法加载。"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "✅ 版本兼容性检查通过。"

# 6. 安装扩展
# 目标目录：~/.local/share/gnome-shell/extensions/<UUID>
TARGET_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

echo "正在安装到：$TARGET_DIR"
mkdir -p "$TARGET_DIR"

# 复制文件 (排除 .git 目录)
# 注意：有些 GitHub 仓库需要编译 (npm/make)，直接复制源码可能无法运行。
# 这里假设仓库根目录或 metadata.json 所在目录即为可扩展目录。
EXT_SOURCE_DIR=$(dirname "$METADATA_FILE")
cp -r "$EXT_SOURCE_DIR"/* "$TARGET_DIR/"

# 7. 启用扩展
echo "正在启用扩展..."
gnome-extensions enable "$EXT_UUID"

# 8. 清理
rm -rf "$TEMP_DIR"

echo ">>> 安装完成！"
echo "⚠️  注意："
echo "   1. 如果是 Wayland 会话，请注销并重新登录以生效。"
echo "   2. 如果是 X11 会话，按 Alt+F2 输入 'r' 重启 Shell。"
```

---

### 🔍 脚本关键点解析

#### 1. 版本提取逻辑
GNOME Shell 的版本号通常是 `45.0`, `46.1` 等。扩展的 `metadata.json` 中通常只写主版本 `45`, `46`。
*   **脚本做法**：使用 `cut -d'.' -f1` 提取主版本号进行比对。
*   **为什么重要**：GNOME Shell 的 API 在主版本之间（如 45 到 46）经常发生破坏性变更，小版本（45.0 到 45.1）通常兼容。

#### 2. `metadata.json` 的定位
GitHub 仓库结构不统一。
*   **情况 A**：`metadata.json` 在仓库根目录（大多数简单扩展）。
*   **情况 B**：`metadata.json` 在 `extension/` 或 `dist/` 子目录（如 Just Perfection 有时需要构建）。
*   **脚本做法**：使用 `find ... -name "metadata.json"` 自动定位，增加鲁棒性。

#### 3. 源码 vs. 构建产物
**这是一个巨大的坑。**
*   很多高级扩展（如 Just Perfection, Dash to Dock）的 GitHub 仓库是**源码**，需要运行 `npm install` 和 `npm run build` 才能生成可用的扩展文件。
*   **脚本假设**：上面的脚本假设仓库下载后**直接可用**（即无需编译）。
*   **如果遇到需要编译的扩展**：你需要在脚本第 6 步之前加入构建逻辑（检测 `package.json` 或 `Makefile`）。

---

### 🚀 更优方案：下载 GitHub Release 的 ZIP 包

对于自动化来说，**下载 Release 页面提供的预编译 ZIP 包** 比 克隆源码 更稳定，因为：
1.  不需要安装 `nodejs`, `npm` 等构建依赖。
2.  Release 包通常已经整理好目录结构。
3.  Release 通常对应稳定的版本。

**修改脚本逻辑以支持 Release 下载：**

```bash
# 替换脚本中的“克隆仓库”部分

# 1. 通过 GitHub API 获取最新 Release 的 zip 下载链接
# 假设仓库是 just-perfection/just-perfection
REPO_OWNER="just-perfection"
REPO_NAME="just-perfection"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"

# 获取 zipball_url
ZIP_URL=$(curl -s "$API_URL" | jq -r '.zipball_url')

if [ -z "$ZIP_URL" ] || [ "$ZIP_URL" == "null" ]; then
    echo "❌ 无法获取 Release 下载链接"
    exit 1
fi

# 2. 下载并解压
wget -O "$TEMP_DIR/extension.zip" "$ZIP_URL"
unzip -q "$TEMP_DIR/extension.zip" -d "$TEMP_DIR/unzipped"

# 3. 查找解压后的目录 (GitHub zip 解压后通常带一层目录名)
REPO_DIR=$(find "$TEMP_DIR/unzipped" -maxdepth 1 -type d | tail -n 1)
# 将 METADATA_FILE 指向这个新目录
METADATA_FILE=$(find "$REPO_DIR" -name "metadata.json" -type f | head -n 1)
```

### ⚠️ 常见问题与处理

1.  **权限问题**：
    *   确保脚本有执行权限：`chmod +x install-github-extension.sh`。
    *   目标目录 `~/.local/share/gnome-shell/extensions/` 必须属于当前用户。

2.  **Wayland 限制**：
    *   在 Wayland 下，安装扩展后**必须注销重登**才能生效，`gdbus` 重启 Shell 的方法在 Wayland 下无效。脚本中应做提示。

3.  **依赖缺失**：
    *   如果扩展依赖特定的 GSettings schema，直接复制文件可能不够。通常 `gnome-extensions install` 会处理 schema 编译，但手动复制时，如果扩展包含 `schemas/` 目录，需要运行：
        ```bash
        glib-compile-schemas "$TARGET_DIR/schemas/"
        ```

4.  **强制安装（不推荐）**：
    *   如果版本检查不通过但你非要安装（例如 46 版扩展在 45 上跑），可以修改 `metadata.json` 中的 `shell-version` 数组。
    *   **脚本修改**：在检查失败后，使用 `jq` 修改 `$METADATA_FILE`，添加当前版本号，然后再继续安装。但这极易导致 Shell 崩溃。

### 总结

*   **最稳妥**：下载 GitHub **Release ZIP** -> 校验 `metadata.json` -> 解压到扩展目录。
*   **最灵活**：克隆源码 -> 校验版本 -> (可选：执行构建) -> 复制到扩展目录。
*   **核心命令**：`jq` 是处理 `metadata.json` 版本校验的神器，必不可少。
*   **安全底线**：务必在脚本中保留版本检查逻辑，不要为了自动化而忽略兼容性，否则可能导致 GNOME 桌面无法启动（进入登录循环）。