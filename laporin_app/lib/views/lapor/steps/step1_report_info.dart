import 'package:flutter/material.dart';
import '../../../models/report.dart';
import '../../../models/report_category.dart';
import '../../../models/government_agency.dart';
import '../../../services/category_service.dart';
import '../../../services/agency_service.dart';
import 'widgets/location_picker.dart';

class Step1ReportInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Report reportData;
  final List<ReportCategory> categories;
  final List<GovernmentAgency> agencies;
  final Function(Report) onDataChanged;
  final Function(List<ReportCategory>) onCategoriesLoaded;
  final Function(List<GovernmentAgency>) onAgenciesLoaded;

  const Step1ReportInfo({
    super.key,
    required this.formKey,
    required this.reportData,
    required this.categories,
    required this.agencies,
    required this.onDataChanged,
    required this.onCategoriesLoaded,
    required this.onAgenciesLoaded,
  });

  @override
  State<Step1ReportInfo> createState() => _Step1ReportInfoState();
}

class _Step1ReportInfoState extends State<Step1ReportInfo> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  ReportCategory? _selectedCategory;
  GovernmentAgency? _selectedAgency;
  bool _isLoading = true;

  // Add these for real-time validation
  bool _titleHasError = false;
  bool _categoryHasError = false;
  bool _descriptionHasError = false;
  bool _locationHasError = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _titleController.text = widget.reportData.title;
    _descriptionController.text = widget.reportData.description;
    _locationController.text = widget.reportData.location;

    // Only set selected category if it exists in the categories list
    if (widget.reportData.categoryId > 0 && widget.categories.isNotEmpty) {
      try {
        _selectedCategory = widget.categories.firstWhere(
          (cat) => cat.id == widget.reportData.categoryId,
        );
      } catch (e) {
        _selectedCategory = null;
      }
    }

    // Only set selected agency if it exists in the agencies list
    if (widget.reportData.agencyId != null &&
        widget.reportData.agencyId! > 0 &&
        widget.agencies.isNotEmpty) {
      try {
        _selectedAgency = widget.agencies.firstWhere(
          (agency) => agency.id == widget.reportData.agencyId,
        );
      } catch (e) {
        _selectedAgency = null;
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final categories = await CategoryService.getCategories();
      final agencies = await AgencyService.getAgencies();

      widget.onCategoriesLoaded(categories);
      widget.onAgenciesLoaded(agencies);

      setState(() {
        _isLoading = false;
      });

      // Re-initialize controllers after data is loaded
      _initializeControllers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateData() {
    final updatedReport = widget.reportData.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      categoryId: _selectedCategory?.id ?? 0,
      location: _locationController.text,
      agencyId: _selectedAgency?.id,
    );
    widget.onDataChanged(updatedReport);
  }

  void _onLocationSelected(String location) {
    _locationController.text = location;
    // Clear location error if field becomes valid
    if (location.isNotEmpty && _locationHasError) {
      setState(() {
        _locationHasError = false;
      });
      widget.formKey.currentState?.validate();
    }
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Provide details about the issue you want to report.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Title Field
            _buildTextField(
              controller: _titleController,
              label: 'Report Title *',
              hint: 'Brief description of the issue',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onChanged: (value) => _updateData(),
            ),
            const SizedBox(height: 12),

            // Category Dropdown
            _buildDropdown<ReportCategory>(
              label: 'Category *',
              value: _selectedCategory,
              items: widget.categories,
              itemBuilder: (category) => category.name,
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                _updateData();
              },
            ),
            const SizedBox(height: 12),

            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: 'Description *',
              hint: 'Detailed description of the issue',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onChanged: (value) => _updateData(),
            ),
            const SizedBox(height: 12),

            // Location Field with Map Picker
            _buildLocationField(),
            const SizedBox(height: 12),

            // Agency Dropdown (Optional)
            _buildDropdown<GovernmentAgency>(
              label: 'Target Agency (Optional)',
              value: _selectedAgency,
              items: widget.agencies,
              itemBuilder: (agency) => agency.name,
              onChanged: (agency) {
                setState(() {
                  _selectedAgency = agency;
                });
                _updateData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
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
          maxLines: maxLines,
          validator: (value) {
            final error = validator?.call(value);
            // Update error state based on validation result
            if (controller == _titleController) {
              _titleHasError = error != null;
            } else if (controller == _descriptionController) {
              _descriptionHasError = error != null;
            } else if (controller == _locationController) {
              _locationHasError = error != null;
            }
            return error;
          },
          onChanged: (value) {
            // Clear error and revalidate if field becomes valid
            if (value.isNotEmpty) {
              bool shouldRevalidate = false;
              if (controller == _titleController && _titleHasError) {
                setState(() {
                  _titleHasError = false;
                });
                shouldRevalidate = true;
              } else if (controller == _descriptionController &&
                  _descriptionHasError) {
                setState(() {
                  _descriptionHasError = false;
                });
                shouldRevalidate = true;
              } else if (controller == _locationController &&
                  _locationHasError) {
                setState(() {
                  _locationHasError = false;
                });
                shouldRevalidate = true;
              }

              if (shouldRevalidate) {
                widget.formKey.currentState?.validate();
              }
            }
            onChanged?.call(value);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    String? Function(T?)? validator,
    required Function(T?) onChanged,
  }) {
    // Ensure the value exists in items, otherwise set to null
    T? validatedValue = value;
    if (value != null && !items.contains(value)) {
      validatedValue = null;
    }

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
        DropdownButtonFormField<T>(
          value: validatedValue,
          menuMaxHeight: 200,
          decoration: InputDecoration(
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
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemBuilder(item),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          validator: (value) {
            final error = validator?.call(value);
            // Update category error state
            if (label.contains('Category')) {
              _categoryHasError = error != null;
            }
            return error;
          },
          onChanged: (newValue) {
            // Clear error if dropdown becomes valid
            if (newValue != null &&
                label.contains('Category') &&
                _categoryHasError) {
              setState(() {
                _categoryHasError = false;
              });
              widget.formKey.currentState?.validate();
            }
            onChanged(newValue);
          },
          hint: Text('Select ${label.toLowerCase()}'),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Enter or select location',
            suffixIcon: IconButton(
              icon: Icon(Icons.map, color: Colors.blue.shade700, size: 20),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            LocationPicker(
                              initialLocation: _locationController.text,
                              onLocationSelected: _onLocationSelected,
                            ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
          onChanged: (value) => _updateData(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
