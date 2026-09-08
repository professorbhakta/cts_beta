/// Role gates for return-trip QR boarding UI (prep — await Dock BE contract).
///
/// Mirrors morning product split: driver/admin-like **show** QR; staff/commuter
/// **scan**. Morning admin D2D channel still has no QR chrome; return **show**
/// entry is driver-primary, with ADMIN/SUPERVISOR allowed on the route for
/// parity with other driver-only prefixes (`d2dLog`, `driverReturnCommuter`).
///
/// Wire: morning helpers in [docs/API_CONTRACTS.md](../../../../docs/API_CONTRACTS.md)
/// client-pack boarding section. Do **not** invent return-QR URLs.
class ReturnBoardingRolePolicy {
  const ReturnBoardingRolePolicy._();

  /// DRIVER shows QR; ADMIN / SUPERVISOR may open the show route (allow-list d2d).
  static bool canShowQr(String? role) {
    return role == 'DRIVER' || role == 'ADMIN' || role == 'SUPERVISOR';
  }

  /// STAFF / COMMUTER scan side — same as morning `/boardingScan`.
  static bool canScan(String? role) {
    return role == 'COMMUTER' || role == 'STAFF';
  }
}
