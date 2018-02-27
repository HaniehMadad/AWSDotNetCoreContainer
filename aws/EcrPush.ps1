Param(
    [string]
    $CONTAINER1_REPO_NAME,
    [string]
    $CONTAINER1_IMG_TAG,
    [string]
    $CONTAINER1_NAME
)

$CONTAINER1_NAME = "NetCoreApp"
$CONTAINER1_ECR_REPO = "200053207227.dkr.ecr.ap-southeast-2.amazonaws.com"
$CONTAINER1_REPO_NAME = "dotnetcorehelloworld"
$ECR_REPO_URI = "$CONTAINER1_ECR_REPO/$CONTAINER1_REPO_NAME"
$CONTAINER1_IMG_TAG = "3"
$IMG_NAME = "dotnetcoreapp"
$IMG_NAME_VERSION = "$($IMG_NAME):$($CONTAINER1_IMG_TAG)"

$loggedIn = aws sts get-caller-identity
if (!$loggedIn){
    throw "Your security token has likely expired!  Run tatts-aws-login again to refresh your token!"
}

Write-Host "Info: Login to ECR"
Invoke-Expression –Command (Get-ECRLoginCommand).Command

Write-Host "Info: Build and push the docker image"
$appDir = Convert-Path $PSScriptRoot/..
Invoke-Expression -Command:"docker build -t $IMG_NAME_VERSION $appDir/."
Invoke-Expression -Command:"docker tag $IMG_NAME_VERSION $($ECR_REPO_URI):$($CONTAINER1_IMG_TAG)"
Invoke-Expression -Command "docker push $($ECR_REPO_URI):$($CONTAINER1_IMG_TAG)"

Write-Host "Info: Replace ECR variables in Dockerrun.aws.json"
$rootDir = $PSScriptRoot
Get-Content $rootDir/Dockerrun.aws.template.json | 
ForEach-Object {$_ -Replace "CONTAINER1_NAME", $CONTAINER1_NAME} | 
ForEach-Object {$_ -Replace "CONTAINER1_ECR_REPO", $CONTAINER1_ECR_REPO} | 
ForEach-Object {$_ -Replace "CONTAINER1_REPO_NAME", $CONTAINER1_REPO_NAME} | 
ForEach-Object {$_ -Replace "CONTAINER1_IMG_TAG", $CONTAINER1_IMG_TAG} | 
Out-File $rootDir/Dockerrun.aws.json