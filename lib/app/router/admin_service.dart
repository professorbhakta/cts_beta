import 'package:cts/app/router/route_names.dart';
import 'package:flutter/material.dart';

/// Admin management services used for dashboard tiles, drawer nav, and
/// route guards. Keep this catalog platform-agnostic so the same gates work
/// for mobile now and web later.
enum AdminService {
  batch,
  cab,
  route,
  pop,
  driver,
  d2d,
  commuter,
  tripReport,
}

/// Phase A capability helpers for ADMIN (full) vs SUPERVISOR (allow-list).
class AdminCapabilities {
  AdminCapabilities._();

  /// Full admin catalog — every management service.
  static const Set<AdminService> all = {
    AdminService.batch,
    AdminService.cab,
    AdminService.route,
    AdminService.pop,
    AdminService.driver,
    AdminService.d2d,
    AdminService.commuter,
    AdminService.tripReport,
  };

  /// SUPERVISOR Phase A allow-list: day-ops CRUD + D2D channel.
  /// Excludes full-admin-only tools (org billing / org-delete / offline temp).
  static const Set<AdminService> supervisorAllowList = {
    AdminService.batch,
    AdminService.cab,
    AdminService.route,
    AdminService.pop,
    AdminService.driver,
    AdminService.d2d,
    AdminService.commuter,
    AdminService.tripReport,
  };

  static Set<AdminService> forRole(String? userType) {
    switch (userType) {
      case 'ADMIN':
      case 'SUPER_ADMIN':
        return all;
      case 'SUPERVISOR':
        return supervisorAllowList;
      default:
        return const {};
    }
  }

  static bool canAccessService(String? userType, AdminService service) =>
      forRole(userType).contains(service);

  /// Maps an admin-only location to its owning service, if any.
  /// [RouteName.adminHomeScreen] is the shared shell (not a service tile).
  static AdminService? serviceForLocation(String location) {
    for (final entry in _serviceRoutePrefixes.entries) {
      for (final prefix in entry.value) {
        if (location == prefix || location.startsWith('$prefix/')) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Whether [userType] may open an admin-only [location].
  /// Admin home (shell) is allowed for any admin-like role.
  static bool canAccessAdminLocation(String? userType, String location) {
    if (!_isAdminHome(location)) {
      final service = serviceForLocation(location);
      if (service == null) {
        // Unknown admin prefix — full admins only (fail closed).
        return userType == 'ADMIN' || userType == 'SUPER_ADMIN';
      }
      return canAccessService(userType, service);
    }
    return RouteName.isAdminLike(userType);
  }

  static bool _isAdminHome(String location) {
    const home = RouteName.adminHomeScreen;
    return location == home || location.startsWith('$home/');
  }

  static const Map<AdminService, Set<String>> _serviceRoutePrefixes = {
    AdminService.batch: {
      RouteName.batchScreen,
      RouteName.batchForm,
      RouteName.runningBatchScreen,
      RouteName.returnBatchScreen,
      RouteName.returnCommuterScreen,
    },
    AdminService.cab: {
      RouteName.cabScreen,
      RouteName.cabForm,
    },
    AdminService.route: {
      RouteName.routeScreen,
      RouteName.routeForm,
    },
    AdminService.pop: {
      RouteName.popScreen,
      RouteName.popForm,
    },
    AdminService.driver: {
      RouteName.driverScreen,
      RouteName.driverForm,
    },
    AdminService.d2d: {
      RouteName.d2dChannel,
    },
    AdminService.commuter: {
      RouteName.commuterScreen,
      RouteName.commuterForm,
    },
    AdminService.tripReport: {
      RouteName.tripReportScreen,
    },
  };
}

/// Drawer / overview metadata for one [AdminService].
class AdminServiceNavItem {
  const AdminServiceNavItem({
    required this.service,
    required this.title,
    required this.route,
    required this.icon,
  });

  final AdminService service;
  final String title;
  final String route;
  final IconData icon;
}

/// Shared catalog for admin drawer management links (filtered by capability).
class AdminServiceCatalog {
  AdminServiceCatalog._();

  static const List<AdminServiceNavItem> managementDrawerItems = [
    AdminServiceNavItem(
      service: AdminService.commuter,
      title: 'Commuters',
      route: RouteName.commuterScreen,
      icon: Icons.people_outline,
    ),
    AdminServiceNavItem(
      service: AdminService.pop,
      title: 'Pick-up Points',
      route: RouteName.popScreen,
      icon: Icons.location_on_outlined,
    ),
    AdminServiceNavItem(
      service: AdminService.batch,
      title: 'Batches',
      route: RouteName.batchScreen,
      icon: Icons.directions_bus_outlined,
    ),
    AdminServiceNavItem(
      service: AdminService.cab,
      title: 'Cabs',
      route: RouteName.cabScreen,
      icon: Icons.directions_car_outlined,
    ),
    AdminServiceNavItem(
      service: AdminService.driver,
      title: 'Drivers',
      route: RouteName.driverScreen,
      icon: Icons.badge_outlined,
    ),
    AdminServiceNavItem(
      service: AdminService.route,
      title: 'Routes',
      route: RouteName.routeScreen,
      icon: Icons.route_outlined,
    ),
    AdminServiceNavItem(
      service: AdminService.tripReport,
      title: 'Trip Report',
      route: RouteName.tripReportScreen,
      icon: Icons.assignment_outlined,
    ),
  ];

  static List<AdminServiceNavItem> drawerItemsForRole(String? userType) {
    final allowed = AdminCapabilities.forRole(userType);
    return managementDrawerItems
        .where((item) => allowed.contains(item.service))
        .toList(growable: false);
  }
}
