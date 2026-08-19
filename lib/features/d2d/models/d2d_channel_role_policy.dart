/// Role-action matrix for live D2D WebSocket mutations.
///
/// Connect/disconnect is allowed for admin (monitor) and assigned driver.
/// Trip closure (STOP) is driver-only; admin Close channel is disconnect only.
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

  static bool can(String? role, D2dChannelAction action) {
    switch (action) {
      case D2dChannelAction.connect:
      case D2dChannelAction.disconnect:
        return role == 'ADMIN' || role == 'DRIVER';
      case D2dChannelAction.addCommuter:
      case D2dChannelAction.removeFromQueue:
        return role == 'ADMIN' || role == 'DRIVER';
      case D2dChannelAction.confirmPickup:
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
        return 'Only the driver can confirm pickups.';
      case D2dChannelAction.stopTrip:
        return 'Only the driver can end the trip. Close channel does not stop the day.';
    }
  }
}
