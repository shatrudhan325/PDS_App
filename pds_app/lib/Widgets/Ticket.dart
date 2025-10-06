import 'package:flutter/material.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  // GlobalKey to identify the form and validate it
  final _formKey = GlobalKey<FormState>();

  // Dropdown options
  final List<String> complaintTypes = [
    'EWS/EPOS Related',
    'H/W Related',
    'S/W Related',
    'Query',
  ];
  final List<String> categories = [
    'On/Off Issue',
    'Charging',
    'Antenna',
    'Battery',
    'Others',
  ];
  final List<String> subCategories = ['Sub-Category 1', 'Sub-Category 2'];
  final List<String> assignees = ['Assignee 1', 'Assignee 2'];
  final List<String> actions = ['Action 1', 'Action 2'];

  // Selected values
  String? selectedComplaintType;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedAssignee;
  String? selectedAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Create Ticket'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        // Wrap the form content with a Form widget and provide the key
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Location Details Section ---
              buildSection(
                title: 'Location Details',
                icon: Icons.location_on,
                children: [
                  Row(
                    children: [
                      Expanded(child: buildTextField('District')),
                      const SizedBox(width: 12),
                      Expanded(child: buildTextField('Block')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Complaint Information Section ---
              buildSection(
                title: 'Complaint Information',
                icon: Icons.error_outline,
                children: [
                  buildDropdown(
                    'Type of Complaint',
                    complaintTypes,
                    selectedComplaintType,
                    (value) {
                      setState(() {
                        selectedComplaintType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  buildDropdown('Category', categories, selectedCategory, (
                    value,
                  ) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  buildDropdown(
                    'Sub-Category',
                    subCategories,
                    selectedSubCategory,
                    (value) {
                      setState(() {
                        selectedSubCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              const SizedBox(height: 16),

              // --- Contact Information Section ---
              buildSection(
                title: 'Contact Information',
                icon: Icons.person_outline,
                children: [
                  const SizedBox(height: 16),
                  buildTextField('Complainant Name'),
                  const SizedBox(height: 16),
                  buildTextField('Caller Number', isNumeric: true),
                  const SizedBox(height: 16),
                  buildTextField('FPS ID'),
                ],
              ),
              const SizedBox(height: 16),

              // --- Assignment & Tracking Section ---
              buildSection(
                title: 'Assignment & Tracking',
                icon: Icons.assignment_ind_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildDropdown(
                          'Assigned To',
                          assignees,
                          selectedAssignee,
                          (value) {
                            setState(() {
                              selectedAssignee = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildDropdown(
                          'Action Taken',
                          actions,
                          selectedAction,
                          (value) {
                            setState(() {
                              selectedAction = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: buildInfoField('Updated Date', '-')),
                      const SizedBox(width: 12),
                      Expanded(child: buildInfoField('Updated Time', '-')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildInfoField('Ticket Age', '15 minutes'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildInfoField(
                          'SLA Status',
                          'On Time',
                          isSLA: true,
                          statusColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Trigger validation on all form fields
            if (_formKey.currentState!.validate()) {
              // The form is valid, proceed with submission logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data...')),
              );
              // Here you would add your code to submit the form data
            } else {
              // The form is invalid, validation errors will be shown
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill out all required fields.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 29, 53, 87),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.send, color: Colors.white),
          label: Text(
            'Submit Ticket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets with added validation properties ---

  Widget buildSection({
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

  Widget buildTextField(String label, {bool isNumeric = false}) {
    return TextFormField(
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
      // Validator to check if the text field is empty
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value for $label';
        }
        return null; // Return null if the input is valid
      },
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF457B9D), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF457B9D)),
        ),
      ),
      initialValue: selectedValue,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
      // Validator to check if a dropdown option is selected
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null; // Return null if a value is selected
      },
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
