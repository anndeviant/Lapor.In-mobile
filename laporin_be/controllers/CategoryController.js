import ReportCategory from "../models/reportCategory.model.js";

export const getReportCategories = async (req, res) => {
  try {
    const response = await ReportCategory.findAll();
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
  }
};

export const createReportCategories = async (req, res) => {
  try {
    await ReportCategory.create(req.body);
    res.status(201).json({ msg: "ReportCategory add" });
  } catch (error) {
    console.log(error.message);
  }
};

export const deleteReportCategory = async (req, res) => {
  try {
    await ReportCategory.destroy({
      where: {
        id: req.params.id,
      },
    });
    res.status(200).json({ msg: "ReportCategory berhasil di hapus" });
  } catch (error) {
    console.log(error.message);
  }
};

export const updateReportCategory = async (req, res) => {
  try {
    await ReportCategory.update(req.body, {
      where: {
        id: req.params.id,
      },
    });
    res.status(200).json({ msg: "Kategori berhasil diperbarui" });
  } catch (error) {
    console.log(error.message);
    res
      .status(500)
      .json({ msg: "Terjadi kesalahan saat memperbarui kategori" });
  }
};
