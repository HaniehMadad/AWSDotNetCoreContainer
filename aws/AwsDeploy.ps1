. "$PSScriptRoot\AwsReplaceConfig.ps1"

$rootDir = $PSScriptRoot
$configFileName = "$rootDir\AwsClientConfig.json"
$configFile = ConvertFrom-JSON (Get-Content $configFileName -Raw)

$APP_NAME = $configFile.ApplicationName
$APP_VERSION = $configFile.VersionLabel
$ENV_NAME= $configFile.EnvironmentName
$DEFAULT_REGION = $configFile.DefaultRegion
$APP_DESC = $configFile.ApplicationDescription
$STACK_NAME = $configFile.SrackName
$S3_BUCKET = $configFile.S3BucketName
$S3_BUCKET_KEY = $configFile.S3BucketFolder+"/$APP_VERSION"

# Replace ECR variables in Dockerrun.aws.json"
$CONTAINER1_NAME = $configFile.Container1Name
$CONTAINER1_ECR_REPO = $configFile.Container1EcrRepo
$CONTAINER1_REPO_NAME = $configFile.Container1EcrRepoName
$CONTAINER1_IMG_TAG = $configFile.Container1EcrImageTag

Replace-Config -CONTAINER1_NAME $CONTAINER1_NAME -CONTAINER1_ECR_REPO $CONTAINER1_ECR_REPO -CONTAINER1_REPO_NAME $CONTAINER1_REPO_NAME -CONTAINER1_IMG_TAG $CONTAINER1_IMG_TAG

# Zip up the Dockerrun file (feel free to zip up an .ebextensions directory with it)
Compress-Archive -Path Dockerrun.aws.json,$rootDir/.ebextensions -DestinationPath myapp.zip -Force

$loggedIn = aws sts get-caller-identity
if (!$loggedIn){
    throw "Your security token has likely expired!  Run tatts-aws-login again to refresh your token!"
}

Set-DefaultAWSRegion -Region $DEFAULT_REGION

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


