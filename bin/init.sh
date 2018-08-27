#!/usr/bin/env bash

# Since: 2018/07/26
# Description: init java/go/shell/python project with log4
# like:
    # ./init.sh java project_name #init java project_name in ../bin/project_name with log4j
    # ./bin/init.sh shell project_name #init shell project_name in ../bin/project_name with log4sh
    # sh init.sh python project_name #init python project_name in ../bin/project_name with log4p
    # sh ./bin/init.sh go project_name #init go project_name in ../bin/project_name with log4go
MY_PATH=`dirname $0`
cd $MY_PATH
MY_PATH=`pwd`
function init(){
    project_path=../$2
    if [ -d $project_path ];then
        echo "$project_path has exist!"
        exit 1
    else
        mkdir -p $project_path
    fi
    # [[ ! -d $project_path ]] && mkdir -p $project_path
    case $1 in
        java)
            cp -r ../JavaLogDemo/ $project_path/
        ;;
        shell)
            echo $project_path
            cp ../shellLogDemo/log4sh $project_path/
            cp ../shellLogDemo/log4sh.properties $project_path/
            cp ../shellLogDemo/demo.sh $project_path/
        ;;
        python)
            cp ../pythonLogDemo/log4p.json $project_path/
            cp ../pythonLogDemo/requirements.txt $project_path/
            cp ../pythonLogDemo/demo.py $project_path/
        ;;
        go)
            cp ../goLogDemo/example.json $project_path/
            cp ../goLogDemo/demo.go $project_path/
        ;;
    esac

}
[[ $# == 0 ]] && echo "\nNeed to point which program you want to init?
                like:
                ./init.sh java project_name #init java project_name in ../bin/project_name with log4j
                ./bin/init.sh shell project_name #init shell project_name in ../bin/project_name with log4sh
                sh init.sh python project_name #init python project_name in ../bin/project_name with log4p
                sh ./bin/init.sh go project_name #init go project_name in ../bin/project_name with log4go
                " && exit 1
case $1 in
    java|shell|python|go)
        init $@
    ;;
    * )
        echo "argument error!ex. sh bin/init.sh java ProjectName"
    ;;
esac
