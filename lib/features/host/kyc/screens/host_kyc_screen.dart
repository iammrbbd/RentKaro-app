import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/host_kyc.dart';
import '../providers/host_kyc_provider.dart';

class HostKycScreen extends ConsumerStatefulWidget {
  const HostKycScreen({
    super.key,
  });

  @override
  ConsumerState<HostKycScreen> createState() =>
      _HostKycScreenState();
}

class _HostKycScreenState
    extends ConsumerState<HostKycScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _aadhaarController =
  TextEditingController();

  final _panController =
  TextEditingController();

  final _licenseController =
  TextEditingController();

  final ImagePicker _picker =
  ImagePicker();

  XFile? _aadhaarDocument;
  XFile? _panDocument;
  XFile? _licenseDocument;

  bool _submitting = false;

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(
      String type,
      ) async {
    final file =
    await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) {
      return;
    }

    setState(() {
      if (type == 'aadhaar') {
        _aadhaarDocument = file;
      } else if (type == 'pan') {
        _panDocument = file;
      } else {
        _licenseDocument = file;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_aadhaarDocument == null ||
        _panDocument == null ||
        _licenseDocument == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload all three documents.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final service =
      ref.read(
        hostKycServiceProvider,
      );

      await service.submitKyc(
        aadhaarNumber:
        _aadhaarController.text,
        panNumber:
        _panController.text,
        drivingLicenseNumber:
        _licenseController.text,
        aadhaarDocument:
        _aadhaarDocument!,
        panDocument:
        _panDocument!,
        drivingLicenseDocument:
        _licenseDocument!,
      );

      ref.invalidate(
        myHostKycProvider,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Host KYC submitted successfully.',
          ),
        ),
      );

    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final kycAsync =
    ref.watch(
      myHostKycProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Host KYC',
        ),
      ),
      body: kycAsync.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(),
        ),
        error: (
            error,
            stack,
            ) =>
            Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Text(
                  error.toString(),
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),
        data: (kyc) {
          if (kyc != null &&
              kyc.isApproved) {
            return _StatusView(
              kyc: kyc,
            );
          }

          if (kyc != null &&
              kyc.isPending) {
            return _StatusView(
              kyc: kyc,
            );
          }

          return _buildForm(
            kyc,
          );
        },
      ),
    );
  }

  Widget _buildForm(
      HostKyc? previousKyc,
      ) {
    final isResubmission =
        previousKyc != null &&
            previousKyc.isRejected;

    return Form(
      key: _formKey,
      child: ListView(
        padding:
        const EdgeInsets.all(20),
        children: [
          Text(
            isResubmission
                ? 'Resubmit Host KYC'
                : 'Complete Host KYC',
            style:
            const TextStyle(
              fontSize: 26,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your KYC must be approved before you can list vehicles.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          if (isResubmission &&
              previousKyc
                  .rejectionReason !=
                  null) ...[
            const SizedBox(height: 18),

            Container(
              padding:
              const EdgeInsets.all(14),
              decoration:
              BoxDecoration(
                color:
                Colors.red.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                'Rejection reason:\n${previousKyc.rejectionReason}',
                style:
                const TextStyle(
                  color:
                  Colors.red,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          TextFormField(
            controller:
            _aadhaarController,
            keyboardType:
            TextInputType.number,
            maxLength: 12,
            decoration:
            const InputDecoration(
              labelText:
              'Aadhaar Number',
              border:
              OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.length != 12) {
                return 'Enter valid 12 digit Aadhaar';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _documentButton(
            title:
            'Aadhaar Document',
            file:
            _aadhaarDocument,
            onTap: () =>
                _pickDocument(
                  'aadhaar',
                ),
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller:
            _panController,
            textCapitalization:
            TextCapitalization
                .characters,
            maxLength: 10,
            decoration:
            const InputDecoration(
              labelText:
              'PAN Number',
              border:
              OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.length != 10) {
                return 'Enter valid PAN';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _documentButton(
            title:
            'PAN Document',
            file:
            _panDocument,
            onTap: () =>
                _pickDocument(
                  'pan',
                ),
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller:
            _licenseController,
            textCapitalization:
            TextCapitalization
                .characters,
            decoration:
            const InputDecoration(
              labelText:
              'Driving Licence Number',
              border:
              OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().length <
                      5) {
                return 'Enter valid driving licence number';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _documentButton(
            title:
            'Driving Licence Document',
            file:
            _licenseDocument,
            onTap: () =>
                _pickDocument(
                  'license',
                ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child:
            ElevatedButton(
              onPressed:
              _submitting
                  ? null
                  : _submit,
              child:
              _submitting
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                ),
              )
                  : Text(
                isResubmission
                    ? 'Resubmit KYC'
                    : 'Submit KYC',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentButton({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        file == null
            ? Icons.upload_file
            : Icons.check_circle,
      ),
      label: Text(
        file == null
            ? 'Upload $title'
            : '$title Selected',
      ),
    );
  }
}

class _StatusView
    extends StatelessWidget {
  final HostKyc kyc;

  const _StatusView({
    required this.kyc,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final approved =
        kyc.isApproved;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              approved
                  ? Icons.verified
                  : Icons.pending_actions,
              size: 72,
              color: approved
                  ? Colors.green
                  : Colors.orange,
            ),

            const SizedBox(height: 20),

            Text(
              approved
                  ? 'Host KYC Approved'
                  : 'KYC Under Review',
              style:
              const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              approved
                  ? 'You can now add vehicles to RentKaro.'
                  : 'Our admin team is reviewing your documents.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}