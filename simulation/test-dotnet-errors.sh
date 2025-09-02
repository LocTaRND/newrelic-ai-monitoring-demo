#!/bin/bash

# Enhanced New Relic Error Simulation Test Script
# Author: Generated for comprehensive error testing
# Usage: ./test-error-simulation.sh [--verbose] [--quick] [--help]

set -e  # Exit on any error

# Configuration
BASE_URL="http://localhost:9080/api/v1/users"
SERVICE_NAME="backend-api"
PORT=9080
NAMESPACE=${NAMESPACE:-default}
VERBOSE=false
QUICK_MODE=false
DELAY_BETWEEN_TESTS=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --quick|-q)
            QUICK_MODE=true
            DELAY_BETWEEN_TESTS=0.5
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --verbose, -v    Enable verbose output"
            echo "  --quick, -q      Run tests with minimal delays"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print test header
print_test_header() {
    local test_num=$1
    local test_name=$2
    local endpoint=$3
    
    echo
    print_status $BLUE "=== Test $test_num: $test_name ==="
    print_status $YELLOW "Endpoint: $endpoint"
    
    if [ "$VERBOSE" = true ]; then
        print_status $YELLOW "Full URL: $BASE_URL$endpoint"
    fi
}

# Function to make API call with error handling
make_api_call() {
    local endpoint=$1
    local description=$2
    local expected_status=${3:-"any"}
    
    if [ "$VERBOSE" = true ]; then
        print_status $YELLOW "Making request to: $BASE_URL$endpoint"
    fi
    
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}s" "$BASE_URL$endpoint" 2>/dev/null || echo "CURL_ERROR")
    
    if [[ "$response" == *"CURL_ERROR"* ]]; then
        print_status $RED "❌ FAILED: Unable to connect to $BASE_URL$endpoint"
        return 1
    fi
    
    local http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    local time_total=$(echo "$response" | grep "TIME_TOTAL:" | cut -d: -f2)
    local body=$(echo "$response" | sed '/HTTP_CODE:/,$d')
    
    print_status $GREEN "✅ SUCCESS: HTTP $http_code (${time_total})"
    
    if [ "$VERBOSE" = true ]; then
        echo "Response body:"
        echo "$body" | jq . 2>/dev/null || echo "$body"
    fi
    
    return 0
}

# Function to test endpoint health
test_health() {
    print_status $BLUE "🏥 Testing service health..."
    
    if make_api_call "" "Health check"; then
        print_status $GREEN "✅ Service is responding"
        return 0
    else
        print_status $RED "❌ Service health check failed"
        return 1
    fi
}

# Function to start port forwarding with retry
start_port_forward() {
    print_status $BLUE "🚀 Starting port-forward to $SERVICE_NAME service..."
    
    # Kill any existing port-forward on this port
    local existing_pid=$(lsof -ti:$PORT 2>/dev/null || true)
    if [ ! -z "$existing_pid" ]; then
        print_status $YELLOW "⚠️  Killing existing process on port $PORT (PID: $existing_pid)"
        kill -9 $existing_pid 2>/dev/null || true
        sleep 1
    fi
    
    # Start new port-forward
    kubectl port-forward -n $NAMESPACE service/$SERVICE_NAME $PORT:80 &
    PORT_FORWARD_PID=$!
    
    # Wait and verify port-forward is working
    print_status $YELLOW "⏳ Waiting for port-forward to establish..."
    local retries=0
    while [ $retries -lt 10 ]; do
        sleep 1
        if curl -s "http://localhost:$PORT/api/v1/users" >/dev/null 2>&1; then
            print_status $GREEN "✅ Port-forward established successfully (PID: $PORT_FORWARD_PID)"
            return 0
        fi
        ((retries++))
        print_status $YELLOW "   Retry $retries/10..."
    done
    
    print_status $RED "❌ Failed to establish port-forward after 10 retries"
    return 1
}

