#!/usr/bin/env bash
FILE_PATH="data/web_log.tsv"

function top100_host(){
	echo "访问来源主机TOP 100和分别对应出现的总次数:"
	echo "				host name		次数"
	echo "		--------------------------------------------"
	awk -F '\t' '
	NR>1{
		host[$1]++
	}
	END{
		for (i in host){
			printf("%40s\t\t%d\n",i,host[i]);
		}
	}' "${FILE_PATH}" | sort -n -r -k 2 |head -100
}

function top100_ip(){
	echo "访问来源主机TOP 100 IP和分别对应出现的总次数:"
	echo "				ip			次数"
	echo "		--------------------------------------------"
	awk -F '\t' '
	NR>1{
		if($1~/([0-9]*\.){3}[0-9]*/){
			ip[$1]++
		}
	}
	END{
		for(i in ip){
			printf("%40s\t\t%d\n",i,ip[i]);
		}
	}
	' "${FILE_PATH}" | sort -n -r -k 2 |head -100
}

function top100_url(){
	echo "最频繁被访问的URL TOP 100:"
	echo "						url		次数"
	echo "		----------------------------------------------------"
	awk -F '\t' '
        NR>1{
                url[$5]++
        }
        END{
                for (i in url){
                        printf("%55s\t\t%d\n",i,url[i]);
                }
        }' "${FILE_PATH}" | sort -n -r -k 2 |head -100
}

function status_code(){
        echo "统计不同响应状态码的出现次数和对应百分比:"
        echo "		状态码			出现次数		百分比"
        echo "		------------------------------------------------------"
        awk -F '\t' '
	BEGIN{
		sum=0
	}
        NR>1{
		if($1!=""){
			sum++
                	stacode[$6]++
		}
        }
        END{
                for (i in stacode){
                        printf("%20s\t%20d\t%20.3f%\n",i,stacode[i],stacode[i]*100/sum);
                }
        }' "${FILE_PATH}" | sort -n -r -k 2

}

function 4xx_status(){
	echo "403状态码对应的TOP 10 URL和对应出现的总次数："
	echo " url								次数"
        echo "----------------------------------------------------------------------"
	awk -F '\t' '
	NR>1{
		if($6~/^403/){
			sta[$5]++;
		}
	}
	END{
		for(i in sta){
			printf("%-60s\t%d\n",i,sta[i]);
			#printf("403%60s\t%5d\n",i,sta[i]);
		}
	}
	' "${FILE_PATH}"  | sort -n -r -k 2 | head -n 10
	echo ""
        echo "404状态码对应的TOP 10 URL和对应出现的总次数："
        echo " url								次数"
        echo "----------------------------------------------------------------------"	
	awk -F '\t' '
	NR>1{
		if($6~/^404/){
			sta[$5]++;
		}
	}
	END{
		for(i in sta){
			printf("%-60s\t%d\n",i,sta[i]);
		}
	}
	' "${FILE_PATH}"  | sort -n -r -k 2 | head -n 10
}

function url_top100(){
        echo "给定URL的TOP 100访问来源主机:"
        echo "          	                host name               次数"
        echo "          	--------------------------------------------"
        awk -F '\t' '
        NR>1{
		if("'$1'" == $5)
                	host[$1]++
        }
        END{
                for (i in host){
                        printf("%40s\t\t%d\n",i,host[i]);
                }
        }' "${FILE_PATH}" | sort -n -r -k 2 |head -100
}

function main(){
	if [[ $# -eq 0 ]];then
		top100_host
		top100_ip
		top100_url
		status_code
		4xx_status
	else
		url_top100 "$@"
	fi
}

main "$@"
