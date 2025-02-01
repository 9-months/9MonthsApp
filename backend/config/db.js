const mongoose = require("mongoose");
require("dotenv").config();

const connection = mongoose
  .createConnection(process.env.MONGODB_URI)
  .on("open", () => {
    console.log("Connected to MongoDB");
  })
  .on("error", (error) => {
    console.log("MongoDB Error", error);
  });

module.exports = connection;
