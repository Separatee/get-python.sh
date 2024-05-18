#!/bin/bash

# 获取 Python 版本信息的函数
get_python_versions() {
    wget -qO- https://www.python.org/ftp/python/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+/' | sed 's|/$||' | sort -u
}

# 主函数
main() {
    echo "Fetching Python versions..."
    versions=$(get_python_versions)

    # 提取大版本号
    major_versions=($(echo "$versions" | awk -F'.' '{print $1"."$2}' | sort -u))

    # 用户选择大版本号
    PS3="Please enter your choice: "
    echo "Available major versions:"
    select major_version in "${major_versions[@]}" "Back"; do
        if [[ "$major_version" == "Back" ]]; then
            main
        elif [[ -n "$major_version" ]]; then
            break
        else
            echo "Invalid selection, please try again."
        fi
    done

    # 提取次版本号
    minor_versions=($(echo "$versions" | grep "^$major_version" | sort -u))

    # 用户选择次版本号
    echo "Available minor versions for $major_version:"
    select minor_version in "${minor_versions[@]}" "Back"; do
        if [[ "$minor_version" == "Back" ]]; then
            main
        elif [[ -n "$minor_version" ]]; then
            break
        else
            echo "Invalid selection, please try again."
        fi
    done

    # 提取修订版本号
    patch_versions=($(echo "$versions" | grep "^$minor_version" | sort -u))

    # 用户选择修订版本号
    echo "Available patch versions for $minor_version:"
    select patch_version in "${patch_versions[@]}" "Back"; do
        if [[ "$patch_version" == "Back" ]]; then
            main
        elif [[ -n "$patch_version" ]]; then
            break
        else
            echo "Invalid selection, please try again."
        fi
    done

    VERSION=$patch_version
    echo "Selected version: $VERSION"

    # 下载源码
    download_url="https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz"
    echo "Downloading Python $VERSION from $download_url..."
    wget $download_url

    echo "Download complete."
}

# 执行主函数
main
