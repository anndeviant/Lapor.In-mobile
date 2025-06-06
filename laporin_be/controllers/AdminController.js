import Admin from "../models/admin.model.js";
import Report from "../models/report.model.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// GET all admins
async function getAdmins(req, res) {
  try {
    const admins = await Admin.findAll({
      attributes: ["id", "username", "name", "email", "createdAt", "updatedAt"],
    });

    res.status(200).json({
      status: "Success",
      message: "Admins Retrieved",
      data: admins,
    });
  } catch (error) {
    console.log("Error fetching admins:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// GET admin by ID
async function getAdminById(req, res) {
  try {
    const admin = await Admin.findOne({
      where: { id: req.params.id },
      attributes: ["id", "username", "name", "email", "createdAt", "updatedAt"],
    });

    if (!admin) {
      const error = new Error("Admin tidak ditemukan 😮");
      error.statusCode = 404;
      throw error;
    }

    res.status(200).json({
      status: "Success",
      message: "Admin Retrieved",
      data: admin,
    });
  } catch (error) {
    console.log("Error fetching admin:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// CREATE new admin
async function registerAdmin(req, res) {
  try {
    const { username, password, name, email } = req.body;

    // Validate input
    if (!username || !password || !name || !email) {
      const msg = `Field tidak boleh kosong 😠`;
      const error = new Error(msg);
      error.statusCode = 401;
      throw error;
    }

    // Check for existing username
    const existingAdmin = await Admin.findOne({
      where: { username: username },
    });
    if (existingAdmin) {
      const error = new Error("Username sudah digunakan");
      error.statusCode = 400;
      throw error;
    }

    // Check for existing email
    const existingEmail = await Admin.findOne({ where: { email: email } });
    if (existingEmail) {
      const error = new Error("Email sudah digunakan");
      error.statusCode = 400;
      throw error;
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create admin
    await Admin.create({
      username: username,
      password: hashedPassword,
      name: name,
      email: email,
    });

    res.status(201).json({
      status: "Success",
      message: "Admin Berhasil Dibuat",
    });
  } catch (error) {
    console.log("Error creating admin:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// UPDATE admin profile
async function updateAdminProfile(req, res) {
  try {
    const { name, email, currentPassword, newPassword } = req.body;
    const adminId = req.adminId;

    const admin = await Admin.findOne({ where: { id: adminId } });

    if (!admin) {
      const error = new Error("Admin tidak ditemukan 😮");
      error.statusCode = 404;
      throw error;
    }

    // Update data
    const dataToUpdate = {};
    if (name) dataToUpdate.name = name;
    if (email) dataToUpdate.email = email;

    // Update password if provided
    if (currentPassword && newPassword) {
      // Verify current password
      const match = await bcrypt.compare(currentPassword, admin.password);

      if (!match) {
        const error = new Error("Password saat ini salah");
        error.statusCode = 400;
        throw error;
      }

      // Hash new password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(newPassword, salt);
      dataToUpdate.password = hashedPassword;
    }

    // Update admin data
    await Admin.update(dataToUpdate, {
      where: { id: adminId },
    });

    res.status(200).json({
      status: "Success",
      message: "Profil Admin Berhasil Diperbarui",
    });
  } catch (error) {
    console.log("Error updating admin profile:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// DELETE admin
async function deleteAdmin(req, res) {
  try {
    const admin = await Admin.findOne({ where: { id: req.params.id } });

    if (!admin) {
      const error = new Error("Admin tidak ditemukan 😮");
      error.statusCode = 404;
      throw error;
    }
    const adminId = req.adminId; // dari token

    // Reset all reports handled by this admin
    await Report.update(
      {
        admin_id: null,
        status: "pending",
      },
      {
        where: { admin_id: adminId },
      }
    );

    // Delete the admin
    await Admin.destroy({ where: { id: req.params.id } });

    res.status(200).json({
      status: "Success",
      message: "Admin Berhasil Dihapus dan laporan terkait telah direset",
    });
  } catch (error) {
    console.log("Error deleting admin:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// LOGIN admin
async function loginAdmin(req, res) {
  try {
    const { username, password } = req.body;

    const admin = await Admin.findOne({
      where: { username: username },
    });

    if (admin) {
      const adminPlain = admin.toJSON(); // Convert to object
      const { password: _, refresh_token: __, ...safeAdminData } = adminPlain;

      //Check if admin already has an active session
      // if (admin.refresh_token) {
      //   try {
      //     // Verify if the token is still valid
      //     const isValidToken = jwt.verify(
      //       admin.refresh_token,
      //       process.env.REFRESH_TOKEN_SECRET
      //     );

      //     if (isValidToken) {
      //       return res.status(403).json({
      //         status: "Failed",
      //         message: "Admin sudah login di perangkat lain",
      //         alreadyLoggedIn: true,
      //       });
      //     }
      //   } catch (tokenError) {
      //     // Token is invalid/expired, can proceed with login
      //     console.log(
      //       "Token sebelumnya telah kedaluwarsa, mengizinkan login baru"
      //     );
      //   }
      // }

      const decryptPassword = await bcrypt.compare(password, admin.password);

      if (decryptPassword) {
        const accessToken = jwt.sign(
          safeAdminData,
          process.env.ACCESS_TOKEN_SECRET,
          { expiresIn: "1h" }
        );

        // Generate device identifier
        const deviceId = req.headers["user-agent"] || "unknown-device";

        const refreshToken = jwt.sign(
          { ...safeAdminData, deviceId },
          process.env.REFRESH_TOKEN_SECRET,
          { expiresIn: "7d" }
        );

        await Admin.update(
          { refresh_token: null },
          { where: { id: admin.id } }
        );
        await Admin.update(
          { refresh_token: refreshToken },
          { where: { id: admin.id } }
        );

        res.cookie("refreshToken", refreshToken, {
          httpOnly: false,
          sameSite: "none",
          maxAge: 24 * 60 * 60 * 1000,
          secure: true,
        });

        // Include expiration information
        const tokenInfo = jwt.decode(accessToken);
        const expiresAt = new Date(tokenInfo.exp * 1000).toISOString();

        res.status(200).json({
          status: "Success",
          message: "Login Berhasil",
          safeAdminData,
          accessToken,
          tokenExpires: expiresAt,
        });
      } else {
        res.status(400).json({
          status: "Failed",
          message: "Username atau password salah",
        });
      }
    } else {
      res.status(400).json({
        status: "Failed",
        message: "Username atau password salah",
      });
    }
  } catch (error) {
    console.log("Error logging in admin:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// LOGOUT admin
async function logoutAdmin(req, res) {
  try {
    const refreshToken = req.cookies.refreshToken;

    if (!refreshToken) return res.sendStatus(204); // No content

    const admin = await Admin.findOne({
      where: { refresh_token: refreshToken },
    });

    if (!admin) return res.sendStatus(204);

    // Clear refresh token in database
    await Admin.update({ refresh_token: null }, { where: { id: admin.id } });

    // Clear cookie
    res.clearCookie("refreshToken");

    return res.status(200).json({
      status: "Success",
      message: "Logout Berhasil",
    });
  } catch (error) {
    console.log("Error logging out admin:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

// GET admin profile
async function getAdminProfile(req, res) {
  try {
    const admin = await Admin.findOne({
      where: { id: req.adminId },
      attributes: ["id", "username", "name", "email"],
    });

    if (!admin) {
      const error = new Error("Admin tidak ditemukan 😮");
      error.statusCode = 404;
      throw error;
    }

    res.status(200).json({
      status: "Success",
      message: "Profil Admin",
      data: admin,
    });
  } catch (error) {
    console.log("Error fetching admin profile:", error);
    res.status(error.statusCode || 500).json({
      status: "Error",
      message: error.message,
    });
  }
}

export {
  getAdmins,
  getAdminById,
  registerAdmin,
  updateAdminProfile,
  deleteAdmin,
  loginAdmin,
  logoutAdmin,
  getAdminProfile,
};
