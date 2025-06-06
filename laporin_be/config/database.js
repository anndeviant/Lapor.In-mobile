import { Sequelize } from "sequelize";
import dotenv from "dotenv";

// dotenv.config();

const DB_NAME = "laporin_db";
const DB_USERNAME = "root";
const DB_PASSWORD = "";
const DB_HOST = "localhost";

const db = new Sequelize(DB_NAME, DB_USERNAME, DB_PASSWORD, {
  host: DB_HOST,
  dialect: "mysql",
  timezone: "+07:00",
});

export default db;
