import ReportCategory from "./reportCategory.model.js";
import Admin from "./admin.model.js";
import GovernmentAgency from "./governmentAgency.model.js";
import Report from "./report.model.js";
import ReportHistory from "./reportHistory.model.js";

const setupAssociations = () => {
  // ReportCategory and Report (one-to-many)
  ReportCategory.hasMany(Report, { foreignKey: "category_id" });
  Report.belongsTo(ReportCategory, { foreignKey: "category_id" });

  // Admin and Report (one-to-many)
  Admin.hasMany(Report, { foreignKey: "admin_id" });
  Report.belongsTo(Admin, { foreignKey: "admin_id" });

  // Admin and ReportHistory (one-to-many)
  Admin.hasMany(ReportHistory, { foreignKey: "admin_id" });
  ReportHistory.belongsTo(Admin, { foreignKey: "admin_id" });

  // GovernmentAgency and Report (one-to-many)
  GovernmentAgency.hasMany(Report, { foreignKey: "agency_id" });
  Report.belongsTo(GovernmentAgency, { foreignKey: "agency_id" });

  // GovernmentAgency and ReportHistory (one-to-many)
  GovernmentAgency.hasMany(ReportHistory, { foreignKey: "agency_id" });
  ReportHistory.belongsTo(GovernmentAgency, { foreignKey: "agency_id" });

  // Report and ReportHistory (one-to-many)
  Report.hasMany(ReportHistory, { foreignKey: "report_id" });
  ReportHistory.belongsTo(Report, { foreignKey: "report_id" });

  console.log("Model associations established successfully");
};

export default setupAssociations;
