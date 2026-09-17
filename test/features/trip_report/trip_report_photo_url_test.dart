import 'package:cts/features/trip_report/helpers/trip_report_photo_url.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveTripReportPhotoUrl A-over-B', () {
    test('prefers non-null wire A over built B', () {
      final url = resolveTripReportPhotoUrl(
        wirePhotoUrl: 'https://cdn.example/a-start.jpg',
        batchId: '42',
        leg: TripReportLegKind.morning,
        kind: 'start',
      );
      expect(url, 'https://cdn.example/a-start.jpg');
    });

    test('prefers relative wire A path over B', () {
      final url = resolveTripReportPhotoUrl(
        wirePhotoUrl: 'd2d/odometer/photo/42/morning/start/',
        batchId: '99',
        leg: TripReportLegKind.ret,
        kind: 'end',
      );
      expect(url, 'd2d/odometer/photo/42/morning/start/');
    });

    test('falls back to B when A is null', () {
      final url = resolveTripReportPhotoUrl(
        wirePhotoUrl: null,
        batchId: '42',
        leg: TripReportLegKind.morning,
        kind: 'start',
      );
      expect(url, 'd2d/odometer/photo/42/morning/start/');
    });

    test('falls back to B when A is empty or "null"', () {
      expect(
        resolveTripReportPhotoUrl(
          wirePhotoUrl: '  ',
          batchId: '7',
          leg: TripReportLegKind.ret,
          kind: 'end',
        ),
        'd2d/odometer/photo/7/return/end/',
      );
      expect(
        resolveTripReportPhotoUrl(
          wirePhotoUrl: 'null',
          batchId: '7',
          leg: TripReportLegKind.ret,
          kind: 'end',
        ),
        'd2d/odometer/photo/7/return/end/',
      );
    });

    test('return leg uses apiValue return in B path', () {
      final url = resolveTripReportPhotoUrl(
        wirePhotoUrl: null,
        batchId: '3',
        leg: TripReportLegKind.ret,
        kind: 'start',
      );
      expect(url, 'd2d/odometer/photo/3/return/start/');
    });

    test('returns null when batchId empty and A missing', () {
      expect(
        resolveTripReportPhotoUrl(
          wirePhotoUrl: null,
          batchId: '',
          leg: TripReportLegKind.morning,
          kind: 'start',
        ),
        isNull,
      );
    });

    test('returns null for invalid kind when A missing', () {
      expect(
        resolveTripReportPhotoUrl(
          wirePhotoUrl: null,
          batchId: '1',
          leg: TripReportLegKind.morning,
          kind: 'mid',
        ),
        isNull,
      );
    });

    test('A wins even when batchId empty', () {
      expect(
        resolveTripReportPhotoUrl(
          wirePhotoUrl: '/media/x.jpg',
          batchId: '',
          leg: TripReportLegKind.morning,
          kind: 'start',
        ),
        '/media/x.jpg',
      );
    });
  });

  group('TripReportLeg photo URL parse', () {
    test('parses start_photo_url and end_photo_url', () {
      final leg = TripReportLeg.fromJson({
        'trip_id': 'm1',
        'close_kind': 'normal',
        'start_km': 10,
        'end_km': 20,
        'start_photo_url': 'https://host/a.jpg',
        'end_photo_url': 'd2d/odometer/photo/1/morning/end/',
      });
      expect(leg.startPhotoUrl, 'https://host/a.jpg');
      expect(leg.endPhotoUrl, 'd2d/odometer/photo/1/morning/end/');
    });

    test('null / empty / string-null photo fields → null', () {
      final leg = TripReportLeg.fromJson({
        'close_kind': 'open',
        'start_photo_url': null,
        'end_photo_url': 'null',
      });
      expect(leg.startPhotoUrl, isNull);
      expect(leg.endPhotoUrl, isNull);

      final empty = TripReportLeg.fromJson({
        'close_kind': 'open',
        'start_photo_url': '',
        'end_photo_url': '   ',
      });
      expect(empty.startPhotoUrl, isNull);
      expect(empty.endPhotoUrl, isNull);
    });

    test('legacy payload without photo keys remains null-safe', () {
      final leg = TripReportLeg.fromJson({
        'close_kind': 'incomplete',
        'auto_closed': true,
        'start_km': 100,
        'end_km': 100,
      });
      expect(leg.startPhotoUrl, isNull);
      expect(leg.endPhotoUrl, isNull);
    });
  });
}
