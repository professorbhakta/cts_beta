/// Role-action matrix for live D2D WebSocket mutations.
///
/// Connect/disconnect: admin-like monitors + assigned driver.
/// Add: ADMIN / SUPERVISOR only (not DRIVER, not SUPER_ADMIN).
/// Board (confirm) + remove: admin operators + driver.
/// Trip closure (STOP): driver only; admin Close channel is disconnect only.
enum D2dChannelAction {
  connect,
  disconnect,
  addCommuter,
  removeFromQueue,
  confirmPickup,
  stopTrip,
}

class D2dChannelRolePolicy {
  const D2dChannelRolePolicy._();

  /// ADMIN / SUPERVISOR day-ops operators (Add + Board + Remove).
  static bool isOperator(String? role) =>
      role == 'ADMIN' || role == 'SUPERVISOR';

  /// Can join the live channel to watch (includes SUPER_ADMIN monitor).
  static bool isMonitor(String? role) =>
      isOperator(role) || role == 'SUPER_ADMIN';

  static bool can(String? role, D2dChannelAction action) {
    switch (action) {
      case D2dChannelAction.connect:
      case D2dChannelAction.disconnect:
        return isMonitor(role) || role == 'DRIVER';
      case D2dChannelAction.addCommuter:
        // Driver never; SUPER_ADMIN monitor-only.
        return isOperator(role);
      case D2dChannelAction.removeFromQueue:
      case D2dChannelAction.confirmPickup:
        return isOperator(role) ||
            role == 'SUPER_ADMIN' ||
            role == 'DRIVER';
      case D2dChannelAction.stopTrip:
        return role == 'DRIVER';
    }
  }

  static String denialMessage(D2dChannelAction action) {
    switch (action) {
      case D2dChannelAction.connect:
      case D2dChannelAction.disconnect:
        return 'You are not allowed to join this live trip.';
      case D2dChannelAction.addCommuter:
        return 'You are not allowed to add commuters to this trip.';
      case D2dChannelAction.removeFromQueue:
        return 'You are not allowed to remove commuters from this trip.';
      case D2dChannelAction.confirmPickup:
        return 'You are not allowed to confirm pickups on this trip.';
      case D2dChannelAction.stopTrip:
        return 'Only the driver can end the trip. Close channel does not stop the day.';
    }
  }
}
