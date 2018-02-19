# AWSDotNetCoreContainer
This is a hello world dot net core app  which can be run as a docker container and deploy to AWS Elastic Beanstalk

# Create a new dot net core application

1. create a helloworld project from ASP.NET Core Web App (razor) template 
``` dotnet new razor -o helloworldapp ```
2. cd to the newly created folder
``` cd helloworldapp ```
3. run the app
``` dotnet run ```
3. you might need to install npm packages 
``` npm install ```
5. Browse to http://localhost:5000

## Reference
https://www.asp.net/get-started

# Use the standard Dockerfile to create an image
1. create a Dockerfile in the root directory as below:
```
FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app

COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "helloworldapp.dll"]
```
2. Build and run your app:
``` bash
$ docker build -t helloworldapp .
$ docker run -d -p 8000:80 helloworldapp
```
3. Browse to localhost:8000 to access your app.

## Reference
https://hub.docker.com/r/microsoft/aspnetcore/

# Use circleci for CI
1. Set up your github repo to circleci's project
2. Add circleci's config yml file under helloworldapp/.circleci/config.yml
```
version: 2
jobs:

  build:
    docker:
      - image: hanieh/dotnetcore-aws-cli-docker-ce
    environment:
      DOTNET_SKIP_FIRST_TIME_EXPERIENCE: 1
      DOTNET_CLI_TELEMETRY_OPTOUT: 1
    steps:
      - checkout
      # For security purposes, circleci requires this step to isolate remote docker commands. 
      # More info at: https://circleci.com/docs/2.0/building-docker-images/
      - setup_remote_docker
      # Login to AWS with IAM credentials
      - run: eval "$(aws ecr get-login --no-include-email --region ap-southeast-2)"
      - run: docker build -t dotnetcorehelloworld:$CIRCLE_BUILD_NUM .
      # Tag image with version
      - run:  docker tag dotnetcorehelloworld:$CIRCLE_BUILD_NUM 200053207227.dkr.ecr.ap-southeast-2.amazonaws.com/dotnetcorehelloworld:$CIRCLE_BUILD_NUM
      # Push image to ECR
      - run: docker push 200053207227.dkr.ecr.ap-southeast-2.amazonaws.com/dotnetcorehelloworld:$CIRCLE_BUILD_NUM
```
this configuration using https://hub.docker.com/r/hanieh/dotnetcore-aws-cli-docker-ce/ image which would have Docker CE and AWS CLI installed so we can login to AWS ECR (Elastic Container Registry) and push our image.

3. Add AWS IAM user credential to the circleci's project settings, under *AWS Permissions*

## Reference
https://aws.amazon.com/ecr/
https://circleci.com/blog/aws-ecr-auth-support/

# Push to ECR and Deploy to EB
1. Run the script ./aws/ecr-push.ps1 to push the latest change to ECR
2. Run the script ./aws/aws-deploy.ps1 to deploy to EB



