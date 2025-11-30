import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pds_app/core/routeconfig/auth_Controler.dart';
import 'package:pds_app/features/authentication/services/permission.dart';
//import 'package:pds_app/features/authentication/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = Get.put(AuthController());
  await auth.loadRole();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDS App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: PermissionPage(),
    );
  }
}

//yaha se
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.white, title: Text('Login')),
//       body: (const Center(child: Text('Hello World'))),

//       // This trailing comma makes
//     );
//   }
// }
