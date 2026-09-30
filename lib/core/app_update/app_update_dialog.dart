import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_update_model.dart';

class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
  });

  final AppUpdateInfo updateInfo;

  @override
  State<AppUpdateDialog> createState() =>
      _AppUpdateDialogState();
}

class _AppUpdateDialogState
    extends State<AppUpdateDialog> {
  bool _isOpening = false;

  bool get _isForceUpdate =>
      widget.updateInfo.forceUpdate;

  Future<void> _updateNow() async {
    if (_isOpening) {
      return;
    }

    final url =
    widget.updateInfo.updateUrl.trim();

    if (url.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Update link is not available yet.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isOpening = true;
    });

    try {
      final uri = Uri.tryParse(url);

      if (uri == null ||
          !uri.hasScheme) {
        throw Exception(
          'Invalid update URL.',
        );
      }

      final launched =
      await launchUrl(
        uri,
        mode:
        LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open the update page.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the update page.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpening = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return PopScope(
      canPop: !_isForceUpdate,
      child: AlertDialog(
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(24),
        ),
        contentPadding:
        const EdgeInsets.fromLTRB(
          24,
          26,
          24,
          20,
        ),
        titlePadding:
        const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          0,
        ),
        title: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFEFF6FF,
                ),
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color:
                Color(0xFF2563EB),
                size: 36,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              _isForceUpdate
                  ? 'Update Required'
                  : widget
                  .updateInfo
                  .title,
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 21,
                fontWeight:
                FontWeight.w800,
                color:
                Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Text(
              widget
                  .updateInfo
                  .message,
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 15,
                height: 1.5,
                color:
                Color(0xFF6B7280),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    'Latest version',
                    style: TextStyle(
                      color:
                      Color(0xFF64748B),
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget
                        .updateInfo
                        .latestVersion,
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF111827),
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding:
        const EdgeInsets.fromLTRB(
          24,
          0,
          24,
          22,
        ),
        actions: [
          if (!_isForceUpdate)
            TextButton(
              onPressed:
                  () => Navigator.of(
                context,
              ).pop(),
              child: const Text(
                'Later',
              ),
            ),
          FilledButton(
            onPressed:
            _isOpening
                ? null
                : _updateNow,
            style:
            FilledButton.styleFrom(
              minimumSize:
              const Size(
                130,
                48,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
            ),
            child: _isOpening
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                Colors.white,
              ),
            )
                : const Text(
              'Update Now',
            ),
          ),
        ],
      ),
    );
  }
}