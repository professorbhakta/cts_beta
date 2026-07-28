import 'package:flutter/material.dart';

class BatchFormProvider with ChangeNotifier {
  final nameCtrl = TextEditingController();

  // Use native types for dates and times, not controllers.
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? returnTime;

  int updateId = 0;
  bool forUpdate = false;

  void clearAll() {
    nameCtrl.clear();
    // Reset to sensible defaults
    startDate = DateTime.now();
    endDate = DateTime.now();
    startTime = const TimeOfDay(hour: 5, minute: 30);
    returnTime = const TimeOfDay(hour: 14, minute: 30);
    forUpdate = false;
    updateId = 0;
    notifyListeners();
  }

  // Methods to update state and notify listeners
  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setReturnTime(TimeOfDay time) {
    returnTime = time;
    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }
}
