import express from "express";
import {
  getReports,
  getReportsById,
  createReports,
  updateReport,
  deleteReport,
  getReportHistory,
  verifyReport,
  assignReportToAgency,
  resolveReport,
  rejectReport,
} from "../controllers/ReportController.js";
import {
  getReportCategories,
  createReportCategories,
  deleteReportCategory,
  updateReportCategory,
} from "../controllers/CategoryController.js";
import {
  getGovernmentAgencies,
  createGovernmentAgencies,
  deleteGovernmentAgency,
  updateGovernmentAgency,
} from "../controllers/AgencyController.js";
import {
  registerAdmin,
  loginAdmin,
  logoutAdmin,
  getAdminProfile,
  updateAdminProfile,
  getAdmins,
  deleteAdmin,
  getAdminById,
} from "../controllers/AdminController.js";
import { verifyToken } from "../middleware/VerifyToken.js";
import { refreshAccessToken } from "../middleware/RefreshToken.js";

const router = express.Router();

// Admin Authentication Routes
router.post("/register", registerAdmin); // Mendaftarkan admin baru
router.post("/login", loginAdmin); // Login admin
router.delete("/logout", logoutAdmin); // Logout admin
router.get("/token", refreshAccessToken); // Refresh token menggunakan middleware

// Admin Profile Routes
router.get("/profile", verifyToken, getAdminProfile); // Mendapatkan profil admin
router.patch("/profile", verifyToken, updateAdminProfile); // Mengupdate profil admin

// Admin User Management Routes
router.get("/users", verifyToken, getAdmins); // Mendapatkan daftar admin
router.get("/users/:id", verifyToken, getAdminById); // Add this line
router.delete("/users/:id", verifyToken, deleteAdmin); // Menghapus admin

// Admin Report Routes (Dengan autentikasi)
router.get("/reports", verifyToken, getReports);
router.get("/reports/:id", verifyToken, getReportsById);
router.post("/reports", verifyToken, createReports);
router.patch("/reports/:id", verifyToken, updateReport);
router.delete("/reports/:id", verifyToken, deleteReport);

// Admin Report Management Routes
router.get("/reports/:id/history", verifyToken, getReportHistory); // Mendapatkan riwayat perubahan aduan
router.patch("/reports/:id/verify", verifyToken, verifyReport); // Memverifikasi aduan
router.patch("/reports/:id/assign", verifyToken, assignReportToAgency); // Menugaskan aduan ke instansi
router.patch("/reports/:id/resolve", verifyToken, resolveReport); // Menyelesaikan aduan
router.patch("/reports/:id/reject", verifyToken, rejectReport); // Menolak aduan

// Admin Category Routes (Dengan autentikasi)
router.get("/categories", verifyToken, getReportCategories);
router.post("/categories", verifyToken, createReportCategories);
router.patch("/categories/:id", verifyToken, updateReportCategory);
router.delete("/categories/:id", verifyToken, deleteReportCategory);

// Admin Agency Routes (Dengan autentikasi)
router.get("/agencies", verifyToken, getGovernmentAgencies);
router.post("/agencies", verifyToken, createGovernmentAgencies);
router.patch("/agencies/:id", verifyToken, updateGovernmentAgency);
router.delete("/agencies/:id", verifyToken, deleteGovernmentAgency);

export default router;
