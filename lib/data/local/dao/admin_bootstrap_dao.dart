import 'dart:convert';

import 'package:cts/data/local/database/app_database.dart';
import 'package:cts/data/local/database/database_schema.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:sqflite/sqflite.dart';

/// Persists admin-bootstrap payload into snake_case SQLite tables.
///
/// When [Database] is null (web / SQLite skipped), writes are no-ops — API is source of truth.
class AdminBootstrapDao {
  AdminBootstrapDao([Database? db]) : _dbOverride = db;

  final Database? _dbOverride;

  Database? get _db =>
      _dbOverride ?? AppDatabase.instanceOrNull?.databaseOrNull;

  Future<void> replaceAll(
    AdminBootstrapResponse payload, {
    required String adminCode,
  }) async {
    final db = _db;
    if (db == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.delete(DatabaseSchema.organizationTable);
      await txn.delete(DatabaseSchema.subAdminOrganizationTable);
      await txn.delete(DatabaseSchema.supervisorTable);
      await txn.delete(DatabaseSchema.routeTable);
      await txn.delete(DatabaseSchema.pickUpPointTable);
      await txn.delete(DatabaseSchema.batchTable);
      await txn.delete(DatabaseSchema.cabTable);
      await txn.delete(DatabaseSchema.driverTable);
      await txn.delete(DatabaseSchema.commuterTable);

      for (final org in payload.organizations) {
        if (org.id.isEmpty) continue;
        await txn.insert(
          DatabaseSchema.organizationTable,
          {
            'id': org.id,
            'org_name': org.orgName,
            'is_active': org.isActive ? 1 : 0,
            'created_at': org.createdAt,
            'updated_at': org.updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final route in payload.routes) {
        if (route.id <= 0) continue;
        await txn.insert(
          DatabaseSchema.routeTable,
          {
            'id': route.id,
            'route_name': route.routeName,
            'route_code': route.routeCode,
            'is_active': route.isActive ? 1 : 0,
            'admin_code': adminCode,
            'organization_id': route.organizationId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final pop in payload.pickUpPoints) {
        if (pop.id <= 0) continue;
        await txn.insert(
          DatabaseSchema.pickUpPointTable,
          {
            'id': pop.id,
            'pick_up_point_name': pop.pickUpPointName,
            'route_id': pop.routeId,
            'lat': pop.lat,
            'longitude': pop.longitude,
            'in_line': pop.inLine,
            'area': pop.area,
            'is_active': pop.isActive ? 1 : 0,
            'admin_code': adminCode,
            'organization_id': pop.organizationId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final batch in payload.batches) {
        if (batch.id.isEmpty) continue;
        await txn.insert(
          DatabaseSchema.batchTable,
          {
            'id': batch.id,
            'batch_name': batch.batchName,
            'batch_time': batch.batchTime,
            'end_time': batch.endTime,
            'start_date': batch.startDate,
            'end_date': batch.endDate,
            'is_active': batch.isActive ? 1 : 0,
            'admin_code': adminCode,
            'organization_id': batch.organizationId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final cab in payload.cabs) {
        if (cab.id <= 0) continue;
        await txn.insert(
          DatabaseSchema.cabTable,
          {
            'id': cab.id,
            'reg_number': cab.regNumber,
            'capacity': cab.capacity,
            'route_id': cab.routeId,
            'ac_type': cab.acType,
            'km': cab.km,
            'tracking_vehicle_id': cab.trackingVehicleId,
            'is_active': cab.isActive ? 1 : 0,
            'admin_code': adminCode,
            'organization_id': cab.organizationId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final driver in payload.drivers) {
        if (driver.driverId <= 0) continue;
        await txn.insert(
          DatabaseSchema.driverTable,
          {
            'driver_id': driver.driverId,
            'user_id': driver.userId,
            'username': driver.username,
            'mobile_number': driver.mobileNumber,
            'batch_id': driver.batchId,
            'cab_id': driver.cabId,
            'is_active': driver.isActive ? 1 : 0,
            'admin_code': adminCode,
            'organization_id': driver.organizationId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final commuter in payload.commuters) {
        if (commuter.commuterId <= 0) continue;
        await txn.insert(
          DatabaseSchema.commuterTable,
          {
            'commuter_id': commuter.commuterId,
            'user_id': commuter.userId,
            'username': commuter.username,
            'mobile_number': commuter.mobileNumber,
            'user_type': commuter.userType,
            'batch_id': commuter.batchId,
            'pop_id': commuter.popId,
            'cab_id': commuter.cabId,
            'is_coming': commuter.isComing ? 1 : 0,
            'has_paid': commuter.hasPaid == null
                ? null
                : (commuter.hasPaid! ? 1 : 0),
            'is_active': commuter.isActive ? 1 : 0,
            'admin_code': adminCode,
            'organization_id': commuter.organizationId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await txn.insert(
        DatabaseSchema.bootstrapMetaTable,
        {
          'id': 1,
          'status': payload.status,
          'generated_at': payload.generatedAt,
          'admin_code': adminCode,
          'trip_date': payload.today.tripDate,
          'active_morning_batch_ids':
              jsonEncode(payload.today.activeMorningBatchIds),
          'active_return_batch_ids':
              jsonEncode(payload.today.activeReturnBatchIds),
          'enum_user_type': jsonEncode(payload.enums.userType),
          'enum_ac_type': jsonEncode(payload.enums.acType),
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<AdminBootstrapResponse?> readMetaAsResponse() async {
    final db = _db;
    if (db == null) return null;
    final rows = await db.query(
      DatabaseSchema.bootstrapMetaTable,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return AdminBootstrapResponse(
      status: row['status']?.toString() ?? 'ok',
      generatedAt: row['generated_at']?.toString() ?? '',
      adminCode: row['admin_code']?.toString(),
      enums: BootstrapEnums(
        userType: _decodeStringList(row['enum_user_type']),
        acType: _decodeStringList(row['enum_ac_type']),
      ),
      today: BootstrapToday(
        tripDate: row['trip_date']?.toString(),
        activeMorningBatchIds:
            _decodeStringList(row['active_morning_batch_ids']),
        activeReturnBatchIds:
            _decodeStringList(row['active_return_batch_ids']),
      ),
    );
  }

  /// Rebuild full luggage from entity tables (cold start on mobile).
  Future<AdminBootstrapResponse?> readFullAsResponse() async {
    final db = _db;
    if (db == null) return null;

    final meta = await readMetaAsResponse();
    if (meta == null) return null;

    final orgRows = await db.query(DatabaseSchema.organizationTable);
    final routeRows = await db.query(DatabaseSchema.routeTable);
    final popRows = await db.query(DatabaseSchema.pickUpPointTable);
    final batchRows = await db.query(DatabaseSchema.batchTable);
    final cabRows = await db.query(DatabaseSchema.cabTable);
    final driverRows = await db.query(DatabaseSchema.driverTable);
    final commuterRows = await db.query(DatabaseSchema.commuterTable);

    return AdminBootstrapResponse(
      status: meta.status,
      generatedAt: meta.generatedAt,
      adminCode: meta.adminCode,
      enums: meta.enums,
      today: meta.today,
      organizations: [
        for (final row in orgRows)
          BootstrapOrganization(
            id: row['id']?.toString() ?? '',
            orgName: row['org_name']?.toString(),
            isActive: row['is_active'] == 1,
            createdAt: row['created_at']?.toString(),
            updatedAt: row['updated_at']?.toString(),
          ),
      ],
      routes: [
        for (final row in routeRows)
          BootstrapRoute(
            id: _rowInt(row['id']) ?? 0,
            routeName: row['route_name']?.toString(),
            routeCode: row['route_code']?.toString(),
            isActive: row['is_active'] == 1,
            organizationId: row['organization_id']?.toString(),
          ),
      ],
      pickUpPoints: [
        for (final row in popRows)
          BootstrapPickUpPoint(
            id: _rowInt(row['id']) ?? 0,
            pickUpPointName: row['pick_up_point_name']?.toString(),
            routeId: _rowInt(row['route_id']),
            lat: _rowDouble(row['lat']),
            longitude: _rowDouble(row['longitude']),
            inLine: _rowInt(row['in_line']),
            area: row['area']?.toString(),
            isActive: row['is_active'] == 1,
            organizationId: row['organization_id']?.toString(),
          ),
      ],
      batches: [
        for (final row in batchRows)
          BootstrapBatch(
            id: row['id']?.toString() ?? '',
            batchName: row['batch_name']?.toString(),
            batchTime: row['batch_time']?.toString(),
            endTime: row['end_time']?.toString(),
            startDate: row['start_date']?.toString(),
            endDate: row['end_date']?.toString(),
            isActive: row['is_active'] == 1,
            organizationId: row['organization_id']?.toString(),
          ),
      ],
      cabs: [
        for (final row in cabRows)
          BootstrapCab(
            id: _rowInt(row['id']) ?? 0,
            regNumber: row['reg_number']?.toString(),
            capacity: _rowInt(row['capacity']),
            routeId: _rowInt(row['route_id']),
            acType: row['ac_type']?.toString(),
            km: _rowInt(row['km']),
            trackingVehicleId: row['tracking_vehicle_id']?.toString(),
            isActive: row['is_active'] == 1,
            organizationId: row['organization_id']?.toString(),
          ),
      ],
      drivers: [
        for (final row in driverRows)
          BootstrapDriver(
            driverId: _rowInt(row['driver_id']) ?? 0,
            userId: _rowInt(row['user_id']),
            username: row['username']?.toString(),
            mobileNumber: row['mobile_number']?.toString(),
            batchId: row['batch_id']?.toString(),
            cabId: _rowInt(row['cab_id']),
            isActive: row['is_active'] == 1,
            organizationId: row['organization_id']?.toString(),
          ),
      ],
      commuters: [
        for (final row in commuterRows)
          BootstrapCommuter(
            commuterId: _rowInt(row['commuter_id']) ?? 0,
            userId: _rowInt(row['user_id']),
            username: row['username']?.toString(),
            mobileNumber: row['mobile_number']?.toString(),
            userType: row['user_type']?.toString(),
            batchId: row['batch_id']?.toString(),
            popId: _rowInt(row['pop_id']),
            cabId: _rowInt(row['cab_id']),
            isComing: row['is_coming'] == 1,
            hasPaid: row['has_paid'] == null ? null : row['has_paid'] == 1,
            isActive: row['is_active'] == 1,
            organizationId: row['organization_id']?.toString(),
          ),
      ],
    );
  }

  int? _rowInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _rowDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> clearAll() async {
    final db = _db;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete(DatabaseSchema.organizationTable);
      await txn.delete(DatabaseSchema.routeTable);
      await txn.delete(DatabaseSchema.pickUpPointTable);
      await txn.delete(DatabaseSchema.batchTable);
      await txn.delete(DatabaseSchema.cabTable);
      await txn.delete(DatabaseSchema.driverTable);
      await txn.delete(DatabaseSchema.commuterTable);
      await txn.delete(DatabaseSchema.bootstrapMetaTable);
    });
  }

  List<String> _decodeStringList(Object? raw) {
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }
}
