import Report from "../models/report.model.js";
import ReportCategory from "../models/reportCategory.model.js";
import ReportHistory from "../models/reportHistory.model.js";
import GovernmentAgency from "../models/governmentAgency.model.js";
import { Op } from "sequelize";
import {
  uploadFileToGCS,
  deleteFilesFromGCSByUrls,
} from "../middleware/UploadFile.js";

export const getReports = async (req, res) => {
  try {
    const response = await Report.findAll({
      include: [
        {
          model: ReportCategory,
          attributes: ["name"],
        },
        {
          model: GovernmentAgency,
          attributes: ["name"],
        },
      ],
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
    res
      .status(500)
      .json({ msg: "Terjadi kesalahan saat mengambil data aduan" });
  }
};

export const getReportsById = async (req, res) => {
  try {
    const response = await Report.findOne({
      where: {
        id: req.params.id,
      },
      include: [
        {
          model: ReportCategory,
          attributes: ["name"],
        },
        {
          model: GovernmentAgency,
          attributes: ["name"],
        },
      ],
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error);
  }
};

export const createReports = async (req, res) => {
  try {
    const {
      title,
      description,
      category_id,
      reporter_name,
      reporter_contact,
      location,
      agency_id,
    } = req.body;

    // Check if image file is uploaded
    if (!req.files || !req.files.image) {
      return res.status(400).json({ msg: "Foto bukti wajib diunggah" });
    }

    let imageUrl = null;
    let lampiranUrl = null;

    // Upload image file
    try {
      imageUrl = await uploadFileToGCS(req.files.image[0], "images");
    } catch (error) {
      console.error("Error uploading image:", error);
      return res
        .status(500)
        .json({ msg: `Gagal mengunggah foto bukti ${error}` });
    }

    // Upload lampiran file if exists
    if (req.files.lampiran && req.files.lampiran[0]) {
      try {
        lampiranUrl = await uploadFileToGCS(req.files.lampiran[0], "files");
      } catch (error) {
        console.error("Error uploading lampiran:", error);
        return res.status(500).json({ msg: "Gagal mengunggah lampiran" });
      }
    }

    // Create report in database
    const newReport = await Report.create({
      title,
      description,
      category_id: parseInt(category_id),
      reporter_name,
      reporter_contact,
      location,
      image_url: imageUrl,
      lampiran_url: lampiranUrl,
      agency_id: agency_id ? parseInt(agency_id) : null,
      status: "pending",
    });

    res.status(201).json({
      msg: "Aduan berhasil dikirim",
      reportId: newReport.id,
      trackingId: newReport.id,
    });
  } catch (error) {
    console.error("Error creating report:", error);
    res.status(500).json({ msg: "Terjadi kesalahan saat mengirim aduan" });
  }
};

export const updateReport = async (req, res) => {
  try {
    const reportId = req.params.id;
    const adminId = req.adminId; // dari token

    // Ambil laporan berdasarkan ID
    const report = await Report.findByPk(reportId);

    if (!report) {
      return res.status(404).json({ message: "Laporan tidak ditemukan." });
    }

    // Persiapkan data update
    const dataUpdate = {
      ...req.body,
    };

    // Jika admin_id di DB masih null, baru update
    if (report.admin_id === null) {
      dataUpdate.admin_id = adminId;
    }

    // Update laporan
    await report.update(dataUpdate);

    // Ambil kembali dengan relasi
    const updatedReport = await Report.findByPk(reportId, {
      include: ["report_category", "government_agency"],
    });

    res.status(200).json(updatedReport);
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ message: "Gagal memperbarui laporan." });
  }
};

export const deleteReport = async (req, res) => {
  try {
    // First, get the report to access file URLs
    const report = await Report.findByPk(req.params.id);

    if (!report) {
      return res.status(404).json({ msg: "Report tidak ditemukan" });
    }

    // Delete files from GCS bucket using the URLs
    const filesToDelete = [report.image_url, report.lampiran_url];
    await deleteFilesFromGCSByUrls(filesToDelete);

    // Delete the report from database
    await Report.destroy({
      where: {
        id: req.params.id,
      },
    });

    res
      .status(200)
      .json({ msg: "Report berhasil dihapus beserta file terkait" });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat menghapus report" });
  }
};

export const getReportsByCategory = async (req, res) => {
  try {
    const response = await Report.findAll({
      where: {
        category_id: req.params.categoryId,
        status: {
          [Op.in]: [
            "pending",
            "verified",
            "in_progress",
            "resolved",
            "rejected",
          ],
        },
      },
      include: [
        {
          model: ReportCategory,
          attributes: ["name"],
        },
      ],
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
    res
      .status(500)
      .json({ msg: "Terjadi kesalahan saat mengambil data aduan" });
  }
};

export const getPublicReportsByStatus = async (req, res) => {
  try {
    const response = await Report.findAll({
      where: {
        status: req.params.status,
      },
      attributes: [
        "id",
        "title",
        "location",
        "status",
        "createdAt",
        "updatedAt",
      ],
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
    res
      .status(500)
      .json({ msg: "Terjadi kesalahan saat mengambil data aduan" });
  }
};

export const trackReportStatus = async (req, res) => {
  try {
    const reporterContact = req.params.trackingId;
    const reports = await Report.findAll({
      where: { reporter_contact: reporterContact },
      attributes: [
        "id",
        "title",
        "description",
        "status",
        "location",
        "reporter_name",
        "reporter_contact",
        "createdAt",
        "updatedAt",
      ],
      include: [
        {
          model: ReportCategory,
          attributes: ["name"],
        },
        {
          model: GovernmentAgency,
          attributes: ["name"],
        },
      ],
      order: [["createdAt", "DESC"]],
    });

    if (!reports || reports.length === 0) {
      return res
        .status(404)
        .json({ msg: "Tidak ada aduan ditemukan untuk kontak ini" });
    }

    res.status(200).json(reports);
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat melacak aduan" });
  }
};

export const getReportStatistics = async (req, res) => {
  try {
    // Statistik jumlah aduan per kategori
    const categoryStats = await Report.findAll({
      attributes: [
        "category_id",
        [
          Report.sequelize.fn("COUNT", Report.sequelize.col("reports.id")),
          "count",
        ],
      ],
      include: [
        {
          model: ReportCategory,
          attributes: ["name"],
        },
      ],
      group: ["category_id"],
      raw: true,
    });

    // Statistik jumlah aduan per status
    const statusStats = await Report.findAll({
      attributes: [
        "status",
        [Report.sequelize.fn("COUNT", Report.sequelize.col("id")), "count"],
      ],
      group: ["status"],
      raw: true,
    });

    res.status(200).json({
      categories: categoryStats,
      statuses: statusStats,
    });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat mengambil statistik" });
  }
};

// Mendapatkan riwayat perubahan aduan
export const getReportHistory = async (req, res) => {
  try {
    const reportId = req.params.id;

    // Cek apakah laporan ada
    const report = await Report.findByPk(reportId);
    if (!report) {
      return res.status(404).json({ msg: "Aduan tidak ditemukan" });
    }

    // Dapatkan riwayat laporan
    const history = await ReportHistory.findAll({
      where: { report_id: reportId },
      include: [
        {
          model: Admin,
          attributes: ["name"],
        },
        {
          model: GovernmentAgency,
          attributes: ["name"],
        },
      ],
      order: [["timestamp", "DESC"]],
    });

    res.status(200).json(history);
  } catch (error) {
    console.log(error.message);
    res
      .status(500)
      .json({ msg: "Terjadi kesalahan saat mengambil riwayat aduan" });
  }
};

// Memverifikasi aduan
export const verifyReport = async (req, res) => {
  const { note } = req.body;
  const reportId = req.params.id;

  try {
    // Cek apakah laporan ada
    const report = await Report.findByPk(reportId);
    if (!report) {
      return res.status(404).json({ msg: "Aduan tidak ditemukan" });
    }

    // Ubah status laporan menjadi terverifikasi
    await Report.update(
      {
        status: "verified",
        admin_id: req.adminId,
      },
      { where: { id: reportId } }
    );

    // Buat catatan riwayat
    await ReportHistory.create({
      report_id: reportId,
      status: "verified",
      note: note || "Aduan telah diverifikasi",
      admin_id: req.adminId,
    });

    res.status(200).json({ msg: "Aduan berhasil diverifikasi" });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat memverifikasi aduan" });
  }
};

// Menugaskan aduan ke instansi
export const assignReportToAgency = async (req, res) => {
  const { agency_id, note } = req.body;
  const reportId = req.params.id;

  try {
    // Validasi input
    if (!agency_id) {
      return res.status(400).json({ msg: "ID instansi diperlukan" });
    }

    // Cek apakah laporan ada
    const report = await Report.findByPk(reportId);
    if (!report) {
      return res.status(404).json({ msg: "Aduan tidak ditemukan" });
    }

    // Cek apakah instansi ada
    const agency = await GovernmentAgency.findByPk(agency_id);
    if (!agency) {
      return res.status(404).json({ msg: "Instansi tidak ditemukan" });
    }

    // Ubah status laporan menjadi dalam proses
    await Report.update(
      {
        status: "in_progress",
        agency_id: agency_id,
        admin_id: req.adminId,
      },
      { where: { id: reportId } }
    );

    // Buat catatan riwayat
    await ReportHistory.create({
      report_id: reportId,
      status: "in_progress",
      note: note || `Aduan ditugaskan ke ${agency.name}`,
      agency_id: agency_id,
      admin_id: req.adminId,
    });

    res.status(200).json({ msg: "Aduan berhasil ditugaskan ke instansi" });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat menugaskan aduan" });
  }
};

// Menyelesaikan aduan
export const resolveReport = async (req, res) => {
  const { note } = req.body;
  const reportId = req.params.id;

  try {
    // Cek apakah laporan ada
    const report = await Report.findByPk(reportId);
    if (!report) {
      return res.status(404).json({ msg: "Aduan tidak ditemukan" });
    }

    // Ubah status laporan menjadi terselesaikan
    await Report.update(
      {
        status: "resolved",
        admin_id: req.adminId,
      },
      { where: { id: reportId } }
    );

    // Buat catatan riwayat
    await ReportHistory.create({
      report_id: reportId,
      status: "resolved",
      note: note || "Aduan telah diselesaikan",
      agency_id: report.agency_id,
      admin_id: req.adminId,
    });

    res.status(200).json({ msg: "Aduan berhasil diselesaikan" });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat menyelesaikan aduan" });
  }
};

// Menolak aduan
export const rejectReport = async (req, res) => {
  const { note } = req.body;
  const reportId = req.params.id;

  try {
    // Cek apakah catatan penolakan disertakan
    if (!note) {
      return res.status(400).json({ msg: "Alasan penolakan diperlukan" });
    }

    // Cek apakah laporan ada
    const report = await Report.findByPk(reportId);
    if (!report) {
      return res.status(404).json({ msg: "Aduan tidak ditemukan" });
    }

    // Ubah status laporan menjadi ditolak
    await Report.update(
      {
        status: "rejected",
        admin_id: req.adminId,
      },
      { where: { id: reportId } }
    );

    // Buat catatan riwayat
    await ReportHistory.create({
      report_id: reportId,
      status: "rejected",
      note: note,
      admin_id: req.adminId,
    });

    res.status(200).json({ msg: "Aduan telah ditolak" });
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ msg: "Terjadi kesalahan saat menolak aduan" });
  }
};
