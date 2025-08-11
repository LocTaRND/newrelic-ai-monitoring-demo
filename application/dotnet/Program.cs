﻿using System.Text.Json.Serialization;
using WebApi.Helpers;
using WebApi.Services;

var builder = WebApplication.CreateBuilder(args);

// add services to DI container
{
    var services = builder.Services;
    var env = builder.Environment;
 
    services.AddDbContext<DataContext>();
    services.AddCors();
    services.AddControllers().AddJsonOptions(x =>
    {
        // serialize enums as strings in api responses (e.g. Role)
        x.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());

        // ignore omitted parameters on models to enable optional params (e.g. User update)
        x.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    });
    services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

    // configure DI for application services
    services.AddScoped<IUserService, UserService>();

    // Add Swagger services
    services.AddEndpointsApiExplorer();
    services.AddSwaggerGen();

    // Add health checks for PostgreSQL
    services.AddHealthChecks()
        .AddNpgSql(builder.Configuration.GetConnectionString("ApiDatabase"));
}

var app = builder.Build();

// configure HTTP request pipeline
{

    // global cors policy
    app.UseCors(x => x
        .AllowAnyOrigin()
        .AllowAnyMethod()
        .AllowAnyHeader());

    // global error handler
    app.UseMiddleware<ErrorHandlerMiddleware>();

    app.MapControllers();

    // Health check endpoint
    app.MapHealthChecks("/health");

    // Enable Swagger middleware
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Web API V1");
        c.RoutePrefix = "swagger";
    });
}

app.Run("http://0.0.0.0:9080");