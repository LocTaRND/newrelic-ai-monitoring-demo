namespace WebApi.Controllers;

using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using WebApi.Models.Users;
using WebApi.Services;

[ApiController]
[Route("api/v1/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly IMapper _mapper;
    private readonly ILogger<UsersController> _logger;

    public UsersController(
        IUserService userService,
        IMapper mapper,
        ILogger<UsersController> logger)
    {
        _userService = userService;
        _mapper = mapper;
        _logger = logger;
    }

    #region Standard CRUD Operations

    [HttpGet]
    public IActionResult GetAll()
    {
        var users = _userService.GetAll();
        return Ok(users);
    }

    [HttpGet("{id}")]
    public IActionResult GetById(int id)
    {
        var user = _userService.GetById(id);
        return Ok(user);
    }

    [HttpPost]
    public IActionResult Create(CreateRequest model)
    {
        _userService.Create(model);
        return Ok(new { message = "User created" });
    }

    [HttpPut("{id}")]
    public IActionResult Update(int id, UpdateRequest model)
    {
        _userService.Update(id, model);
        return Ok(new { message = "User updated" });
    }

    [HttpDelete("{id}")]
    public IActionResult Delete(int id)
    {
        _userService.Delete(id);
        return Ok(new { message = "User deleted" });
    }

    #endregion

    #region Error Simulation Endpoints for New Relic Testing

    /// <summary>
    /// Simulates a basic application error with exception throwing
    /// </summary>
    [HttpGet("simulate-error")]
    public IActionResult SimulateError()
    {
        try 
        {
            _logger.LogError("Starting error simulation for New Relic testing");
            
            // Create a detailed exception
            var exception = new ApplicationException("Simulated backend error for New Relic testing!");
            
            // Log the exception explicitly at ERROR level
            _logger.LogError(exception, "Critical error occurred during simulation: {ErrorMessage}", exception.Message);
            
            // This will be captured by New Relic APM as an error
            throw exception;
        }
        catch (Exception ex)
        {
            // Ensure the exception is logged at ERROR level
            _logger.LogError(ex, "Unhandled exception in SimulateError endpoint");
            throw; // Re-throw to ensure proper error response
        }
    }

    /// <summary>
    /// Simulates critical system errors with multiple ERROR and CRITICAL logs
    /// </summary>
    [HttpGet("simulate-critical-error")]
    public IActionResult SimulateCriticalError()
    {
        // Create an exception for proper error logging
        var exception = new InvalidOperationException("Critical system failure detected - Database connection lost");
        
        // Log critical error with exception context
        _logger.LogCritical(exception, "CRITICAL ERROR: System failure during operation. Error: {ErrorMessage}", exception.Message);
        _logger.LogError(exception, "ERROR: Database connection failed during critical operation");
        _logger.LogError(exception, "ERROR: Transaction rollback initiated due to critical failure");
        
        // Log additional error context
        _logger.LogError("ERROR: Service unavailable - returning HTTP 500");
        
        return StatusCode(500, new { 
            error = "Critical system error occurred",
            details = "Simulated critical failure for New Relic testing",
            timestamp = DateTime.UtcNow,
            errorCode = "SYS_CRITICAL_001"
        });
    }

    /// <summary>
    /// Forces multiple types of ERROR level logs
    /// </summary>
    [HttpGet("force-error-log")]
    public IActionResult ForceErrorLog()
    {
        // Create multiple error scenarios with concrete exception types
        var dbException = new InvalidOperationException("Database connection timeout occurred");
        var networkException = new HttpRequestException("Network connection failed - unable to reach external service");
        var validationException = new ArgumentException("Invalid user input provided - missing required fields");

        // Log each as explicit ERROR level with exception context
        _logger.LogError(dbException, "DATABASE ERROR: Connection timeout occurred - {ErrorType}", "DatabaseTimeout");
        _logger.LogError(networkException, "NETWORK ERROR: Connection failed - {ErrorType}", "NetworkFailure");  
        _logger.LogError(validationException, "VALIDATION ERROR: Invalid input received - {ErrorType}", "ValidationError");
        
        // Additional structured error logging
        _logger.LogError("BUSINESS ERROR: Critical business rule violation detected at {Timestamp}", DateTime.UtcNow);
        _logger.LogError("SECURITY ERROR: Unauthorized access attempt detected from endpoint");

        return StatusCode(500, new { 
            error = "Multiple system errors detected",
            details = "Forced error logging for New Relic testing",
            errorTypes = new[] { "Database", "Network", "Validation", "Business", "Security" },
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates timeout scenarios
    /// </summary>
    [HttpGet("simulate-timeout")]
    public IActionResult SimulateTimeout()
    {
        var timeoutException = new TimeoutException("Operation timed out after 30 seconds");
        
        _logger.LogError(timeoutException, "TIMEOUT ERROR: Operation exceeded maximum allowed time - {TimeoutSeconds}s", 30);
        _logger.LogError("PERFORMANCE ERROR: Slow database query detected - consider optimization");
        
        return StatusCode(504, new { 
            error = "Gateway Timeout",
            details = "Operation timed out - simulated for New Relic testing",
            timeoutDuration = "30s",
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates memory-related errors
    /// </summary>
    [HttpGet("simulate-memory-error")]
    public IActionResult SimulateMemoryError()
    {
        var memoryException = new OutOfMemoryException("Insufficient memory to complete operation");
        
        _logger.LogCritical(memoryException, "CRITICAL MEMORY ERROR: System running low on available memory");
        _logger.LogError(memoryException, "SYSTEM ERROR: Memory allocation failed for user operation");
        _logger.LogError("RESOURCE ERROR: Available memory below critical threshold - {AvailableMemory}MB", 128);
        
        return StatusCode(503, new { 
            error = "Service Unavailable - Memory Issues",
            details = "Insufficient system resources - simulated error",
            errorCode = "MEM_CRITICAL_002",
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates authentication and authorization errors
    /// </summary>
    [HttpGet("simulate-auth-error")]
    public IActionResult SimulateAuthError()
    {
        var authException = new UnauthorizedAccessException("Invalid authentication token provided");
        
        _logger.LogError(authException, "SECURITY ERROR: Authentication failed for user request");
        _logger.LogWarning("SECURITY WARNING: Multiple failed authentication attempts detected");
        _logger.LogError("ACCESS ERROR: Unauthorized access attempt from endpoint - IP logging recommended");
        
        return StatusCode(401, new { 
            error = "Unauthorized Access",
            details = "Authentication failed - simulated security error",
            errorCode = "AUTH_ERROR_001",
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates data corruption scenarios
    /// </summary>
    [HttpGet("simulate-data-corruption")]
    public IActionResult SimulateDataCorruption()
    {
        var dataException = new InvalidDataException("Data integrity check failed - corruption detected");
        
        _logger.LogCritical(dataException, "CRITICAL DATA ERROR: Data corruption detected in user records");
        _logger.LogError(dataException, "DATABASE ERROR: Data integrity violation - {TableName}", "Users");
        _logger.LogError("BACKUP ERROR: Automated backup initiated due to data corruption");
        _logger.LogError("RECOVERY ERROR: Manual intervention required for data recovery");
        
        return StatusCode(500, new { 
            error = "Data Corruption Detected",
            details = "Critical data integrity failure - simulated error",
            affectedTable = "Users",
            errorCode = "DATA_CORRUPT_001",
            recoveryRequired = true,
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates cascade system failures
    /// </summary>
    [HttpGet("simulate-cascade-failure")]
    public IActionResult SimulateCascadeFailure()
    {
        // Simulate multiple system failures happening in sequence
        var dbException = new InvalidOperationException("Primary database connection failed");
        var cacheException = new InvalidOperationException("Redis cache server unavailable");
        var serviceException = new HttpRequestException("External API service unreachable");
        
        _logger.LogCritical(dbException, "CRITICAL SYSTEM FAILURE: Primary database offline");
        _logger.LogError(cacheException, "CACHE ERROR: Redis server connection lost");
        _logger.LogError(serviceException, "SERVICE ERROR: External API dependencies failing");
        _logger.LogError("CASCADE ERROR: Multiple system components failing simultaneously");
        _logger.LogCritical("SYSTEM STATUS: Application entering degraded mode");
        _logger.LogError("ALERT: Operations team notification triggered");
        
        return StatusCode(503, new { 
            error = "Cascade System Failure",
            details = "Multiple critical systems offline - simulated disaster scenario",
            failedSystems = new[] { "Database", "Cache", "ExternalAPI" },
            errorCode = "CASCADE_FAIL_001",
            systemStatus = "Degraded",
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates business logic violations
    /// </summary>
    [HttpGet("simulate-business-logic-error")]
    public IActionResult SimulateBusinessLogicError()
    {
        var businessException = new InvalidOperationException("Business rule violation: Insufficient funds for transaction");
        
        _logger.LogError(businessException, "BUSINESS ERROR: Transaction failed - insufficient account balance");
        _logger.LogWarning("BUSINESS WARNING: User attempted transaction exceeding account limits");
        _logger.LogError("COMPLIANCE ERROR: Transaction violates business rules - {RuleId}", "FUND_LIMIT_001");
        
        return StatusCode(422, new { 
            error = "Business Logic Violation",
            details = "Transaction violates business rules - simulated error",
            violatedRule = "Insufficient Funds",
            errorCode = "BIZ_RULE_001",
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates different types of exceptions based on parameter
    /// </summary>
    [HttpGet("simulate-custom-exception/{errorType}")]
    public IActionResult SimulateCustomException(string errorType)
    {
        Exception exception = errorType.ToLower() switch
        {
            "null" => new NullReferenceException("Null reference encountered in user processing"),
            "argument" => new ArgumentNullException("userId", "Required user ID parameter is null"),
            "format" => new FormatException("Invalid date format provided in user data"),
            "overflow" => new OverflowException("Numeric value exceeds maximum allowed range"),
            "io" => new IOException("File system error while processing user data"),
            "network" => new HttpRequestException("Network connectivity issues detected"),
            "sql" => new InvalidOperationException("Database query execution failed"),
            "unauthorized" => new UnauthorizedAccessException("User lacks required permissions"),
            "notfound" => new KeyNotFoundException("Requested user record not found"),
            _ => new ApplicationException($"Unknown error type requested: {errorType}")
        };
        
        _logger.LogError(exception, "CUSTOM ERROR SIMULATION: {ErrorType} - {ErrorMessage}", 
            errorType.ToUpper(), exception.Message);
        _logger.LogError("ERROR CONTEXT: Simulated {ErrorType} for New Relic testing", errorType);
        
        return StatusCode(500, new { 
            error = $"Simulated {errorType} Error",
            details = exception.Message,
            errorType = errorType,
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates warning level logs (won't show as ERROR in New Relic)
    /// </summary>
    [HttpGet("simulate-warning")]
    public IActionResult SimulateWarning()
    {
        _logger.LogWarning("This is a simulated warning message for New Relic logging");
        _logger.LogWarning("WARNING: User performing suspicious activity - monitoring recommended");
        
        return Ok(new { message = "Warning logged successfully", timestamp = DateTime.UtcNow });
    }

    /// <summary>
    /// Simulates info level logs (won't show as ERROR in New Relic)
    /// </summary>
    [HttpGet("simulate-info")]
    public IActionResult SimulateInfo()
    {
        _logger.LogInformation("This is a simulated info message for New Relic logging");
        _logger.LogInformation("INFO: User operation completed successfully");
        
        return Ok(new { message = "Info logged successfully", timestamp = DateTime.UtcNow });
    }

    /// <summary>
    /// Test endpoint that throws unhandled exception (will be caught by global exception handler)
    /// </summary>
    [HttpGet("simulate-unhandled-exception")]
    public IActionResult SimulateUnhandledException()
    {
        _logger.LogInformation("About to throw unhandled exception");
        
        // This will be caught by global exception handling middleware
        throw new InvalidOperationException("This is an unhandled exception for testing global error handling");
    }

    /// <summary>
    /// Simulates database-specific errors
    /// </summary>
    [HttpGet("simulate-database-error")]
    public IActionResult SimulateDatabaseError()
    {
        var dbException = new InvalidOperationException("Connection to SQL Server failed - timeout expired");
        
        _logger.LogCritical(dbException, "DATABASE CRITICAL: Primary database connection failed");
        _logger.LogError(dbException, "DATABASE ERROR: Query execution timeout - {QueryTimeout}s", 30);
        _logger.LogError("DATABASE ERROR: Connection pool exhausted - max connections reached");
        _logger.LogError("DATABASE ERROR: Failover to backup database initiated");
        
        return StatusCode(503, new { 
            error = "Database Service Unavailable",
            details = "Primary database connection failed - failover in progress",
            errorCode = "DB_CONN_001",
            estimatedRecoveryTime = "5 minutes",
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates bad request that will be converted to 500 with error logging
    /// </summary>
    [HttpGet("simulate-bad-request")]
    public IActionResult SimulateBadRequest()
    {
        _logger.LogWarning("About to return HTTP 400 Bad Request - will be converted to 500 by middleware");
        
        return BadRequest(new { 
            error = "Bad Request - Invalid Input",
            details = "This 400 response will be converted to 500 by ErrorHandlerMiddleware",
            originalStatusCode = 400,
            timestamp = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Simulates validation error that normally returns 400 but will be converted to 500
    /// </summary>
    [HttpPost("simulate-validation-error")]
    public IActionResult SimulateValidationError([FromBody] object invalidData)
    {
        _logger.LogInformation("Received validation request with potentially invalid data");
        
        // Simulate validation failure
        return BadRequest(new { 
            error = "Validation Failed",
            details = "Required fields are missing or invalid - will be converted to 500",
            validationErrors = new[] { 
                "Email is required",
                "Name must be at least 2 characters",
                "Age must be between 18 and 120"
            },
            originalStatusCode = 400,
            timestamp = DateTime.UtcNow
        });
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Lists all available error simulation endpoints
    /// </summary>
    [HttpGet("error-simulation-help")]
    public IActionResult GetErrorSimulationHelp()
    {
        var endpoints = new
        {
            basicErrors = new[]
            {
                "simulate-error - Basic application error with exception",
                "simulate-critical-error - Critical system failure with multiple logs",
                "force-error-log - Multiple structured error logs"
            },
            systemErrors = new[]
            {
                "simulate-timeout - Gateway timeout simulation",
                "simulate-memory-error - Out of memory errors",
                "simulate-cascade-failure - Multiple system failures",
                "simulate-database-error - Database connection errors"
            },
            statusCodeConversion = new[]
            {
                "simulate-bad-request - HTTP 400 converted to 500 with error logging",
                "simulate-validation-error - POST validation failure converted to 500"
            },
            securityErrors = new[]
            {
                "simulate-auth-error - Authentication failures",
                "simulate-business-logic-error - Business rule violations"
            },
            customErrors = new[]
            {
                "simulate-custom-exception/{type} - Custom exception types",
                "Available types: null, argument, format, overflow, io, network, sql, unauthorized, notfound"
            },
            nonErrorLogs = new[]
            {
                "simulate-warning - Warning level logs",
                "simulate-info - Information level logs"
            },
            specialTests = new[]
            {
                "simulate-unhandled-exception - Unhandled exception test",
                "simulate-data-corruption - Data integrity failures"
            }
        };

        return Ok(new
        {
            message = "Available error simulation endpoints for New Relic testing",
            endpoints,
            usage = "Call any endpoint to generate corresponding log levels and error types",
            note = "Only ERROR and CRITICAL level logs will appear as errors in New Relic",
            statusCodeConversion = "HTTP 400 responses are automatically converted to 500 with error logging",
            timestamp = DateTime.UtcNow
        });
    }

    #endregion
}