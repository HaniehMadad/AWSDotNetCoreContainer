Param(
    [string]
    $ECR_REPO_NAME,
    [string]
    $ECR_IMG_TAG,
    [string]
    $CONTAINER_NAME
)

$CONTAINER_NAME = "NetCoreApp"
$ECR_REPO_NAME = "dotnetcorehelloworld"
$ECR_REPO_URI = "200053207227.dkr.ecr.ap-southeast-2.amazonaws.com/$ECR_REPO_NAME"
$ECR_IMG_TAG = "2"
$IMG_NAME = "netcoreapp"
$IMG_NAME_VERSION = "$($IMG_NAME):$($ECR_IMG_TAG)"

# Write-Host "Info: Login to ECR"
Invoke-Expression –Command (Get-ECRLoginCommand).Command

Invoke-Expression -Command:"docker build -t $IMG_NAME_VERSION ../."
Invoke-Expression -Command:"docker tag $IMG_NAME_VERSION $($ECR_REPO_URI):$($ECR_IMG_TAG)"
Invoke-Expression -Command "docker push $($ECR_REPO_URI):$($ECR_IMG_TAG)"

Write-Host "Info: Replace ECR variables in Dockerrun.aws.json"

Get-Content ./Dockerrun.aws.template.json | 
ForEach-Object {$_ -Replace "CONTAINER_NAME", $CONTAINER_NAME} | 
ForEach-Object {$_ -Replace "ECR_REPO_NAME", $ECR_REPO_NAME} | 
ForEach-Object {$_ -Replace "ECR_IMG_TAG", $ECR_IMG_TAG} | 
Out-File ./Dockerrun.aws.json