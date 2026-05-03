当软件托管在**官方网站**而非 GitHub 时，整体架构需要微调：**Copr 仍需要一个 Git 仓库来存放 `.spec` 文件并触发构建**，但 `Source0` 将直接指向官网下载链接。版本检测逻辑也需从 GitHub API 改为网页解析或官方 RSS/JSON 接口。

以下是完整的解决方案，包含工作流适配思路、配置文件升级、以及两个带详细中文注释的 `.spec` 模板。

---
### 🌐 核心架构说明
| 环节            | GitHub 仓库方案                   | 官方网站方案                                                 |
| --------------- | --------------------------------- | ------------------------------------------------------------ |
| **代码托管**    | 源码在 GitHub，Copr 直接 clone    | 源码在官网，您的 Git 仓库**仅存放 `.spec`**                  |
| **版本检测**    | 调用 `api.github.com`             | 使用 `curl`/`python` 抓取官网页面、RSS 或下载目录            |
| **Source 下载** | GitHub Release 直链               | 官网固定 URL 模式（需包含 `%{version}` 宏）                  |
| **Copr 构建**   | `copr-cli build --url <git-repo>` | 完全相同。Copr 会 clone 您的 spec 仓库，解析 `Source0` 后从官网下载 |

---
### 📝 步骤 1：升级 `upstream_packages.yaml`
官网版本检测需要自定义解析规则，建议扩展配置格式：
```yaml
# upstream_packages.yaml
packages:
  - spec: "packages/nginx/nginx.spec"
    # 官网版本检测页（通常是一个下载列表页或 RSS）
    version_url: "https://nginx.org/download/"
    # 正则表达式：从页面中提取最新版本号（捕获组 1 为版本号）
    version_regex: 'nginx-(\d+\.\d+\.\d+)\.tar\.gz'
    # 源码包下载模板（%{version} 会被工作流替换）
    source_url: "https://nginx.org/download/nginx-%{version}.tar.gz"
    type: "source"  # source 或 rpm

  - spec: "packages/teamviewer/teamviewer.spec"
    version_url: "https://www.teamviewer.com/en/download/linux/"
    version_regex: 'teamviewer.*?(\d+\.\d+\.\d+)'
    source_url: "https://download.teamviewer.com/download/linux/teamviewer-host.x86_64.rpm"
    type: "rpm"
```

---
### 🛠️ 步骤 2：GitHub Actions 版本检测逻辑改造（核心片段）
将原工作流中的 Python 版本检查部分替换为以下通用网页抓取逻辑（需安装 `requests` 和 `re`）：
```python
import requests, re
# ... (前文读取 yaml 配置逻辑不变) ...

for pkg in config.get("packages", []):
    spec_path = pkg["spec"]
    v_url = pkg["version_url"]
    v_regex = pkg["version_regex"]
    
    # 伪装浏览器 UA，防止官网反爬拦截
    headers = {"User-Agent": "Mozilla/5.0 (Fedora Copr Builder; +https://github.com/your/repo)"}
    try:
        resp = requests.get(v_url, headers=headers, timeout=10)
        match = re.search(v_regex, resp.text, re.MULTILINE)
        if not match:
            print(f"⚠️ 未在 {v_url} 匹配到版本号 (正则: {v_regex})")
            continue
        latest_ver = match.group(1)
    except Exception as e:
        print(f"❌ 抓取 {v_url} 失败: {e}")
        continue
    # ... (后续版本比对与 spec 替换逻辑与原版完全一致) ...
```
> 💡 **提示**：许多开源项目官网提供 `latest` 重定向链接（如 `https://example.com/latest.tar.gz`）或 RSS/Atom 订阅源。优先使用这些标准接口可大幅降低解析失败率。

---
### 📦 Spec 示例一：官方提供源码压缩包（推荐）
适用于 Nginx、Vim、GCC 等传统开源项目官网。

