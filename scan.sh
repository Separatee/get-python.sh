#!/bin/bash

# 获取初始块设备列表
initial_devices=$(lsblk -o NAME,MOUNTPOINT -J | jq -r '.blockdevices[] | select(.mountpoint != null) | .name')

echo "初始块设备列表:"
echo "$initial_devices"

while true; do
    # 获取当前块设备列表
    current_devices=$(lsblk -o NAME,MOUNTPOINT -J | jq -r '.blockdevices[] | select(.mountpoint != null) | .name')

    # 比较初始和当前设备列表，找出新增的设备
    new_device=$(comm -13 <(echo "$initial_devices" | sort) <(echo "$current_devices" | sort))

    if [ -n "$new_device" ]; then
        echo "检测到新硬盘: $new_device"
        
        # 获取新硬盘的挂载点
        mountpoint=$(lsblk -o NAME,MOUNTPOINT -J | jq -r --arg dev "$new_device" '.blockdevices[] | select(.name == $dev) | .mountpoint')

        if [ -n "$mountpoint" ]; then
            echo "新硬盘挂载位置: $mountpoint"
        else
            echo "新硬盘未挂载"
        fi

        # 更新初始设备列表
        initial_devices="$current_devices"
    fi

    # 每5秒检查一次
    sleep 5
done
