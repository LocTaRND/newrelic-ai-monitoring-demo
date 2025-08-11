require('newrelic');
require('dotenv').config(); // Load env variables


const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();

// Enable CORS for development
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    services: {
      'ai-chatbot': process.env.AI_CHATBOT_URL || 'http://ai-chatbot-service:80/chat',
      'backend-api': process.env.INTERNAL_USER_API || 'http://backend-api/api/v1/users'
    }
  });
});

// API route to communicate with AI chatbot service
app.post('/api/chat', async (req, res) => {
  try {
    const { message } = req.body;
    
    const aiServiceUrl = process.env.AI_CHATBOT_URL || 'http://ai-chatbot-service:80/chat';
    
    const response = await fetch(aiServiceUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message })
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error calling ai-chatbot service:', error);
    res.status(500).json({ error: 'Failed to communicate with ai-chatbot service' });
  }
});

// API proxy routes for internal services
app.use('/api/v1/users', async (req, res) => {
  try {
    const internalApiUrl = process.env.INTERNAL_USER_API || 'http://backend-api/api/v1/users';
    const targetUrl = `${internalApiUrl}${req.path}`;
    
    // Prepare headers - exclude problematic headers
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    
    // Add authorization headers if present
    if (req.headers.authorization) {
      headers.authorization = req.headers.authorization;
    }
    
    const fetchOptions = {
      method: req.method,
      headers: headers
    };
    
    // Add body for POST, PUT, PATCH requests
    if (['POST', 'PUT', 'PATCH'].includes(req.method) && req.body) {
      fetchOptions.body = JSON.stringify(req.body);
    }
    
    console.log(`Proxying ${req.method} ${targetUrl}`, { body: req.body });
    
    const response = await fetch(targetUrl, fetchOptions);
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error(`Backend API error: ${response.status} - ${errorText}`);
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error calling backend-api service:', error);
    res.status(500).json({ error: 'Failed to communicate with backend-api service', details: error.message });
  }
});

// Serve static files from the React app
app.use(express.static(path.join(__dirname, 'build')));

// Serve static files from public directory (for development)
app.use(express.static(path.join(__dirname, 'public')));

// The "catchall" handler: for any request that doesn't
// match one above, send back React's index.html file.
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Health check available at http://localhost:${PORT}/health`);
});

// Example usage:
// const apiUrl = process.env.API_URL;
// const dbPassword = process.env.DB_PASSWORD;