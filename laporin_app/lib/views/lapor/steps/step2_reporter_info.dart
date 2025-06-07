import 'package:flutter/material.dart';
import '../../../models/report.dart';

class Step2ReporterInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Report reportData;
  final Function(Report) onDataChanged;

  const Step2ReporterInfo({
    super.key,
    required this.formKey,
    required this.reportData,
    required this.onDataChanged,
  });

  @override
  State<Step2ReporterInfo> createState() => _Step2ReporterInfoState();
}

class _Step2ReporterInfoState extends State<Step2ReporterInfo> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Add these for real-time validation
  bool _nameHasError = false;
  bool _phoneHasError = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.reportData.reporterName;
    _phoneController.text = widget.reportData.reporterContact;
  }

  void _updateData() {
    final updatedReport = widget.reportData.copyWith(
      reporterName: _nameController.text,
      reporterContact: _phoneController.text,
    );
    widget.onDataChanged(updatedReport);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporter Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Provide your contact information.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
      
              _buildTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
      
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue.shade700, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(12),
          ),
          keyboardType: keyboardType,
          validator: (value) {
            final error = validator?.call(value);
            // Update error state based on validation result
            if (controller == _nameController) {
              _nameHasError = error != null;
            } else if (controller == _phoneController) {
              _phoneHasError = error != null;
            }
            return error;
          },
          onChanged: (value) {
            // Clear error and revalidate if field becomes valid
            if (value.isNotEmpty) {
              bool shouldRevalidate = false;
              if (controller == _nameController && _nameHasError) {
                setState(() {
                  _nameHasError = false;
                });
                shouldRevalidate = true;
              } else if (controller == _phoneController && _phoneHasError) {
                setState(() {
                  _phoneHasError = false;
                });
                shouldRevalidate = true;
              }

              if (shouldRevalidate) {
                widget.formKey.currentState?.validate();
              }
            }
            _updateData();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
