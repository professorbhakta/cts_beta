import 'package:cts/features/batches/providers/batch_controller.dart';
import 'package:cts/features/cabs/providers/cab_controller.dart';
import 'package:cts/features/commuters/providers/commuter_controller.dart';
import 'package:cts/features/drivers/providers/driver_controller.dart';
import 'package:cts/features/pops/providers/pop_controller.dart';
import 'package:cts/features/routes/providers/route_controller.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Utility class to reset all controller states on logout
class ControllerResetUtil {
  /// Resets all data controllers to their initial state
  /// Call this after successful logout to clear user data
  static void resetAllControllers(BuildContext context) {
    try {
      // Reset data controllers
      context.read<BatchProvider>().reset();
      context.read<CabProvider>().reset();
      context.read<CommuterController>().reset();
      context.read<DriverProvider>().reset();
      context.read<RouteController>().reset();
      context.read<PopProvider>().reset();
      
      // Reset sign in provider state
      final signInProvider = context.read<SignInProvider>();
      signInProvider.mobileCtrl.clear();
      signInProvider.passwordCtrl.clear();
      
      // Note: Form providers (BatchFormProvider, CabFormProvider, etc.)
      // are automatically reset when new instances are created or when clearAll() is called
    } catch (e) {
      // Silently handle errors - controllers might not be available in all contexts
      debugPrint('ControllerResetUtil: Error resetting controllers: $e');
    }
  }
}








