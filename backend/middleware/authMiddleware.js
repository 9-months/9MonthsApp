const jwt = require('jsonwebtoken');

// Secret key for JWT signing - store in .env file
const JWT_SECRET = process.env.JWT_SECRET;

/**
 * Generate JWT token from user data
 */
const generateToken = (user) => {
  return jwt.sign(
    { 
      uid: user.uid,
      email: user.email,
      username: user.username,
    },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
};

/**
 * Middleware to verify JWT tokens
 */
const verifyToken = (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        status: false,
        message: "Access denied. No token provided."
      });
    }
    
    const token = authHeader.split('Bearer ')[1];
    
    // Verify token
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Add user info to request
    req.user = decoded;
    next();
  } catch (error) {
    console.error("Token verification error:", error);
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        status: false,
        message: "Token expired. Please login again."
      });
    }
    
    return res.status(401).json({
      status: false,
      message: "Invalid token."
    });
  }
};

module.exports = { generateToken, verifyToken };