```spec
# =================================================================
# 场景：官方网站提供源码压缩包 (.tar.gz / .zip / .tar.bz2)
# 核心逻辑：Copr 根据 Source0 宏指向官网下载源码，在 COPR 沙箱中编译
# 适配要求：官网下载链接必须支持通过版本号直接拼接，或提供固定 latest 链接
# =================================================================

Name:           example-web-source
Version:        3.14.2
Release:        1%{?dist}
Summary:        示例软件（官网源码包构建）
License:        LGPL-2.1-or-later
URL:            https://www.example.org
# 【关键】官网源码下载直链。%{version} 由工作流自动替换
# Copr 构建时会先解析此宏，再发起 HTTP 请求下载
Source0:        https://www.example.org/releases/v%{version}/example-%{version}.tar.gz
# 【安全建议】强烈建议添加校验和，防止网络劫持或文件损坏
# 手动构建时需运行：sha256sum example-3.14.2.tar.gz 并填入此处
# Source0-SHA256:  a1b2c3d4e5f6...

# 构建依赖（根据实际项目替换）
BuildRequires:  gcc, make, cmake, pkgconfig(libssl), pkgconfig(zlib)
Requires:       openssl-libs >= 1.1.1, zlib

%description
从官方网站下载源码压缩包进行编译打包。
适用于未托管在公共 Git 平台的独立项目。
Copr 构建环境会自动解析 Source0 并下载对应版本源码。

%prep
# %autosetup 自动解压源码并进入目录
# -p1 自动打同目录下的 patch（如有）
# -n 指定解压后目录名（若官网压缩包内目录名与 name-version 不一致时使用）
%autosetup -p1

# 若源码包未包含 configure 脚本，需先生成（常见于 autotools 项目）
# autoreconf -fi

%build
# CMake 构建示例（常见于 C/C++）
# %cmake 宏已自动配置 -DCMAKE_BUILD_TYPE=Release 等标准参数
%cmake
%cmake_build

# 其他构建系统参考：
# Autotools: %configure\n %make_build
# Meson:     %meson\n %meson_build
# Python:    %pyproject_build

%install
# %cmake_install 自动处理 DESTDIR，将文件安装至构建根目录
%cmake_install

# 安装完成后清理构建根目录中不需要的临时文件（按需）
# rm -rf %{buildroot}%{_datadir}/doc/example/examples

%files
# 【强制要求】声明许可证与文档路径
%license LICENSE
%doc README.md CHANGELOG.md
# 声明可执行文件、动态库、配置文件、服务文件等
%{_bindir}/example
%{_libdir}/libexample.so.*
%{_datadir}/example/
# 若有 systemd 服务，添加：
# %{_unitdir}/example.service

%changelog
* Sun Apr 19 2026 Your Name <you@example.com> - 3.14.2-1
- Update to upstream version 3.14.2
- Built from official website source archive
```

---
### 📦 Spec 示例二：官方提供预编译 RPM（仅限 Copr 个人仓库）
适用于 TeamViewer、Zoom、 proprietary 驱动等闭源/官方直发包。

