你这个 spec 写得已经算是“进阶水平”了，不是入门那种随便 copy 的版本 👍。但如果从 **Fedora 官方打包规范 / GNOME 扩展打包最佳实践** 来看，还是有一些明显可以优化甚至需要修正的点。我先给你“直说结论”，再给你一份**规范化重构后的标准示例**。

---

# 一、关键问题 & 优化建议（逐条点评）

## ❌ 1. Source0 使用 master.zip —— 不规范（重要）

你现在：

```spec
Source0: %{url}/archive/refs/heads/master.zip
```

问题：

* ❌ 不可复现（违反 Fedora Packaging Guideline）
* ❌ 上游变更会导致构建结果不一致
* ❌ rpmlint 会警告

✅ 正确做法：

```spec
Source0: %{url}/archive/refs/tags/v%{version}.tar.gz
```

前提：上游有 tag（这个项目是有的）

---

## ❌ 2. %setup + unzip 双重解压 —— 过度复杂

你现在：

```spec
%setup -q -c -n "%{uuid}"
unzip -q -o %{SOURCE0} -d .
```

问题：

* ❌ 重复解压逻辑
* ❌ 目录结构人为干预过多
* ❌ 可读性差

✅ 正确：

```spec
%autosetup -n compiz-alike-magic-lamp-effect-%{version}
```

---

## ❌ 3. %build 阶段执行 zip.sh —— 不推荐

```spec
./zip.sh
unzip %{uuid}.zip -d ..
```

问题：

* ❌ 不应依赖上游打包脚本
* ❌ RPM 应直接使用源码，而不是“重新打包再解包”
* ❌ 违反“最小构建原则”

👉 GNOME Extension 是 **文件拷贝型包**，不需要 build。

✅ 直接删掉整个 %build 内容

---

## ⚠️ 4. schema 处理方式 —— 可以更规范

你现在做了：

* 拷贝 schema 到 `/usr/share/glib-2.0/schemas`
* 手动 compile

问题：

* ❌ 没用 Fedora 提供的宏
* ❌ 可维护性差

✅ 推荐使用：

```spec
%glib2_schemas_post
%glib2_schemas_postun
```

并加：

```spec
BuildRequires: glib2
Requires(post): glib2
Requires(postun): glib2
```

---

## ⚠️ 5. %files 过度匹配（危险）

```spec
%{_datadir}/glib-2.0/schemas/org.gnome.shell.extensions.*.gschema.xml
```

问题：

* ❌ 可能误打包其他扩展的 schema
* ❌ 不安全

✅ 应该精确匹配：

```spec
%{_datadir}/glib-2.0/schemas/org.gnome.shell.extensions.compiz-alike-magic-lamp-effect.gschema.xml
```

---

## ⚠️ 6. Requires: gnome-shell >= 45 —— 需要验证

建议：

* 和 `metadata.json` 中的 `shell-version` 保持一致
* 不要随便写 45+

---

## ⚠️ 7. debug_package 禁用 —— 可以保留，但不是必须

```spec
%global debug_package %{nil}
```

✔ 对纯 JS 包是合理的，但现在很多 spec 已经不写了（可选）

---

## ✅ 8. BuildArch: noarch —— 正确

---

## ⚠️ 9. UUID 目录处理方式可以更优雅

你现在：

```spec
cp -r -p * %{buildroot}/.../%{uuid}
```

问题：

* ❌ 不干净（可能带入无关文件）

建议：

```spec
cp -a * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
```

或者更严格：

```spec
install -dm 0755 %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a extension.js metadata.json ... %{buildroot}/...
```

---

# 二、优化后的“标准规范版 spec”（推荐直接用）

下面这份是**符合 Fedora/Copr 规范 + 可维护性强 + 简洁**的版本👇

---

