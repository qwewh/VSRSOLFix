#!/usr/bin/env bash

# ==========================================
# VS Code Remote-SSH Old Linux Fix Script
# 基于 Conda/Miniconda 自动修复 glibc/libstdc++ 版本过低问题
# Auto-fix glibc/libstdc++ version issues using Conda/Miniconda
# ==========================================

ENV_NAME="vscode_sysroot"
GLIBC_VERSION="2.28"

# Bilingual message function | 双语消息函数
msg() {
    local cn="$1"
    local en="$2"
    echo "$cn | $en"
}

# 1. 检测系统架构 | Detect system architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
    msg "⚠️  警告: 当前系统架构为 $ARCH，此脚本仅支持 x86_64" \
        "Warning: Current architecture is $ARCH, this script only supports x86_64"
    msg "   脚本将继续运行，但可能无法正常工作" \
        "The script will continue, but may not work properly"
fi

# 2. 检测 Conda 是否可用 | Check if Conda is available
if ! command -v conda &> /dev/null; then
    msg "❌ 错误: 未找到 conda 命令" \
        "Error: conda command not found"
    msg "   请确保你已安装 Anaconda 或 Miniconda，并且已在当前 Shell 中激活" \
        "Please ensure Anaconda or Miniconda is installed and initialized in your shell"
    msg "   提示: 如果已安装，请尝试运行 'source ~/miniconda3/etc/profile.d/conda.sh' 或类似命令" \
        "Hint: If installed, try running 'source ~/miniconda3/etc/profile.d/conda.sh' or similar"
    exit 1
fi

msg "✅ 检测到 Conda" \
    "Conda detected: $(which conda)"

# 3. 检测 Shell 类型 | Detect shell type (.bashrc or .zshrc)
if [[ "$SHELL" == *"zsh"* ]]; then
    RC_FILE="$HOME/.zshrc"
else
    RC_FILE="$HOME/.bashrc"
fi

# 检查配置文件写入权限 | Check write permission for config file
if [[ ! -w "$RC_FILE" ]] && [[ -f "$RC_FILE" ]]; then
    msg "❌ 错误: 无法写入配置文件 $RC_FILE" \
        "Error: Cannot write to config file $RC_FILE"
    exit 1
fi

msg "✅ 目标配置文件" \
    "Target config file: $RC_FILE"

# 4. 检查并创建专用 Conda 环境 | Check and create dedicated Conda environment
msg "🔍 检查环境 '$ENV_NAME'..." \
    "Checking environment '$ENV_NAME'..."

if conda env list | grep -q "$ENV_NAME"; then
    msg "   环境已存在，跳过创建" \
        "Environment exists, skipping creation"
else
    msg "⚡️ 环境不存在，正在创建 (可能需要几分钟)..." \
        "Environment not found, creating (this may take a few minutes)..."
    # 安装 sysroot (glibc), gcc_impl (libstdc++), patchelf
    # Install sysroot (glibc), gcc_impl (libstdc++), patchelf
    conda create -n "$ENV_NAME" -c conda-forge sysroot_linux-64=$GLIBC_VERSION gcc_impl_linux-64 patchelf -y
    if [ $? -ne 0 ]; then
        msg "❌ 环境创建失败，请检查网络或 Conda 配置" \
            "Environment creation failed, please check network or Conda configuration"
        exit 1
    fi
fi

# 5. 获取环境绝对路径 | Get environment absolute path
# 使用 conda run 获取该环境下的环境变量，提取 CONDA_PREFIX
# Use conda run to get environment variables and extract CONDA_PREFIX
ENV_PREFIX=$(conda run -n "$ENV_NAME" printenv CONDA_PREFIX)

if [ -z "$ENV_PREFIX" ]; then
    msg "❌ 无法获取环境路径" \
        "Cannot get environment path"
    exit 1
fi

msg "✅ 环境路径" \
    "Environment path: $ENV_PREFIX"

# 6. 构造配置块 | Construct configuration block
# 注意：这里严格按照我们调试成功的顺序，把 ENV_PREFIX/lib 放在最前面
# Note: Strictly follow the order that worked, putting ENV_PREFIX/lib first
CONFIG_BLOCK="# === VS Code Remote SSH Fix Start ===
export VSCODE_SYSROOT_ENV=\"$ENV_PREFIX\"
export VSCODE_SYSROOT_DIR=\"\$VSCODE_SYSROOT_ENV/x86_64-conda-linux-gnu/sysroot\"
export VSCODE_SERVER_PATCHELF_PATH=\"\$VSCODE_SYSROOT_ENV/bin/patchelf\"
export VSCODE_SERVER_CUSTOM_GLIBC_LINKER=\"\$VSCODE_SYSROOT_DIR/lib/ld-linux-x86-64.so.2\"
export VSCODE_SERVER_CUSTOM_GLIBC_PATH=\"\$VSCODE_SYSROOT_ENV/lib:\$VSCODE_SYSROOT_DIR/lib:\$VSCODE_SYSROOT_DIR/usr/lib\"
# === VS Code Remote SSH Fix End ==="

# 7. 写入配置文件 | Write to config file
# 先清理旧配置，再追加新配置 | Clean old config first, then append new config
# 使用 sed 删除旧的 Fix 块（如果存在），防止重复
# Use sed to delete old Fix block (if exists) to prevent duplicates
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/# === VS Code Remote SSH Fix Start ===/,/# === VS Code Remote SSH Fix End ===/d' "$RC_FILE"
else
    sed -i '/# === VS Code Remote SSH Fix Start ===/,/# === VS Code Remote SSH Fix End ===/d' "$RC_FILE"
fi

# 追加新配置 | Append new configuration
echo "$CONFIG_BLOCK" >> "$RC_FILE"

msg "✅ 配置已写入" \
    "Config written to: $RC_FILE"

# 8. 结束提示 | Completion notice
echo "=========================================="
msg "🎉 安装完成！请务必执行以下操作：" \
    "Installation complete! Please do the following:"
msg "   1. 在当前终端运行: source $RC_FILE" \
    "   1. Run in current terminal: source $RC_FILE"
msg "   2. 关闭本地 VS Code" \
    "   2. Close local VS Code"
msg "   3. 重启本地 VS Code 并重新连接服务器" \
    "   3. Restart local VS Code and reconnect to the server"
echo "=========================================="