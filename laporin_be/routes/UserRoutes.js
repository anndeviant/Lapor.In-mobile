import express from "express";
import {
  registerUser,
  loginUser,
  checkSession,
  logoutUser,
} from "../controllers/UserController.js";

const router = express.Router();

// User Authentication Routes
router.post("/register", registerUser); // Register user baru
router.post("/login", loginUser); // Login user
router.post("/check-session", checkSession); // Cek apakah user masih login
router.post("/logout", logoutUser); // Logout user

export default router;
