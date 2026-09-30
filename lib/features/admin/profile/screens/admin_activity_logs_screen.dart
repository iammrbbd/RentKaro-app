import 'package:flutter/material.dart';

class AdminActivityLogsScreen
    extends StatelessWidget {
  const AdminActivityLogsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final logs = [
      _ActivityLog(
        icon: Icons.login_rounded,
        title: 'Admin Login',
        description:
        'Administrator logged into the RentKaro admin panel.',
        time: 'Current session',
      ),
      _ActivityLog(
        icon:
        Icons.dashboard_outlined,
        title: 'Dashboard Opened',
        description:
        'Administrator opened the admin dashboard.',
        time: 'Current session',
      ),
      _ActivityLog(
        icon:
        Icons.verified_user_outlined,
        title: 'Host KYC Section',
        description:
        'Host KYC management section was opened.',
        time: 'Recent',
      ),
      _ActivityLog(
        icon:
        Icons.directions_car_outlined,
        title: 'Vehicle Approval Section',
        description:
        'Vehicle approval management section was opened.',
        time: 'Recent',
      ),
      _ActivityLog(
        icon: Icons.people_outline,
        title: 'Users Section',
        description:
        'User management section was opened.',
        time: 'Recent',
      ),
    ];

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF8FAFC),
        foregroundColor:
        const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'Activity Logs',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView.separated(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            30,
          ),
          itemCount: logs.length,
          separatorBuilder:
              (_, __) =>
          const SizedBox(height: 10),
          itemBuilder: (
              context,
              index,
              ) {
            final log = logs[index];

            return Container(
              padding:
              const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(17),
                border: Border.all(
                  color:
                  const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    alignment:
                    Alignment.center,
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFF3F4F6),
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: Icon(
                      log.icon,
                      color:
                      const Color(0xFF374151),
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          log.title,
                          style:
                          const TextStyle(
                            color:
                            Color(0xFF111827),
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          log.description,
                          style:
                          const TextStyle(
                            color:
                            Color(0xFF6B7280),
                            fontSize: 10,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          log.time,
                          style:
                          const TextStyle(
                            color:
                            Color(0xFF9CA3AF),
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityLog {
  final IconData icon;
  final String title;
  final String description;
  final String time;

  const _ActivityLog({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });
}