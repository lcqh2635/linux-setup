`%setup` 和 `%autosetup` 都是 RPM 打包中用于**准备阶段（%prep）**的宏，主要作用是将源代码包解压到构建目录。

它们的核心区别在于**自动化程度**和**对补丁的处理方式**。

### 🔍 核心区别

| 特性 | %setup | %autosetup |
| :--- | :--- | :--- |
| **主要功能** | 解压源代码包。 | 解压源代码包 + **自动应用所有补丁**。 |
| **补丁处理** | 需要手动编写 `%patch` 命令来应用补丁。 | 自动识别并应用 Spec 文件中定义的所有 `Patch` 文件。 |
| **灵活性** | 高。适合需要精细控制解压顺序或应用特定补丁的场景。 | 高。支持参数（如 `-p1`, `-n`）来调整行为。 |
| **兼容性** | **极高**。几乎所有基于 RPM 的发行版（包括老旧版本）都支持。 | 较高。需要 RPM 4.11 及以上版本（Fedora, RHEL 7+, CentOS 7+ 均支持）。 |
| **代码量** | 较多（需要写 `%setup` 和多行 `%patch`）。 | 极少（通常一行搞定）。 |

### 💡 推荐使用哪一个？

**推荐使用 `%autosetup`。**

*   **理由**：它更简洁、更现代，且能自动处理补丁，减少了人为忘记打补丁的错误。
*   **例外**：如果你需要打包的软件必须在非常古老的系统（如 RHEL 6 或更早）上构建，或者你需要极其特殊的解压顺序（例如先解压 A 的一部分，再解压 B），那么才需要使用 `%setup`。

---

### 📝 详细使用示例（带中文注释）

#### 1. 使用 %autosetup (推荐)

这是现代 Fedora/RHEL 打包的标准写法。

```spec
Name:           myapp
Version:        1.0
Release:        1%{?dist}
Summary:        我的应用程序

License:        GPL
Source0:        %{name}-%{version}.tar.gz
# 定义补丁文件
Patch0:         fix-build-error.patch
Patch1:         update-icon.patch

BuildArch:      noarch

%description
这是一个使用 %autosetup 的示例。

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
# -----------------------------------------------------------
%autosetup -n myapp-1.0 -p1

%build
# 编译步骤...
%configure
make %{?_smp_mflags}

%install
# 安装步骤...
make install DESTDIR=%{buildroot}

%files
%{_bindir}/myapp
```

#### 2. 使用 %setup (传统/手动方式)

如果你需要兼容旧系统，或者需要手动控制补丁顺序。

```spec
Name:           myapp
Version:        1.0
Release:        1%{?dist}
Summary:        我的应用程序

License:        GPL
Source0:        %{name}-%{version}.tar.gz
# 定义补丁文件
Patch0:         fix-build-error.patch
Patch1:         update-icon.patch

BuildArch:      noarch

%description
这是一个使用 %setup 的示例。

%prep
# -----------------------------------------------------------
# %setup 详解
# -----------------------------------------------------------
# -q            : 安静模式 (Quiet)。减少解压时的屏幕输出，保持日志整洁。
# -n myapp-1.0  : 指定解压后的目录名。同 %autosetup。
# -----------------------------------------------------------
%setup -q -n myapp-1.0

# -----------------------------------------------------------
# %patch 详解 (必须手动写)
# -----------------------------------------------------------
# %patch0       : 应用第 0 个补丁 (即 Patch0: fix-build-error.patch)。
# -p1           : 指定补丁层级。
#
# %patch1       : 应用第 1 个补丁 (即 Patch1: update-icon.patch)。
# -p1           : 指定补丁层级。
# -----------------------------------------------------------
%patch0 -p1
%patch1 -p1

%build
# 编译步骤...
%configure
make %{?_smp_mflags}

%install
# 安装步骤...
make install DESTDIR=%{buildroot}

%files
%{_bindir}/myapp
```

### 🛠️ 常用参数速查表

| 参数 | 适用宏 | 说明 |
| :--- | :--- | :--- |
| **-n `<目录名>`** | 两者通用 | **最常用**。告诉 RPM 源码解压后的文件夹叫什么。如果源码包里是 `app-1.0/`，但你的 Name 是 `my-special-app`，你就必须用 `-n app-1.0`。 |
| **-q** | 两者通用 | 安静模式，不显示解压过程的文件列表。 |
| **-p1** | `%autosetup` | 传递给 patch 命令的参数，通常用于去除路径前缀（如 `a/file.txt` -> `file.txt`）。 |
| **-c** | 两者通用 | 在解压前创建目录（Create）。通常用于源码包解压后不是单一目录的情况。 |
| **-a `<数字>`** | `%setup` | 仅解压指定的 Source（例如 `-a 0` 解压 Source0）。 |
| **-T** | `%setup` | 禁用默认的解压操作（通常配合 `-a` 使用，用于复杂的解压顺序）。 |

**总结：** 在 Fedora 和现代 RHEL 打包中，请**优先使用 `%autosetup -n <目录名> -p1`**，这能让你的 Spec 文件更加整洁且不易出错。