以下是针对您提到的三种上游分发场景，精心编写的 **Fedora/Copr 标准 `.spec` 参考文件**。每个文件均包含详细的中文注释，严格遵循 Fedora 打包规范（Fedora Packaging Guidelines），并完全适配您前文提供的 GitHub Actions 自动版本追踪工作流。

---

### 📦 场景一：上游已发布预编译 RPM 包
> ⚠️ **政策说明**：Fedora 官方源**严格禁止**重新打包二进制 RPM（违反可重现构建与安全审计原则）。但在 **Copr 个人仓库**中可用于测试或闭源软件。此模板采用安全提取方式，避免直接安装依赖冲突。

```spec
# =================================================================
# 场景一：上游提供预编译 RPM 包（二进制重新打包）
# 适用条件：上游在 GitHub Releases 中直接提供 .x86_64.rpm 或 .noarch.rpm
# 工作流适配：Actions 会自动更新 Version 字段，Source0 将动态指向对应 RPM
# =================================================================

Name:           example-bin-repackage
Version:        1.2.3
Release:        1%{?dist}
Summary:        示例软件（上游预编译 RPM 重新打包）
License:        MIT
URL:            https://github.com/owner/example
# 使用 GitHub Releases 直链，%{version} 由工作流自动替换
Source0:        %{url}/releases/download/v%{version}/%{name}-%{version}-1.x86_64.rpm

# 架构与依赖（根据实际二进制文件调整）
BuildArch:      x86_64
Requires:       coreutils, bash, glibc

%description
此包直接从上游发布的预编译 RPM 中提取文件安装。
不执行任何编译操作，仅做路径重组与权限修正。
适用于 Copr 个人测试，不建议提交至 Fedora 官方仓库。

%prep
# 二进制包无需解压源码，跳过默认 setup
# 创建空目录供后续安装使用
mkdir -p %{buildroot}

%build
# 无需编译

%install
# 使用 rpm2cpio + cpio 安全提取上游 RPM 内容到构建根目录
# --no-absolute-filenames 防止覆盖宿主系统文件
rpm2cpio %{SOURCE0} | (cd %{buildroot} && cpio -idm --quiet --no-absolute-filenames)

# 可选：修正二进制文件权限（上游 RPM 可能未设置执行位）
chmod 0755 %{buildroot}/usr/bin/* 2>/dev/null || true

%files
# 声明安装路径（需根据实际提取内容调整）
%license LICENSE
%doc README.md
/usr/bin/%{name}
%{_datadir}/%{name}/

%changelog
* Sun Apr 19 2026 Your Name <you@example.com> - 1.2.3-1
- Initial package for Copr (repackaged from upstream binary RPM)
```

---

### 📦 场景二：上游提供源码压缩包（最常见场景）
> ✅ **推荐场景**：90% 的 GitHub 开源项目采用此方式。工作流更新 `Version` 后，`Source0` 会自动匹配对应 Tag 的 `.tar.gz`。

```spec
# =================================================================
# 场景二：上游提供源码压缩包（标准源码构建）
# 适用条件：GitHub Releases 提供 .tar.gz / .zip 源码包
# 工作流适配：Version 更新后，Source0 自动指向 v{version} 对应的归档
# =================================================================

Name:           example-source-tarball
Version:        1.2.3
Release:        1%{?dist}
Summary:        示例软件（从上游源码压缩包编译）
License:        MIT
URL:            https://github.com/owner/example
# GitHub 标准 Release 压缩包下载链接（支持 .tar.gz / .tar.bz2 / .zip）
Source0:        %{url}/archive/refs/tags/v%{version}/%{name}-%{version}.tar.gz

# 构建依赖（按项目实际工具链替换：cmake / meson / python3-devel / go 等）
BuildRequires:  gcc, cmake, make, pkgconfig(libfoo)
Requires:       libfoo >= 2.0

%description
从上游发布的源码压缩包中编译安装。
工作流每日自动检测上游新版本，并触发 Copr 重新构建。
符合 Fedora 源码构建规范，适合长期维护。

%prep
# %autosetup 自动解压源码并进入目录
# -p1 表示自动应用同目录下的 .patch 文件（如有）
# -n 指定解压后目录名，若压缩包内目录名与 name-version 不一致时使用
%autosetup -p1

%build
# 以 CMake 构建系统为例（常见 C/C++ 项目）
# 若使用 meson： %meson\n %meson_build
# 若使用 autotools： %configure\n %make_build
%cmake
%cmake_build

%install
# 将编译产物安装至构建根目录，自动处理 DESTDIR
%cmake_install

%files
# 自动归类文档与许可证（Fedora 强制要求）
%license LICENSE
%doc README.md CHANGELOG.md examples/
# 声明可执行文件、库、配置、服务等路径
%{_bindir}/%{name}
%{_libdir}/%{name}/
%{_datadir}/%{name}/

%changelog
* Sun Apr 19 2026 Your Name <you@example.com> - 1.2.3-1
- Initial package for Copr
- Built from upstream source tarball v1.2.3
```

