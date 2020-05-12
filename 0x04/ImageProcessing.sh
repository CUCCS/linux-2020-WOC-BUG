#!/usr/bin/env bash

## 变量
TOOL_NAME="$0"	# 操作文件名
FILE_PATH=""	# 文件路径
IMAGE_QUALITY=0	# 图片质量
NEW_FILE=""	# 文件新名字
FILE_TYPE=""	# 文件类型

## 帮助信息
function help_info(){

# 设置结束符
cat <<EOF
Usage:
	bash ${TOOL_NAME} [options]
	This script is to operate on the pictures,such as compressing the images,adding water mark on the pictures,converting the format of pictures,add prefix or suffix name to the pictures and so on.
	NOTE:you must use -f file first,then use -m,-p,-s,-q,-r options.For example:bash ${tOOL_NAME} -f file -p prefix -s suffix.
Options:
	-h,             		show this help info
	-c file/path,   		convert png/svg images to jpg images
	-f file/path,			input the file name or the path of the file
	-m file/path watermark_path,	add warter mark to the file,the warter mark is the image "img/watermark.png"
	-p prefix,			add prefix name to the file,this option must use with -f file option
	-s suffix,			add suffix name to the file,this option must use with -f file option
	-q quality,			compress the quality,this option must use with -f file option
	-r pixel,			compress the resolving power.input the horizontal pixel,the vertical pixel will change in proportion, this option must use with -f file option
EOF

}

