#!/usr/bin/env bash

printf "==================== task1 ====================\n"
bash ImageProcessing.sh -h
bash ImageProcessing.sh -f img/spring.jpeg -q 50   # 压缩jpg质量
bash ImageProcessing.sh -f img/boy.png -r 100      # 压缩分辨率
bash ImageProcessing.sh -c img/xumo.svg            # 格式转为jpg
bash ImageProcessing.sh -f img/girl.png -p prefix  # 添加前缀
bash ImageProcessing.sh -m img                     # 批量添加水印
printf "-------------------- shellcheck --------------------"
shellcheck ImageProcessing.sh

printf "==================== task2 ====================\n"
bash WorldCup.sh
printf "-------------------- shellcheck --------------------"
shellcheck WorldCup.sh

printf "==================== task3 ====================\n"
cat result_task3.txt
