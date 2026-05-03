一个标准的 RPM Spec 文件其实就像是一份详细的“施工蓝图”，它告诉构建系统如何把源代码一步步变成最终的安装包。它主要由几个核心部分组成，每个部分都有特定的职责。

以下是 Spec 文件的标准结构解析，以及一个带有详细中文注释的通用参考示例。

### 📝 Spec 文件的标准结构解析

一个完整的 Spec 文件通常包含以下几个主要区域（按顺序排列）：

1.  **头部信息 (Preamble)**
    这是文件的开头部分，定义了软件包的基本元数据。
    - **`Name`**: 包的名称。
    - **`Version`**: 上游软件的版本号。
    - **`Release`**: 包的发布号（通常包含发行版标识，如 `fc43`）。
    - **`Summary`**: 一句话简介。
    - **`License`**: 许可证类型（如 GPL, MIT）。
    - **`URL`**: 项目主页。
    - **`Source0`**: 源码包的下载地址或文件名。
    - **`BuildRequires`**: **构建依赖**。编译这个软件需要安装哪些开发包（如 `gcc`, `make`, `glib2-devel`）。
    - **`Requires`**: **运行依赖**。安装这个软件后，运行它需要哪些库。

2.  **描述部分 (%description)**
    对软件功能的详细描述，可以写多行。

3.  **构建阶段 (Build Stages)**
    这是 Spec 文件的核心，由一系列以 `%` 开头的脚本段组成。
    - **`%prep`**: **准备阶段**。通常用于解压源码包、打补丁。
    - **`%build`**: **编译阶段**。执行 `./configure`, `make` 等命令将源码编译成二进制文件。
    - **`%install`**: **安装阶段**。将编译好的文件复制到临时的构建根目录 (`%{buildroot}`) 中，模拟安装过程。
    - **`%check`**: **检查阶段**。运行测试套件（可选）。

4.  **脚本阶段 (Scriptlets)**
    定义在安装、卸载、升级时执行的脚本。
    - **`%post`**: 安装后执行（如更新缓存、编译 schema）。
    - **`%preun`**: 卸载前执行。
    - **`%postun`**: 卸载后执行。

5.  **文件列表 (%files)**
    明确列出哪些文件应该被打包进最终的 RPM 包中。

6.  **变更日志 (%changelog)**
    记录包的修改历史。

---

### 📄 标准 Spec 文件参考示例（带详细中文注释）

你可以将以下内容作为模板，根据实际项目进行修改。

