/// Arguments for door-to-door named routes (`d2dChannel`, `d2dLog`).
class D2dRouteArgs {
  const D2dRouteArgs(this.batchId);

  final String batchId;

  static String? batchIdFrom(Object? arguments) {
    return switch (arguments) {
      D2dRouteArgs args => args.batchId,
      String batchId when batchId.isNotEmpty => batchId,
      _ => null,
    };
  }
}
