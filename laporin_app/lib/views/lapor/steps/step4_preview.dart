import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/report.dart';
import '../../../models/report_category.dart';
import '../../../models/government_agency.dart';
import '../../../services/report_submission_service.dart';
import '../../../utils/report_storage.dart';

class Step4Preview extends StatefulWidget {
  final Report reportData;
  final List<ReportCategory> categories;
  final List<GovernmentAgency> agencies;
  final VoidCallback? onPrevious;

  const Step4Preview({
    super.key,
    required this.reportData,
    required this.categories,
    required this.agencies,
    this.onPrevious,
  });

  @override
  State<Step4Preview> createState() => _Step4PreviewState();
}

class _Step4PreviewState extends State<Step4Preview> {
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (widget.reportData.imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo evidence is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ReportSubmissionService.submitReport(
        widget.reportData,
      );

      // Clear draft after successful submission
      await ReportStorage.clearDraft();

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 64,
                ),
                title: const Text('Report Submitted!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Your report has been submitted successfully.'),
                    const SizedBox(height: 16),
                    if (response['trackingId'] != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Tracking ID',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              response['trackingId'].toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close dialog and go back to main page
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      ); // Go back to main page
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.categories.firstWhere(
      (cat) => cat.id == widget.reportData.categoryId,
      orElse: () => ReportCategory(id: 0, name: 'Unknown', description: ''),
    );

    final agency =
        widget.reportData.agencyId != null
            ? widget.agencies.firstWhere(
              (ag) => ag.id == widget.reportData.agencyId,
              orElse:
                  () => GovernmentAgency(
                    id: 0,
                    name: 'Not specified',
                    description: '',
                  ),
            )
            : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please review your report before submitting.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Report Information Card
          _buildSectionCard(
            title: 'Report Information',
            icon: Icons.report_outlined,
            children: [
              _buildInfoRow('Title', widget.reportData.title),
              _buildInfoRow('Category', category.name),
              _buildInfoRow('Desc', widget.reportData.description),
              _buildInfoRow('Location', widget.reportData.location),
              if (agency != null) _buildInfoRow('Agency', agency.name),
            ],
          ),
          const SizedBox(height: 12),

          // Reporter Information Card
          _buildSectionCard(
            title: 'Reporter Information',
            icon: Icons.person_outlined,
            children: [
              _buildInfoRow('Name', widget.reportData.reporterName),
              _buildInfoRow('Phone', widget.reportData.reporterContact),
            ],
          ),
          const SizedBox(height: 12),

          // Evidence Card
          _buildSectionCard(
            title: 'Evidence',
            icon: Icons.camera_alt_outlined,
            children: [
              if (widget.reportData.imageFile != null)
                _buildImagePreview(
                  'Photo Evidence',
                  widget.reportData.imageFile!,
                ),
              if (widget.reportData.attachmentFile != null)
                _buildImagePreview(
                  'Additional Attachment',
                  widget.reportData.attachmentFile!,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Navigation buttons (Previous and Submit)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _isSubmitting
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Submitting...'),
                            ],
                          )
                          : const Text(
                            'Submit Report',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String title, File imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
