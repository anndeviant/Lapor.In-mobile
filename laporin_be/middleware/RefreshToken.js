import Admin from "../models/admin.model.js";
import jwt from "jsonwebtoken";

export const refreshAccessToken = async (req, res) => {
  try {
    const refreshToken = req.cookies.refreshToken;
    if (!refreshToken) return res.sendStatus(401);

    const admin = await Admin.findOne({
      where: {
        refresh_token: refreshToken,
      },
    });

    if (!admin || admin.refresh_token !== refreshToken) {
      res.clearCookie("refreshToken");
      return res.status(403).json({
        message: "Akun digunakan di perangkat lain atau token tidak cocok",
      });
    }

    jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, (err, decoded) => {
      if (err) return res.sendStatus(403);

      const adminPlain = admin.toJSON();
      // Hindari data sensitif
      const { password, refresh_token, ...safeAdminData } = adminPlain;

      const accessToken = jwt.sign(
        safeAdminData,
        process.env.ACCESS_TOKEN_SECRET,
        { expiresIn: "1h" } // direkomendasikan 5 menit
      );

      res.json({ accessToken });
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: "Terjadi kesalahan saat memproses token",
    });
  }
};
