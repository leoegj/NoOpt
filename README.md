# NoOpt

[中文版本](#noopt中文)

A lightweight Android arm64 / GKI external kernel module that hides configured file paths from common filesystem operations. It resolves target inodes at load time and installs kretprobes around VFS-related paths.

> This repository is intended for controlled lab/demo use on your own device or another device where you have explicit permission.

## Features

- Hides direct access via `security_inode_permission`
- Hides stat/getattr checks via `security_inode_getattr`
- Filters `getdents64` results to remove targets from directory listings
- Supports up to 16 target paths per module load
- Supports `scope_mode=global` and `scope_mode=deny` (hide only from configured UIDs)
- KernelSU module wrapper with WebUI for managing paths, app blacklist, UID blacklist, and scope mode
- Persistent config under `/data/adb/noopt` survives module updates
- GitHub Actions CI builds for all GKI KMI targets

## Supported KMI Targets

| Target | Kernel |
|--------|--------|
| android12-5.10 | 5.10 |
| android13-5.10 | 5.10 |
| android13-5.15 | 5.15 |
| android14-5.15 | 5.15 |
| android14-6.1 | 6.1 |
| android15-6.6 | 6.6 |
| android16-6.12 | 6.12 |

## Build

### GitHub Actions

- **Release**: Push a `v*` tag or manually trigger the `Build & Release All Kernels` workflow to compile all targets and publish a GitHub Release.
- **CI Build**: Triggered on pull requests or manual dispatch via `Build LKM for All KMI Targets`.

### Local Build

```sh
cd kernel
CONFIG_KSU=m CC=clang make
```

Output: `kernel/noopt.ko`

## Usage

```sh
# Single path
insmod noopt.ko target_path=/data/local/tmp/secret

# Multiple paths
insmod noopt.ko target_paths=/data/local/tmp/a,/data/local/tmp/b

# Deny scope (hide only from specific UIDs)
insmod noopt.ko target_paths=/data/local/tmp/a scope_mode=deny deny_uids=10123,10124

# Disable directory listing filter
insmod noopt.ko target_paths=/data/local/tmp/a hide_dirents=0
```

## KernelSU Module

Install the `*_noopt-ksu.zip` from Releases in KernelSU Manager. The WebUI is available after installation for managing all settings without rebooting.

Package manually:

```sh
# Linux/macOS
./tools/package_ksu.sh kernel/noopt.ko out/noopt-ksu.zip

# Windows PowerShell
.\tools\package_ksu.ps1 -KoPath .\kernel\noopt.ko -Output .\out\noopt-ksu.zip
```

## Known Limitations

- Target paths must exist before `insmod` (missing paths are skipped)
- Existing open file descriptors are not hidden retroactively
- Module must match device KMI/kernel version and arm64 ABI
- `/proc/*/mountinfo` and `/proc/*/mounts` are not filtered

---

# NoOpt（中文）

一个轻量级 Android arm64 / GKI 外部内核模块，用于隐藏指定文件路径，使其在常见文件系统操作中不可见。模块在加载时解析目标 inode，并在 VFS 相关路径上安装 kretprobe。

> 本仓库仅供在您自己的设备或已获得明确授权的设备上进行受控实验/演示使用。

## 功能特性

- 通过 `security_inode_permission` 隐藏直接访问
- 通过 `security_inode_getattr` 隐藏 stat/getattr 检查
- 过滤 `getdents64` 结果，从目录列表中移除目标项
- 每次加载支持最多 16 个目标路径
- 支持 `scope_mode=global`（全局）和 `scope_mode=deny`（仅对配置的 UID 隐藏）
- KernelSU 模块封装，带 WebUI 管理路径、应用黑名单、UID 黑名单和作用范围
- 持久化配置存储在 `/data/adb/noopt`，模块更新后配置不丢失
- GitHub Actions CI 自动编译所有 GKI KMI 目标

## 支持的 KMI 目标

| 目标 | 内核版本 |
|------|----------|
| android12-5.10 | 5.10 |
| android13-5.10 | 5.10 |
| android13-5.15 | 5.15 |
| android14-5.15 | 5.15 |
| android14-6.1 | 6.1 |
| android15-6.6 | 6.6 |
| android16-6.12 | 6.12 |

## 编译

### GitHub Actions

- **发布**：推送 `v*` tag 或手动触发 `Build & Release All Kernels` 工作流，自动编译所有目标并创建 GitHub Release。
- **CI 编译**：在 Pull Request 或手动触发时运行 `Build LKM for All KMI Targets`。

### 本地编译

```sh
cd kernel
CONFIG_KSU=m CC=clang make
```

输出：`kernel/noopt.ko`

## 使用方法

```sh
# 单路径
insmod noopt.ko target_path=/data/local/tmp/secret

# 多路径
insmod noopt.ko target_paths=/data/local/tmp/a,/data/local/tmp/b

# 黑名单模式（仅对指定 UID 隐藏）
insmod noopt.ko target_paths=/data/local/tmp/a scope_mode=deny deny_uids=10123,10124

# 禁用目录列表过滤
insmod noopt.ko target_paths=/data/local/tmp/a hide_dirents=0
```

## KernelSU 模块

从 Releases 下载 `*_noopt-ksu.zip`，在 KernelSU 管理器中安装。安装后可通过 WebUI 管理所有设置，无需重启。

手动打包：

```sh
# Linux/macOS
./tools/package_ksu.sh kernel/noopt.ko out/noopt-ksu.zip

# Windows PowerShell
.\tools\package_ksu.ps1 -KoPath .\kernel\noopt.ko -Output .\out\noopt-ksu.zip
```

## 已知限制

- 目标路径必须在 `insmod` 前存在（不存在的路径会被跳过）
- 已打开的文件描述符不会被追溯隐藏
- 模块必须匹配设备的 KMI/内核版本和 arm64 ABI
- 不过滤 `/proc/*/mountinfo` 和 `/proc/*/mounts`