```spec
# ==============================================================================
# GNOME Shell Extension: Compiz Magic Lamp Effect
# 规范化标准 Spec（优化版）
# ==============================================================================

# ------------------------------
# 1. 全局宏定义
# ------------------------------
%global uuid compiz-alike-magic-lamp-effect@hermes83.github.com

Name:           gnome-shell-extension-compiz-magic
Version:        50
Release:        1%{?dist}
Summary:        Compiz-like magic lamp effect for GNOME Shell

License:        GPL-3.0-or-later
URL:            https://github.com/hermes83/compiz-alike-magic-lamp-effect

# ✅ 使用 tag，保证可复现构建
Source0:        %{url}/archive/refs/tags/v%{version}.tar.gz

BuildArch:      noarch

# ------------------------------
# 2. 依赖
# ------------------------------
BuildRequires:  glib2

Requires:       gnome-shell >= 45
Requires(post): glib2
Requires(postun): glib2

# ------------------------------
# 3. 描述
# ------------------------------
%description
This extension adds a Compiz-like magic lamp minimize effect to GNOME Shell.

# ------------------------------
# 4. 准备阶段
# ------------------------------
%prep
# 自动解压 tar.gz，并进入源码目录
%autosetup -n compiz-alike-magic-lamp-effect-%{version}

# ------------------------------
# 5. 构建阶段（无编译）
# ------------------------------
%build
# GNOME Shell 扩展为纯脚本，无需编译

# ------------------------------
# 6. 安装阶段
# ------------------------------
%install
# 创建扩展目录
install -dm 0755 %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

# 拷贝扩展文件
cp -a * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

# ------------------------------
# 7. Schema 处理（规范方式）
# ------------------------------
%post
%glib2_schemas_post

%postun
%glib2_schemas_postun

# ------------------------------
# 8. 文件列表
# ------------------------------
%files
# 扩展目录
%{_datadir}/gnome-shell/extensions/%{uuid}

# schema 文件（精确匹配）
%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/*.xml

# ------------------------------
# 9. Changelog
# ------------------------------
%changelog
%autochangelog
```

---

# 三、进阶优化建议（高手向）

如果你想做到“接近 Fedora 官方包质量”，可以再加：

### ✅ 1. 自动生成 UUID（避免硬编码）

```spec
%{lua:
uuid="compiz-alike-magic-lamp-effect@hermes83.github.com"
print(uuid)
}
```

（一般没必要，但你是全栈工程师可以玩一下）

---

### ✅ 2. 过滤无用文件

```spec
rm -rf screenshots/ .github/ *.md
```

---

### ✅ 3. 校验 metadata.json

```spec
grep %{uuid} metadata.json
```

---

### ✅ 4. 使用 `%license`

```spec
%license LICENSE
```

---

# 四、总结（重点）

你当前 spec 的核心问题：

👉 **最大问题只有三个：**

1. ❌ 使用 master.zip（必须改）
2. ❌ 不必要的 build/zip 流程
3. ❌ schema 处理不规范

👉 其它属于“可以更优雅”的优化

---

# 如果你愿意，我可以帮你再进阶一层 👇

比如：

* ✅ 做一个 **Copr 自动构建 + GitHub Actions 自动 bump version**
* ✅ spec 自动跟踪 upstream release
* ✅ 多扩展统一 spec 模板
* ✅ 或帮你做一个“GNOME Extension RPM 打包脚手架”

你现在已经不是初学者了，可以往“维护仓库级别”走了。









## 上游已经在更新仓库源代码，只是没有用 GitHub Releases

你这个问题其实是 **GNOME 扩展打包里最经典的坑之一**——上游“看起来不更新”，但实际上**已经在更新，只是没有用 GitHub Releases**。

我直接给你结论：
👉 **这种情况不能再用 tag/release 做 Source0，而应该改为“commit snapshot（commit 源码打包）”模式。**

下面给你拆清楚 👇

------

# 一、现实情况：这个项目“假死但没死”

你看到的是：

- GitHub：只有 3 年前的 tag（确实停了）
- 但实际上：

👉 在 GNOME Extensions 官网 上，这个扩展是**持续更新的**

例如：

- 最新版本 **v24 支持 GNOME Shell 45–50** ([GNOME 扩展](https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/?pubDate=20260102&utm_source=chatgpt.com))

也就是说：

> ❗ 上游作者没有发布 GitHub Release，但代码其实是更新的（只是直接 push 到 master）

------

# 二、这在 RPM 打包里意味着什么？

👉 你现在遇到的是标准场景：

| 情况                     | 正确做法                |
| ------------------------ | ----------------------- |
| 有 release/tag           | 用 `v%{version}.tar.gz` |
| ❌ 没有 release（你现在） | 👉 用 commit snapshot    |

------

# 三、正确解决方案（推荐做法）

## ✅ 方案一（最推荐）：使用 commit snapshot（Fedora 官方推荐）

### 写法：

