/*
 File: App.js
 Purpose: This file is the main entry point for the application.
 Created Date: 2025-01-29 CCS-1 Irosh Perera
 Author: Irosh Perera

 last modified: 11-02-2025 | Melissa | CCS-50 added diary routes
*/

const express = require("express");
const db = require("./config/db");
const dotenv = require("dotenv");
const cors = require("cors");
const swaggerSetup = require("./swagger");
const authRoutes = require("./routes/authRoutes");
const moodRoutes = require('./routes/moodRoutes');
const emergencyRouter = require("./routes/emergencyRouter");
const pregnancyRouter = require("./routes/pregnancyRoutes");
const reminderRoutes = require('./routes/reminderRoutes');
const diaryRoutes = require("./routes/diaryRoutes");


// Load environment variables
dotenv.config();

const admin = require("firebase-admin");

// Ensure FIREBASE_CREDENTIALS is defined
if (!process.env.FIREBASE_CREDENTIALS) {
  throw new Error("Missing FIREBASE_CREDENTIALS environment variable");
}

const credentials = JSON.parse(Buffer.from(process.env.FIREBASE_CREDENTIALS, 'base64').toString());

admin.initializeApp({
  credential: admin.credential.cert(credentials),
});

// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

//Routes
app.use("/emergency", emergencyRouter);
app.use("/auth", authRoutes);
app.use('/moods', moodRoutes);
app.use("/pregnancy", pregnancyRouter);
app.use('/reminder', reminderRoutes);
app.use("/diary", diaryRoutes);
app.use('/weekly-data', require('./routes/weeklyDataRoutes'));
app.use('/tips', require('./routes/weeklyDataRoutes'));

// Routes
app.get("/", (req, res) => {
  res.send("Pregnancy Support App Backend");
});

// Swagger API documentation
swaggerSetup(app);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
