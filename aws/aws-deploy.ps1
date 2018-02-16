Param(
    [parameter(Mandatory = $true)]
    [string]
    $APP_NAME,
    [parameter(Mandatory = $true)]
    [string]
    $ENV_NAME,
    [parameter(Mandatory = $true)]
    [string]
    $APP_VERSION
)

# Parameters e.g.: $APP_NAME="Docker" $ENV_NAME="testdocker21" $APP_VERSION="21"
$DEFAULT_REGION = "ap-southeast-2"
$APP_DESC = ""
$STACK_NAME = "64bit Amazon Linux 2017.09 v2.8.4 running Multi-container Docker 17.09.1-ce (Generic)"
$S3_BUCKET = "elasticbeanstalk-$DEFAULT_REGION-200053207227"
$S3_BUCKET_KEY = "docker-app-versions/$APP_VERSION"

Set-DefaultAWSRegion -Region $DEFAULT_REGION

# Zip up the Dockerrun file (feel free to zip up an .ebextensions directory with it)
Compress-Archive -Path Dockerrun.aws.json,./.ebextensions -DestinationPath myapp.zip -Force

$appExists = Get-EBApplication -ApplicationName $APP_NAME

if (!$appExists)
{
    write-host "Info: Create application: $APP_NAME"
    New-EBApplication -ApplicationName $APP_NAME -Description $APP_DESC
}
else
{
    write-host "Warn: Application: '$APP_NAME' already exists!"
}

# Upload to s3
Write-Host "Info: Upload to s3"
Write-S3Object -BucketName $S3_BUCKET -Key $S3_BUCKET_KEY -File myapp.zip

$versionExists = Get-EBApplicationVersion -ApplicationName $APP_NAME -VersionLabel $APP_VERSION
if (!$versionExists)
{
    write-host "Info: Create an application version"
    New-EBApplicationVersion -ApplicationName $APP_NAME -VersionLabel $APP_VERSION -SourceBundle_S3Bucket $S3_BUCKET -SourceBundle_S3Key $S3_BUCKET_KEY
    Start-Sleep -Seconds 2
}
else 
{
    write-host "Warn: Application Version '$APP_VERSION' already exists!"
}

$environmentExists = Get-EBEnvironment -ApplicationName $APP_NAME -EnvironmentName $ENV_NAME
if ($environmentExists -ne $null)
{
    write-host "Info: Updating existing environment '$ENV_NAME' with version '$APP_VERSION'"
    Update-EBEnvironment -ApplicationName $APP_NAME -EnvironmentName $ENV_NAME -VersionLabel $APP_VERSION
}
else
{
    write-host "Info: Create Environment: $ENV_NAME"
    New-EBEnvironment -CNAMEPrefix $ENV_NAME -ApplicationName $APP_NAME -EnvironmentName $ENV_NAME -SolutionStackName $STACK_NAME -VersionLabel $APP_VERSION
}


