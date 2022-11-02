import 'database_manager.dart';
import 'estimate_dto.dart';
import '../models/engagement.dart';
import '../models/estimate.dart';

class EstimateDAO {

  static const sqlSelect = "SELECT * FROM estimates WHERE engagementId = ? ORDER BY createdAt DESC;";
  static const sqlDelete = "DELETE FROM estimates WHERE estimateId = ?;";
  static const sqlInsert = "INSERT INTO estimates(engagementId, name, createdAt, acres, structures) VALUES (?, ?, ?, ?, ?);";

  static Future<List<Estimate>> estimates({required DatabaseManager databaseManager, required Engagement engagement}) async {
    final estimateRecords = await databaseManager.selectWhere(sql: sqlSelect, values: [engagement.id]);
    return estimateRecords.map( (row) => Estimate.fromMap(map: row) ).toList();
  }

  static Future<void> delete({required DatabaseManager databaseManager, required Estimate estimate}) async {
    final id = estimate.id;
    if (id != null) databaseManager.delete(sql: sqlDelete, id: id);
  }

  static Future<void> save({required DatabaseManager databaseManager, required EstimateDTO dto}) async {
    databaseManager.insert(sql: sqlInsert, values: [dto.engagementId, dto.name, dto.createdAt.toString(), dto.acres, dto.structures]);
  }

}
