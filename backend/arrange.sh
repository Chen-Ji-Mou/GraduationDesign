#!/bin/sh

port=8088

# 根据端口号查询对应的pid
pid=$(netstat -nlp|grep :$port|awk '{ print $7 }'|awk -F"/" '{ print $1 }')

# 杀掉对应的进程，如果pid不存在，则不执行
if [ -n "$pid" ]; then
  kill -9 "$pid"
fi

if [ -f log.txt ]; then
  rm -rf log.txt
fi

if [ -f upload ]; then
  rm -rf upload
fi

if [ -f backend-release.jar ];
then
  nohup java -jar backend-release.jar >log.txt 2>&1 &
  while [ "$(netstat -nlp|grep :$port|awk '{ print $7 }'|awk -F"/" '{ print $1 }')" != "$!" ]
  do
    echo "Pid $! process starting..."
    sleep 1
  done
  echo "Pid $! process started"
else
  echo "The backend-release.jar is not exist"
fi