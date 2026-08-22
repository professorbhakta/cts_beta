class ApiUrl {

  static String loginUrl = "user/login";
  static String logoutUrl = "user/logout";

  static String userUrl = "user";
  static String cndUserUrl = "user/";
  static String adminUrl = "user/admin/";
  static String driverUrl = "user/driver";
  static String adminDriverUrl = "user/admin/driver/";
  static String commuterUrl = "user/commuter";
  static String commuterDriverUrl = "user/driver/batch/";
  static String adminCommuterUrl = "user/admin/commuter/";

  static String batchUrl = "cab/batch";
  static String adminBatchUrl = "cab/admin/batch/";
  static String pickUpPointUrl = "cab/pickUpPoint";
  static String adminPickUpPointUrl = "cab/admin/pickuppoint/";
  static String routeUrl = "cab/route";
  static String adminRouteUrl = "cab/admin/route/";
  static String cabUrl = "cab/cab";
  static String adminCabUrl = "cab/admin/cab/";
  static String dtotLogUrl = "d2d/running_batches";
  static const String d2dLogStatus = "d2d/get_d2d_log_status/";
  static String userTypeUrl = "";

  static const String returnBatchView = "d2d/return_batch/view/";
  static const String returnBatchStatus = "d2d/return_batch/status/";
  static const String returnBatchGetCommuter = "d2d/return_batch/get_commuter/";
  static const String returnBatchAddCommuter = "d2d/return_batch/add_commuter";
  static const String returnBatchRemoveCommuter =
      "d2d/return_batch/remove_commuter";
  static const String returnBatchEnd = "d2d/return_batch/end/";
  static const String returnBatchIntent = "d2d/return_batch/intent";
  static const String returnBatchIntentOptions =
      "d2d/return_batch/intent_options";

}