## 判断文件类型
function file_type(){
	len=${#1}
	num=0
	for ((i=$len-1;i>=0;i--));do	
		if [[ ${1:$i:1} == "." ]];then
			break
		fi
		num=$((num+1))
	done

	pos=$((len-num))
	FILE_TYPE=${1:$pos:$num}	# 截取文件类型
	typeset -l ${FILE_TYPE}		# 转为小写

	if [[ "$FILE_TYPE" != "jpg" ]] && [[ "$FILE_TYPE" != "jpeg" ]] && [[ "$FILE_TYPE" != "png" ]] && [[ "$FILE_TYPE" != "svg" ]];then
		echo "不支持.${FILE_TYPE}类型的文件！"
		FILE_TYPE=""
	fi
}

## 输入文件
function input_file(){
	if [[ -d $1 ]];then	# 目录
		FILE_PATH=$1
		echo "这是一个路径: ${FILE_PATH}"
		shift
	elif [[ -f $1 ]];then	# 普通文件
		FILE_PATH=$1
		file_type "${FILE_PATH}"
		if [[ "${FILE_TYPE}" != "" ]];then
			echo "这是一个.${FILE_TYPE}类型的文件: ${FILE_PATH}"
		fi
		shift
	else
		echo "路径出错！"
	fi
}

## 添加前缀名
function add_prefix_name(){
        file=$1		# 需要添加前缀的文件名
        len=${#file}   	# 字符串长度
        NEW_FILE="" 	# 新文件名
        num=0

	#echo "file = $file"
	#echo "len = $len"

        # 倒序遍历字符串，遇到/或数完为止
        for((i=$len-1;i>=0;i--));do
                num=$(($num+1))
                #echo "i=$i,num=$num"
                if [[ "${file:$i:1}" == "/" ]];then
                        #echo "第$i个字符为: ${file:$i:1}"
                        break
                fi
        done

        if [[ $num -eq $len ]]
        then
                num=0
        else
                num=$(($len-$num+1))            # 正着数到/的长度
        fi

        remlen=$(($len-$num))
        NEW_FILE="${file:0:$num}$2_${file:$num:$remlen}"

        echo "新的文件名为：$NEW_FILE"
}

## 添加后缀名
function add_suffix_name(){
	file=$1		# 需要添加前缀的文件名
        len=${#file}    # 字符串长度
        num=0

        # 倒序遍历字符串，遇到/或数完为止
        for((i=$len-1;i>=0;i--));do
                num=$(($num+1))
                #echo "i=$i,num=$num"
                if [[ "${file:$i:1}" == "." ]];then
                       # echo "第$i个字符为: ${file:$i:1}"
                        break
                fi
        done

        remlen=$num
        num=$(($len-$num))              # 正着数到/的长度

        NEW_FILE="${file:0:$num}_$2${file:$num:$remlen}"

        echo "新的文件名为：$NEW_FILE"
}

## 图片质量压缩
function compress_quality(){
	#echo "quality = $1"
	#echo "file_path = ${FILE_PATH}"
	if [[ "${FILE_PATH}" == "" ]];then			# 路径为空
		echo "图片路径为空！"
	elif [[ $1 -le 0 ]]||[[ $1 -gt 100 ]];then		# 图片质量小于0或大于100
		echo "图片质量出错！"
	else
		# 压缩图片质量
		if [[ -d ${FILE_PATH} ]];then
			for tmp_file in ${FILE_PATH}/*;do	# 遍历路径下的所有文件
				file_type "${tmp_file}"
				if [[ "${FILE_TYPE}" == "" ]];then
					continue
				fi
				#echo "tmp_file = ${tmp_file}"
				add_prefix_name "${tmp_file}" "quality"
				convert -quality $1 ${tmp_file} ${NEW_FILE}
			done
		fi

		if [[ -f ${FILE_PATH} ]] && [[ "${FILE_TYPE}" != "" ]];then
			add_prefix_name "${FILE_PATH}" "quality"
			convert -quality $1 ${FILE_PATH} ${NEW_FILE}
		fi
	fi
}

## 压缩图片分辨率
function compress_resolving_power(){
	if [[ "${FILE_PATH}" == "" ]];then	# 路径为空
		echo "图片路径为空！"
	elif [[ $1 -le 0 ]];then	# 图片分辨率小于0%
		echo "分辨率出错！"
	else
		# 压缩分辨率
		if [[ -d ${FILE_PATH} ]];then
			for tmp_file in ${FILE_PATH}/*;do	# 遍历路径下的所有文件
				file_type "${tmp_file}"
                                if [[ "${FILE_TYPE}" == "" ]];then
                                        continue
                                fi
				#echo "tmp_file = ${tmp_file}"
				add_prefix_name "${tmp_file}" "resolution"
				convert -sample $1 ${tmp_file} ${NEW_FILE}
			done
		fi

		if [[ -f ${FILE_PATH} ]] && [[ "${FILE_TYPE}" != "" ]];then
			add_prefix_name "${FILE_PATH}" "resolution"
			convert -sample $1 ${FILE_PATH} ${NEW_FILE}
		fi
	fi
}

## 格式转换
function convert_type(){
	if [[ -d ${FILE_PATH} ]];then
		for file in ${FILE_PATH}/*;do
			file_type "${file}"
			if [[ "${FILE_TYPE}" == "png" ]] || [[ "${FILE_TYPE}" == "svg" ]];then
				len=${#file}
				len=$((len-4))			# 去掉后缀的长度
				new_file="${file:0:$len}.jpg"	# 改为.jpg后缀的名字
				convert "${file}" "${new_file}"	# 格式转换
			elif [[ "${FILE_TYPE}" == "jpg" ]] || [[ "${FILE_TYPE}" == "jpeg" ]];then
				echo ".${FILE_TYPE}类型的文件无需转换"
			else
				continue
			fi
		done
	elif [[ -f ${FILE_PATH} ]];then
		if [[ "${FILE_TYPE}" == "png" ]] || [[ "${FILE_TYPE}" == "svg" ]];then
			len=${#FILE_PATH}
			len=$((len-4))
                        new_file="${FILE_PATH:0:$len}.jpg"
                        convert "${FILE_PATH}" "${new_file}"
                elif [[ "${FILE_TYPE}" == "jpg" ]] || [[ "${FILE_TYPE}" == "jpeg" ]];then
                        echo ".${FILE_TYPE}类型的文件无需转换"
      	        fi
	fi

}

## 添加水印
function add_water_mark(){
	WaterMark="$1"
	if [[ -d ${FILE_PATH} ]]
	then
		for file in ${FILE_PATH}/*;do
			add_prefix_name "${file}" "marked"
			composite -gravity center "${WaterMark}"  "${file}" "${NEW_FILE}"
			#convert ${file} img/watermark.png -gravity center ${NEW_FILE}
		done
	else
		add_prefix_name "${FILE_PATH}" "marked"
		composite -gravity center "${WaterMark}" "${FILE_PATH}" "${NEW_FILE}"
		#convert "${FILE_PATH}" img/watermark.png -gravity center "${NEW_FILE}"
	fi
}

## 主函数
function main(){

	while [ -n "$1" ];do		#一直往下取参数
		case "$1" in
			-h)
				help_info
				shift;;
			-c)		# png/svg转jpg
				input_file "$2"
				convert_type
				shift;;
			-f)		# 导入文件
				input_file "$2"
				shift;;
			-m)		#添加水印
				input_file "$2"
				add_water_mark "$3"
				shift;;
			-p)
				if [[ -d ${FILE_PATH} ]]
				then
					for file in ${FILE_PATH}/*;do
						add_prefix_name "${file}" "$2"
						mv ${file} ${NEW_FILE}
					done
				else
					add_prefix_name  "${FILE_PATH}" "$2"
					mv ${FILE_PATH} ${NEW_FILE}
				fi
				shift;;
			-s)
				if [[ -d ${FILE_PATH} ]]
				then
					for file in ${FILE_PATH}/*;do
						add_suffix_name "${file}" "$2"
						mv ${file} ${NEW_FILE}
					done
				else
					add_suffix_name "${FILE_PATH}" "$2"
					mv ${FILE_PATH} ${NEW_FILE}
				fi
				shift;;
			-q)		# 图片质量压缩
				compress_quality "$2"	
				shift;;
			-r)
				compress_resolving_power "$2"
				shift;;
			*)
				shift;;
		esac
	done

}

main "$@"
