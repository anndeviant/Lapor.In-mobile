import { Sequelize } from "sequelize";
import db from "../config/database.js";

const { DataTypes } = Sequelize;

const User = db.define(
  "users",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    fullname: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    phone_number: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    device_info: {
      type: DataTypes.STRING,
      allowNull: true, // null = tidak sedang login
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    timestamps: true,
  }
);

export default User;
