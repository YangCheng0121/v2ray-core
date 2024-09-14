#!/bin/bash

# 设置输出路径
OUTPUT_PATH="./build/ios"
LIB_NAME="libv2ray.a"

# 创建输出目录
mkdir -p $OUTPUT_PATH

# 检查 Go 安装
if ! command -v go &> /dev/null
then
    echo "Go 未安装，请先安装 Go。"
    exit 1
fi

# 编译 arm64 架构 (iOS 设备)
echo "编译 arm64 架构..."
export GOOS=darwin
export GOARCH=arm64
export CGO_ENABLED=1
export CC=$(xcrun --sdk iphoneos --find clang)
export CXX=$(xcrun --sdk iphoneos --find clang++)
go build -buildmode=c-archive -o $OUTPUT_PATH/arm64.a main/main.go
if [ $? -ne 0 ]; then
    echo "arm64 编译失败"
    exit 1
fi

# 编译 x86_64 架构 (iOS 模拟器)
echo "编译 x86_64 架构..."
export GOARCH=amd64  # x86_64 对应的 GOARCH 是 amd64
export CC=$(xcrun --sdk iphonesimulator --find clang)
export CXX=$(xcrun --sdk iphonesimulator --find clang++)
go build -buildmode=c-archive -o $OUTPUT_PATH/x86_64.a main/main.go
if [ $? -ne 0 ]; then
    echo "x86_64 编译失败"
    exit 1
fi

# 合并不同架构的静态库
echo "合并架构..."
lipo -create -output $OUTPUT_PATH/$LIB_NAME $OUTPUT_PATH/arm64.a $OUTPUT_PATH/x86_64.a
if [ $? -ne 0 ]; then
    echo "合并架构失败"
    exit 1
fi

# 清理单独架构的文件
rm $OUTPUT_PATH/arm64.a $OUTPUT_PATH/x86_64.a

echo "编译完成，输出文件为: $OUTPUT_PATH/$LIB_NAME"
