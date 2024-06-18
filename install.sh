#!/bin/bash
# 欢迎使用 Termux 启动和 Neovim 设置脚本

# 函数：检查并创建目录
check_and_create_directory() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        echo "创建目录: $dir_path"
        mkdir -p "$dir_path"
    fi
}

# 函数：安装软件包
# 参数 $1: 软件包列表，以空格分隔
install_packages() {
    local packages="$1"
    for package in $packages; do
        pkg install $package -y
        if [ $? -ne 0 ]; then
            echo "安装 $package 失败。"
        fi
        echo "$package 安装完成"
    done
}

# 函数：安装基础软件依赖
install_base_dependencies() {
    echo "安装基础软件依赖..."
    base_packages="git curl wget openssl openssh tmux neovim binutils nodejs ripgrep lua54"
    install_packages "$base_packages"
}

# 函数：安装Python依赖
install_python_dependencies() {
    echo "安装 Python 依赖..."
    python_packages="python"
    install_packages "$python_packages"
}

# 函数：安装Go依赖
install_go_dependencies() {
    echo "安装 Go 依赖..."
    go_packages="golang"
    install_packages "$go_packages"
}

install_tools_dependencies() {
    echo "安装常用工具"
    tool_packages="croc" 
    install_packages "$tool_packages"
}

# 函数：设置Neovim
setup_neovim() {
    echo "设置 Neovim..."

    # 克隆您的 Neovim 配置仓库
    echo "克隆您的 Neovim 配置..."
    
    CONFIG_DIR="$HOME/.config"
    check_and_create_directory "$CONFIG_DIR"
    
    cd $CONFIG_DIR
    git clone https://github.com/hustuhao/my-nvim.git nvim
    #git clone git@github.com:hustuhao/my-nvim.git nvim

    # 进入配置目录并打开插件文件以进行修改
    echo "进入 nvim 配置目录并打开插件文件以进行修改..."
    check_and_create_directory "$CONFIG_DIR/nivm"
    cd $CONFIG_DIR/nvim
    nvim lua/plugins.lua

    # 如果用户同意，将 Neovim 设置为默认编辑器
    echo -n "是否将 Neovim 设置为默认代码编辑器？ [Y|y|N|n]: "
    read user_input

    if [[ "$user_input" =~ ^[Yy]$ ]]; then
        ln -s $PREFIX/bin/nvim $HOME/bin/termux-file-editor
        echo "Neovim 现在是您的默认代码编辑器."
    else
        echo "未做任何更改."
    fi
}

# 函数：安装和设置字体
install_and_set_font() {
    echo "安装和设置字体..."

    # 设置字体变量
    FONT_NAME="Agave"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/${FONT_NAME}.zip"
    FONT_FILE="${FONT_NAME} Regular Nerd Font Complete.ttf"

    # 创建字体目录
    FONT_DIR="$HOME/.termux"
    check_and_create_directory "$FONT_DIR"

    # 下载字体文件
    echo "下载字体文件..."
    curl -L -o $FONT_DIR/${FONT_NAME}.zip $FONT_URL

    # 解压字体文件
    echo "解压字体文件..."
    unzip -o $FONT_DIR/${FONT_NAME}.zip -d $FONT_DIR

    # 检查字体文件是否成功解压
    if [ -f "$FONT_DIR/${FONT_FILE}" ]; then
        # 备份现有字体文件
        if [ -f "$FONT_DIR/font.ttf" ]; then
            mv "$FONT_DIR/font.ttf" "$FONT_DIR/font.ttf.bak"
            echo "之前的字体已备份到 $FONT_DIR/font.ttf.bak"
        fi

        # 移动并重命名字体文件
        mv "$FONT_DIR/${FONT_FILE}" "$FONT_DIR/font.ttf"

        # 设置字体
        echo "font: $FONT_DIR/font.ttf" > "$FONT_DIR/font.properties"

        # 应用设置
        termux-reload-settings

        echo "字体安装和设置完成."
    else
        echo "字体文件解压失败，未找到目标字体文件。"

        # 恢复原来的字体
        if [ -f "$FONT_DIR/font.ttf.bak" ]; then
            mv "$FONT_DIR/font.ttf.bak" "$FONT_DIR/font.ttf"
            echo "恢复原来的字体."
        fi
    fi

    # 清理下载的zip文件
    rm "$FONT_DIR/${FONT_NAME}.zip"
}

# 函数：主函数，依次安装各类别依赖和设置Neovim
main() {
    # 记录开始时间
    start_time=$(date +%s)
    # 开始 Termux 设置
    echo "启动 Termux 设置..."

    # 更新和升级 Termux 软件包
    echo "正在更新和升级 Termux..."
    pkg update -y
    pkg upgrade -y

    # 安装基础软件依赖
    install_base_dependencies

    # 安装Python依赖
    install_python_dependencies

    # 安装Go依赖
    install_go_dependencies

    # 常用工具安装
    install_tools_dependencies

    # 设置Neovim
    setup_neovim

    # 安装和设置字体
    install_and_set_font

      # 计算耗时并输出
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "安装完成，耗时: $duration 秒"
}

# 执行主函数
main

