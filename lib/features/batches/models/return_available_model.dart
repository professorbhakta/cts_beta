import 'package:cts/features/commuters/models/commuter_model.dart';

class ReturnAvailableResult {
  const ReturnAvailableResult({
    required this.home,
    required this.overflow,
    this.waiting = const [],
  });

  final List<CommuterModel> home;
  final List<CommuterModel> overflow;
  final List<CommuterModel> waiting;

  List<CommuterModel> get all => [...home, ...overflow];

  /// Breaking GET view/: parse home[] / overflow[] / waiting[]. Ignore flat `commuters`.
  factory ReturnAvailableResult.fromJson(Map<String, dynamic> json) {
    final hasSplit = json.containsKey('home') ||
        json.containsKey('overflow') ||
        json.containsKey('waiting');
    if (!hasSplit) {
      return const ReturnAvailableResult(home: [], overflow: []);
    }
    return ReturnAvailableResult(
      home: _parseList(json['home']),
      overflow: _parseList(json['overflow']),
      waiting: _parseList(json['waiting']),
    );
  }

  static List<CommuterModel> _parseList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => CommuterModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
