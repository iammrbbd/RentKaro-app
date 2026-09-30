import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/kyc_model.dart';
import '../providers/kyc_provider.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({
    super.key,
  });

  @override
  ConsumerState<KycScreen> createState() =>
      _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController =
  TextEditingController();

  final _addressController =
  TextEditingController();

  final _aadhaarController =
  TextEditingController();

  final _licenseController =
  TextEditingController();

  DateTime? _dateOfBirth;
  DateTime? _licenseExpiry;

  XFile? _aadhaarDocument;
  XFile? _drivingLicenseDocument;

  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    _licenseController.dispose();

    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(
        now.year - 18,
        now.month,
        now.day,
      ),
      firstDate: DateTime(1940),
      lastDate: DateTime(
        now.year - 18,
        now.month,
        now.day,
      ),
    );

    if (selected != null) {
      setState(() {
        _dateOfBirth = selected;
      });
    }
  }

  Future<void> _pickLicenseExpiry() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 20,
        now.month,
        now.day,
      ),
    );

    if (selected != null) {
      setState(() {
        _licenseExpiry = selected;
      });
    }
  }

  Future<void> _pickAadhaarDocument() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) {
      return;
    }

    setState(() {
      _aadhaarDocument = file;
    });
  }

  Future<void> _pickDrivingLicenseDocument() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) {
      return;
    }

    setState(() {
      _drivingLicenseDocument = file;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage(
        'Please select your date of birth.',
      );
      return;
    }

    if (_licenseExpiry == null) {
      _showMessage(
        'Please select driving licence expiry date.',
      );
      return;
    }

    if (_aadhaarDocument == null) {
      _showMessage(
        'Please upload Aadhaar/KYC document.',
      );
      return;
    }

    if (_drivingLicenseDocument == null) {
      _showMessage(
        'Please upload driving licence document.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = ref.read(
        kycServiceProvider,
      );

      await service.submitKyc(
        fullName: _fullNameController.text,
        dateOfBirth: _dateOfBirth!,
        address: _addressController.text,
        aadhaarLast4:
        _aadhaarController.text,
        drivingLicenseNumber:
        _licenseController.text,
        drivingLicenseExpiry:
        _licenseExpiry!,
        aadhaarDocument:
        _aadhaarDocument!,
        drivingLicenseDocument:
        _drivingLicenseDocument!,
      );

      ref.invalidate(myKycProvider);

      if (!mounted) {
        return;
      }

      _showMessage(
        'KYC submitted successfully.',
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final kycAsync = ref.watch(
      myKycProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
      ),
      body: kycAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      myKycProvider,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (kyc) {
          if (kyc != null &&
              kyc.verificationStatus ==
                  'pending') {
            return _buildStatusView(
              kyc,
              'Your KYC is under review.',
            );
          }

          if (kyc != null &&
              kyc.verificationStatus ==
                  'approved') {
            return _buildStatusView(
              kyc,
              'Your KYC has been approved.',
            );
          }

          if (kyc != null &&
              kyc.verificationStatus ==
                  'rejected') {
            return _buildRejectedView(
              kyc,
            );
          }

          return _buildForm();
        },
      ),
    );
  }

  Widget _buildStatusView(
      KycModel kyc,
      String message,
      ) {
    final isApproved =
        kyc.verificationStatus ==
            'approved';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Icon(
            isApproved
                ? Icons.verified
                : Icons.pending_actions,
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            isApproved
                ? 'KYC Approved'
                : 'KYC Under Review',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _infoCard(
            'Name',
            kyc.fullName,
          ),
          _infoCard(
            'Driving Licence',
            kyc.drivingLicenseNumber,
          ),
          _infoCard(
            'Aadhaar',
            'XXXX XXXX ${kyc.aadhaarLast4}',
          ),
          _infoCard(
            'Licence Expiry',
            _formatDate(
              kyc.drivingLicenseExpiry,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedView(
      KycModel kyc,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.cancel_outlined,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'KYC Rejected',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),
          const SizedBox(height: 12),
          if (kyc.rejectionReason != null)
            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(16),
                child: Text(
                  kyc.rejectionReason!,
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'You can submit your KYC again with corrected documents.',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetAndShowForm,
            child: const Text(
              'Resubmit KYC',
            ),
          ),
        ],
      ),
    );
  }

  void _resetAndShowForm() {
    setState(() {
      _fullNameController.clear();
      _addressController.clear();
      _aadhaarController.clear();
      _licenseController.clear();

      _dateOfBirth = null;
      _licenseExpiry = null;

      _aadhaarDocument = null;
      _drivingLicenseDocument = null;
    });
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Complete your KYC',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'KYC verification is required before you can book a vehicle.',
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _fullNameController,
            textCapitalization:
            TextCapitalization.words,
            decoration:
            const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter your full name';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: _pickDateOfBirth,
            child: InputDecorator(
              decoration:
              const InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
                suffixIcon:
                Icon(Icons.calendar_month),
              ),
              child: Text(
                _dateOfBirth == null
                    ? 'Select date'
                    : _formatDate(
                  _dateOfBirth!,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration:
            const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter your address';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _aadhaarController,
            keyboardType:
            TextInputType.number,
            maxLength: 4,
            decoration:
            const InputDecoration(
              labelText: 'Aadhaar Last 4 Digits',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) {
              if (value == null ||
                  value.length != 4 ||
                  int.tryParse(value) == null) {
                return 'Enter exactly 4 digits';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _licenseController,
            textCapitalization:
            TextCapitalization.characters,
            decoration:
            const InputDecoration(
              labelText:
              'Driving Licence Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter licence number';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: _pickLicenseExpiry,
            child: InputDecorator(
              decoration:
              const InputDecoration(
                labelText:
                'Driving Licence Expiry',
                border: OutlineInputBorder(),
                suffixIcon:
                Icon(Icons.calendar_month),
              ),
              child: Text(
                _licenseExpiry == null
                    ? 'Select expiry date'
                    : _formatDate(
                  _licenseExpiry!,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _documentPicker(
            title: 'Aadhaar / KYC Document',
            file: _aadhaarDocument,
            onPressed:
            _pickAadhaarDocument,
          ),

          const SizedBox(height: 16),

          _documentPicker(
            title:
            'Driving Licence Document',
            file: _drivingLicenseDocument,
            onPressed:
            _pickDrivingLicenseDocument,
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
              _isSubmitting
                  ? null
                  : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                height: 22,
                width: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Submit KYC',
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _documentPicker({
    required String title,
    required XFile? file,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          file == null
              ? Icons.upload_file
              : Icons.check_circle,
        ),
        title: Text(title),
        subtitle: Text(
          file == null
              ? 'Upload JPG or PNG'
              : file.name,
        ),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            file == null
                ? 'Upload'
                : 'Change',
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
      String title,
      String value,
      ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}