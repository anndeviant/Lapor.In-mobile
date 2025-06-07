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
      await ReportSubmissionService.submitReport(widget.reportData);

      // Clear draft after successful submission
      await ReportStorage.clearDraft();

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green.shade600,
                        size: 56,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Report Submitted',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your report has been sent successfully.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

    return SafeArea(
      child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.blue.shade700, size: 16),
                ),
                const SizedBox(width: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              softWrap: true,
              overflow: TextOverflow.visible,
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
