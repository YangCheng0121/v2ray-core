#!/bin/bash

# 设置输出路径
OUTPUT_PATH="./build/android"
LIB_NAME="libv2ray.so"

# Android NDK 路径（需要根据实际路径修改）
ANDROID_NDK_PATH="C:\Users\Administrator\AppData\Local\Android\Sdk"

# 创建输出目录
mkdir -p $OUTPUT_PATH

# 检查 Go 安装
if ! command -v go &> /dev/null
then
    echo "Go 未安装，请先安装 Go。"
    exit 1
fi

# 编译函数
compile_for_arch() {
    ARCH=$1
    CC=$2
    CXX=$3
    OUT_FILE=$4
    
    echo "编译 $ARCH 架构..."
    export GOOS=android
    export GOARCH=$ARCH
    export CGO_ENABLED=1
    export CC=$CC
    export CXX=$CXX
    go build -buildmode=c-shared -o $OUTPUT_PATH/$OUT_FILE main/main.go
    if [ $? -ne 0 ]; then
        echo "$ARCH 编译失败"
        exit 1
    fi
}

# 编译 arm64-v8a 架构
compile_for_arch "arm64" "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang" \
    "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++" "arm64-v8a/$LIB_NAME"

# 编译 armeabi-v7a 架构
compile_for_arch "arm" "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi16-clang" \
    "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi16-clang++" "armeabi-v7a/$LIB_NAME"

# 编译 x86 架构
compile_for_arch "386" "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android16-clang" \
    "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android16-clang++" "x86/$LIB_NAME"

# 编译 x86_64 架构
compile_for_arch "amd64" "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang" \
    "$ANDROID_NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang++" "x86_64/$LIB_NAME"

echo "编译完成，输出文件位于: $OUTPUT_PATH"
