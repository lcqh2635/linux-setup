# git clone https://github.com/hermes83/compiz-alike-magic-lamp-effect.git
# cd compiz-alike-magic-lamp-effect


# 定义软件包名、版本、发布号。版本号可从仓库的 metadata.json 或 Tag 中获取
Name:    gnome-shell-extension-compiz-alike-magic-lamp
Version: 1.0
Release: 1%{?dist}
Summary: A Compiz-like magic lamp effect for GNOME Shell

# 许可证和项目主页，请根据仓库信息填写
License: GPLv2+
URL:     https://github.com/hermes83/compiz-alike-magic-lamp-effect

# 源代码压缩包。可以指向 GitHub 的 Release 或直接使用克隆的源码
# 方式1：指向Release (推荐)
Source0: https://github.com/hermes83/compiz-alike-magic-lamp-effect/archive/v%{version}.tar.gz
# 方式2：使用本地克隆目录打包（用于测试）
# Source0: %{name}-%{version}.tar.gz

# 描述
%description
This extension provides a Compiz-like magic lamp effect for window minimizing in GNOME Shell.

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
%changelog
* Mon Feb 07 2026 Your Name <your.email@example.com> - 1.0-1
- Initial package for Fedora Copr
