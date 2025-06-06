import jwt from "jsonwebtoken";

export const verifyToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ message: "No authentication token provided" });

  jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, decoded) => {
    if (err) {
      if (err.name === "TokenExpiredError") {
        return res.status(403).json({
          message: "Authentication token has expired",
          expiredAt: err.expiredAt,
          error: "token_expired",
        });
      }
      return res.status(403).json({
        message: "Invalid authentication token",
        error: err.name,
      });
    }

    // Simpan info admin ke dalam request
    req.adminId = decoded.id;
    req.username = decoded.username;
    req.name = decoded.name;
    req.email = decoded.email;

    next();
  });
};
