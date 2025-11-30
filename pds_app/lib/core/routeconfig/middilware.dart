import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:pds_app/core/routeconfig/auth_Controler.dart';
import 'package:pds_app/core/routeconfig/route.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> allowRoles;
  RoleMiddleware(this.allowRoles);

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();

    if (!auth.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    if (!allowRoles.contains(auth.role.value)) {
      return const RouteSettings(name: Routes.FORBIDDEN);
    }

    return null;
  }
}