---

### 📦 场景三：上游仅维护 Git 仓库（无 Release / 无压缩包）
> 🔍 **说明**：部分活跃开发项目不发布 Tag。此时使用 GitHub 提供的**分支快照归档**。Fedora 官方建议推动上游发版，但 Copr 个人仓库允许此方式。

```spec
# =================================================================
# 场景三：仅 Git 仓库（无 Release / 无压缩包）
# 适用条件：上游未创建任何 Tag，仅通过 main/dev 分支迭代
# 工作流适配：Version 建议使用日期或 Commit 短哈希，Actions 可自动替换
# =================================================================

Name:           example-git-snapshot
# 建议使用 日期 或 Commit 短哈希 作为版本号，避免与未来正式 Release 冲突
Version:        0.0.0.20260419
Release:        1%{?dist}
Summary:        示例软件（从 Git 分支快照构建）
License:        MIT
URL:            https://github.com/owner/example
# 使用 GitHub 提供的任意分支归档链接（生成 tar.gz）
# 注意：压缩包内目录名通常为 repo-branch/
Source0:        %{url}/archive/refs/heads/main/%{name}-%{version}.tar.gz

# 需要 git 处理子模块或版本检测脚本
BuildRequires:  gcc, make, git, autoconf
Requires:       coreutils

%description
当上游未发布任何 Release 时，直接从 main 分支生成快照构建。
适用于跟踪最新开发版或热修复。
注意：快照版本不具备语义化版本稳定性，Copr 构建可能因上游代码变更而失败。

%prep
# GitHub 分支归档解压后目录名为：example-main/
# 使用 -n 显式指定目录名，确保 %autosetup 正确进入源码树
%autosetup -n %{name}-main

# 若项目使用 git submodule，需在此初始化
# git submodule update --init --recursive

%build
# 示例：使用 Autotools 构建系统
# 若使用其他构建工具请替换对应宏
./autogen.sh 2>/dev/null || true
%configure
%make_build

%install
%make_install

%files
%license LICENSE
%doc README.md
%{_bindir}/%{name}
%{_datadir}/%{name}/

%changelog
* Sun Apr 19 2026 Your Name <you@example.com> - 0.0.0.20260419-1
- Daily snapshot build from main branch
- Tracking upstream development version
```

---

### 📊 三种场景对比与选型建议

| 维度              | 场景一（预编译 RPM）        | 场景二（源码压缩包）        | 场景三（Git 快照）          |
| ----------------- | --------------------------- | --------------------------- | --------------------------- |
| **构建方式**      | 二进制提取（不编译）        | 标准源码编译                | 分支快照编译                |
| **Fedora 合规性** | ❌ 官方源禁止，Copr 允许     | ✅ 完全符合规范              | ⚠️ 需注明快照属性            |
| **可重现性**      | 高（依赖上游 RPM）          | 极高                        | 中（代码每日变动）          |
| **工作流适配**    | `Version` 匹配 Release 标签 | `Version` 匹配 Release 标签 | `Version` 建议用日期/Commit |
| **维护成本**      | 低                          | 中（需适配构建系统）        | 高（可能频繁构建失败）      |
| **推荐用途**      | 闭源/测试软件               | 主流开源项目                | 活跃开发版/紧急修复         |

---

### 🔗 与 GitHub Actions 工作流的联动要点

1. **`Version` 字段是核心**：您的 Actions 脚本会精准替换 `^Version:\s*.*`，三个模板均将 `Version` 置于顶部，确保替换无误。
2. **`Release` 重置逻辑**：Actions 在更新版本时会将 `Release` 重置为 `1`，符合 Fedora `Version` 变更时 `Release` 归零的规范。
3. **`Source0` 宏替换**：所有模板的 `Source0` 均使用 `%{version}`，Copr 在拉取代码后会先解析 Spec 中的版本，再下载对应归档，与 Actions 逻辑完美契合。
4. **Copr 构建超时防护**：场景三若上游代码频繁变更，可能触发依赖缺失或编译错误。建议在 Copr 项目设置中开启 `Enable chroot` 失败自动重试，或配置邮件通知。

---

### 🛠️ 快速验证步骤
1. 将对应场景的 `.spec` 放入仓库（如 `packages/example/example.spec`）
2. 在 `upstream_packages.yaml` 中映射路径与上游仓库
3. 手动触发一次 GitHub Actions 工作流
4. 观察 Actions 日志 → 确认 Spec 版本更新 → 查看 Copr 构建队列是否成功接收任务

如需针对特定构建系统（如 Python `pyproject.toml`、Rust `Cargo`、Node.js、Go 模块等）提供定制化 `%build`/`%install` 段落，请告知具体技术栈，我将补充对应宏与依赖配置。
