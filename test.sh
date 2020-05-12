#!/usr/bin/env bash

printf "==================== task1 ====================\n"
bash 0x04/ImageProcessing.sh -h
bash 0x04/ImageProcessing.sh -f 0x04/img/spring.jpeg -q 50   	# 压缩jpg质量
bash 0x04/ImageProcessing.sh -f 0x04/img/boy.png -r 100      	# 压缩分辨率
bash 0x04/ImageProcessing.sh -c 0x04/img/xumo.svg            	# 格式转为jpg
bash 0x04/ImageProcessing.sh -f 0x04/img/girl.png -p prefix  	# 添加前缀
bash 0x04/ImageProcessing.sh -m 0x04/img 0x04/img/watermark.png	# 批量添加水印
printf "-------------------- shellcheck --------------------"
shellcheck 0x04/ImageProcessing.sh

printf "==================== task2 ====================\n"
bash 0x04/WorldCup.sh 0x04/data/worldcupplayerinfo.tsv
printf "-------------------- shellcheck --------------------"
shellcheck 0x04/WorldCup.sh

printf "==================== task3 ====================\n"
cat 0x04/result_task3.md