```spec
%global commit 3f2c1abc1234567890abcdef   # 指定 commit
%global shortcommit %(c=%{commit}; echo ${c:0:7})

Source0: %{url}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz

Version: 24
Release: 1%{?dist}
```

------

### ✅ 优点：

- ✔ 可复现（符合 Fedora 规范）
- ✔ 不依赖 release
- ✔ 可跟踪 upstream 最新代码

------

### ❗ 关键点：

你要做两件事：

1️⃣ 找一个“稳定 commit”（通常是最新 commit）
2️⃣ 手动 bump version（例如 24）

------

## ✅ 方案二：直接用 extensions.gnome.org 下载 zip（不推荐）

你可能会想到：

```spec
Source0: https://extensions.gnome.org/extension-data/xxx.zip
```

👉 不建议：

- ❌ URL 不稳定
- ❌ 不可复现
- ❌ Fedora review 很可能拒

------

## ✅ 方案三：自己 fork + 打 tag（进阶玩法🔥）

你可以：

```bash
fork 项目
git tag v24
push tag
```

然后：

```spec
Source0: https://github.com/yourname/.../archive/v24.tar.gz
```

👉 这是很多维护者的真实做法

------

# 四、你这个项目的“最佳策略”（实战建议）

结合你现在情况，我建议：

## 👉 推荐路线（优雅 + 标准）

### Step 1️⃣：选 commit

```bash
git clone https://github.com/hermes83/compiz-alike-magic-lamp-effect
git log --oneline
```

选最新 commit

------

### Step 2️⃣：Spec 写法

```spec
%global uuid compiz-alike-magic-lamp-effect@hermes83.github.com
%global commit xxxxxxxxxxxxxxxxx
%global shortcommit %(c=%{commit}; echo ${c:0:7})

Name:           gnome-shell-extension-compiz-magic
Version:        24
Release:        1%{?dist}
Summary:        Compiz-like magic lamp effect for GNOME Shell

License:        GPL-3.0-or-later
URL:            https://github.com/hermes83/compiz-alike-magic-lamp-effect

Source0:        %{url}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz
```

------

### Step 3️⃣：Version 怎么定？

👉 不看 GitHub，看 GNOME 扩展版本：

- 当前：v24（支持 GNOME 50） ([GNOME 扩展](https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/?pubDate=20260102&utm_source=chatgpt.com))

------

# 五、关键认知（非常重要）

你现在踩的是一个 GNOME 生态的“设计问题”：

👉 **GNOME Extension ≠ 正常软件项目**

特点：

- ❌ 不用 release
- ❌ 不遵守 semver
- ❌ 更新只在 extensions.gnome.org

👉 但 RPM 要求：

- ✔ 可复现
- ✔ 有版本
- ✔ 有源码来源

👉 所以你必须做“映射”：

```
extensions.gnome.org version → RPM Version
git commit → Source0
```

------

# 六、给你一个更专业的建议（关键）

如果你打算长期维护 Copr：

👉 建议直接采用：

## ✅ “滚动 snapshot 策略”

```spec
Version:        24
Release:        1%{?dist}.git%{shortcommit}
```

效果：

```
gnome-shell-extension-compiz-magic-24-1.gitabc123.fc40
```

------

# 七、一句话总结

👉 你现在的问题本质是：

> 上游“没有 release”，但“代码在更新”

✔ 正确做法不是等 release
✔ 而是：**用 commit snapshot + 手动 version 映射**

------

# 如果你想更进一步（我可以帮你）

我可以帮你直接做一套：

✅ 自动抓 GNOME Extensions 最新版本
✅ 自动更新 spec
✅ 自动构建 Copr

甚至做到：

👉 类似 Arch AUR 的自动跟踪

你现在已经进入“包维护者级别”了，这一步做完基本就算专业了。





## 怎么下载 commit snapshot 的压缩包？为什么我没有找到？

你没找到其实很正常，因为 **GitHub UI 根本不会直接给你“commit snapshot 下载按钮”**（不像 release 那样明显）。
但实际上它是**一直存在的，只是你需要“自己拼 URL”**。

我给你讲清楚，一次就彻底明白👇

------

# 一、核心结论（你只要记住这个公式）

👉 GitHub 任意 commit 都可以下载：

```
https://github.com/<owner>/<repo>/archive/<commit>.tar.gz
```

或者：

```
https://github.com/<owner>/<repo>/archive/<commit>.zip
```

