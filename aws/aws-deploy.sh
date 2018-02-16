APP_NAME=Docker
ENV_NAME=testdocker18

APP_VERSION=18
APP_ZIP_VERSION=$APP_VERSION.zip



S3_BUCKET=elasticbeanstalk-ap-southeast-2-200053207227
S3_BUCKET_KEY=docker-app-versions/$APP_ZIP_VERSION



aws configure set default.region ap-southeast-2

# Authenticate against our Docker registry
eval $(aws ecr get-login)

# Zip up the Dockerrun file (feel free to zip up an .ebextensions directory with it)
zip -r $APP_ZIP_VERSION Dockerrun.aws.json .ebextensions

aws s3 cp $APP_ZIP_VERSION s3://$S3_BUCKET/$S3_BUCKET_KEY

# Create a new application version with the zipped up Dockerrun file
aws elasticbeanstalk create-application-version --application-name $APP_NAME --version-label $APP_ZIP_VERSION --source-bundle S3Bucket=$S3_BUCKET,S3Key=$S3_BUCKET_KEY

# # Create a new environment
aws elasticbeanstalk check-dns-availability --cname-prefix $ENV_NAME
aws elasticbeanstalk create-environment --application-name $APP_NAME --version-label $APP_ZIP_VERSION --environment-name $ENV_NAME --solution-stack-name "64bit Amazon Linux 2017.09 v2.8.4 running Multi-container Docker 17.09.1-ce (Generic)"



# Update the environment to use the new application version
#aws elasticbeanstalk update-environment --environment-name $NAME --version-label $VERSION
