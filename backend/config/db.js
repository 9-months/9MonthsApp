const mongoose = require("mongoose");

const connection = mongoose
  .createConnection(
    "mongodb+srv://Irosh:Irosh9m@nine-months-db.kzccf.mongodb.net/?retryWrites=true&w=majority&appName=nine-months-db"
  )
  .on("open", () => {
    console.log("Connected to MongoDB");
  })
  .on("error", (error) => {
    console.log("MongoDB Error", error);
  });

module.exports = connection;