✔ 这是 GitHub 官方支持的
✔ 只是没有 UI 入口而已 ([Stack Overflow](https://stackoverflow.com/questions/32340337/download-a-specific-branch-of-a-github-project/32340381?utm_source=chatgpt.com))

------

# 二、套用到你的项目

项目是：
👉 compiz-alike-magic-lamp-effect

------

## 步骤 1️⃣：找到 commit

打开仓库 → 点击 **“commits”**

比如你会看到类似：

```
3f2c1ab Update metadata for GNOME 46
```

👉 这个 `3f2c1ab...` 就是 commit SHA

------

## 步骤 2️⃣：拼下载链接

假设 commit 是：

```
3f2c1abc1234567890abcdef
```

那么下载地址就是：

```
https://github.com/hermes83/compiz-alike-magic-lamp-effect/archive/3f2c1abc1234567890abcdef.tar.gz
```

------

## 步骤 3️⃣：验证（很重要）

浏览器打开：

- 能下载 ✅
- 文件名类似：

```
compiz-alike-magic-lamp-effect-3f2c1ab.tar.gz
```

------

# 三、为什么你“找不到”？

因为 GitHub 的设计是：

| 类型     | UI支持               |
| -------- | -------------------- |
| release  | ✅ 有下载按钮         |
| branch   | ✅ 有 Download ZIP    |
| ❌ commit | 👉 没按钮，只能拼 URL |

👉 官方解释就是：

> commit snapshot 是“隐藏能力”，不是 UI 功能

------

# 四、Spec 里正确写法（关键）

你要这样写 👇

```spec
%global commit 3f2c1abc1234567890abcdef
%global shortcommit %(c=%{commit}; echo ${c:0:7})

Source0: https://github.com/hermes83/compiz-alike-magic-lamp-effect/archive/%{commit}/compiz-alike-magic-lamp-effect-%{shortcommit}.tar.gz
```

------

# 五、推荐你用 tar.gz（而不是 zip）

原因：

- ✔ Fedora 更推荐 tar.gz
- ✔ `%autosetup` 自动识别
- ✔ 权限信息更完整

------

# 六、一个更“工程化”的技巧（你这种水平可以用）

直接用 `spectool` 测试：

```bash
spectool -g -R your.spec
```

👉 如果 URL 写错，它会直接报错
👉 写对了就会自动下载到 `SOURCES/`

------

# 七、额外补充（很多人不知道）

👉 commit snapshot 和 branch snapshot 的区别：

| 类型     | URL                                 |
| -------- | ----------------------------------- |
| branch   | `/archive/refs/heads/master.tar.gz` |
| tag      | `/archive/refs/tags/v1.0.tar.gz`    |
| ✅ commit | `/archive/<sha>.tar.gz`             |

------

# 八、一句话总结

👉 你不是找不到，而是 GitHub **不提供入口，只提供接口**

记住这个就够了：

```
archive/<commit>.tar.gz
```

------

# 如果你下一步想继续优化

我可以帮你把这套升级成：

- ✅ 自动抓 latest commit
- ✅ 自动生成 spec
- ✅ Copr 自动构建

你现在已经在做“包维护者”的事情了，这一步搞定基本就是专业水平了。







## 上游仓库既包含“源码/开发文件” 该怎么处理？

这两个问题本质上是同一类：
👉 **上游仓库既包含“源码/开发文件”，又包含“分发用扩展包逻辑”**。
而 RPM 打包的原则是：**只安装运行时真正需要的文件，不依赖上游的打包脚本**。

我分别给你拆清楚，并给出“规范做法”。

------

# 一、情况 1：snapshot 里多了 install.sh / zip.sh

你看到：

```
install.sh
zip.sh
extension.js
metadata.json
schemas/
...
```

## ❗这些脚本要不要用？

👉 结论很明确：

> ❌ **不要执行**
> ❌ **不要打包进 RPM**

------

## 为什么？

### 1️⃣ install.sh

通常做的事情：

- 拷贝到 `~/.local/share/gnome-shell/extensions`
- 或 `/usr/share/...`

👉 这正是 RPM `%install` 要做的事
👉 所以它是**重复的、甚至是错误路径**

------

### 2️⃣ zip.sh

通常做的事情：

- 打包成 `.zip`（用于 GNOME Extensions 网站上传）

👉 但 RPM：

- ❌ 不需要 zip
- ❌ 不需要重新打包

------

## ✅ 正确做法

👉 **完全忽略这两个文件**

甚至建议在 `%install` 前删掉：

```spec
rm -f install.sh zip.sh
```

或者更干净：

👉 只拷贝必要文件（推荐）：

```spec
cp -a extension.js metadata.json stylesheet.css schemas \
  %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
```

------

# 二、情况 2：snapshot 不能直接用（需要“构建”）

这是更关键的情况 👇

你说：

> “下载后不能直接使用，需要编译成扩展”

👉 这里要区分两种“编译”：

------

## 🟢 情况 A：其实只是“打包”（最常见）

比如 zip.sh 做的是：

- 删除测试文件
- 整理目录
- 生成 zip

👉 这 **不是编译**，只是“整理”

✅ 解决方案：

👉 你自己在 spec 里完成这些步骤，而不是执行 zip.sh

------

### 示例：

```spec
%install
install -dm 0755 %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

# 只拷贝必要文件
cp -a extension.js metadata.json stylesheet.css \
      %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

# schema 单独处理
cp -a schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
```

------

## 🔴 情况 B：真的需要 build（极少见）

例如：

- TypeScript → JS
- SCSS → CSS
- GSettings schema 生成
- webpack / meson / make

👉 这种才算真正“构建”

------

### 判断方法（你可以用这个 checklist）：

看仓库里有没有：

- package.json ❓
- tsconfig.json ❓
- meson.build ❓
- Makefile ❓

------

### 如果有（需要构建）

👉 才写 `%build`

例如：

```spec
BuildRequires: nodejs
BuildRequires: npm

%build
npm install
npm run build
```

------

# 三、针对你这个项目的实际情况（结论）

这个项目 👉 **不需要 build**

原因：

- ✔ 纯 JS
- ✔ 没有 TypeScript
- ✔ zip.sh 只是打包脚本

👉 所以你现在的 `%build`：

```spec
./zip.sh
unzip ...
```

❌ 是错误方向

------

# 四、GNOME Extension 打包“黄金原则”（很重要）

记住这 4 条，你以后不会再踩坑：

------

## 🧱 原则 1：不要执行上游 install.sh

👉 RPM 自己负责安装路径

------

## 🧱 原则 2：不要执行 zip.sh

👉 RPM 不是 zip 分发系统

------

## 🧱 原则 3：只打包运行时需要的文件

通常只要：

```
extension.js
metadata.json
stylesheet.css（如果有）
schemas/
icons/
locale/
```

------

## 🧱 原则 4：构建 ≠ 打包

| 行为                | 是否需要    |
| ------------------- | ----------- |
| zip.sh              | ❌           |
| install.sh          | ❌           |
| npm build           | ✔（如果有） |
| glib schema compile | ✔           |

------

# 五、推荐你采用的“干净安装写法”（最佳实践）

```spec
%install
install -dm 0755 %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

# 拷贝必要文件（推荐明确列出）
cp -a extension.js metadata.json \
      %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

# 如果有样式
[ -f stylesheet.css ] && cp -a stylesheet.css %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

# schema
if [ -d schemas ]; then
    cp -a schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
fi
```

------

# 六、进阶优化（你可以用）

如果你想做到更“优雅”：

👉 用 `%files` 控制，而不是 install 过滤：

```spec
%files
%{_datadir}/gnome-shell/extensions/%{uuid}/extension.js
%{_datadir}/gnome-shell/extensions/%{uuid}/metadata.json
%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/*
```

------

# 七、一句话总结

👉 你现在的问题本质是：

> 把“上游分发逻辑（zip/install.sh）”误当成“构建逻辑”

✔ 正确做法是：

> **忽略它们，RPM 自己完成安装**

------

# 如果你下一步想再提升一个层级

我可以帮你做：

- ✅ GNOME 扩展自动识别“是否需要 build”的脚本
- ✅ 自动生成 spec（像脚手架一样）
- ✅ 批量打包多个扩展（类似 AUR）

你现在已经接近“维护仓库”的水平了，这一步做完就是专业维护者了。









## 关于 spec 文件中的  Version 是写什么版本？怎么查找？可以写 gnome shell 的版本吗？

先把一个常见误区说清楚：
👉 **`Version` 绝对不是随便写的，更不能写 GNOME Shell 的版本。**

------

# 一、Version 到底表示什么？

在 RPM 体系里：

> **Version = 上游软件版本（upstream version）**

也就是：

👉 **这个扩展本身的版本号**，而不是：

- ❌ GNOME Shell 版本
- ❌ 你打包的版本
- ❌ Fedora 版本

------

# 二、你这个项目的“麻烦点”

这个扩展：

👉 没有 GitHub Release
👉 但在 GNOME Extensions 网站有版本

也就是说：

> ❗ 上游版本来源 ≠ GitHub
> ✅ 上游版本来源 = GNOME Extensions

------

# 三、正确的 Version 获取方式（按优先级）

## 🥇 方法 1（推荐）：看 metadata.json（最权威）

在源码里有：

```json
{
  "version": 24,
  "shell-version": ["45", "46", "47"]
}
```

👉 这里的：

- `version` ✅ = 你要写的 Version
- `shell-version` ❌ ≠ Version

------

## 🥈 方法 2：GNOME Extensions 官网

你这个扩展：

👉 当前版本是：

- **v24（支持 GNOME 45–50）**

------

## 🥉 方法 3：自己定义（特殊情况）

如果：

- 上游完全没有 version 字段

👉 才用：

```spec
Version: 0
Release: 1.git<commit>
```

------

# 四、绝对不要这样写 ❌

## ❌ 错误写法 1

```spec
Version: 45
```

👉 这是 GNOME Shell 版本，不是扩展版本

------

## ❌ 错误写法 2

```spec
Version: 20260505
```

👉 这是日期版本（除非 upstream 就是这样）

------

## ❌ 错误写法 3

```spec
Version: 1.0
```

👉 随便编的，会导致升级混乱

------

# 五、你这个项目的“标准写法”

👉 推荐这样：

```spec
Version: 24
Release: 1%{?dist}.git%{shortcommit}
```

------

## 为什么这样写？

| 字段              | 含义                           |
| ----------------- | ------------------------------ |
| Version: 24       | 上游版本（来自 metadata.json） |
| Release           | 你这个 RPM 构建版本            |
| git%{shortcommit} | 区分不同 snapshot              |

------

# 六、Version vs Release（很多人混淆）

你必须区分这两个：

| 项目     | Version | Release |
| -------- | ------- | ------- |
| 来源     | 上游    | 打包者  |
| 变化频率 | 低      | 高      |
| 示例     | 24      | 1.fc40  |

------

### 举个例子

```text
gnome-shell-extension-compiz-magic-24-1.fc40
```

👉 含义：

- 24 = 扩展版本
- 1 = 第一次打包
- fc40 = Fedora 版本

------

# 七、如果上游没有 version（进阶）

可以用：

```spec
Version: 0
Release: 1.git%{shortcommit}%{?dist}
```

👉 Fedora 官方允许这种写法

------

# 八、最佳实践（给你总结一套规则）

## ✅ GNOME Extension 专用规则

1️⃣ 优先看 `metadata.json`

2️⃣ 如果有：

```json
"version": 24
```

👉 就写：

```spec
Version: 24
```

------

3️⃣ commit snapshot：

```spec
Release: 1.git%{shortcommit}%{?dist}
```

------

# 九、一句话总结

👉 你这个问题的本质是：

> 不知道“谁才是上游版本”

✔ 正确答案：

> **metadata.json 里的 version 才是**

------

# 十、给你一个最终推荐模板（适用于你这个项目）

```spec
%global commit xxxxxxxxxxxxxxxxx
%global shortcommit %(c=%{commit}; echo ${c:0:7})

Version: 24
Release: 1.git%{shortcommit}%{?dist}
```

------

# 如果你还想再进阶一点

我可以帮你做一个：

- ✅ 自动读取 metadata.json → 填 Version
- ✅ 自动抓 commit → 填 Release
- ✅ 自动生成 spec

👉 直接做到“一键打包 GNOME 扩展”

你现在已经在做维护者的事情了，这一步优化完就很专业了。







你现在这段依赖写法**方向是对的，但还不够“规范级”**，有几个点需要明确优化。我先直接给你结论，再帮你整理一套“GNOME Extension 标准依赖模板”。

------

# 一、你当前写法的问题点评

## ❌ 1. `BuildRequires: unzip` —— 不推荐

👉 你现在已经用的是 **commit snapshot / tar.gz**

所以：

- ❌ 不需要 unzip
- ❌ `%autosetup` 会自动解压

✅ 结论：**可以删掉**

------

## ⚠️ 2. `BuildRequires: glib2-devel` —— 用错了

你写的是：

```spec
BuildRequires: glib2-devel
```

问题：

- `glib-compile-schemas` 实际来自：
  - 👉 **glib2**
- ❌ 不需要 `-devel`

✅ 正确写法：

```spec
BuildRequires: glib2
```

------

## ⚠️ 3. 缺少 scriptlet 依赖（关键）

你用了：

```spec
%post
glib-compile-schemas ...
```

👉 那就必须加：

```spec
Requires(post): glib2
Requires(postun): glib2
```

否则：

- ❌ 在最小系统可能执行失败
- ❌ 不符合 Fedora 规范

------

## ✅ 4. `Requires: gnome-shell >= 45` —— 基本正确

👉 但要注意：

- 必须和 `metadata.json` 一致
- 不要“猜版本”

👉 依赖的是：

- **gnome-shell**

------

## ⚠️ 5. 你少了一个“隐性依赖认知”

很多人会问：

👉 要不要写：

```spec
Requires: gjs
```

答案：

- ❌ 不需要
- ✔ 因为 gnome-shell 已经依赖 gjs

👉 RPM 原则：

> **不要重复声明间接依赖**

------

# 二、GNOME Extension 标准依赖模型（非常重要）

你可以记住这个“通用模板”👇

------

## 🧱 最小标准依赖（适用于 90% 扩展）

```spec
BuildArch:      noarch

BuildRequires:  glib2

Requires:       gnome-shell >= X

Requires(post): glib2
Requires(postun): glib2
```

------

## 🧱 如果没有 schema（极简扩展）

```spec
BuildArch:      noarch

Requires:       gnome-shell >= X
```

👉 连 glib2 都可以不要

------

## 🧱 如果需要编译（极少数）

例如 TypeScript：

```spec
BuildRequires: nodejs
BuildRequires: npm
```

------

# 三、你这个扩展的“最佳依赖写法”

结合你项目（有 schema + 纯 JS）👇

```spec
# ------------------------------------------------------------------------------
# 依赖关系
# ------------------------------------------------------------------------------

BuildArch:      noarch

# 构建依赖（用于 schema 处理）
BuildRequires:  glib2

# 运行依赖
Requires:       gnome-shell >= 45

# scriptlet 依赖（用于 glib-compile-schemas）
Requires(post): glib2
Requires(postun): glib2
```

------

# 四、进阶优化（更规范的写法）

如果你用了 Fedora 宏：

```spec
%post
%glib2_schemas_post

%postun
%glib2_schemas_postun
```

👉 那么依赖仍然需要保留：

```spec
BuildRequires:  glib2
Requires(post): glib2
Requires(postun): glib2
```

------

# 五、常见错误总结（你基本踩了一半）

| 错误           | 是否存在    |
| -------------- | ----------- |
| 用 unzip       | ❌（你踩了） |
| 用 glib2-devel | ❌（你踩了） |
| 缺少 post 依赖 | ❌（你踩了） |
| 重复依赖 gjs   | ✅（你没踩） |
| 写一堆无关依赖 | ✅（你没踩） |

------

# 六、一个“判断依赖是否正确”的思维模型

以后你可以用这个方法自检：

------

## 🔍 问自己 4 个问题：

1️⃣ **这个包运行时需要什么？**
👉 gnome-shell ✔

2️⃣ **构建时需要什么？**
👉 glib2（schema）✔

3️⃣ **脚本执行需要什么？**
👉 glib2 ✔

4️⃣ **有没有间接依赖？**
👉 不写 ✔

------

# 七、一句话总结

👉 你现在的问题本质是：

> 把“能用”当成“规范”

✔ 正确做法是：

> **最小依赖 + 正确依赖 + 不重复依赖**

------

# 八、给你最终推荐版本（可直接用）

```spec
BuildArch:      noarch

BuildRequires:  glib2

Requires:       gnome-shell >= 45

Requires(post): glib2
Requires(postun): glib2
```

------

如果你下一步想继续优化，我可以帮你做一个：

✅ 自动分析扩展 → 生成依赖
✅ 判断是否需要 schema / node / meson
✅ 一键生成 spec 模板

你现在已经在往“Fedora packager”水平走了，这一步其实就是规范化思维的问题。
