import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_kyc_model.dart';
import '../services/admin_kyc_service.dart';

// ============================================================
// ADMIN HOST KYC SERVICE PROVIDER
// ============================================================

final adminKycServiceProvider =
Provider<AdminKycService>((ref) {
  return AdminKycService();
});

// ============================================================
// ADMIN HOST KYC LIST PROVIDER
// ============================================================

final adminKycListProvider = FutureProvider.autoDispose
    .family<List<AdminKycModel>, String?>(
      (ref, status) async {
    final service =
    ref.read(adminKycServiceProvider);

    return service.getKycList(
      status: status,
    );
  },
);

// ============================================================
// ADMIN HOST KYC SCREEN
// ============================================================

class AdminKycScreen
    extends ConsumerStatefulWidget {
  const AdminKycScreen({
    super.key,
  });

  @override
  ConsumerState<AdminKycScreen> createState() =>
      _AdminKycScreenState();
}

class _AdminKycScreenState
    extends ConsumerState<AdminKycScreen> {
  String _selectedFilter = 'all';

  String? get _apiStatus {
    switch (_selectedFilter) {
      case 'pending':
        return 'pending';

      case 'approved':
        return 'approved';

      case 'rejected':
        return 'rejected';

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _apiStatus;

    final kycAsync = ref.watch(
      adminKycListProvider(status),
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Host KYC Verification',
        ),
        backgroundColor:
        Colors.white,
        foregroundColor:
        const Color(0xFF111827),
        elevation: 0,
      ),

      body: Column(
        children: [
          _buildFilter(),

          Expanded(
            child: kycAsync.when(
              loading: () {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              },

              error: (
                  error,
                  stackTrace,
                  ) {
                return _ErrorView(
                  message: error
                      .toString()
                      .replaceFirst(
                    'Exception: ',
                    '',
                  ),
                  onRetry: () {
                    ref.invalidate(
                      adminKycListProvider(
                        status,
                      ),
                    );
                  },
                );
              },

              data: (items) {
                if (items.isEmpty) {
                  return _EmptyView(
                    status:
                    _selectedFilter,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      adminKycListProvider(
                        status,
                      ),
                    );

                    await ref.read(
                      adminKycListProvider(
                        status,
                      ).future,
                    );
                  },

                  child:
                  ListView.builder(
                    physics:
                    const AlwaysScrollableScrollPhysics(),

                    padding:
                    const EdgeInsets.all(
                      14,
                    ),

                    itemCount:
                    items.length,

                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      final kyc =
                      items[index];

                      return _HostKycCard(
                        kyc: kyc,
                        onTap: () =>
                            _openDetails(
                              kyc,
                            ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  Widget _buildFilter() {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        12,
      ),

      color: Colors.white,

      child:
      DropdownButtonFormField<String>(
        initialValue:
        _selectedFilter,

        decoration:
        InputDecoration(
          labelText:
          'Filter status',

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),

        items: const [
          DropdownMenuItem(
            value: 'all',
            child: Text('All'),
          ),
          DropdownMenuItem(
            value: 'pending',
            child: Text('Pending'),
          ),
          DropdownMenuItem(
            value: 'approved',
            child: Text('Approved'),
          ),
          DropdownMenuItem(
            value: 'rejected',
            child: Text('Rejected'),
          ),
        ],

        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _selectedFilter =
                value;
          });
        },
      ),
    );
  }

  // ==========================================================
  // OPEN DETAILS
  // ==========================================================

  Future<void> _openDetails(
      AdminKycModel kyc,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AdminKycDetailScreen(
            kyc: kyc,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    ref.invalidate(
      adminKycListProvider(
        _apiStatus,
      ),
    );
  }
}

// ============================================================
// HOST KYC CARD
// ============================================================

class _HostKycCard
    extends StatelessWidget {
  final AdminKycModel kyc;
  final VoidCallback onTap;

  const _HostKycCard({
    required this.kyc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status =
    kyc.verificationStatus
        .trim()
        .toLowerCase();

    final Color statusColor;

    if (status == 'approved') {
      statusColor =
      const Color(0xFF16A34A);
    } else if (status == 'rejected') {
      statusColor =
      const Color(0xFFDC2626);
    } else {
      statusColor =
      const Color(0xFFD97706);
    }

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      elevation: 1,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child: InkWell(
        onTap: onTap,

        borderRadius:
        BorderRadius.circular(
          14,
        ),

        child: Padding(
          padding:
          const EdgeInsets.all(
            15,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    const Color(
                      0xFFEFF6FF,
                    ),

                    child: Text(
                      kyc.userName
                          .trim()
                          .isNotEmpty
                          ? kyc.userName
                          .trim()[0]
                          .toUpperCase()
                          : 'H',

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF2563EB,
                        ),
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          kyc.fullName
                              .trim()
                              .isEmpty
                              ? 'Name not provided'
                              : kyc.fullName,

                          maxLines: 1,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            Color(
                              0xFF111827,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          kyc.userPhone
                              .trim()
                              .isEmpty
                              ? 'Phone not provided'
                              : kyc.userPhone,

                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF64748B,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration:
                    BoxDecoration(
                      color: statusColor
                          .withValues(
                        alpha: 0.10,
                      ),

                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                    ),

                    child: Text(
                      status.isEmpty
                          ? 'PENDING'
                          : status
                          .toUpperCase(),

                      style:
                      TextStyle(
                        color:
                        statusColor,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              _InfoLine(
                icon:
                Icons.badge_outlined,
                text:
                'DL: ${_displayValue(kyc.drivingLicenseNumber)}',
              ),

              const SizedBox(
                height: 5,
              ),

              _InfoLine(
                icon:
                Icons.credit_card_outlined,
                text:
                'Aadhaar: ${_aadhaarDisplay(kyc.aadhaarLast4)}',
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  if (kyc.hasAadhaarDocument)
                    const _DocumentBadge(
                      text:
                      'Aadhaar',
                    ),

                  if (kyc.hasAadhaarDocument &&
                      kyc.hasDrivingLicenseDocument)
                    const SizedBox(
                      width: 6,
                    ),

                  if (kyc.hasDrivingLicenseDocument)
                    const _DocumentBadge(
                      text:
                      'Driving Licence',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _displayValue(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }

    return value;
  }

  static String _aadhaarDisplay(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }

    return 'XXXX-XXXX-$value';
  }
}

// ============================================================
// INFO LINE
// ============================================================

class _InfoLine
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
          const Color(0xFF64748B),
        ),

        const SizedBox(
          width: 7,
        ),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 12,
              color:
              Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DOCUMENT BADGE
// ============================================================

class _DocumentBadge
    extends StatelessWidget {
  final String text;

  const _DocumentBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(0xFFF1F5F9),

        borderRadius:
        BorderRadius.circular(
          6,
        ),
      ),

      child: Text(
        text,

        style:
        const TextStyle(
          fontSize: 10,
          color:
          Color(0xFF475569),
          fontWeight:
          FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class _EmptyView
    extends StatelessWidget {
  final String status;

  const _EmptyView({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;

    switch (status) {
      case 'pending':
        title =
        'No pending Host KYC';
        subtitle =
        'There are no KYC applications waiting for review.';
        break;

      case 'approved':
        title =
        'No approved Host KYC';
        subtitle =
        'No Host KYC applications have been approved yet.';
        break;

      case 'rejected':
        title =
        'No rejected Host KYC';
        subtitle =
        'No rejected Host KYC applications were found.';
        break;

      default:
        title =
        'No Host KYC records';
        subtitle =
        'No Host KYC applications were found.';
    }

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          24,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .verified_user_outlined,

              size: 58,

              color:
              Colors.grey.shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              title,

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w700,
                color:
                Color(0xFF111827),
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              subtitle,

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 12,
                color:
                Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          24,
        ),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color:
              Color(0xFFDC2626),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              message,

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 13,
                color:
                Color(0xFF475569),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            OutlinedButton.icon(
              onPressed: onRetry,

              icon: const Icon(
                Icons.refresh,
                size: 18,
              ),

              label:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL SCREEN
// ============================================================

class AdminKycDetailScreen
    extends ConsumerStatefulWidget {
  final AdminKycModel kyc;

  const AdminKycDetailScreen({
    super.key,
    required this.kyc,
  });

  @override
  ConsumerState<
      AdminKycDetailScreen>
  createState() =>
      _AdminKycDetailScreenState();
}

class _AdminKycDetailScreenState
    extends ConsumerState<
        AdminKycDetailScreen> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final kyc = widget.kyc;

    final status =
    kyc.verificationStatus
        .trim()
        .toLowerCase();

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Host KYC Details',
        ),

        backgroundColor:
        Colors.white,

        foregroundColor:
        const Color(0xFF111827),

        elevation: 0,
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [
            _buildStatusCard(
              status,
            ),

            _buildSection(
              title:
              'Host / Applicant',

              children: [
                _buildRow(
                  'Name',
                  _valueOrFallback(
                    kyc.fullName,
                  ),
                ),

                _buildRow(
                  'Phone',
                  _valueOrFallback(
                    kyc.userPhone,
                  ),
                ),

                _buildRow(
                  'Email',
                  kyc.userEmail
                      ?.trim()
                      .isNotEmpty ==
                      true
                      ? kyc.userEmail!
                      : 'Not provided',
                ),
              ],
            ),

            _buildSection(
              title:
              'Personal Details',

              children: [
                _buildRow(
                  'Date of Birth',
                  _formatDate(
                    kyc.dateOfBirth,
                  ),
                ),

                _buildRow(
                  'Address',
                  _valueOrFallback(
                    kyc.address,
                  ),
                ),
              ],
            ),

            _buildSection(
              title:
              'Identity Verification',

              children: [
                _buildRow(
                  'Aadhaar',
                  _aadhaarDisplay(
                    kyc.aadhaarLast4,
                  ),
                ),

                _buildRow(
                  'Driving Licence',
                  _valueOrFallback(
                    kyc.drivingLicenseNumber,
                  ),
                ),

                _buildRow(
                  'Licence Expiry',
                  _formatDate(
                    kyc.drivingLicenseExpiry,
                  ),
                ),
              ],
            ),

            _buildSection(
              title: 'Documents',

              children: [
                _buildDocumentButton(
                  title:
                  'View Aadhaar Document',
                  available:
                  kyc.hasAadhaarDocument,
                  documentType:
                  'aadhaar',
                ),

                const SizedBox(
                  height: 10,
                ),

                _buildDocumentButton(
                  title:
                  'View Driving Licence',
                  available:
                  kyc.hasDrivingLicenseDocument,
                  documentType:
                  'driving_license',
                ),
              ],
            ),

            if (kyc.rejectionReason
                ?.trim()
                .isNotEmpty ==
                true)
              _buildSection(
                title:
                'Rejection Reason',

                children: [
                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      12,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFFEF2F2,
                      ),

                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),

                    child: Text(
                      kyc.rejectionReason!,

                      style:
                      const TextStyle(
                        fontSize: 13,
                        color:
                        Color(
                          0xFFDC2626,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            _buildSection(
              title:
              'Submission Information',

              children: [
                _buildRow(
                  'Submitted At',
                  _formatDateTime(
                    kyc.submittedAt,
                  ),
                ),

                _buildRow(
                  'Reviewed At',
                  _formatDateTime(
                    kyc.reviewedAt,
                  ),
                ),

                _buildRow(
                  'Created At',
                  _formatDateTime(
                    kyc.createdAt,
                  ),
                ),

                _buildRow(
                  'Updated At',
                  _formatDateTime(
                    kyc.updatedAt,
                  ),
                ),
              ],
            ),

            if (status == 'pending')
              _buildActionButtons(),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STATUS CARD
  // ==========================================================

  Widget _buildStatusCard(
      String status,
      ) {
    final Color color;
    final IconData icon;

    if (status == 'approved') {
      color =
      const Color(0xFF16A34A);
      icon = Icons.verified;
    } else if (status == 'rejected') {
      color =
      const Color(0xFFDC2626);
      icon = Icons.cancel_outlined;
    } else {
      color =
      const Color(0xFFD97706);
      icon =
          Icons.pending_outlined;
    }

    return Container(
      width: double.infinity,

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                const Text(
                  'Verification Status',

                  style:
                  TextStyle(
                    fontSize: 12,
                    color:
                    Color(
                      0xFF64748B,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  status.isEmpty
                      ? 'PENDING'
                      : status
                      .toUpperCase(),

                  style:
                  TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _buildSection({
    required String title,
    required List<Widget>
    children,
  }) {
    return Container(
      width: double.infinity,

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          Text(
            title,

            style:
            const TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w700,
              color:
              Color(0xFF111827),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ...children,
        ],
      ),
    );
  }

  // ==========================================================
  // ROW
  // ==========================================================

  Widget _buildRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              label,

              style:
              const TextStyle(
                fontSize: 12,
                color:
                Color(
                  0xFF64748B,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              value,

              style:
              const TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w500,
                color:
                Color(
                  0xFF111827,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DOCUMENT BUTTON
  // ==========================================================

  Widget _buildDocumentButton({
    required String title,
    required bool available,
    required String documentType,
  }) {
    return SizedBox(
      width: double.infinity,

      child: OutlinedButton.icon(
        onPressed:
        available &&
            !_processing
            ? () =>
            _viewDocument(
              documentType,
              title,
            )
            : null,

        icon: Icon(
          available
              ? Icons
              .description_outlined
              : Icons
              .description,
        ),

        label: Text(
          available
              ? title
              : '$title unavailable',
        ),

        style:
        OutlinedButton.styleFrom(
          padding:
          const EdgeInsets
              .symmetric(
            vertical: 13,
          ),

          alignment:
          Alignment.centerLeft,
        ),
      ),
    );
  }

  // ==========================================================
  // ACTION BUTTONS
  // ==========================================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
            _processing
                ? null
                : _reject,

            style:
            OutlinedButton
                .styleFrom(
              foregroundColor:
              const Color(
                0xFFDC2626,
              ),

              side:
              const BorderSide(
                color:
                Color(
                  0xFFDC2626,
                ),
              ),

              padding:
              const EdgeInsets
                  .symmetric(
                vertical: 14,
              ),
            ),

            child:
            const Text(
              'Reject',
            ),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: ElevatedButton(
            onPressed:
            _processing
                ? null
                : _approve,

            style:
            ElevatedButton
                .styleFrom(
              backgroundColor:
              const Color(
                0xFF16A34A,
              ),

              foregroundColor:
              Colors.white,

              padding:
              const EdgeInsets
                  .symmetric(
                vertical: 14,
              ),
            ),

            child: _processing
                ? const SizedBox(
              height: 18,
              width: 18,

              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                Colors.white,
              ),
            )
                : const Text(
              'Approve',
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // VIEW DOCUMENT
  // ==========================================================

  Future<void> _viewDocument(
      String documentType,
      String title,
      ) async {
    showDialog(
      context: context,

      barrierDismissible:
      false,

      builder: (_) {
        return const Center(
          child:
          CircularProgressIndicator(),
        );
      },
    );

    try {
      final Uint8List bytes =
      await ref
          .read(
        adminKycServiceProvider,
      )
          .getDocument(
        kycId:
        widget.kyc.id,
        documentType:
        documentType,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
      );

      if (bytes.isEmpty) {
        throw Exception(
          'Document is empty.',
        );
      }

      await showDialog(
        context: context,

        builder: (_) {
          return Dialog(
            insetPadding:
            const EdgeInsets.all(
              16,
            ),

            child: Container(
              constraints:
              const BoxConstraints(
                maxHeight: 650,
              ),

              padding:
              const EdgeInsets.all(
                12,
              ),

              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,

                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },

                        icon:
                        const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Flexible(
                    child:
                    InteractiveViewer(
                      minScale:
                      0.5,

                      maxScale:
                      4,

                      child:
                      Image.memory(
                        bytes,

                        fit:
                        BoxFit.contain,

                        errorBuilder:
                            (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return const Padding(
                            padding:
                            EdgeInsets
                                .all(
                              30,
                            ),

                            child:
                            Text(
                              'Unable to preview this document.',
                              textAlign:
                              TextAlign
                                  .center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (error) {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
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
      }
    }
  }

  // ==========================================================
  // APPROVE
  // ==========================================================

  Future<void> _approve() async {
    final confirmed =
    await showDialog<bool>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Approve Host KYC?',
          ),

          content:
          const Text(
            'This will approve the host KYC application.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child:
              const Text(
                'Approve',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await ref
          .read(
        adminKycServiceProvider,
      )
          .approveKyc(
        widget.kyc.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Host KYC approved successfully.',
          ),
        ),
      );

      Navigator.pop(
        context,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _processing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
    }
  }

  // ==========================================================
  // REJECT
  // ==========================================================

  Future<void> _reject() async {
    final controller =
    TextEditingController();

    final reason =
    await showDialog<String>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Reject Host KYC',
          ),

          content:
          TextField(
            controller:
            controller,

            maxLines: 4,

            maxLength: 500,

            textCapitalization:
            TextCapitalization
                .sentences,

            decoration:
            const InputDecoration(
              hintText:
              'Enter rejection reason',
              border:
              OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final value =
                controller.text
                    .trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  value,
                );
              },

              child:
              const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null ||
        reason.trim().isEmpty) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await ref
          .read(
        adminKycServiceProvider,
      )
          .rejectKyc(
        kycId:
        widget.kyc.id,
        reason:
        reason.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Host KYC rejected successfully.',
          ),
        ),
      );

      Navigator.pop(
        context,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _processing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
    }
  }

  // ==========================================================
  // DATE
  // ==========================================================

  String _formatDate(
      DateTime? date,
      ) {
    if (date == null) {
      return 'Not available';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ==========================================================
  // DATE TIME
  // ==========================================================

  String _formatDateTime(
      DateTime? date,
      ) {
    if (date == null) {
      return 'Not available';
    }

    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final hour =
    date.hour.toString().padLeft(
      2,
      '0',
    );

    final minute =
    date.minute.toString().padLeft(
      2,
      '0',
    );

    return '$day/$month/${date.year} '
        '$hour:$minute';
  }

  // ==========================================================
  // VALUE
  // ==========================================================

  String _valueOrFallback(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return 'Not provided';
    }

    return value;
  }

  // ==========================================================
  // AADHAAR
  // ==========================================================

  String _aadhaarDisplay(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }

    return 'XXXX-XXXX-$value';
  }
}