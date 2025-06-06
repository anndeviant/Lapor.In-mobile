import User from "../models/user.model.js";
import bcrypt from "bcrypt";

// Register new user
export const registerUser = async (req, res) => {
  try {
    const { fullname, phone_number, password } = req.body;

    // Validate input
    if (!fullname || !phone_number || !password) {
      return res.status(400).json({
        status: "Failed",
        message: "Semua field harus diisi",
      });
    }

    // Check if phone number already exists
    const existingUser = await User.findOne({
      where: { phone_number: phone_number },
    });

    if (existingUser) {
      return res.status(400).json({
        status: "Failed",
        message: "Nomor telepon sudah terdaftar",
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const newUser = await User.create({
      fullname: fullname,
      phone_number: phone_number,
      password: hashedPassword,
      device_info: null,
    });

    res.status(201).json({
      status: "Success",
      message: "Registrasi berhasil",
      data: {
        id: newUser.id,
        fullname: newUser.fullname,
        phone_number: newUser.phone_number,
      },
    });
  } catch (error) {
    console.log("Error registering user:", error);
    res.status(500).json({
      status: "Error",
      message: "Terjadi kesalahan saat registrasi",
    });
  }
};

// Login user
export const loginUser = async (req, res) => {
  try {
    const { phone_number, password, device_info } = req.body;

    // Validate input
    if (!phone_number || !password || !device_info) {
      return res.status(400).json({
        status: "Failed",
        message: "Nomor telepon, password, dan info device harus diisi",
      });
    }

    // Find user by phone number
    const user = await User.findOne({
      where: { phone_number: phone_number, is_active: true },
    });

    if (!user) {
      return res.status(400).json({
        status: "Failed",
        message: "Nomor telepon atau password salah",
      });
    }

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(400).json({
        status: "Failed",
        message: "Nomor telepon atau password salah",
      });
    }

    // Update device info
    await User.update({ device_info: device_info }, { where: { id: user.id } });

    res.status(200).json({
      status: "Success",
      message: "Login berhasil",
      data: {
        id: user.id,
        fullname: user.fullname,
        phone_number: user.phone_number,
        device_info: device_info,
      },
    });
  } catch (error) {
    console.log("Error logging in user:", error);
    res.status(500).json({
      status: "Error",
      message: "Terjadi kesalahan saat login",
    });
  }
};

// Check session
export const checkSession = async (req, res) => {
  try {
    const { phone_number } = req.body;

    if (!phone_number) {
      return res.status(400).json({
        status: "Failed",
        message: "Nomor telepon harus diisi",
      });
    }

    const user = await User.findOne({
      where: { phone_number: phone_number, is_active: true },
      attributes: ["id", "fullname", "phone_number", "device_info"],
    });

    if (!user) {
      return res.status(404).json({
        status: "Failed",
        message: "User tidak ditemukan",
      });
    }

    // Check if user still has active session (device_info not null)
    if (user.device_info) {
      return res.status(200).json({
        status: "Success",
        message: "Session masih aktif",
        data: {
          id: user.id,
          fullname: user.fullname,
          phone_number: user.phone_number,
          device_info: user.device_info,
        },
        isLoggedIn: true,
      });
    } else {
      return res.status(200).json({
        status: "Success",
        message: "Session tidak aktif",
        isLoggedIn: false,
      });
    }
  } catch (error) {
    console.log("Error checking session:", error);
    res.status(500).json({
      status: "Error",
      message: "Terjadi kesalahan saat mengecek session",
    });
  }
};

// Logout user
export const logoutUser = async (req, res) => {
  try {
    const { phone_number } = req.body;

    if (!phone_number) {
      return res.status(400).json({
        status: "Failed",
        message: "Nomor telepon harus diisi",
      });
    }

    // Set device_info to null
    const result = await User.update(
      { device_info: null },
      { where: { phone_number: phone_number, is_active: true } }
    );

    if (result[0] === 0) {
      return res.status(404).json({
        status: "Failed",
        message: "User tidak ditemukan",
      });
    }

    res.status(200).json({
      status: "Success",
      message: "Logout berhasil",
    });
  } catch (error) {
    console.log("Error logging out user:", error);
    res.status(500).json({
      status: "Error",
      message: "Terjadi kesalahan saat logout",
    });
  }
};
