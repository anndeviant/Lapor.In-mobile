import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import AdminRoutes from "./routes/AdminRoutes.js";
import PublicRoutes from "./routes/PublicRoutes.js";
import DocsRoutes from "./routes/DocsRoutes.js";
import UserRoutes from "./routes/UserRoutes.js";
import dotenv from "dotenv";
import { initializeDatabase } from "./models/db_connect.js";

// Init environment variables
dotenv.config();

// Init Express app
const app = express();
const PORT = process.env.BACKEND_PORT;

app.use(
  cors({
    origin: "*",
    credentials: true,
  })
);
app.use(cookieParser());
app.use(express.json());

// New routes with prefixes for better organization
app.use("/admin", AdminRoutes);
app.use("/public", PublicRoutes);
app.use("/users", UserRoutes);
app.use("/api/docs", DocsRoutes);

// Health check route
app.get("/", (req, res) => {
  res.json({
    message: "Laporin API is running",
    time: new Date().toString(),
  });
});

// Init database and start server
const startServer = async () => {
  try {
    await initializeDatabase();

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
