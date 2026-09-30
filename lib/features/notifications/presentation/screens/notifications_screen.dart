import 'package:flutter/material.dart';

import '../../data/notification_service.dart';

class NotificationsScreen
    extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen>
  createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final NotificationService _service =
  NotificationService();

  bool _loading = true;
  bool _markingAll = false;

  String? _error;

  List<Map<String, dynamic>>
  _notifications = [];

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();

    _loadNotifications();
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data =
      await _service
          .getNotifications();

      final raw =
      data['notifications'];

      final notifications =
      raw is List
          ? raw
          .whereType<Map>()
          .map(
            (item) =>
        Map<String, dynamic>.from(
          item,
        ),
      )
          .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications =
            notifications;

        _unreadCount =
            _toInt(
              data['unread_count'],
            );

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = _cleanError(
          error,
        );
      });
    }
  }

  // ==========================================================
  // MARK READ
  // ==========================================================

  Future<void> _markAsRead(
      Map<String, dynamic> notification,
      ) async {
    final id =
    _toInt(
      notification['id'],
    );

    if (id <= 0) {
      return;
    }

    final isRead =
        notification['is_read'] == true;

    if (isRead) {
      return;
    }

    try {
      await _service.markAsRead(id);

      if (!mounted) {
        return;
      }

      setState(() {
        notification['is_read'] = true;

        if (_unreadCount > 0) {
          _unreadCount--;
        }
      });
    } catch (_) {
      // Keep UI unchanged on failure.
    }
  }

  // ==========================================================
  // MARK ALL READ
  // ==========================================================

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0 ||
        _markingAll) {
      return;
    }

    setState(() {
      _markingAll = true;
    });

    try {
      await _service.markAllAsRead();

      if (!mounted) {
        return;
      }

      setState(() {
        for (final item
        in _notifications) {
          item['is_read'] = true;
        }

        _unreadCount = 0;
        _markingAll = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _markingAll = false;
      });

      _showMessage(
        _cleanError(error),
      );
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> _delete(
      Map<String, dynamic> notification,
      ) async {
    final id =
    _toInt(
      notification['id'],
    );

    if (id <= 0) {
      return;
    }

    try {
      await _service
          .deleteNotification(id);

      if (!mounted) {
        return;
      }

      final wasUnread =
          notification['is_read'] != true;

      setState(() {
        _notifications.remove(
          notification,
        );

        if (wasUnread &&
            _unreadCount > 0) {
          _unreadCount--;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
        const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.white,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.w800,
          ),
        ),

        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed:
              _markingAll
                  ? null
                  : _markAllAsRead,
              child: Text(
                _markingAll
                    ? '...'
                    : 'Read all',
                style:
                const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh:
        _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context)
                .size
                .height *
                0.32,
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons
                          .error_outline_rounded,
                      size: 52,
                      color:
                      Color(0xFFDC2626),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    const Text(
                      'Unable to load notifications',
                      style:
                      TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      _error!,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        fontSize: 12,
                        color:
                        Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed:
                      _loadNotifications,
                      child:
                      const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context)
                .size
                .height *
                0.65,
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFEFF6FF,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .notifications_none_rounded,
                      size: 38,
                      color:
                      Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w800,
                      color:
                      Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    'You are all caught up.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        30,
      ),
      itemCount:
      _notifications.length,
      itemBuilder:
          (context, index) {
        final notification =
        _notifications[index];

        return _NotificationCard(
          notification:
          notification,
          onTap: () {
            _markAsRead(
              notification,
            );
          },
          onDelete: () {
            _delete(
              notification,
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  String _cleanError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION CARD
// ============================================================================

class _NotificationCard
    extends StatelessWidget {
  final Map<String, dynamic>
  notification;

  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final title =
        notification['title']
            ?.toString() ??
            'Notification';

    final message =
        notification['message']
            ?.toString() ??
            '';

    final type =
        notification[
        'notification_type']
            ?.toString()
            .toLowerCase() ??
            'general';

    final isRead =
        notification['is_read'] == true;

    final createdAt =
    notification['created_at']
        ?.toString();

    final icon =
    _getIcon(type);

    return Dismissible(
      key: ValueKey(
        notification['id'],
      ),
      direction:
      DismissDirection.endToStart,
      onDismissed: (_) {
        onDelete();
      },
      background: Container(
        margin:
        const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
        const EdgeInsets.only(
          right: 20,
        ),
        alignment:
        Alignment.centerRight,
        decoration:
        BoxDecoration(
          color:
          const Color(0xFFDC2626),
          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 10,
        ),
        decoration:
        BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: isRead
                ? const Color(
              0xFFE5E7EB,
            )
                : const Color(
              0xFFBFDBFE,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            onTap: onTap,
            child: Padding(
              padding:
              const EdgeInsets.all(
                15,
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment:
                    Alignment.center,
                    decoration:
                    BoxDecoration(
                      color:
                      _iconBackground(
                        type,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color:
                      _iconColor(type),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines:
                                2,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                TextStyle(
                                  color:
                                  const Color(
                                    0xFF111827,
                                  ),
                                  fontSize:
                                  14,
                                  fontWeight:
                                  isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin:
                                const EdgeInsets
                                    .only(
                                  left: 8,
                                  top: 3,
                                ),
                                decoration:
                                const BoxDecoration(
                                  color:
                                  Color(
                                    0xFF2563EB,
                                  ),
                                  shape:
                                  BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          message,
                          maxLines: 4,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF6B7280,
                            ),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          _formatDate(
                            createdAt,
                          ),
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF9CA3AF,
                            ),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    padding:
                    EdgeInsets.zero,
                    icon: const Icon(
                      Icons
                          .more_vert_rounded,
                      size: 20,
                      color:
                      Color(0xFF9CA3AF),
                    ),
                    onSelected: (value) {
                      if (value ==
                          'delete') {
                        onDelete();
                      }

                      if (value ==
                          'read') {
                        onTap();
                      }
                    },
                    itemBuilder:
                        (context) => [
                      if (!isRead)
                        const PopupMenuItem(
                          value: 'read',
                          child: Text(
                            'Mark as read',
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(
      String type,
      ) {
    switch (type) {
      case 'booking':
        return Icons
            .calendar_month_outlined;

      case 'payment':
        return Icons
            .payments_outlined;

      case 'kyc':
        return Icons
            .verified_user_outlined;

      case 'vehicle':
        return Icons
            .directions_car_outlined;

      default:
        return Icons
            .notifications_none_rounded;
    }
  }

  Color _iconBackground(
      String type,
      ) {
    switch (type) {
      case 'booking':
        return const Color(
          0xFFEFF6FF,
        );

      case 'payment':
        return const Color(
          0xFFECFDF5,
        );

      case 'kyc':
        return const Color(
          0xFFF5F3FF,
        );

      case 'vehicle':
        return const Color(
          0xFFFFF7ED,
        );

      default:
        return const Color(
          0xFFF3F4F6,
        );
    }
  }

  Color _iconColor(
      String type,
      ) {
    switch (type) {
      case 'booking':
        return const Color(
          0xFF2563EB,
        );

      case 'payment':
        return const Color(
          0xFF16A34A,
        );

      case 'kyc':
        return const Color(
          0xFF7C3AED,
        );

      case 'vehicle':
        return const Color(
          0xFFEA580C,
        );

      default:
        return const Color(
          0xFF374151,
        );
    }
  }

  String _formatDate(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return '';
    }

    final date =
    DateTime.tryParse(value);

    if (date == null) {
      return '';
    }

    final local =
    date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}