import { DataTypes } from "sequelize";
import db from "../config/database.js";

const ReportHistory = db.define(
  "report_history",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    report_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    status: {
      type: DataTypes.ENUM(
        "pending",
        "verified",
        "in_progress",
        "resolved",
        "rejected"
      ),
      allowNull: false,
    },
    note: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    agency_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    admin_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    timestamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    timestamps: false,
  }
);

// Class methods
ReportHistory.getFullHistory = function (reportId) {
  return this.findAll({
    where: { report_id: reportId },
    order: [["timestamp", "ASC"]],
  });
};

export default ReportHistory;