```spec
# ==============================================================================
# 1. 头部信息 (Preamble)
# ==============================================================================

# 禁用 debuginfo 包生成（对于纯脚本/无编译过程的项目，如 GNOME 扩展，通常加上这行）
%global debug_package %{nil}

# 定义宏，方便后续引用。例如 %{uuid} 代表扩展的唯一标识符
%global uuid copyous@boerdereinar.dev

Name:           gnome-shell-extension-copyous
Version:        2.0.0
# Release 通常以 1%{?dist} 开头，每次修改 spec 文件需增加数字
Release:        3%{?dist}
Summary:        Modern Clipboard Manager for GNOME

# 许可证必须与上游代码一致
License:        GPL-3.0-or-later

# 项目主页
URL:            https://github.com/boerdereinar/copyous

# 源码包地址。可以是 URL 也可以是本地文件名
# rpmbuild 会自动尝试下载这里指定的文件
Source0:        %{url}/releases/download/v%{version}/%{uuid}.zip

# ------------------------------------------------------------------------------
# 依赖关系
# ------------------------------------------------------------------------------

# BuildRequires: 编译/构建阶段需要的包
# 如果没有这些包，rpmbuild 会报错
BuildRequires:  glib2-devel
BuildRequires:  gnome-shell-devel

# Requires: 运行时必须的依赖
# 如果用户没装这些包，dnf 会自动安装它们
Requires:       gnome-shell
Requires:       glib2

# Recommends: 推荐的依赖（可选）
# 强烈建议安装，但不是绝对必须
Recommends:     libgda-sqlite

# 架构。noarch 表示不依赖 CPU 架构（纯脚本、数据文件）
BuildArch:      noarch

# ==============================================================================
# 2. 描述部分 (%description)
# ==============================================================================
%description
Copyous 是一个现代化的 GNOME 剪贴板管理器。
它允许用户保存剪贴板历史，支持搜索、收藏，并提供流畅的用户体验。
本软件包包含 GNOME Shell 扩展的核心文件。

# ==============================================================================
# 3. 构建阶段 (Build Stages)
# ==============================================================================

# ------------------------------------------------------------------------------
# %prep - 准备阶段
# 作用：解压源码，应用补丁
# ------------------------------------------------------------------------------
%prep
# %setup 是宏，相当于自动执行了 tar -xzvf 等操作
# -c: 创建目录
# -T: 不使用默认的 tar 命令（因为我们的 Source0 可能是 zip 或特殊结构）
# -a 0: 处理 Source0
%setup -c -T -a 0

# 重命名目录以符合标准规范（可选，视源码包结构而定）
mv %{uuid} %{name}-%{version}

# ------------------------------------------------------------------------------
# %build - 编译阶段
# 作用：编译源代码
# ------------------------------------------------------------------------------
%build
# 对于 GNOME 扩展（纯 JS），通常不需要编译
# 如果是 C/C++ 项目，这里通常是:
# %configure
# make %{?_smp_mflags}

# ------------------------------------------------------------------------------
# %install - 安装阶段
# 作用：将文件复制到临时目录 (%{buildroot})
# ------------------------------------------------------------------------------
%install
# 清理旧的构建目录
rm -rf %{buildroot}

# 1. 创建目标目录结构
# %{_datadir} 通常是 /usr/share
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

# 2. 复制文件
# 使用 cp -p 保留文件时间戳和权限
cp -r -p src %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
cp -r -p schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
cp -p metadata.json %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

# 3. 准备文档文件（为了在 %files 中标记为 %doc）
# 将 LICENSE 复制到当前目录，方便引用
cp -p %{name}-%{version}/LICENSE .

# ==============================================================================
# 4. 脚本阶段 (Scriptlets)
# ==============================================================================

# %post - 安装后脚本
# 用户执行 dnf install 后运行
%post
# 编译 GSettings 模式，使设置生效
# || : 表示即使出错也不要中断安装
glib-compile-schemas %{_datadir}/gnome-shell/extensions/%{uuid}/schemas/ || :

# %postun - 卸载后脚本
# $1 参数含义：0=完全卸载, 1=升级
%postun
if [ $1 -eq 0 ]; then
    # 仅在完全卸载时清理缓存
    glib-compile-schemas %{_datadir}/gnome-shell/extensions/%{uuid}/schemas/ || :
fi

# ==============================================================================
# 5. 文件列表 (%files)
# ==============================================================================
%files
# %license 标记许可证文件，RPM 策略要求必须包含
%license LICENSE

# %doc 标记文档文件
%doc README.md

# 声明扩展的主目录
# 这里使用通配符 * 包含目录下的所有内容
%{_datadir}/gnome
```



