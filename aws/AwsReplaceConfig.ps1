function Replace-Config
{
    param(
        [parameter(Mandatory = $true)]
        [string]
        $CONTAINER1_NAME,
        [parameter(Mandatory = $true)]
        [string]
        $CONTAINER1_ECR_REPO,
        [parameter(Mandatory = $true)]
        [string]
        $CONTAINER1_REPO_NAME,
        [parameter(Mandatory = $true)]
        [string]
        $CONTAINER1_IMG_TAG
    )

    Write-Host "Info: Replace ECR variables in Dockerrun.aws.json"

    $rootDir = $PSScriptRoot
    Get-Content $rootDir/Dockerrun.aws.template.json | 
    ForEach-Object {$_ -Replace "CONTAINER1_NAME", $CONTAINER1_NAME} | 
    ForEach-Object {$_ -Replace "CONTAINER1_ECR_REPO", $CONTAINER1_ECR_REPO} | 
    ForEach-Object {$_ -Replace "CONTAINER1_REPO_NAME", $CONTAINER1_REPO_NAME} | 
    ForEach-Object {$_ -Replace "CONTAINER1_IMG_TAG", $CONTAINER1_IMG_TAG} | 
    Out-File $rootDir/Dockerrun.aws.json
}