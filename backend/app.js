const express = require("express");
const db = require("./config/db");
const dotenv = require("dotenv");
const cors = require("cors");
const swaggerSetup = require("./swagger");
const authRoutes = require("./routes/authRoutes");

// Load environment variables
dotenv.config();

const admin = require("firebase-admin");
const serviceAccount = require("./ServicesAccountKey.json");

admin.initializeApp({
  credential:admin.credential.cert(serviceAccount),
});


// Initialize Express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

//Routes
app.use("/auth", authRoutes);

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
