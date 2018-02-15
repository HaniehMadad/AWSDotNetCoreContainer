## AWSDotNetCoreContainer
This is a hello world dot net core app  which can be run as a docker container and deploy to AWS Elastic Beanstalk

## Create a new dot net core application

1. create a helloworld project from ASP.NET Core Web App (razor) template 
``` dotnet new razor -o helloworldapp ```
2. cd to the newly created folder
``` cd helloworldapp ```
3. run the app
``` dotnet run ```
3. you might need to install npm packages 
``` npm install ```
5. Browse to http://localhost:5000

# Reference
https://www.asp.net/get-started

## Use the standard Dockerfile to create an image
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

# Reference
https://hub.docker.com/r/microsoft/aspnetcore/