```spec
# =================================================================
# 场景：官方网站提供预编译 RPM 包
# ⚠️ 政策警告：Fedora 官方源严禁重新打包二进制 RPM。
# 此模板仅适用于 Copr 个人仓库，用于内部测试或分发闭源软件。
# =================================================================

Name:           example-web-rpm
Version:        5.8.0
Release:        1%{?dist}
Summary:        示例软件（官方 RPM 二次提取打包）
License:        Proprietary
URL:            https://www.example.org
# 官网 RPM 下载直链。%{version} 由工作流替换
Source0:        https://www.example.org/download/rpm/x86_64/example-%{version}.x86_64.rpm
# 指定硬件架构（必须与上游 RPM 一致，否则 Copr 会跳过构建）
BuildArch:      x86_64
# 上游 RPM 依赖的库（需确保 Copr 目标 Fedora 版本已包含）
Requires:       glibc >= 2.31, libcurl, openssl-libs

%description
从官方网站发布的预编译 RPM 中提取文件并重新打包。
不进行任何源码编译，仅重组路径、修正权限。
仅用于 Copr 个人仓库测试，不符合 Fedora 官方打包规范。

%prep
# 二进制包无需解压源码，跳过默认 %setup
# 创建干净的构建根目录
mkdir -p %{buildroot}

%build
# 无需编译步骤

%install
# 【核心】使用 rpm2cpio + cpio 安全提取上游 RPM 内容
# --no-absolute-filenames 防止覆盖宿主系统文件
# --quiet 减少日志噪音
rpm2cpio %{SOURCE0} | (cd %{buildroot} && cpio -idm --quiet --no-absolute-filenames)

# 修正二进制文件执行权限（部分上游 RPM 权限设置不规范）
chmod 0755 %{buildroot}/usr/bin/* 2>/dev/null || true
chmod 0755 %{buildroot}/usr/lib64/*.so.* 2>/dev/null || true

# 若上游 RPM 包含 systemd 服务，需启用或链接（按需）
# mkdir -p %{buildroot}%{_unitdir}
# ln -s %{_datadir}/example/example.service %{buildroot}%{_unitdir}/

%files
# 【注意】二进制重打包必须显式声明所有文件路径
# 可使用 `rpm -qlp %{SOURCE0}` 查看上游 RPM 包含的文件列表
%license /usr/share/doc/example/LICENSE
%doc /usr/share/doc/example/README.md
/usr/bin/example
%{_libdir}/libexample_core.so.*
%{_datadir}/example/

%changelog
* Sun Apr 19 2026 Your Name <you@example.com> - 5.8.0-1
- Repackage upstream binary RPM from official website
- Adjusted file permissions and paths for Copr compatibility
```

---
### ⚠️ 关键注意事项与最佳实践

| 问题                 | 解决方案                                                     |
| -------------------- | ------------------------------------------------------------ |
| **官网反爬/封 IP**   | GitHub Actions Runner IP 可能被官网拦截。添加 `User-Agent` 请求头，或使用官网提供的 RSS/JSON API。必要时可配置 `GITHUB_TOKEN` 代理或缓存镜像。 |
| **下载链接动态变化** | 若官网 URL 包含随机哈希（如 `?token=xyz`），Copr 无法稳定下载。需寻找固定模式链接，或在 Actions 中先用 `curl -L -o` 下载并重命名为静态路径，再作为本地 Source 上传至 Copr。 |
| **校验和自动更新**   | Fedora 强制要求 `Source0-SHA256`。可在 Actions 中添加步骤：`curl -sL %{Source0} \| sha256sum \| awk '{print $1}'` 并自动写入 spec。但需注意 Copr 构建时 Source0 是重新下载的，校验和在本地验证即可。 |
| **架构限制**         | 官网 RPM 通常只提供 `x86_64`。若需在 Copr 构建 `aarch64`，需确认官网是否提供对应架构包，否则 `BuildArch: x86_64` 会导致其他架构构建直接跳过（符合预期）。 |
| **依赖缺失**         | Copr 沙箱仅包含 Fedora 官方源软件。若官网 RPM 依赖第三方私有库，需在 spec 中提供兼容包，或在 Copr 项目中 `Enable` 其他依赖仓库（如 RPM Fusion）。 |

---
### ✅ 验证流程
1. 将对应 `.spec` 放入 Git 仓库（如 `packages/example/example.spec`）
2. 更新 `upstream_packages.yaml`，填入官网 `version_url` 和 `version_regex`
3. 手动触发 GitHub Actions，观察日志是否成功提取版本号并更新 spec
4. 确认 Copr 收到构建任务后，查看 `Copr Builder` 日志：
   - `Downloading Source0...` 成功 → 官网直链可用
   - `Build failed` → 检查依赖或构建系统宏是否匹配

此方案已脱离 GitHub API 依赖，可无缝对接任意提供稳定下载链接的官方网站。若您需要针对**特定官网**（如 SourceForge、FossHub、自定义 PHP/ASP 下载页）提供精准的正则提取脚本或 Actions 适配代码，请提供目标 URL，我将为您定制解析逻辑。
