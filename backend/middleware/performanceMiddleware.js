/*
 File: performanceMiddleware.js
 Purpose: Monitor API performance and response times
 Created Date: 2026-01-10
 Author: Dinith Perera
*/

// Simple performance monitoring middleware
const performanceMiddleware = (req, res, next) => {
  // Record start time
  const start = process.hrtime();
  
  // Once the response is finished
  res.on('finish', () => {
    // Calculate duration
    const end = process.hrtime(start);
    const durationMs = (end[0] * 1000) + (end[1] / 1000000);
    
    // Format for logging
    const log = {
      method: req.method,
      path: req.originalUrl,
      status: res.statusCode,
      duration: `${durationMs.toFixed(2)}ms`
    };
    
    // Log requests that take too long (more than 200ms)
    if (durationMs > 200) {
      console.warn(`SLOW REQUEST: ${JSON.stringify(log)}`);
    } else {
      console.log(`REQUEST: ${JSON.stringify(log)}`);
    }
  });
  
  next();
};

module.exports = performanceMiddleware;
