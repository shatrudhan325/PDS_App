// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/features/Location_Get&Finde_Mock/map_view.dart';
// import 'package:pds_app/Widgets/dashbordview/drawer.dart';
// import 'package:pds_app/Widgets/user%20profile/profile_c.dart';
// import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_db.dart';
// import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_history_record.dart';

// // import 'package:pds_app/features/authentication/services/token_Decoder.dart';
// //import 'package:pds_app/Widgets/Location_Get&Finde_Mock/locationservice.dart';

// class DashboardController extends GetxController {
//   // device width reactive
//   RxDouble deviceWidth = 0.0.obs;
//   RxDouble deviceHeight = 0.0.obs;
//   RxInt totalAttendance = 0.obs;

//   void updateSize(BoxConstraints constraints) {
//     deviceWidth.value = constraints.maxWidth;
//     deviceHeight.value = constraints.maxHeight;
//   }

//   Future<void> loadAttendanceStats() async {
//     final records = await AttendanceDb.instance.getAllRecords();

//     // only completed days:
//     final completed = records
//         .where((r) => r.status == RecordStatus.complete)
//         .length;

//     // if you want all records (complete + incomplete), use records.length instead
//     totalAttendance.value = completed;
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     loadAttendanceStats();
//   }
// }

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(DashboardController());

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         controller.updateSize(constraints);

//         return Obx(
//           () => Scaffold(
//             backgroundColor: Colors.white,
//             drawer: MyDrawer(),
//             drawerEnableOpenDragGesture: true,
//             drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.5,

//             appBar: PreferredSize(
//               preferredSize: Size.fromHeight(60 * _scale(controller)),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border(
//                     bottom: BorderSide(
//                       color: Colors.grey.withOpacity(0.1),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16 * _scale(controller),
//                       vertical: 8 * _scale(controller),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Builder(
//                           builder: (context) => GestureDetector(
//                             onTap: () => Scaffold.of(context).openDrawer(),
//                             child: Container(
//                               padding: EdgeInsets.all(8 * _scale(controller)),
//                               child: Icon(
//                                 Icons.menu,
//                                 size: 30 * _scale(controller),
//                                 color: const Color(0xFF030213),
//                               ),
//                             ),
//                           ),
//                         ),

//                         Text(
//                           'Dashboard',
//                           style: TextStyle(
//                             fontSize: 22 * _scale(controller),
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xFF030213),
//                           ),
//                         ),

//                         GestureDetector(
//                           onTap: () => Get.to(() => const ProfileScreen()),
//                           child: Container(
//                             width: 40 * _scale(controller),
//                             height: 40 * _scale(controller),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF030213),
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             child: Icon(
//                               Icons.person,
//                               size: 20 * _scale(controller),
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             body: SingleChildScrollView(
//               padding: EdgeInsets.all(16 * _scale(controller)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(top: 8 * _scale(controller)),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello Engineer',
//                           style: TextStyle(
//                             fontSize: 28 * _scale(controller),
//                             fontWeight: FontWeight.w500,
//                             color: const Color(0xFF030213),
//                           ),
//                         ),
//                         SizedBox(height: 4 * _scale(controller)),
//                         Text(
//                           'Welcome back to your dashboard',
//                           style: TextStyle(
//                             fontSize: 16 * _scale(controller),
//                             color: const Color(0xFF717182),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 24 * _scale(controller)),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => Get.to(() => const PastRecordsScreen()),
//                           child: _buildStatsCard(
//                             controller,
//                             title: 'TOTAL ATTENDANCE',
//                             value: controller.totalAttendance.value.toString(),
//                             icon: Icons.trending_up,
//                             iconColor: const Color(0xFF16A34A),
//                             iconBgColor: const Color.fromARGB(
//                               255,
//                               226,
//                               231,
//                               228,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12 * _scale(controller)),
//                       Expanded(
//                         child: _buildStatsCard(
//                           controller,
//                           title: 'LEAVE TAKEN',
//                           value: '0',
//                           icon: Icons.circle,
//                           iconColor: const Color(0xFF2563EB),
//                           iconBgColor: const Color(0xFFDEEEFF),
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 12 * _scale(controller)),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildActionCard(
//                           controller,
//                           title: 'ALL TICKETS',
//                           subtitle: 'View All',
//                           iconColor: const Color(0xFFEA580C),
//                           iconBgColor: const Color(0xFFFED7AA),
//                           onTap: () {},
//                         ),
//                       ),
//                       SizedBox(width: 12 * _scale(controller)),
//                       Expanded(
//                         child: _buildActionCard(
//                           controller,
//                           title: 'TODAYS TICKETS',
//                           subtitle: 'View Today',
//                           iconColor: const Color(0xFF9333EA),
//                           iconBgColor: const Color(0xFFE9D5FF),
//                           onTap: () {},
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 24 * _scale(controller)),
//                   Text(
//                     'Location',
//                     style: TextStyle(
//                       fontSize: 22 * _scale(controller),
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF030213),
//                     ),
//                   ),
//                   SizedBox(height: 16 * _scale(controller)),

//                   Container(
//                     height: 380 * _scale(controller),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: MapView(), //LiveLocationWidget(),
//                   ),

//                   SizedBox(height: 32 * _scale(controller)),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   double _scale(DashboardController c) {
//     double baseWidth = 430; // reference width
//     return (c.deviceWidth.value / baseWidth).clamp(0.8, 1.2);
//   }

//   static Widget _buildStatsCard(
//     DashboardController c, {
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBgColor,
//   }) {
//     double s = (c.deviceWidth.value / 430).clamp(0.7, 1.3);

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, const Color(0xFFE9EBEF).withOpacity(0.3)],
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16 * s),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 10 * s,
//                 fontWeight: FontWeight.w500,
//                 color: const Color(0xFF717182),
//               ),
//             ),
//             SizedBox(height: 12 * s),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 24 * s,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xFF030213),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(6 * s),
//                   decoration: BoxDecoration(
//                     color: iconBgColor,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Icon(icon, size: 16 * s, color: iconColor),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _buildActionCard(
//     DashboardController c, {
//     required String title,
//     required String subtitle,
//     required Color iconColor,
//     required Color iconBgColor,
//     required VoidCallback onTap,
//   }) {
//     double s = (c.deviceWidth.value / 430).clamp(0.7, 1.3);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.white, const Color(0xFFE9EBEF).withOpacity(0.3)],
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16 * s),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 10 * s,
//                   fontWeight: FontWeight.w500,
//                   color: const Color(0xFF717182),
//                 ),
//               ),
//               SizedBox(height: 12 * s),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 16 * s,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF030213),
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.all(6 * s),
//                     decoration: BoxDecoration(
//                       color: iconBgColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Container(
//                       width: 16 * s,
//                       height: 16 * s,
//                       decoration: BoxDecoration(color: iconColor),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
