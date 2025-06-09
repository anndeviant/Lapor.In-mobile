import { Sequelize } from "sequelize";
import dotenv from "dotenv";

dotenv.config();

const DB_NAME = "laporin_mobile";
const DB_USERNAME = process.env.DB_USERNAME;
const DB_PASSWORD = process.env.DB_PASSWORD;
const DB_HOST = process.env.DB_HOST;

// const DB_NAME = "laporin_db";
// const DB_USERNAME = "root";
// const DB_PASSWORD = "";
// const DB_HOST = "localhost";

const db = new Sequelize(DB_NAME, DB_USERNAME, DB_PASSWORD, {
  host: DB_HOST,
  dialect: "mysql",
  // timezone: "+07:00",
});

export default db;
