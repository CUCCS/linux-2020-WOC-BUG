#!/usr/bin/env bash

printf "==================== task1 ====================\n"
bash 0x04/ImageProcessing.sh -h
bash 0x04/ImageProcessing.sh -f img/spring.jpeg -q      # 压缩jpg质量
bash 0x04/ImageProcessing.sh -f img/boy.png -r          # 压缩分辨率
bash 0x04/ImageProcessing.sh -f img/xumo.svg -t         # 格式转为jpg
bash 0x04/ImageProcessing.sh -f img/girl.png -p prefix  # 添加前缀
bash 0x04/ImageProcessing.sh -f img -m                  # 批量添加水印
printf "-------------------- shellcheck --------------------"
shellcheck 0x04/ImageProcessing.sh

printf "==================== task2 ====================\n"
bash 0x04/WorldCup.sh
printf "-------------------- shellcheck --------------------"
shellcheck 0x04/WorldCup.sh

printf "==================== task3 ====================\n"
cat result_task3.txt
