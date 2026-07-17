import 'package:cts/offline_temp/models/offline_commuter.dart';

class OfflineExportService {
  static String buildReport({
    required List<OfflineCommuter> commuters,
  }) {
    if (commuters.isEmpty) {
      return 'No commuters found.';
    }

    final buffer = StringBuffer('Name | PoP | Mobile');
    for (final c in commuters) {
      buffer.writeln();
      buffer.write(c.name);
      buffer.write(' | ');
      buffer.write(c.popName?.isNotEmpty == true ? c.popName! : '-');
      buffer.write(' | ');
      buffer.write(c.mobile.isEmpty ? '-' : c.mobile);
    }

    return buffer.toString();
  }

  static String buildBatchSummary({
    required String batchName,
    required List<OfflineCommuter> commuters,
  }) {
    return buildReport(commuters: commuters);
  }
}
