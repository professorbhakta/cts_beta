class ApiUrl {

  static String loginUrl = "user/login";
  static String logoutUrl = "user/logout";
  static const webSocket = "ws://localhost:8000/ws/";

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
  static String userTypeUrl = "";

  static String returnBatchView = "return_batch/view/";
  static String returnBatchGetCommuter = "return_batch/get_commuter/";
  static String returnBatchAddCommuter = "return_batch/add_commuter";
  static String returnBatchRemoveCommuter = "return_batch/remove_commuter";
  static String returnBatchEnd = "return_batch/end/";

}
