# 源代码仓库 https://github.com/hermes83/compiz-alike-magic-lamp-effect
# git clone --depth=1 https://github.com/hermes83/compiz-alike-magic-lamp-effect.git


# ==============================================================================
# 1. 宏定义与全局设置
# ==============================================================================
# 禁用默认的 debuginfo 包生成，因为扩展通常不需要调试符号
%global debug_package %{nil}
# 定义扩展的 UUID，这是 GNOME Shell 识别扩展的唯一 ID
%global uuid copyous@boerdereinar.dev


# ==============================================================================
# 2. 包基本信息 (Header)
# ==============================================================================
# 包的名称。通常与扩展名或项目名一致。
Name:           gnome-shell-extension-compiz-alike-magic-lamp
# 版本号。
# 建议通过自动化工具（如 Renovate）管理，保持与 GitHub Release 同步。
Version:        1.0
# 发布版本。
# 每次修改 Spec 文件但未升级软件版本时，递增此数字。
Release:        1%{?dist}
# 简短描述。出现在软件中心的列表中。
Summary:        Modern Clipboard Manager for GNOME
# 许可证类型。必须与源码中的 LICENSE 文件一致。
License:        GPLv2+
# 项目主页 URL。
URL:            https://github.com/hermes83/compiz-alike-magic-lamp-effect
# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向 Release (推荐)
# 这里假设源码是以 Zip 包形式发布，且文件名包含 UUID
Source0:        https://github.com/hermes83/compiz-alike-magic-lamp-effect/archive/v%{version}.tar.gz
# 方式2：使用本地克隆目录打包（用于测试）
# Source0: %{name}-%{version}.tar.gz


# ==============================================================================
# 3. 依赖关系 (Build & Runtime Requirements)
# ==============================================================================
# --- 构建依赖 (BuildRequires) 这些是编译或打包过程中需要的工具，用户安装时不需要 ---
# glib2-devel: 提供 glib-compile-schemas 工具。
# 这是必须的，因为我们需要在打包时或安装时编译 GSettings 的 XML 模式文件。
BuildRequires:  glib2
# gnome-shell-devel: 提供 GNOME Shell 的开发宏和头文件。
# 虽然不是所有扩展都严格需要，但加上它可以确保环境一致性。
# BuildRequires:  gnome-shell-devel
# --- 运行依赖 (Requires) 用户安装此包时必须存在的软件 ---
# gnome-shell: 扩展运行的宿主环境。
Requires:       gnome-shell
# glib2: 运行时库，用于处理 GSettings 配置。
Requires:       glib2
# --- 推荐依赖 (Recommends) 非强制，但强烈建议安装以获得完整功能 ---
# libgda-sqlite: Copyous 使用 SQLite 数据库存储剪贴板历史。
# 如果没有这个，扩展可能无法保存数据。使用 Recommends 而非 Requires 可以
# 避免在某些最小化安装环境中产生冲突。
Recommends:     libgda-sqlite
# --- 架构 ---
# noarch 表示此包不包含任何与 CPU 架构相关的二进制文件（如 C 编译的程序）。
# 它可以在 x86_64, aarch64 等任何架构上运行。
BuildArch:      noarch


# ==============================================================================
# 4. 描述信息
# ==============================================================================
%description
This extension provides a Compiz-like magic lamp effect for window minimizing in GNOME Shell.


# ==============================================================================
# 5. 准备阶段 (%prep)
# ==============================================================================
# 准备阶段：解压源码
%prep
%autosetup

# 安装阶段：这是关键，将扩展文件复制到正确位置
%install
# 创建必要的目录
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{name}
# 复制扩展的所有文件
cp -r ./* %{buildroot}%{_datadir}/gnome-shell/extensions/%{name}/

# 清理：确保不打包 .git 等无关目录
rm -rf %{buildroot}%{_datadir}/gnome-shell/extensions/%{name}/.git

# 定义哪些文件将被打入最终的RPM包
%files
%{_datadir}/gnome-shell/extensions/%{name}/

# 更新日志（可选，但建议记录）
# 修正日期格式：将未来的日期 2026 改为过去或现在的有效日期
%changelog
* Thu Feb 06 2025 Your Name <your.email@example.com> - 1.0-1
- Initial package for Fedora Copr
