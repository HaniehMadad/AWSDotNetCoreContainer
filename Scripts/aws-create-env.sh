#!/bin/sh

APP_NAME="testHanieh"
ENV_NAME="testDocker8"
App_Version="testdocker6"

aws elasticbeanstalk check-dns-availability --cname-prefix $ENV_NAME
aws elasticbeanstalk create-environment --cname-prefix $ENV_NAME --application-name $APP_NAME --version-label $App_Version --environment-name $ENV_NAME --solution-stack-name "64bit Amazon Linux 2017.09 v2.8.4 running Multi-container Docker 17.09.1-ce (Generic)"

