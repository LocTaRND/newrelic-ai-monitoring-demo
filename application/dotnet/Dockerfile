# Build .NET backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy project files for restore
COPY . .
RUN dotnet restore \
    && dotnet publish -c Release -o out

# Final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=build /app/out ./
ENV ASPNETCORE_URLS=http://+:9080
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 9080
ENTRYPOINT ["dotnet", "WebApi.dll"]
