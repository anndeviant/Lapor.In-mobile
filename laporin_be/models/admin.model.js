import { DataTypes } from "sequelize";
import db from "../config/database.js";

const Admin = db.define(
  "admins",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    refresh_token: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    timestamps: true,
  }
);

export default Admin;
