import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/report.dart';

class Step3EvidenceUpload extends StatefulWidget {
  final Report reportData;
  final Function(Report) onDataChanged;

  const Step3EvidenceUpload({
    super.key,
    required this.reportData,
    required this.onDataChanged,
  });

  @override
  State<Step3EvidenceUpload> createState() => _Step3EvidenceUploadState();
}

class _Step3EvidenceUploadState extends State<Step3EvidenceUpload> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  File? _attachmentFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.reportData.imageFile;
    _attachmentFile = widget.reportData.attachmentFile;
  }

  // Add validation method
  bool validateAndShowError() {
    if (_imageFile == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Photo evidence is required to proceed!'),
      //     backgroundColor: Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //     margin: const EdgeInsets.all(16),
      //   ),
      // );
      return false;
    }
    return true;
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
        _updateData();
      }
    } catch (e) {
      // Remove the SnackBar error handling
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
        _updateData();
      }
    } catch (e) {
      // Remove the SnackBar error handling
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickFromGallery();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file != null) {
        setState(() {
          _attachmentFile = File(file.path);
        });
        _updateData();
      }
    } catch (e) {
      // Remove the SnackBar error handling
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateData() {
    final updatedReport = widget.reportData.copyWith(
      imageFile: _imageFile,
      attachmentFile: _attachmentFile,
    );
    widget.onDataChanged(updatedReport);
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
    // Update report data to ensure the file is completely removed
    final updatedReport = widget.reportData.copyWith(
      imageFile: null,
      clearImageFile: true, // Add flag to indicate explicit removal
    );
    widget.onDataChanged(updatedReport);
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
    });
    // Update report data to ensure the file is completely removed
    final updatedReport = widget.reportData.copyWith(
      attachmentFile: null,
      clearAttachmentFile: true, // Add flag to indicate explicit removal
    );
    widget.onDataChanged(updatedReport);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence Upload',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Take a photo of the issue to provide evidence.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Required Photo Section
          _buildPhotoSection(),
          const SizedBox(height: 16),

          // Optional Attachment Section
          _buildAttachmentSection(),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Photo Evidence *',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.camera_alt, color: Colors.blue.shade700, size: 18),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Take a clear photo showing the issue',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),

        if (_imageFile == null)
          _buildTakePhotoButton()
        else
          _buildImagePreview(),

        // Validation message text remains as visual feedback
        if (_imageFile == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Photo evidence is required!',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTakePhotoButton() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _showPhotoSourceDialog,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Icon(Icons.add_a_photo, size: 40, color: Colors.blue.shade700),
              const SizedBox(height: 12),
              Text(
                _isLoading ? 'Loading...' : 'Add Photo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      _isLoading ? Colors.grey.shade600 : Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Camera or Gallery',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _imageFile!,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _removeImage,
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Additional Attachment (Optional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.attach_file, color: Colors.blue.shade700, size: 18),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Upload additional documents if needed',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),

        if (_attachmentFile == null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickAttachment,
              icon: Icon(
                Icons.upload_file,
                color: Colors.blue.shade700,
                size: 18,
              ),
              label: Text(
                'Upload File',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.blue.shade700),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _attachmentFile!.path.split('/').last,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _removeAttachment,
                  icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
