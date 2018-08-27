#!/usr/bin/env bash

# Since: 2018/08/20
# Description: Generate a configuration file based on a given path 
#              start logstash container
#              stop&rm logstash container
# like:
    # ./operateLogstash.sh conf #默认路径/data0/dorylus/local/gitlab/logs
    # ./operateLogstash.sh conf /data1/dorylus #指定路径
    # ./operateLogstash.sh start #默认路径/data0/dorylus/local/gitlab/logs
    # ./operateLogstash.sh stop

# 存储最深子目录列表
dir_list=()
# 给定的log根目录
base_dir="/data0/dorylus/local/gitlab/logs"
# logstash目录
conf_path="/data0/dorylus/pipeline"
conf_file="$conf_path/logstash.conf"
# elasticsearch服务
address="127.0.0.1:9200"
# logstash docker image
docker_file="registry.api.weibo.com/weibo_qa_dorylus/logstash:6.3.2"
# container name
container_name="logstash"
# 递归读取最深子目录
function read_dir(){
    # echo -e $1
    if [ "`ls $1`" = "" ] || [ `ls -l $1|grep ^d|wc -l` -eq 0 ]
    then
        dir_list[${#dir_list[@]}]=$1
    else
        for file in `ls $1`
        do
            if [ -d $1"/"$file ]
            then
                read_dir $1"/"$file
            fi
        done
    fi
}
# 将根目录下所有最深文件夹写入配置文件
function write_conf_file(){
    # 写入input配置
    echo -e "input {" > $conf_file
    for dir in ${dir_list[@]}
    do
        
        # echo -e  "\tfile {" >> $conf_file
        path=$dir
        # 除根路径的子目录
        obj_dir=${dir:((${#base_dir}+1))}
        # 将／替换成-
        type=${obj_dir//\//-}
        echo "  file {
		path => [\"$path/*.log*\"]
		type => \"$type\"
		start_position => "beginning"
	    }"  >> $conf_file
        
    done
    echo -e "}" >> $conf_file
    # 写入filter配置，过滤日志信息
    echo  "filter {
	grok {
		match => [
            \"message\", \"%{TIMESTAMP_ISO8601:logtime}\s+\[%{LOGLEVEL:loglevel}\]\s+%{DATA:logid}\s+%{DATA:method}\s+%{GREEDYDATA:msg}\",
            \"message\", \"\[%{DATA:logtime}\] *\[%{LOGLEVEL:loglevel}\] *%{DATA:method} * %{GREEDYDATA:msg}\"
        ]
        }
    }" >> $conf_file
    # 写入output配置
    echo -e "output {" >> $conf_file
    for dir in ${dir_list[@]}
    do
        obj_dir=${dir:((${#base_dir}+1))}
        type=${obj_dir//\//-}
        echo "  if [type] == \"$type\" {
		elasticsearch {
		hosts => [\"$address\"]
		index => \"$type-%{+YYYY.MM.dd}\"
		}
	}" >> $conf_file
        
    done
    echo  "}" >> $conf_file

}
function conf(){
    if [ ! -d $conf_path ];then
        mkdir -p $conf_path
    fi
    read_dir $base_dir
    write_conf_file $dir_list
}
# 启动logstash服务
function start(){
    conf $1
    # echo ${dir_list[*]}
    v_conf=""
    # 根据获取的子目录列表，挂载各子目录
    for dir in ${dir_list[@]}
    do
        v_conf=$v_conf" -v $dir/:$dir/"
    done
    command="sudo docker run --name $container_name --net=host -d  --env XPACK.MONITORING.ELASTICSEARCH.URL=http://$address -v $conf_path/:/usr/share/logstash/pipeline/ $v_conf  $docker_file"
    $command
    # sudo docker run --name $container_name --net=host --rm -ti -v $conf_path/:/usr/share/logstash/pipeline/ -v /data0/dorylus/config/logstash.yml:/usr/share/logstash/config/logstash.yml  $docker_file
}
# 停止logstash服务
function stop(){
    docker stop $container_name
    docker rm -f $container_name
}
[[ $# == 0 ]] && echo -e "\nNeed to point which program you want to init?
                like:
                ./operateLogstash.sh conf  #根据给定路径生成logstash.conf配置文件
                ./operateLogstash.sh start # 启动logstash服务
                ./operateLogstash.sh stop # 停止并删除logstash服务
                "&& exit 1
[[ $# == 2 ]] && $base_dir=$2
case $1 in
    conf|start)
        $1 $base_dir
    ;;
    stop)
        $1
    ;;
    * )
        echo -e "argument error!like:
                ./operateLogstash.sh conf [path] #根据给定路径生成logstash.conf配置文件,默认路径为/data0/dorylus/local/gitlab/logs
                ./operateLogstash.sh start [path] #启动logstash服务
                ./operateLogstash.sh stop # 停止并删除logstash服务"
    ;;
esac
