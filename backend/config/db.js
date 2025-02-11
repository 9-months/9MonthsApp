/*
 File: db.js
 Purpose: Create a connection to the MongoDB database.
 Created Date: 2025-02-02 CCS-7 Irosh Perera
 Author: Irosh Perera
*/

const mongoose = require('mongoose');
require ('dotenv').config();

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  dbName: 'nine-months-db'  
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

// Listen for connection errors after initial connection
mongoose.connection.on('error', err => {
  console.error('MongoDB runtime error:', err);
});