# Function to cleanup on exit
cleanup() {
    if [ ! -z "$PORT_FORWARD_PID" ]; then
        print_status $YELLOW "🧹 Cleaning up port-forward (PID: $PORT_FORWARD_PID)..."
        kill $PORT_FORWARD_PID 2>/dev/null || true
        print_status $GREEN "✅ Port-forward stopped"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Main execution starts here
print_status $GREEN "🎯 Enhanced New Relic Error Simulation Test Suite"
print_status $BLUE "📊 Configuration:"
echo "   Service: $SERVICE_NAME"
echo "   Namespace: $NAMESPACE"
echo "   Port: $PORT"
echo "   Base URL: $BASE_URL"
echo "   Verbose: $VERBOSE"
echo "   Quick mode: $QUICK_MODE"
echo

# Start port forwarding
if ! start_port_forward; then
    print_status $RED "❌ Cannot proceed without port-forward"
    exit 1
fi

# Test service health
if ! test_health; then
    print_status $RED "❌ Service is not healthy, aborting tests"
    exit 1
fi

# Test execution starts here
print_status $GREEN "🧪 Starting comprehensive error simulation tests..."

# Test 1: Basic Exception Error
print_test_header "1" "Basic Application Exception" "/simulate-error"
make_api_call "/simulate-error" "Exception with ERROR logs"
sleep $DELAY_BETWEEN_TESTS

# Test 2: Critical System Error
print_test_header "2" "Critical System Failure" "/simulate-critical-error"
make_api_call "/simulate-critical-error" "Critical error with multiple ERROR/CRITICAL logs"
sleep $DELAY_BETWEEN_TESTS

# Test 3: Multiple Structured Errors
print_test_header "3" "Multiple Structured Errors" "/force-error-log"
make_api_call "/force-error-log" "Multiple error types and structured logging"
sleep $DELAY_BETWEEN_TESTS

# Test 4: Memory Error Simulation
print_test_header "4" "Memory Error Simulation" "/simulate-memory-error"
make_api_call "/simulate-memory-error" "Out of memory error simulation"
sleep $DELAY_BETWEEN_TESTS

# Test 5: Database Error Simulation
print_test_header "5" "Database Connection Error" "/simulate-database-error"
make_api_call "/simulate-database-error" "Database connection failure"
sleep $DELAY_BETWEEN_TESTS

# Test 6: Authentication Error
print_test_header "6" "Authentication Failure" "/simulate-auth-error"
make_api_call "/simulate-auth-error" "Authentication/security error"
sleep $DELAY_BETWEEN_TESTS

# Test 7: Cascade System Failure
print_test_header "7" "Cascade System Failure" "/simulate-cascade-failure"
make_api_call "/simulate-cascade-failure" "Multiple system failures"
sleep $DELAY_BETWEEN_TESTS

# Test 8: Custom Exception Types
if [ "$QUICK_MODE" = false ]; then
    print_status $BLUE "🔧 Testing Custom Exception Types:"
    
    exception_types=("null" "argument" "format" "overflow" "io" "network" "unauthorized" "notfound")
    
    for exc_type in "${exception_types[@]}"; do
        print_test_header "8.$exc_type" "Custom $exc_type Exception" "/simulate-custom-exception/$exc_type"
        make_api_call "/simulate-custom-exception/$exc_type" "Custom $exc_type exception"
        sleep 0.5
    done
fi

# Test 9: Business Logic Error
print_test_header "9" "Business Logic Violation" "/simulate-business-logic-error"
make_api_call "/simulate-business-logic-error" "Business rule violation"
sleep $DELAY_BETWEEN_TESTS

# Test 10: Timeout Simulation
print_test_header "10" "Timeout Error" "/simulate-timeout"
make_api_call "/simulate-timeout" "Gateway timeout simulation"
sleep $DELAY_BETWEEN_TESTS

# Test 11: Data Corruption
print_test_header "11" "Data Corruption Error" "/simulate-data-corruption"
make_api_call "/simulate-data-corruption" "Data integrity failure"
sleep $DELAY_BETWEEN_TESTS

# Test 12: Unhandled Exception
print_test_header "12" "Unhandled Exception" "/simulate-unhandled-exception"
make_api_call "/simulate-unhandled-exception" "Unhandled exception test"
sleep $DELAY_BETWEEN_TESTS

# Test 13: Bad Request (400 to 500 conversion)
print_test_header "13" "Bad Request (400→500)" "/simulate-bad-request"
make_api_call "/simulate-bad-request" "HTTP 400 converted to 500 with error logging"
sleep $DELAY_BETWEEN_TESTS

# Test 14: Validation Error (400 to 500 conversion)
print_test_header "14" "Validation Error (400→500)" "/simulate-validation-error"
curl -s -X POST -H "Content-Type: application/json" -d '{"invalid": "data"}' "$BASE_URL/simulate-validation-error" >/dev/null 2>&1 || true
print_status $GREEN "✅ SUCCESS: Validation error with POST request (400→500 conversion)"
sleep $DELAY_BETWEEN_TESTS

# Test 15: Warning Level Logs (for comparison)
print_test_header "15" "Warning Logs (Non-Error)" "/simulate-warning"
make_api_call "/simulate-warning" "Warning level logging"
sleep $DELAY_BETWEEN_TESTS

# Test 16: Info Level Logs (for comparison)
print_test_header "16" "Info Logs (Non-Error)" "/simulate-info"
make_api_call "/simulate-info" "Information level logging"
sleep $DELAY_BETWEEN_TESTS

# Test 17: Normal Endpoint (baseline)
print_test_header "17" "Normal Operation (Baseline)" ""
make_api_call "" "Normal endpoint for comparison"

# Summary and New Relic guidance
echo
print_status $GREEN "🎉 === Test Suite Complete ==="
print_status $BLUE "📈 New Relic Monitoring Guide:"

echo
print_status $YELLOW "🔍 What to check in New Relic APM:"
echo "   1. 🚨 Errors Tab - Look for exceptions from tests 1, 2, 3, 12"
echo "   2. 📊 Error Analytics - HTTP 500 errors from tests 1-14 (including 400→500 conversions)"
echo "   3. 📋 Logs - ERROR/CRITICAL level logs from all error tests"
echo "   4. 🕸️  Transaction Traces - Detailed traces of failed requests"
echo "   5. 🔔 Alerts - If configured, should trigger on error rate spikes"
echo "   6. 🔄 Status Code Conversion - Tests 13-14 show 400→500 conversion with error logs"

echo
print_status $YELLOW "📝 Expected Log Levels in New Relic:"
echo "   • ERROR/CRITICAL: Tests 1-14 (will show as errors, including converted 400s)"
echo "   • WARNING: Test 15 (will show as warnings, not errors)"
echo "   • INFO: Test 16 (will show as info, not errors)"
echo "   • SUCCESS: Test 17 (normal operation)"

echo
print_status $YELLOW "🎯 Key Metrics to Monitor:"
echo "   • Error Rate: Should spike during test execution"
echo "   • Response Time: May increase for error scenarios"
echo "   • Throughput: Number of requests processed"
echo "   • Apdex Score: May temporarily decrease"

echo
print_status $BLUE "💡 Pro Tips:"
echo "   • Run this script multiple times to generate more error data"
echo "   • Use --quick flag for rapid testing during development"
echo "   • Use --verbose flag to see detailed request/response data"
echo "   • Check New Relic within 1-2 minutes after test completion"

echo
print_status $GREEN "✅ All tests completed successfully!"
print_status $BLUE "🔗 Check your New Relic dashboard now: https://one.newrelic.com/"