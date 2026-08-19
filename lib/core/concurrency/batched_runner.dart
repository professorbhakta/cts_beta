/// Runs [task] for each item with at most [concurrency] tasks in flight.
Future<List<R>> runWithConcurrency<T, R>(
  List<T> items, {
  required int concurrency,
  required Future<R> Function(T item) task,
}) async {
  if (items.isEmpty) return [];
  if (concurrency < 1) {
    throw ArgumentError.value(concurrency, 'concurrency', 'must be >= 1');
  }

  final results = List<R?>.filled(items.length, null);
  var nextIndex = 0;

  Future<void> worker() async {
    while (true) {
      final index = nextIndex++;
      if (index >= items.length) return;
      results[index] = await task(items[index]);
    }
  }

  final workerCount = concurrency.clamp(1, items.length);
  await Future.wait(List.generate(workerCount, (_) => worker()));

  return results.cast<R>();
}
