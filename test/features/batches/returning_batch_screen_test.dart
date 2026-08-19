import 'package:cts/api/api_result.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/batches/widgets/return_batch_picker_card.dart';
import 'package:cts/features/batches/screens/returning_batch_screen.dart';
import 'package:cts/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeBatchRepository implements BatchRepository {
  _FakeBatchRepository(this.batches);

  final List<BatchModel> batches;

  @override
  Future<ApiResult<List<BatchModel>>> getBatches() async {
    return ApiResult.success(batches);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReturnBatchRepository implements ReturnBatchRepository {
  _FakeReturnBatchRepository(this.statusById);

  final Map<String, ReturnBatchStatusModel> statusById;

  @override
  Future<ApiResult<ReturnBatchStatusModel>> getReturnBatchStatus(
    String batchId,
  ) async {
    final status = statusById[batchId];
    if (status == null) {
      return ApiResult.failure(
        const ApiFailure(type: ApiFailureType.unexpected, message: 'missing'),
      );
    }
    return ApiResult.success(status);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ReturnBatchStatusModel _baseStatus(String batchId) {
  return ReturnBatchStatusModel(
    batchId: batchId,
    tripDate: '2026-08-20',
    isActive: false,
    availableCount: 3,
    confirmedCount: 1,
    totalCapacity: 8,
    remainingCapacity: 5,
  );
}

ReturnBatchStatusModel _statusWithExtras(String batchId) {
  return ReturnBatchStatusModel(
    batchId: batchId,
    tripDate: '2026-08-20',
    isActive: true,
    availableCount: 3,
    confirmedCount: 1,
    totalCapacity: 8,
    remainingCapacity: 5,
    homeHold: 2,
    overflowConfirmed: 1,
    overflowRemaining: 0,
  );
}

BatchModel _batch(int id, String name) {
  return BatchModel(id: id, batchName: name, returnTime: '18:30:00');
}

Widget _wrap({
  required Widget child,
  required BatchProvider batchProvider,
  required ReturnBatchProvider returnProvider,
  Size viewport = const Size(390, 844),
}) {
  return MediaQuery(
    data: MediaQueryData(size: viewport),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<BatchProvider>.value(value: batchProvider),
          ChangeNotifierProvider<ReturnBatchProvider>.value(
            value: returnProvider,
          ),
        ],
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReturningBatchScreen layout', () {
    testWidgets('small viewport uses list layout without nested card scroll',
        (tester) async {
      final batches = List.generate(3, (index) => _batch(index + 1, 'Batch-$index'));
      final batchProvider = BatchProvider(_FakeBatchRepository(batches));
      await batchProvider.fetchBatches();

      final returnProvider = ReturnBatchProvider(
        _FakeReturnBatchRepository({
          for (final batch in batches)
            '${batch.id}': _baseStatus('${batch.id}'),
        }),
      );
      await returnProvider.fetchStatusesForBatches(
        batches.map((b) => '${b.id}').toList(),
      );

      await tester.pumpWidget(
        _wrap(
          child: const ReturningBatchScreen(),
          batchProvider: batchProvider,
          returnProvider: returnProvider,
          viewport: const Size(360, 640),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('Batch-0'), findsOneWidget);
    });

    testWidgets('pool extras on narrow screen show overflow rows in list cards',
        (tester) async {
      final batches = [_batch(1, 'Evening-A')];
      final batchProvider = BatchProvider(_FakeBatchRepository(batches));
      await batchProvider.fetchBatches();

      final returnProvider = ReturnBatchProvider(
        _FakeReturnBatchRepository({'1': _statusWithExtras('1')}),
      );
      await returnProvider.fetchStatusesForBatches(['1']);

      await tester.pumpWidget(
        _wrap(
          child: const ReturningBatchScreen(),
          batchProvider: batchProvider,
          returnProvider: returnProvider,
          viewport: const Size(360, 640),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home hold'), findsOneWidget);
      expect(find.text('Overflow open'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('wide viewport with many batches uses grid without nested scroll',
        (tester) async {
      final batches = List.generate(
        24,
        (index) => _batch(index + 1, 'Batch-${index + 1}'),
      );
      final batchProvider = BatchProvider(_FakeBatchRepository(batches));
      await batchProvider.fetchBatches();

      final returnProvider = ReturnBatchProvider(
        _FakeReturnBatchRepository({
          for (final batch in batches)
            '${batch.id}': _baseStatus('${batch.id}'),
        }),
        statusFetchConcurrency: 8,
      );
      await returnProvider.fetchStatusesForBatches(
        batches.map((b) => '${b.id}').toList(),
      );

      await tester.pumpWidget(
        _wrap(
          child: const ReturningBatchScreen(),
          batchProvider: batchProvider,
          returnProvider: returnProvider,
          viewport: const Size(900, 900),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('Batch-1'), findsOneWidget);
      expect(returnProvider.statusByBatchId.length, 24);
      expect(find.byType(ReturnBatchPickerCard), findsWidgets);
    });
  });
}
