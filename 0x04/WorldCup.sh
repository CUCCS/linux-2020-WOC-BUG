#!/usr/bin/env bash

FILE_PATH="data/worldcupplayerinfo.tsv"
sum=0

## 年龄段
age20=0
age20_30=0
age30=0

## 场上位置
Goalie=0
Defender=0
Midfielder=0
Forward=0

## 比较长度
MaxLen=0
MinLen=100
MaxAge=0
MinAge=100
LongestName=()
ShortestName=()
OldestPlayer=()
YongestPlayer=()
numL=0
numS=0
numO=0
numY=0


## 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
function count_age(){
	#echo "$1"
	if [[ $1 -lt 20 ]];then
		age20=$((age20+1))
	elif [[ $1 -gt 30 ]];then
		age30=$((age30+1))
	elif [[ $1 -ge 20 ]] && [[ $1 -le 30 ]];then
		age20_30=$((age20_30+1))
        fi

}

## 统计不同场上位置的球员数量、百分比 
function count_pos(){

	#echo "$1"
	if [[ "$1" == "Goalie" ]];then
		Goalie=$((Goalie+1))
	elif [[ "$1" == "Defender" ]]||[[ "$1" == "Défenseur" ]];then # 这一个法语找死我了
		Defender=$((Defender+1))
	elif [[ "$1" == "Midfielder" ]];then
		Midfielder=$((Midfielder+1))
	elif [[ "$1" == "Forward" ]];then
		Forward=$((Forward+1))
	fi
}

## 找最长、最短姓名
function compare_name(){
	if [[ $1 -lt ${MinLen} ]];then
		MinLen=$1
	fi
	if [[ $1 -gt ${MaxLen} ]];then
		MaxLen=$1
	fi
}

## 找最大、最小年龄
function compare_age(){
	if [[ $1 -lt ${MinAge} ]];then
		MinAge=$1
	fi
	if [[ $1 -gt ${MaxAge} ]];then
		MaxAge=$1
	fi
}

## 百分比
function percent(){
	echo "scale=3; $1*100/$sum" | bc
}

## 输出信息
function print_info(){
	echo "不同年龄段范围："
	echo "  年龄段	人数	占比"
	echo "  [0,20)	${age20}	$(percent ${age20})%"
	echo " [20,30]	${age20_30}	$(percent ${age20_30})%"
	echo "(30,100]	${age30}	$(percent ${age30})%"
	echo "------------------------------------------------"
	
	echo "场上球员位置："
	echo "      位置	人数	占比"
	echo "    Goalie	${Goalie}	$(percent ${Goalie})%"
	echo "  Defender	${Defender}	$(percent ${Defender})%"
        echo "Midfielder	${Midfielder}	$(percent ${Midfielder})%"
        echo "   Forward	${Forward}	$(percent ${Forward})%"
	echo "------------------------------------------------"
	
	echo "名字最长的人："
	for ((i=0;i<$numL;i++));do
		echo "${LongestName[$i]}"
	done
	echo "长度为：${MaxLen}"
	echo "------------------------------------------------"

	echo "名字最短的人："
        for ((i=0;i<$numS;i++));do
                echo "${ShortestName[$i]}"
        done
	echo "长度为：${MinLen}"
        echo "------------------------------------------------"

	echo "年龄最大的人："
        for ((i=0;i<$numO;i++));do
                echo "${OldestPlayer[$i]}"
        done
	echo "年龄为：${MaxAge}"
        echo "------------------------------------------------"

	echo "年龄最小的人："
        for ((i=0;i<$numY;i++));do
                echo "${YongestPlayer[$i]}"
        done
	echo "年龄为：${MinAge}"
        echo "------------------------------------------------"
}

function main()
{
        flag=true
        while IFS=$'\t' read -r -a file
        do
                if $flag;then
                        flag=false
                        continue
		elif [[ "${file[0]}" == "" ]];then
			continue
		fi

		count_age "${file[5]}"
		count_pos "${file[4]}"
		compare_age "${file[5]}"
		namelen=${#file[8]}
		compare_name "${namelen}"
		sum=$((sum+1))
        done <"${FILE_PATH}"
       	

        flag=true
        while IFS=$'\t' read -r -a file
        do
                if $flag;then
                        flag=false
                        continue
                elif [[ "${file[0]}" == "" ]];then
                        continue
                fi
		
		namelen=${#file[8]}
		if [[ ${namelen} == ${MaxLen} ]];then
			LongestName[$numL]="${file[8]}"
			numL=$((numL+1))
		fi
		if [[ ${namelen} == ${MinLen} ]];then
			ShortestName[$numS]="${file[8]}"
			numS=$((numS+1))
		fi
		if [[ ${file[5]} == ${MaxAge} ]];then
			OldestPlayer[$numO]="${file[8]}"
			numO=$((numO+1))
		fi
		if [[ ${file[5]} == ${MinAge} ]];then
			YongestPlayer[$numY]="${file[8]}"
			numY=$((numY+1))
		fi
		
        done <"${FILE_PATH}"


	print_info
	#echo "age20=${age20},age20_30=${age20_30},age30=${age30}"
	#echo "Goalie=${Goalie},Defender=${Defender},Midfielder=${Midfielder},Forward=${Forward}"
       	#echo "sum=$sum"
	#echo "MaxLen=${MaxLen},MinLen=${MinLen}"
	#echo "MaxAge=${MaxAge},MinAge=${MinAge}"

}

main
