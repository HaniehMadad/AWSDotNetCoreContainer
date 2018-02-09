#!/bin/sh

APP_NAME="testHanieh"
ENV_NAME="testDocker13"
App_Version="testdocker6"

aws elasticbeanstalk check-dns-availability --cname-prefix $ENV_NAME
aws elasticbeanstalk create-environment --application-name $APP_NAME --version-label $App_Version --environment-name $ENV_NAME --template-name dockerconfig --solution-stack-name "64bit Amazon Linux 2017.09 v2.8.4 running Multi-container Docker 17.09.1-ce (Generic)"