```spec
# ==============================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# Fedora Copr 仓库 https://copr.fedorainfracloud.org/coprs/architektapx/zen-browser/
# 参考文件 https://github.com/lukasgierth/fedora-packages/blob/main/tools-misc/gnome-shell-extension-copyous/gnome-shell-extension-copyous.spec
# 源代码仓库 https://github.com/stuarthayhurst/alphabetical-grid-extension
# git clone --depth=1 https://github.com/stuarthayhurst/alphabetical-grid-extension.git
# ==============================================================================

# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 禁用默认的 debuginfo 包生成，因为扩展通常不需要调试符号
%global debug_package %{nil}
# 定义扩展的 UUID，这是 GNOME Shell 识别扩展的唯一 ID
%global uuid add-to-desktop@tommimon.github.com

# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与扩展名或项目名一致。
Name:           gnome-shell-extension-add-to-desktop
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        16
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release:        1%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        An easy way to create desktop app shortcuts in GNOME
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:        GPL-3.0-or-later
# 项目主页 URL。
URL:            https://github.com/Tommimon/add-to-desktop
# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向 Release (推荐)
# 这里假设源码是以 Zip 包形式发布，且文件名包含 UUID
# 源码：zip 包（GNOME 扩展通常是纯脚本，无需编译）
# https://github.com/Tommimon/add-to-desktop/releases/download/v16/add-to-desktop@tommimon.github.com.v16.shell-extension.zip
Source0:        %{url}/releases/download/v%{version}/%{uuid}.v%{version}.shell-extension.zip

# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# --- 构建依赖 (BuildRequires) 这些是编译或打包过程中需要的工具，用户安装时不需要 ---
# 📌 规则：依赖声明行（Requires/BuildRequires/Conflicts 等）必须独占一行，不能有任何行内注释
# ⚠️ 移除不必要的编译依赖！纯 JS 扩展只需要解压+复制
BuildRequires:  unzip
# glib2-devel: 提供 glib-compile-schemas 工具。
# 这是必须的，因为我们需要在打包时或安装时编译 GSettings 的 XML 模式文件。
BuildRequires:  glib2
# gnome-shell-devel: 提供 GNOME Shell 的开发宏和头文件。
# 虽然不是所有扩展都严格需要，但加上它可以确保环境一致性。
# BuildRequires:  gnome-shell-devel
# --- 运行依赖 (Requires) 用户安装此包时必须存在的软件 ---
# 扩展要求 GNOME Shell 45+ 版本（与 extension metadata 保持一致）✅ 建议匹配扩展实际支持的最低版本
Requires:       gnome-shell >= 45
# --- 推荐依赖 (Recommends) 非强制，但强烈建议安装以获得完整功能 ---
# libgda-sqlite: Copyous 使用 SQLite 数据库存储剪贴板历史。
# 如果没有这个，扩展可能无法保存数据。使用 Recommends 而非 Requires 可以
# 避免在某些最小化安装环境中产生冲突。
# Recommends:     libgda-sqlite
# --- 架构 ---
# noarch 表示此包不包含任何与 CPU 架构相关的二进制文件（如 C 编译的程序）。
# 它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch

# ==============================================================================
# 4. 描述信息
# ==============================================================================
%description
Copyous 是一个专为 GNOME 桌面设计的现代化剪贴板管理器。
它允许用户保存复制历史，快速搜索并重新粘贴之前的内容，
极大地提升了办公效率。

# ==============================================================================
# 3. 构建阶段 (Build Stages)
# ==============================================================================
# ------------------------------------------------------------------------------
# %prep - 准备阶段
# 作用：解压源码，应用补丁
# ------------------------------------------------------------------------------
%prep
# -----------------------------------------------------------
# %autosetup 详解
# -----------------------------------------------------------
# -n myapp-1.0 : 指定解压后的目录名。
#                如果源码包解压出的目录名和 %{name}-%{version} 不一致，必须用这个参数。
#
# -p1          : 指定打补丁时的层级（strip level）。
#                通常对应 git diff 或 diff -u 生成的补丁，默认就是 -p1。
#                如果不写，它通常会尝试自动检测。
#
# 作用：
# 1. 自动解压 Source0 (myapp-1.0.tar.gz)
# 2. 自动进入解压后的目录
# 3. 自动应用 Patch0 和 Patch1
# autosetup 是 RPM 提供的现代化宏（用于替代老旧的 %setup），它的解压目标始终是 %{_builddir}/%{buildsubdir}。目录名由以下规则决定：
# %{_builddir}/%{buildsubdir} 默认展开为：
# /home/lcqh/rpmbuild/BUILD/%{name}-%{version}          # 旧版 RPM
# /home/lcqh/rpmbuild/BUILD/%{name}-%{version}-build    # Fedora 40+（启用了 %mkbuilddir）
# -----------------------------------------------------------
# ✅ 纯手动控制目录，100% 绕过 %mkbuilddir 干扰
mkdir -p "%{uuid}"
cd "%{uuid}"
unzip -q -o "%{SOURCE0}"

# ------------------------------------------------------------------------------
# %build - 编译阶段
# 作用：编译源代码
# ------------------------------------------------------------------------------
# %build
# 对于 GNOME 扩展（纯 JS），通常不需要编译，留空即可
# 如果是 C/C++ 项目，这里通常是:
# %configure
# make %{?_smp_mflags}

# ------------------------------------------------------------------------------
# %install - 安装阶段
# 作用：将文件复制到临时目录 (%{buildroot})
# ------------------------------------------------------------------------------
%install
# 1. 创建扩展安装目录
# %{_datadir} 通常是 /usr/share
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
# 2. 复制所有扩展文件（排除不需要的构建产物）
cp -r -p * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
# ✅ 如果有 schemas 目录，编译它
if [ -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas ]; then
    glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas
fi

# ==============================================================================
# 5. 文件列表 (%files)
# ==============================================================================
%files
%{_datadir}/gnome-shell/extensions/%{uuid}

%changelog
%autochangelog

# ==============================================================================
# 1. 将 spec 文件放到正确位置
# cp gnome-shell-extension-add-to-desktop.spec ~/rpmbuild/SPECS/
# 2. 进入 SPECS 目录
# cd ~/rpmbuild/SPECS/
# 🔍 检查 spec 语法
# rpmlint ~/rpmbuild/SPECS/gnome-shell-extension-add-to-desktop.spec
# 3. 下载源码到 SOURCES（spectool 会自动处理 Source0/1/2）
# spectool -g -R gnome-shell-extension-add-to-desktop.spec
# ✅ 验证源码是否下载成功
# ls -lh ~/rpmbuild/SOURCES/ | grep AlphabeticalAppGrid
# 4. 生成 SRPM（源码 RPM）
# rpmbuild -bs gnome-shell-extension-add-to-desktop.spec
# ✅ 查看生成的 SRPM
# ls -lh ~/rpmbuild/SRPMS/
# 输出示例: gnome-shell-extension-alphabetical-grid-44.0-1.fc44.src.rpm
# 5. 直接生成本地 RPM
# rpmbuild -bb gnome-shell-extension-alphabetical-grid.spec
# 或者将 .src.rpm 源码包编译成 .rpm 安装包
# rpmbuild --rebuild ~/rpmbuild/SRPMS/gnome-shell-extension-alphabetical-grid-44.0-1.fc44.src.rpm
# 生成的 RPM 位置
# ls -lh ~/rpmbuild/RPMS/noarch/
# 输出: gnome-shell-extension-alphabetical-grid-44.0-1.fc43.noarch.rpm
# 安装测试
# sudo dnf install -y ~/rpmbuild/RPMS/noarch/gnome-shell-extension-alphabetical-grid-44.0-1.fc44.noarch.rpm
# sudo dnf remove -y gnome-shell-extension-alphabetical-grid
# gnome-session-quit --logout

    # dnf list gnome-shell-extension*
    # gsettings 修改的是当前用户的 GNOME 配置，必须由 桌面用户（而非 root）执行。如果脚本通过 sudo 运行，命令会被忽略
    # gsettings list-schemas
    # gsettings list-schemas | grep 'org.gnome.shell.extensions'
    # gsettings list-recursively org.gnome.desktop.interface
    # 列出所有系统级扩展
    # gnome-extensions list --system
    # 查看所有系统级扩展的文件目录
    # nautilus admin:/usr/share/gnome-shell/extensions

# 启用扩展（需重启 GNOME Shell 或按 Alt+F2 输入 'r'）
# gnome-extensions enable AlphabeticalAppGrid@stuarthayhurst
# ==============================================================================
```

