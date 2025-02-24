#!/usr/bin/env bash
# start.sh

PROJECT="ezenshop-1.0.0"
PROJECT_NAME=ezenshop
PROJECT_FULL_PATH="/home/ec2-user/app2/step1"
JAR_FILE="$PROJECT_FULL_PATH/$PROJECT.jar"
LOG_PATH="$PROJECT_FULL_PATH/logs"

APP_LOG="$LOG_PATH/application.log"
ERROR_LOG="$LOG_PATH/error.log"
DEPLOY_LOG="$LOG_PATH/0_deploy.log"

# 현재 날짜/시간정보를 변수에 저장.
NOW_DATETIME=$(date "+%Y-%m-%d-%aT%T")

# $LOG_PATH 변수명에 폴더가 존재하지 않으면 폴더생성
if [ ! -d $LOG_PATH ]; then
    mkdir $LOG_PATH
fi

# echo "문자열" 화면에 출력
# build 파일 복사
echo "$NOW_DATETIME > $JAR_FILE 파일 복사" >> $DEPLOY_LOG

# 폴더변경
cd $PROJECT_FULL_PATH

# target 폴더안에 있는 jar파일을 step1 으로 복사
cp $PROJECT_FULL_PATH/ezenshop/target/*.jar $JAR_FILE
#sudo cp /home/ec2-user/app1/step1/ezenshop/target/ezenshop-1.0.0.jar.jar ezenshop-1.0.0.jar

# 폴더변경
cd $PROJECT_FULL_PATH


# 기존 실행중인 프로세스 종료
CURRENT_PID=$(pgrep -f $JAR_FILE)

# 문자열 $CURRENT_PID 이 비어있지 않으면(null이 아니면) 참(true)이 됩니다. 프로세스가 존재한다면 의미.
if [ -n "$CURRENT_PID" ]; then
    echo "Stopping existing process: $CURRENT_PID"
    kill -15 "$CURRENT_PID"
    sleep 5
fi

# jar 파일실행
#nohup java -jar $JAR_FILE 1>$APP_LOG 2>$ERROR_LOG &
#nohup java -jar $JAR_FILE 1>>$APP_LOG 2>>$ERROR_LOG &
#nohup java -jar -Dspring.config.location=classpath:/application.properties,/home/ec2-user/app1/application-prod-db.properties -Dspring.profiles.active=prod $JAR_FILE > $APP_LOG 2> $ERROR_LOG &

# ec2 80 port 는 sudo권한사용
# 스프링 부트 프로젝트 java -jar ezenshop-1.0.0.jar 실행
sudo nohup java -jar -Dspring.config.location=classpath:/application.properties,/home/ec2-user/app1/application-real.properties $JAR_FILE > $APP_LOG 2> $ERROR_LOG &

sleep 30s

NEW_PID=$(pgrep -f $JAR_FILE)

# 문자열 NEW_PID이 비어 있으면(null이면) 참(true)이 됩니다. 프로세스가 존재하지 않는다는 의미.
if [ -z "$NEW_PID" ]; then
  echo "$NOW_DATETIME :: $JAR_FILE :: failed to start!" >> $DEPLOY_LOG
else
  echo "$NOW_DATETIME :: $JAR_FILE :: $CURRENT_PID started!" >> $DEPLOY_LOG
fi
