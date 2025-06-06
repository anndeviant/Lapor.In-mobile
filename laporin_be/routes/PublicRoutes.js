import express from "express";
import {
  getReports,
  getReportsById,
  createReports,
  getReportsByCategory,
  getPublicReportsByStatus,
  trackReportStatus,
  getReportStatistics,
} from "../controllers/ReportController.js";
import { getReportCategories } from "../controllers/CategoryController.js";
import { getGovernmentAgencies } from "../controllers/AgencyController.js";
import { uploadFiles } from "../middleware/UploadFile.js";

const router = express.Router();

// Public Report Routes
router.get("/reports", getReports); // Mendapatkan daftar aduan dengan filter dasar
router.get("/reports/category/:categoryId", getReportsByCategory); // Mendapatkan aduan berdasarkan kategori
router.get("/reports/status/:status", getPublicReportsByStatus); // Melihat aduan berdasarkan status
router.get("/reports/:id", getReportsById); // Melihat detail aduan spesifik
router.post("/reports", uploadFiles, createReports); // Membuat aduan baru
router.get("/reports/track/:trackingId", trackReportStatus); // Melacak status aduan dengan ID pelacakan
router.get("/statistics", getReportStatistics); // Mendapatkan statistik aduan (jumlah per kategori/status)

// Public Category Routes
router.get("/categories", getReportCategories); // Mendapatkan semua kategori aduan

// Public Agency Routes
router.get("/agencies", getGovernmentAgencies); // Mendapatkan daftar instansi pemerintah

export default router;
