import { DataTypes } from "sequelize";
import db from "../config/database.js";

const ReportCategory = db.define(
  "report_categories",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    timestamps: true,
  }
);

export default ReportCategory;
