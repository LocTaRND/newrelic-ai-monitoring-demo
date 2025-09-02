namespace WebApi.Helpers;

using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;

public class ErrorHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger _logger;

    public ErrorHandlerMiddleware(RequestDelegate next, ILogger<ErrorHandlerMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task Invoke(HttpContext context)
    {
        try
        {
            await _next(context);
            
            // Check if response status code is 400 and convert to 500
            if (context.Response.StatusCode == 400)
            {
                // Log the 400 to 500 conversion as an error
                _logger.LogError("HTTP 400 Bad Request converted to 500 Internal Server Error for enhanced monitoring. Original request path: {RequestPath}", context.Request.Path);
                
                // Create an exception for better New Relic error tracking
                var badRequestException = new InvalidOperationException($"Bad Request converted to Internal Server Error for path: {context.Request.Path}");
                _logger.LogError(badRequestException, "BAD REQUEST ERROR: HTTP 400 status converted to 500 for New Relic error tracking");
                
                // Convert 400 to 500
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            }
        }
        catch (Exception error)
        {
            var response = context.Response;
            response.ContentType = "application/json";

            switch (error)
            {
                case AppException e:
                    // Convert custom application error from 400 to 500 with error logging
                    _logger.LogError(e, "APPLICATION ERROR: AppException converted from 400 to 500 - {ErrorMessage}", e.Message);
                    response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    break;
                case KeyNotFoundException e:
                    // not found error
                    response.StatusCode = (int)HttpStatusCode.NotFound;
                    break;
                default:
                    // unhandled error
                    _logger.LogError(error, "UNHANDLED ERROR: {ErrorMessage}", error.Message);
                    response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    break;
            }

            var result = JsonSerializer.Serialize(new { message = error?.Message });
            await response.WriteAsync(result);
        }
    }
}