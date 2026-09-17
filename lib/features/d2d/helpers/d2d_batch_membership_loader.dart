import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership.dart';

/// Loads org luggage once and exposes [D2dBatchMembership] for live/return UIs.
class D2dBatchMembershipLoader {
  D2dBatchMembershipLoader(this._repository);

  final CommuterRepository _repository;
  D2dBatchMembership _membership = D2dBatchMembership.empty();
  bool _loaded = false;

  D2dBatchMembership get membership => _membership;
  bool get isLoaded => _loaded;

  Future<D2dBatchMembership> ensureLoaded() async {
    if (_loaded) return _membership;
    final result = await _repository.getCommuters();
    if (result.isSuccess && result.data != null) {
      _membership = fromCommuters(result.data!);
    } else {
      _membership = D2dBatchMembership.empty();
    }
    _loaded = true;
    return _membership;
  }

  static D2dBatchMembership fromCommuters(List<CommuterModel> commuters) {
    return D2dBatchMembership.fromCommuterRows(
      commuters.map(
        (c) => (
          userId: c.userId?.id,
          batchId: c.batchId?.id?.toString(),
        ),
      ),
    );
  }
}
