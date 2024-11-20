const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const picRoutes = require("./routes/pic");

const app = express();

// Middleware
app.use(bodyParser.json());
app.use("/api/profile", picRoutes);

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost:27017/your_database_name", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error("MongoDB connection error:", err));

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
