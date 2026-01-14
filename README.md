# VSRSOLFix (VS Code Remote-SSH Old Linux Fix)

[中文](#中文) | [English](#english)

---

## 中文

### 简介

这个脚本用于修复 **VS Code Remote-SSH** 在老旧 Linux 服务器上无法连接的问题。

新版本的 VS Code Server 需要较高版本的 `glibc` 和 `libstdc++`，而很多老旧的 Linux 发行版系统自带的库版本过低，导致连接失败并出现错误。

### 前提条件

- 服务器上已安装 **Anaconda** 或 **Miniconda**
- Conda 已在当前 Shell 中初始化（可以运行 `conda` 命令）

### 使用方法

1. **下载脚本到服务器**

2. **赋予权限并运行脚本**

   ```bash
   chmod +x VSRSOLFix.sh
   ./VSRSOLFix.sh
   ```

3. **按照提示操作**

   - 在终端中运行 `source ~/.bashrc`（或 `~/.zshrc`）
   - 关闭本地 VS Code
   - 重启本地 VS Code
   - 重新连接服务器

### 工作原理

脚本通过 Conda 安装新版本的 `glibc` 和 `libstdc++` 库到一个独立的环境中，然后设置环境变量告诉 VS Code Server 使用这些新库，从而绕过系统自带老旧库的限制。

---

## English

### Introduction

This script fixes the **VS Code Remote-SSH** connection issue on older Linux servers.

Newer versions of VS Code Server require higher versions of `glibc` and `libstdc++`. Many older Linux distributions have outdated system libraries, causing connection failures and errors.

### Prerequisites

- **Anaconda** or **Miniconda** installed on the server
- Conda initialized in the current shell (the `conda` command works)

### Usage

1. **Download the script to your server**

2. **Make it executable and run the script**

   ```bash
   chmod +x VSRSOLFix.sh
   ./VSRSOLFix.sh
   ```

3. **Follow the instructions**

   - Run `source ~/.bashrc` (or `~/.zshrc`) in your terminal
   - Close local VS Code
   - Restart local VS Code
   - Reconnect to the server

### How It Works

The script uses Conda to install newer versions of `glibc` and `libstdc++` libraries into an isolated environment, then sets environment variables to tell VS Code Server to use these libraries, bypassing the system's outdated libraries.

---

## License

MIT License
