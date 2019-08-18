FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2.6-alpine3.9 AS runtime
EXPOSE 80
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "WebGateway.dll"]