import { DataTypes } from "sequelize";
import db from "../config/database.js";

const GovernmentAgency = db.define(
  "government_agencies",
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
    division: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    contact: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    service_area: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
  },
  {
    timestamps: true,
  }
);

export default GovernmentAgency;
