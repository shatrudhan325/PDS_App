// import 'package:flutter/material.dart';

// class CreateTicketPage extends StatefulWidget {
//   const CreateTicketPage({super.key});

//   @override
//   State<CreateTicketPage> createState() => _CreateTicketPageState();
// }

// class _CreateTicketPageState extends State<CreateTicketPage> {
//   // GlobalKey to identify the form and validate it
//   final _formKey = GlobalKey<FormState>();

//   // Dropdown options
//   final List<String> complaintTypes = [
//     'EWS/EPOS Related',
//     'H/W Related',
//     'S/W Related',
//     'Query',
//   ];
//   final List<String> categories = [
//     'On/Off Issue',
//     'Charging',
//     'Antenna',
//     'Battery',
//     'Others',
//   ];
//   final List<String> subCategories = ['Sub-Category 1', 'Sub-Category 2'];
//   final List<String> assignees = ['Assignee 1', 'Assignee 2'];
//   final List<String> actions = ['Action 1', 'Action 2'];

//   // Selected values
//   String? selectedComplaintType;
//   String? selectedCategory;
//   String? selectedSubCategory;
//   String? selectedAssignee;
//   String? selectedAction;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Create Ticket'),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//         // Wrap the form content with a Form widget and provide the key
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // --- Location Details Section ---
//               buildSection(
//                 title: 'Location Details',
//                 icon: Icons.location_on,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(child: buildTextField('District')),
//                       const SizedBox(width: 12),
//                       Expanded(child: buildTextField('Block')),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // --- Complaint Information Section ---
//               buildSection(
//                 title: 'Complaint Information',
//                 icon: Icons.error_outline,
//                 children: [
//                   buildDropdown(
//                     'Type of Complaint',
//                     complaintTypes,
//                     selectedComplaintType,
//                     (value) {
//                       setState(() {
//                         selectedComplaintType = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   buildDropdown('Category', categories, selectedCategory, (
//                     value,
//                   ) {
//                     setState(() {
//                       selectedCategory = value;
//                     });
//                   }),
//                   const SizedBox(height: 16),
//                   buildDropdown(
//                     'Sub-Category',
//                     subCategories,
//                     selectedSubCategory,
//                     (value) {
//                       setState(() {
//                         selectedSubCategory = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // --- Contact Information Section ---
//               buildSection(
//                 title: 'Contact Information',
//                 icon: Icons.person_outline,
//                 children: [
//                   const SizedBox(height: 16),
//                   buildTextField('Complainant Name'),
//                   const SizedBox(height: 16),
//                   buildTextField('Caller Number', isNumeric: true),
//                   const SizedBox(height: 16),
//                   buildTextField('FPS ID'),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // --- Assignment & Tracking Section ---
//               buildSection(
//                 title: 'Assignment & Tracking',
//                 icon: Icons.assignment_ind_outlined,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: buildDropdown(
//                           'Assigned To',
//                           assignees,
//                           selectedAssignee,
//                           (value) {
//                             setState(() {
//                               selectedAssignee = value;
//                             });
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: buildDropdown(
//                           'Action Taken',
//                           actions,
//                           selectedAction,
//                           (value) {
//                             setState(() {
//                               selectedAction = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(child: buildInfoField('Updated Date', '-')),
//                       const SizedBox(width: 12),
//                       Expanded(child: buildInfoField('Updated Time', '-')),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: buildInfoField('Ticket Age', '15 minutes'),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: buildInfoField(
//                           'SLA Status',
//                           'On Time',
//                           isSLA: true,
//                           statusColor: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton.icon(
//           onPressed: () {
//             // Trigger validation on all form fields
//             if (_formKey.currentState!.validate()) {
//               // The form is valid, proceed with submission logic
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Processing Data...')),
//               );
//               // Here you would add your code to submit the form data
//             } else {
//               // The form is invalid, validation errors will be shown
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Please fill out all required fields.'),
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color.fromARGB(255, 29, 53, 87),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           icon: const Icon(Icons.send, color: Colors.white),
//           label: Text(
//             'Submit Ticket',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Helper Widgets with added validation properties ---

//   Widget buildSection({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: const Color(0xFF1D3557)),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1D3557),
//                 ),
//               ),
//             ],
//           ),
//           const Divider(color: Colors.grey),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget buildTextField(String label, {bool isNumeric = false}) {
//     return TextFormField(
//       keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Color(0xFF457B9D)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFF457B9D)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFF1D3557)),
//         ),
//       ),
//       // Validator to check if the text field is empty
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter a value for $label';
//         }
//         return null; // Return null if the input is valid
//       },
//     );
//   }

//   Widget buildDropdown(
//     String label,
//     List<String> items,
//     String? selectedValue,
//     ValueChanged<String?> onChanged,
//   ) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Color(0xFF457B9D), fontSize: 14),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFF457B9D)),
//         ),
//       ),
//       initialValue: selectedValue,
//       items: items.map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(value: value, child: Text(value));
//       }).toList(),
//       onChanged: onChanged,
//       // Validator to check if a dropdown option is selected
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a $label';
//         }
//         return null; // Return null if a value is selected
//       },
//     );
//   }

//   Widget buildInfoField(
//     String label,
//     String value, {
//     bool isSLA = false,
//     Color statusColor = Colors.transparent,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF457B9D),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               if (isSLA)
//                 Padding(
//                   padding: const EdgeInsets.only(right: 4.0),
//                   child: Icon(Icons.circle, size: 12, color: statusColor),
//                 ),
//               Text(value, style: const TextStyle(fontSize: 16)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

//fully responsive Ticket Page with validation
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller using Getx for state and responsiveness helpers
class TicketController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final districtController = TextEditingController();
  final blockController = TextEditingController();
  final complainantController = TextEditingController();
  final callerNumberController = TextEditingController();
  final fpsIdController = TextEditingController();

  // Dropdown options (could be fetched remotely)
  final complaintTypes = <String>[
    'EWS/EPOS Related',
    'H/W Related',
    'S/W Related',
    'Query',
  ];
  final categories = <String>[
    'On/Off Issue',
    'Charging',
    'Antenna',
    'Battery',
    'Others',
  ];
  final subCategories = <String>['Sub-Category 1', 'Sub-Category 2'];
  final assignees = <String>['Assignee 1', 'Assignee 2'];
  final actions = <String>['Action 1', 'Action 2'];

  // Selected values
  final selectedComplaintType = RxnString();
  final selectedCategory = RxnString();
  final selectedSubCategory = RxnString();
  final selectedAssignee = RxnString();
  final selectedAction = RxnString();

  // Info fields (in a real app these would be dynamic)
  final updatedDate = ' - '.obs;
  final updatedTime = ' - '.obs;
  final ticketAge = '15 minutes'.obs;
  final slaStatus = 'On Time'.obs;
  final slaColor = Colors.green.obs;

  void submit() {
    if (formKey.currentState?.validate() ?? false) {
      // perform submission logic, API call etc.
      Get.snackbar(
        'Success',
        'Ticket submitted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    districtController.dispose();
    blockController.dispose();
    complainantController.dispose();
    callerNumberController.dispose();
    fpsIdController.dispose();
    super.onClose();
  }
}

// Responsive helper
class R {
  final BuildContext context;
  R(this.context);

  double wp(double percent) =>
      MediaQuery.of(context).size.width * percent / 100; // width percentage
  double hp(double percent) =>
      MediaQuery.of(context).size.height * percent / 100; // height percentage
  bool get isTablet => MediaQuery.of(context).size.width >= 600;
}

class CreateTicketPage extends StatelessWidget {
  CreateTicketPage({Key? key}) : super(key: key);

  final TicketController c = Get.put(TicketController());

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Create Ticket'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth >= 800; // switch to multi-column when wide
          final horizontalPadding = isWide ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16.0,
            ),
            child: Form(
              key: c.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildSection(
                    context,
                    title: 'Location Details',
                    icon: Icons.location_on,
                    children: [
                      isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: buildTextField(
                                    c.districtController,
                                    'District',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: buildTextField(
                                    c.blockController,
                                    'Block',
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                buildTextField(
                                  c.districtController,
                                  'District',
                                ),
                                const SizedBox(height: 12),
                                buildTextField(c.blockController, 'Block'),
                              ],
                            ),
                    ],
                  ),
                  SizedBox(height: r.hp(2)),

                  buildSection(
                    context,
                    title: 'Complaint Information',
                    icon: Icons.error_outline,
                    children: [
                      buildDropdown(
                        label: 'Type of Complaint',
                        items: c.complaintTypes,
                        selectedValue: c.selectedComplaintType,
                        validatorText: 'Please select a Type of Complaint',
                      ),
                      SizedBox(height: r.hp(2)),
                      buildDropdown(
                        label: 'Category',
                        items: c.categories,
                        selectedValue: c.selectedCategory,
                        validatorText: 'Please select a Category',
                      ),
                      SizedBox(height: r.hp(2)),
                      buildDropdown(
                        label: 'Sub-Category',
                        items: c.subCategories,
                        selectedValue: c.selectedSubCategory,
                        validatorText: 'Please select a Sub-Category',
                      ),
                      SizedBox(height: r.hp(2)),
                    ],
                  ),
                  SizedBox(height: r.hp(2)),

                  buildSection(
                    context,
                    title: 'Contact Information',
                    icon: Icons.person_outline,
                    children: [
                      SizedBox(height: r.hp(1)),
                      buildTextField(
                        c.complainantController,
                        'Complainant Name',
                      ),
                      SizedBox(height: r.hp(2)),
                      buildTextField(
                        c.callerNumberController,
                        'Caller Number',
                        isNumeric: true,
                      ),
                      SizedBox(height: r.hp(2)),
                      buildTextField(c.fpsIdController, 'FPS ID'),
                    ],
                  ),
                  SizedBox(height: r.hp(2)),

                  buildSection(
                    context,
                    title: 'Assignment & Tracking',
                    icon: Icons.assignment_ind_outlined,
                    children: [
                      isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: buildDropdown(
                                    label: 'Assigned To',
                                    items: c.assignees,
                                    selectedValue: c.selectedAssignee,
                                    validatorText: 'Please select an Assignee',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: buildDropdown(
                                    label: 'Action Taken',
                                    items: c.actions,
                                    selectedValue: c.selectedAction,
                                    validatorText: 'Please select an Action',
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                buildDropdown(
                                  label: 'Assigned To',
                                  items: c.assignees,
                                  selectedValue: c.selectedAssignee,
                                  validatorText: 'Please select an Assignee',
                                ),
                                SizedBox(height: r.hp(2)),
                                buildDropdown(
                                  label: 'Action Taken',
                                  items: c.actions,
                                  selectedValue: c.selectedAction,
                                  validatorText: 'Please select an Action',
                                ),
                              ],
                            ),
                      SizedBox(height: r.hp(2)),
                      isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: buildInfoField(
                                    'Updated Date',
                                    c.updatedDate.value,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: buildInfoField(
                                    'Updated Time',
                                    c.updatedTime.value,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                buildInfoField(
                                  'Updated Date',
                                  c.updatedDate.value,
                                ),
                                SizedBox(height: r.hp(1)),
                                buildInfoField(
                                  'Updated Time',
                                  c.updatedTime.value,
                                ),
                              ],
                            ),
                      SizedBox(height: r.hp(2)),
                      isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: buildInfoField(
                                    'Ticket Age',
                                    c.ticketAge.value,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(
                                    () => buildInfoField(
                                      'SLA Status',
                                      c.slaStatus.value,
                                      isSLA: true,
                                      statusColor: c.slaColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                buildInfoField('Ticket Age', c.ticketAge.value),
                                SizedBox(height: r.hp(1)),
                                Obx(
                                  () => buildInfoField(
                                    'SLA Status',
                                    c.slaStatus.value,
                                    isSLA: true,
                                    statusColor: c.slaColor.value,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                  SizedBox(height: r.hp(3)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? r.wp(20) : 0,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: c.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 29, 53, 87),
                        padding: EdgeInsets.symmetric(vertical: r.hp(2.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        'Submit Ticket',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: r.hp(2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1D3557)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          ...children,
        ],
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF457B9D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF457B9D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1D3557)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty)
          return 'Please enter a value for $label';
        return null;
      },
    );
  }

  Widget buildDropdown({
    required String label,
    required List<String> items,
    required RxnString selectedValue,
    required String validatorText,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF457B9D), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF457B9D)),
          ),
        ),
        value: selectedValue.value,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (value) => selectedValue.value = value,
        validator: (value) {
          if (value == null || value.isEmpty) return validatorText;
          return null;
        },
      ),
    );
  }

  Widget buildInfoField(
    String label,
    String value, {
    bool isSLA = false,
    Color statusColor = Colors.transparent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF457B9D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isSLA)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.circle, size: 12, color: statusColor),
                ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
