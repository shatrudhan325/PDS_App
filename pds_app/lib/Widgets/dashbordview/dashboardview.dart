// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/Widgets/Location_Get&Finde_Mock/locationservice.dart';
// import 'package:pds_app/Widgets/dashbordview/drawer.dart';
// import 'package:pds_app/features/user%20profile/profile_c.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       // ✅ Drawer attached here
//       drawer: MyDrawer(),

//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border(
//               bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // ✅ Proper menu button with Builder
//                   Builder(
//                     builder: (context) => GestureDetector(
//                       onTap: () {
//                         Scaffold.of(
//                           context,
//                         ).openDrawer(); // opens overlay drawer
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.menu,
//                           size: 24,
//                           color: Color(0xFF030213),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Text(
//                     'Dashboard',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF030213),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Get.to(() => const ProfileScreen());
//                     },
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF030213),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(
//                         Icons.person,
//                         size: 20,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Greeting Section
//             Container(
//               padding: const EdgeInsets.only(top: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'Hello, Block Engineer',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF030213),
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Welcome back to your dashboard',
//                     style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Stats Cards Row
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Get.to(() => const PastRecordsScreen());
//                     },
//                     child: _buildStatsCard(
//                       title: 'TOTAL ATTENDANCE',
//                       value: "0",
//                       icon: Icons.trending_up,
//                       iconColor: const Color(0xFF16A34A),
//                       iconBgColor: const Color.fromARGB(255, 226, 231, 228),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatsCard(
//                     title: 'LEAVE TAKEN',
//                     value: '0',
//                     icon: Icons.circle,
//                     iconColor: const Color(0xFF2563EB),
//                     iconBgColor: const Color(0xFFDEEEFF),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Action Cards Row
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildActionCard(
//                     title: 'ALL TICKETS',
//                     subtitle: 'View All',
//                     iconColor: const Color(0xFFEA580C),
//                     iconBgColor: const Color(0xFFFED7AA),
//                     onTap: () {
//                       // Handle all tickets tap
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildActionCard(
//                     title: 'TODAY\'S TICKETS',
//                     subtitle: 'View Today',
//                     iconColor: const Color(0xFF9333EA),
//                     iconBgColor: const Color(0xFFE9D5FF),
//                     onTap: () {
//                       // Handle today's tickets tap
//                     },
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Location Section
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Location',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF030213),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         // Handle view details tap
//                       },
//                       child: const Text(
//                         'View Details',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF030213),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   height: 280,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color.fromARGB(
//                           255,
//                           212,
//                           210,
//                           210,
//                         ).withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: LiveLocationWidget(),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🔹 Stats Card
//   static Widget _buildStatsCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBgColor,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Colors.white, const Color(0xFFE9EBEF).withOpacity(0.3)],
//         ),
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF717182),
//                 letterSpacing: 0.5,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF030213),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: iconBgColor,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Icon(icon, size: 16, color: iconColor),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🔹 Action Card
//   static Widget _buildActionCard({
//     required String title,
//     required String subtitle,
//     required Color iconColor,
//     required Color iconBgColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.white, const Color(0xFFE9EBEF).withOpacity(0.3)],
//           ),
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF717182),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF030213),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: iconBgColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         color: iconColor,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
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

//Fully resposive
// Responsive Dashboard using GetX
// This version keeps your exact UI style but makes it responsive
// Breakpoints and scaling applied

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/Widgets/Location_Get&Finde_Mock/map_view.dart';
import 'package:pds_app/Widgets/dashbordview/drawer.dart';
import 'package:pds_app/features/user profile/profile_c.dart';
//import 'package:pds_app/Widgets/Location_Get&Finde_Mock/locationservice.dart';

class DashboardController extends GetxController {
  // device width reactive
  RxDouble deviceWidth = 0.0.obs;
  RxDouble deviceHeight = 0.0.obs;

  void updateSize(BoxConstraints constraints) {
    deviceWidth.value = constraints.maxWidth;
    deviceHeight.value = constraints.maxHeight;
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return LayoutBuilder(
      builder: (context, constraints) {
        controller.updateSize(constraints);

        return Obx(
          () => Scaffold(
            backgroundColor: Colors.white,
            drawer: MyDrawer(),

            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60 * _scale(controller)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * _scale(controller),
                      vertical: 8 * _scale(controller),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Container(
                              padding: EdgeInsets.all(8 * _scale(controller)),
                              child: Icon(
                                Icons.menu,
                                size: 30 * _scale(controller),
                                color: const Color(0xFF030213),
                              ),
                            ),
                          ),
                        ),

                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 22 * _scale(controller),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF030213),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => Get.to(() => const ProfileScreen()),
                          child: Container(
                            width: 40 * _scale(controller),
                            height: 40 * _scale(controller),
                            decoration: BoxDecoration(
                              color: const Color(0xFF030213),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 20 * _scale(controller),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            body: SingleChildScrollView(
              padding: EdgeInsets.all(16 * _scale(controller)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8 * _scale(controller)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Block Engineer',
                          style: TextStyle(
                            fontSize: 28 * _scale(controller),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF030213),
                          ),
                        ),
                        SizedBox(height: 4 * _scale(controller)),
                        Text(
                          'Welcome back to your dashboard',
                          style: TextStyle(
                            fontSize: 16 * _scale(controller),
                            color: const Color(0xFF717182),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24 * _scale(controller)),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.to(() => const PastRecordsScreen()),
                          child: _buildStatsCard(
                            controller,
                            title: 'TOTAL ATTENDANCE',
                            value: "0",
                            icon: Icons.trending_up,
                            iconColor: const Color(0xFF16A34A),
                            iconBgColor: const Color.fromARGB(
                              255,
                              226,
                              231,
                              228,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * _scale(controller)),
                      Expanded(
                        child: _buildStatsCard(
                          controller,
                          title: 'LEAVE TAKEN',
                          value: '0',
                          icon: Icons.circle,
                          iconColor: const Color(0xFF2563EB),
                          iconBgColor: const Color(0xFFDEEEFF),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12 * _scale(controller)),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          controller,
                          title: 'ALL TICKETS',
                          subtitle: 'View All',
                          iconColor: const Color(0xFFEA580C),
                          iconBgColor: const Color(0xFFFED7AA),
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 12 * _scale(controller)),
                      Expanded(
                        child: _buildActionCard(
                          controller,
                          title: 'TODAYS TICKETS',
                          subtitle: 'View Today',
                          iconColor: const Color(0xFF9333EA),
                          iconBgColor: const Color(0xFFE9D5FF),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24 * _scale(controller)),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 22 * _scale(controller),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF030213),
                    ),
                  ),
                  SizedBox(height: 16 * _scale(controller)),

                  Container(
                    height: 380 * _scale(controller),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MapView(), //LiveLocationWidget(),
                  ),

                  SizedBox(height: 32 * _scale(controller)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _scale(DashboardController c) {
    double baseWidth = 430; // reference width
    return (c.deviceWidth.value / baseWidth).clamp(0.8, 1.2);
  }

  static Widget _buildStatsCard(
    DashboardController c, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    double s = (c.deviceWidth.value / 430).clamp(0.7, 1.3);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFE9EBEF).withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF717182),
              ),
            ),
            SizedBox(height: 12 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF030213),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6 * s),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 16 * s, color: iconColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionCard(
    DashboardController c, {
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    double s = (c.deviceWidth.value / 430).clamp(0.7, 1.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFE9EBEF).withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF717182),
                ),
              ),
              SizedBox(height: 12 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF030213),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6 * s),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: 16 * s,
                      height: 16 * s,
                      decoration: BoxDecoration(color: iconColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
