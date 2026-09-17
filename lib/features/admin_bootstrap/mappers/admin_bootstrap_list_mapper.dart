import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/commuters/models/commuter_model.dart' show CommuterModel;
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/models/cab_model.dart' as cab_models;
import 'package:cts/models/pop_model.dart';
import 'package:cts/models/route_model.dart';
import 'package:cts/models/user_model.dart';

/// Maps bootstrap luggage → list UI models (nested ids resolved from flat rows).
class AdminBootstrapListMapper {
  const AdminBootstrapListMapper._();

  static List<RouteModel> routes(AdminBootstrapResponse luggage) {
    return [
      for (final r in luggage.routes)
        if (r.id > 0) RouteModel(id: r.id, routeName: r.routeName),
    ];
  }

  static List<BatchModel> batches(AdminBootstrapResponse luggage) {
    return [
      for (final b in luggage.batches)
        if (b.id.isNotEmpty) _batch(b),
    ];
  }

  static List<PickUpPointModel> pops(AdminBootstrapResponse luggage) {
    final routeById = {for (final r in luggage.routes) r.id: r};
    return [
      for (final p in luggage.pickUpPoints)
        if (p.id > 0)
          PickUpPointModel(
            id: p.id,
            pickUpPointName: p.pickUpPointName,
            inLine: p.inLine,
            routeId: _routeId(p.routeId, routeById),
          ),
    ];
  }

  static List<cab_models.CabModel> cabs(AdminBootstrapResponse luggage) {
    final routeById = {for (final r in luggage.routes) r.id: r};
    final driversByCab = <int, List<DriverModel>>{};
    for (final d in luggage.drivers) {
      final cabId = d.cabId;
      if (cabId == null || cabId <= 0) continue;
      driversByCab.putIfAbsent(cabId, () => <DriverModel>[]).add(
            _driver(d, luggage),
          );
    }

    return [
      for (final c in luggage.cabs)
        if (c.id > 0)
          cab_models.CabModel(
            id: c.id,
            regNumber: c.regNumber,
            capacity: c.capacity,
            km: c.km,
            trackingVehicleId: c.trackingVehicleId,
            routeId: _cabRouteId(c.routeId, routeById),
            driver: driversByCab[c.id] ?? const [],
          ),
    ];
  }

  static List<DriverModel> drivers(AdminBootstrapResponse luggage) {
    return [
      for (final d in luggage.drivers)
        if (d.driverId > 0) _driver(d, luggage),
    ];
  }

  static List<CommuterModel> commuters(AdminBootstrapResponse luggage) {
    final batchById = {for (final b in luggage.batches) b.id: b};
    final popById = {for (final p in luggage.pickUpPoints) p.id: p};
    final cabById = {for (final c in luggage.cabs) c.id: c};
    final routeById = {for (final r in luggage.routes) r.id: r};
    final orgById = {for (final o in luggage.organizations) o.id: o};

    return [
      for (final c in luggage.commuters)
        if (c.commuterId > 0)
          CommuterModel(
            id: c.commuterId,
            isComing: c.isComing,
            organizationId: c.organizationId,
            organizationName: c.organizationId == null
                ? null
                : orgById[c.organizationId!]?.orgName,
            batchId:
                c.batchId == null ? null : _batchOrNull(batchById[c.batchId!]),
            popId: c.popId == null
                ? null
                : _popOrNull(popById[c.popId!], routeById),
            cabId: c.cabId == null
                ? null
                : _cabOrNull(cabById[c.cabId!], routeById),
            userId: UserModel(
              id: c.userId,
              username: c.username,
              mobileNumber: c.mobileNumber,
              userType: c.userType,
              hasPaid: c.hasPaid,
            ),
          ),
    ];
  }

  static BatchModel _batch(BootstrapBatch b) {
    return BatchModel(
      id: int.tryParse(b.id),
      batchName: b.batchName,
      batchTime: b.batchTime,
      returnTime: b.endTime,
      startDate: b.startDate,
      endDate: b.endDate,
    );
  }

  static BatchModel? _batchOrNull(BootstrapBatch? b) =>
      b == null ? null : _batch(b);

  static PickUpPointModel? _popOrNull(
    BootstrapPickUpPoint? pop,
    Map<int, BootstrapRoute> routeById,
  ) {
    if (pop == null) return null;
    return PickUpPointModel(
      id: pop.id,
      pickUpPointName: pop.pickUpPointName,
      inLine: pop.inLine,
      routeId: _routeId(pop.routeId, routeById),
    );
  }

  static cab_models.CabModel? _cabOrNull(
    BootstrapCab? cab,
    Map<int, BootstrapRoute> routeById,
  ) {
    if (cab == null) return null;
    return cab_models.CabModel(
      id: cab.id,
      regNumber: cab.regNumber,
      capacity: cab.capacity,
      km: cab.km,
      trackingVehicleId: cab.trackingVehicleId,
      routeId: _cabRouteId(cab.routeId, routeById),
    );
  }

  static RouteId? _routeId(int? routeId, Map<int, BootstrapRoute> routeById) {
    if (routeId == null) return null;
    return RouteId(
      id: routeId,
      routeName: routeById[routeId]?.routeName,
    );
  }

  static cab_models.RouteId? _cabRouteId(
    int? routeId,
    Map<int, BootstrapRoute> routeById,
  ) {
    if (routeId == null) return null;
    return cab_models.RouteId(
      id: routeId,
      routeName: routeById[routeId]?.routeName,
    );
  }

  static DriverModel _driver(
    BootstrapDriver d,
    AdminBootstrapResponse luggage,
  ) {
    final batchById = {for (final b in luggage.batches) b.id: b};
    final cabById = {for (final c in luggage.cabs) c.id: c};
    final routeById = {for (final r in luggage.routes) r.id: r};
    final batch = d.batchId == null ? null : batchById[d.batchId!];
    final cab = d.cabId == null ? null : cabById[d.cabId!];

    return DriverModel(
      id: d.driverId,
      userId: UserModel(
        id: d.userId,
        username: d.username,
        mobileNumber: d.mobileNumber,
      ),
      batchId: _batchOrNull(batch),
      cabId: _cabOrNull(cab, routeById),
    );
  }
}
