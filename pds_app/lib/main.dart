import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:pds_app/features/authentication/screens/login.dart';
import 'package:pds_app/features/authentication/services/permission.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDS App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PermissionPage(),
    );
  }
}

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
