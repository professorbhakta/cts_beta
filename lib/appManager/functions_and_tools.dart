import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/theme/app_theme.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

ThemeData _snackTheme() {
  final ctx = SnackBarService.scaffoldMessengerKey.currentContext;
  return ctx != null ? Theme.of(ctx) : AppTheme.light();
}

SizedBox sizeBox(double w, double h) {
  return SizedBox(
    width: w,
    height: h,
  );
}

int getIdFromMap(String name, List<dynamic> list, String column) {
  var item =
      list.firstWhere((element) => element[column] == name, orElse: () => null);
  return item != null ? item['id'] : 0;
}

String getNameFromMap(String name, List<dynamic> list, String column) {
  var item =
      list.firstWhere((element) => element[column] == name, orElse: () => null);
  return item != null ? item[column] : 0;
}

String getStringFromMap(int id, List<dynamic> list, String column) {
  var item = list.firstWhere(
    (element) => element['id'] == id,
    orElse: () => null,
  );
  return item != null ? item[column].toString() : '';
}

String dateFormat(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  return formatter.format(dateTime);
}

String timeFormat(String timeString) {
  final DateFormat inputFormatter = DateFormat('HH:mm');
  final DateFormat outputFormatter = DateFormat('hh:mm a');
  final DateTime dateTime = inputFormatter.parse(timeString);
  return outputFormatter.format(dateTime);
}



Widget text(String string,Color? color, double? fontSize, FontWeight? fontWeight, ){
  return Text(string, style: TextStyle(
    fontFamily: "Noto Serif Nyiakeng Puachue Hmong",
    color: color,
    fontSize: fontSize,
    overflow: TextOverflow.ellipsis,
    fontWeight: fontWeight,
    letterSpacing: 0.8,



  ),
  overflow: TextOverflow.ellipsis,
  );
}

Duration batchTimeDuration(String time) {
  List<String> timeComponents = time.split(':');
  int hours = int.parse(timeComponents[0]);
  int minutes = int.parse(timeComponents[1]);
  int seconds = int.parse(timeComponents[2]);
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

Future<bool> calling(String mobile) async {
  final normalized = mobile.trim();
  if (normalized.isEmpty) return false;

  final launchUri = Uri(scheme: 'tel', path: normalized);
  if (await canLaunchUrl(launchUri)) {
    return launchUrl(launchUri);
  }
  return false;
}

Future<Future> confirmBox(
    BuildContext context,
    String title,
    String message,
    String positiveButtonText,
    String negativeButtonText,
    bool yes,
    bool no,
    StateSetter state) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        final scheme = context.scheme;
        return AlertDialog(
          backgroundColor: Colors.black45,
          title: Text(
            title,
            style: TextStyle(
              color: scheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: scheme.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: scheme.surface,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    positiveButtonText,
                    style: TextStyle(color: scheme.surface),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                AppClass.confirmYesOrNo = true;
                state(() {});
              },
            ),
            TextButton(
              child: Text(negativeButtonText),
              onPressed: () {
                AppClass.confirmYesOrNo = false;
                Navigator.of(context).pop();
                state(() {});
              },
            ),
          ],
        );
      });
}

void alertBox(String title, String message, bool goodORbad) {
  final theme = _snackTheme();
  final cts = theme.extension<CtsColors>() ?? CtsColors.light();
  final scheme = theme.colorScheme;
  final onBanner = scheme.onError;
  final SnackBar snackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: onBanner)),
        goodORbad
            ? Icon(Icons.done_outline, color: onBanner)
            : Icon(Icons.error_outline, color: onBanner),
      ],
    ),
    backgroundColor: goodORbad ? cts.success : scheme.error,
  );
  SnackBarService.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}

void dialogBoxWidget(Widget widget, bool canDismiss) {
  final BuildContext? context = SnackBarService.scaffoldMessengerKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: canDismiss,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }
}

class Utils {
  static void fieldFocusChange(
      BuildContext context, FocusNode currentNode, FocusNode nextNode) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextNode);
  }
  //
  // static void utilsToastMessage(String message) {
  //   Fluttertoast.showToast(
  //     msg: message,
  //     backgroundColor: /* scheme.error */,
  //     textColor: /* scheme.onSurface */,
  //     fontSize: 21,
  //     timeInSecForIosWeb: 2,
  //   );
  // }
  //
  // static void utilsToastMessageTrue(String message) {
  //   Fluttertoast.showToast(
  //     msg: message,
  //     gravity: ToastGravity.TOP,
  //
  //     backgroundColor: /* cts.success */,
  //     textColor: /* scheme.onSurface */,
  //     fontSize: 21,
  //     timeInSecForIosWeb: 2,
  //   );
  // }

  static void utilsSnackBarTopFloat(
      String title, String message, Color color, Icon icon) {
    final scheme = _snackTheme().colorScheme;
    final SnackBar snackBar = SnackBar(
      content: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
              Text(
                message,
                style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    );
    SnackBarService.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  static void utilsSnackBarBottomStick(String title, String message, Color color) {
    final SnackBar snackBar = SnackBar(
      content: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
    SnackBarService.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  static double deviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static void deviceWidth(BuildContext context) {
    MediaQuery.of(context).size.width;
  }
}

