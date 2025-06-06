import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../models/report.dart';
import '../../models/report_category.dart';
import '../../models/government_agency.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../utils/report_storage.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/connection_popup.dart';
import 'steps/step1_report_info.dart';
import 'steps/step2_reporter_info.dart';
import 'steps/step3_evidence_upload.dart';
import 'steps/step4_preview.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  final int _totalSteps = 4;
  bool _showConnectionPopup = false;

  // Form keys for validation
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Report data
  Report _reportData = Report(
    title: '',
    description: '',
    categoryId: 0,
    reporterName: '',
    reporterContact: '',
    location: '',
  );

  // Categories and agencies
  List<ReportCategory> _categories = [];
  List<GovernmentAgency> _agencies = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    _checkConnectivity();
    _loadExistingData();
    ConnectivityService.startMonitoring(_onConnectivityChanged);
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ConnectivityService.hasConnection();
    setState(() {
      _showConnectionPopup = !hasConnection;
    });
  }

  void _onConnectivityChanged(bool hasConnection) {
    setState(() {
      _showConnectionPopup = !hasConnection;
    });
  }

  Future<void> _loadExistingData() async {
    // Load draft if exists
    final draft = await ReportStorage.loadDraft();
    if (draft != null) {
      setState(() {
        _reportData = draft;
      });
    }

    // Load current user data if logged in
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser != null) {
      setState(() {
        _reportData = _reportData.copyWith(
          reporterName: currentUser.fullname,
          reporterContact: currentUser.phoneNumber,
        );
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      // Validate current step
      bool isValid = true;

      if (_currentStep == 1) {
        isValid = _step1FormKey.currentState?.validate() ?? false;
      } else if (_currentStep == 2) {
        isValid = _step2FormKey.currentState?.validate() ?? false;
      } else if (_currentStep == 3) {
        // Validate that image is uploaded - check the actual report data
        if (_reportData.imageFile == null ||
            !File(_reportData.imageFile!.path).existsSync()) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Photo evidence is required to proceed'),
          //     backgroundColor: Colors.red,
          //   ),
          // );
          isValid = false;
        }
      }

      if (isValid) {
        if (_currentStep == _totalSteps) {
          // This is handled by Step4Preview itself
          return;
        }

        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _saveDraft();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateReportData(Report newData) {
    setState(() {
      _reportData = newData;
    });
    _saveDraft();
  }

  Future<void> _saveDraft() async {
    await ReportStorage.saveDraft(_reportData);
  }

  void _onCategoriesLoaded(List<ReportCategory> categories) {
    setState(() {
      _categories = categories;
      // Reset category selection if current selection is not in the new list
      if (_reportData.categoryId > 0) {
        final categoryExists = categories.any(
          (cat) => cat.id == _reportData.categoryId,
        );
        if (!categoryExists) {
          _reportData = _reportData.copyWith(categoryId: 0);
        }
      }
    });
  }

  void _onAgenciesLoaded(List<GovernmentAgency> agencies) {
    setState(() {
      _agencies = agencies;
      // Reset agency selection if current selection is not in the new list
      if (_reportData.agencyId != null && _reportData.agencyId! > 0) {
        final agencyExists = agencies.any(
          (agency) => agency.id == _reportData.agencyId,
        );
        if (!agencyExists) {
          _reportData = _reportData.copyWith(agencyId: null);
        }
      }
    });
  }

  @override
  void dispose() {
    ConnectivityService.stopMonitoring();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        title: const Text(
          'Create Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CircularStepIndicator(
                      totalSteps: _totalSteps,
                      currentStep: _currentStep,
                      activeColor: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Step $_currentStep of $_totalSteps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Step content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Step1ReportInfo(
                      formKey: _step1FormKey,
                      reportData: _reportData,
                      categories: _categories,
                      agencies: _agencies,
                      onDataChanged: _updateReportData,
                      onCategoriesLoaded: _onCategoriesLoaded,
                      onAgenciesLoaded: _onAgenciesLoaded,
                    ),
                    Step2ReporterInfo(
                      formKey: _step2FormKey,
                      reportData: _reportData,
                      onDataChanged: _updateReportData,
                    ),
                    Step3EvidenceUpload(
                      reportData: _reportData,
                      onDataChanged: _updateReportData,
                    ),
                    Step4Preview(
                      reportData: _reportData,
                      categories: _categories,
                      agencies: _agencies,
                      onPrevious: _previousStep,
                    ),
                  ],
                ),
              ),

              // Navigation buttons (hide on step 4 as it has its own navigation buttons)
              if (_currentStep < _totalSteps)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (_currentStep > 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentStep > 1) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          ConnectionPopup(isVisible: _showConnectionPopup),
        ],
      ),
    );
  }
}
