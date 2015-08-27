#!/bin/bash

LOCATION='/root/sysdata'   #生成JSON文件路径,替换成你的路径
API_KEY='DiYPacfrEEZIV83YrPGEDktRqayutsfSFj0WeZbxmVU7mfVH' #API使用的KEY,替换成你的KEY
FEED_ID='1205479287' #提交数据的FEED,替换成你的FEED_ID
####################################################

COSM_URL=https://api.xively.com/v2/feeds/${FEED_ID}?timezone=+8

##CPU负载
cpu_load=`cat /proc/loadavg | awk '{print $2*1}'`

##Raspberry温度
for i in 1 2 3 4 5; do
        cpu_t=`cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}'`
        if [[ "${cpu_t}" =~ ^- ]]
        then
                cpu_t='0.0'
        else
                echo ${cpu_t}
                break
        fi
done

##硬盘使用量
disk_load=`df | awk '/rootfs/ {print $5/100}'`

##内存使用量
mem=`free | awk '/Mem/ {print $4/$2 * 1}'`

STR=`awk 'BEGIN{printf "{\"datastreams\":[ {\"id\":\"load\",\"current_value\":\"%.2f\"}, {\"id\":\"temp\",\"current_value\":\"%.2f\"}, {\"id\":\"disk\",\"current_value\":\"%.2f\"}, {\"id\":\"mem\",\"current_value\":\"%.2f\"}] } ",'$cpu_load','$cpu_t','$disk_load','$mem'}'`

echo ${cpu_t}
echo ${cpu_load}
echo ${disk_load}
echo ${mem}
echo ${STR}
echo ${STR} > ${LOCATION}/cosm.json
curl -s -v --request PUT --header "X-ApiKey: ${API_KEY}" --data-binary @${LOCATION}/cosm.json ${COSM_URL}

