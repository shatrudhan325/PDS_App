// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pds_app/Widgets/dashbordview/dashboardview.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(237, 238, 238, 1),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Welcome Back',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF003060),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Sign in to Access your tickets',
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//               const SizedBox(height: 23),
//               Container(
//                 padding: const EdgeInsets.all(24.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       spreadRadius: 1,
//                       blurRadius: 10,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(
//                           Icons.person_outline,
//                           color: Colors.black54,
//                         ),
//                         hintText: 'Username',
//                         hintStyle: const TextStyle(color: Colors.black54),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(
//                           Icons.lock_outline,
//                           color: Colors.black54,
//                         ),
//                         hintText: 'Password',
//                         hintStyle: const TextStyle(color: Colors.black54),
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {},
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(
//                             color: Color(0xFF003060),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Get.to(() => DashboardScreen());
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF003060),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Sign In',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // // // // Yaha Se Hai Updated Code
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:pds_app/core/routeconfig/auth_Controler.dart';
// import 'package:pds_app/core/routeconfig/route.dart';
import '../services/auth.dart';
import 'package:pds_app/Widgets/dashbordview/dashboardview.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Local synchronous validation before calling AuthService
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form == null) return false;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> handleLogin() async {
    // run local validation first
    if (!_validateAndSave()) {
      // show a snack if you want an extra hint (optional)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the errors and try again.')),
        );
      }
      return;
    }

    setState(() => loading = true);

    final result = await AuthService.login(
      usernameController.text.trim(),
      passwordController.text,
    );
    //change for routes
    // if (result != null && result["accessToken"] != null) {
    //   final token = result["accessToken"];
    //   final role = extractRole(token);

    //   final auth = Get.find<AuthController>();
    //   auth.setRole(role);

    //   final route = routeForRole[role] ?? Routes.LOGIN;
    //   Get.offNamed(route);
    // }
    //
    setState(() => loading = false);

    if (result != null && !result.containsKey('error')) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Successful')));
        Get.off(() => const DashboardScreen());
      }
    } else {
      String errorMessage = result?['error'] ?? 'Login failed. Unknown error.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  String? _usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 6 characters';
    }
    // optionally add other checks (digits, symbols) if needed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003060),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to Access your tickets',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 23),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: usernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: _usernameValidator,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText: 'Username',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: _passwordValidator,
                        onFieldSubmitted: (_) {
                          // Optionally submit when user presses done
                          if (!loading) handleLogin();
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003060),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
