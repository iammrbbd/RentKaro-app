import 'package:flutter/material.dart';

class AdminNotificationsScreen
    extends StatefulWidget {
  const AdminNotificationsScreen({
    super.key,
  });

  @override
  State<AdminNotificationsScreen>
  createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {
  bool newUserNotifications = true;
  bool kycNotifications = true;
  bool vehicleNotifications = true;
  bool bookingNotifications = true;
  bool paymentNotifications = true;
  bool systemNotifications = true;

  @override
  Widget build(BuildContext context) {
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
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            30,
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color:
                    const Color(0xFFE5E7EB),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor:
                      Color(0xFFFFF7ED),
                      child: Icon(
                        Icons
                            .notifications_none_outlined,
                        color:
                        Color(0xFFEA580C),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Settings',
                            style: TextStyle(
                              color:
                              Color(0xFF111827),
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose which admin alerts you want to receive.',
                            style: TextStyle(
                              color:
                              Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _NotificationTile(
                icon: Icons.person_add_outlined,
                title: 'New Users',
                subtitle:
                'Receive alerts when a new user registers.',
                value: newUserNotifications,
                onChanged: (value) {
                  setState(() {
                    newUserNotifications =
                        value;
                  });
                },
              ),

              _NotificationTile(
                icon:
                Icons.verified_user_outlined,
                title: 'Host KYC',
                subtitle:
                'Receive alerts for new KYC submissions.',
                value: kycNotifications,
                onChanged: (value) {
                  setState(() {
                    kycNotifications = value;
                  });
                },
              ),

              _NotificationTile(
                icon:
                Icons.directions_car_outlined,
                title: 'Vehicle Approvals',
                subtitle:
                'Receive alerts for vehicle submissions.',
                value: vehicleNotifications,
                onChanged: (value) {
                  setState(() {
                    vehicleNotifications =
                        value;
                  });
                },
              ),

              _NotificationTile(
                icon:
                Icons.book_online_outlined,
                title: 'Bookings',
                subtitle:
                'Receive important booking alerts.',
                value: bookingNotifications,
                onChanged: (value) {
                  setState(() {
                    bookingNotifications =
                        value;
                  });
                },
              ),

              _NotificationTile(
                icon: Icons.payments_outlined,
                title: 'Payments',
                subtitle:
                'Receive payment related alerts.',
                value: paymentNotifications,
                onChanged: (value) {
                  setState(() {
                    paymentNotifications =
                        value;
                  });
                },
              ),

              _NotificationTile(
                icon:
                Icons.settings_outlined,
                title: 'System',
                subtitle:
                'Receive important system alerts.',
                value: systemNotifications,
                onChanged: (value) {
                  setState(() {
                    systemNotifications =
                        value;
                  });
                },
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notification preferences saved.',
                        ),
                        behavior:
                        SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF111827),
                    foregroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
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
}

class _NotificationTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
              const Color(0xFFF3F4F6),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 21,
              color:
              const Color(0xFF374151),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF6B7280),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}