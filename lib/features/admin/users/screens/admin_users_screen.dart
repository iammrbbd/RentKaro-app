import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({
    super.key,
  });

  @override
  State<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState
    extends State<AdminUsersScreen> {
  // ============================================================
  // CONFIG
  // ============================================================

  static const String baseUrl =
      'https://rentkaro.up.railway.app';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _users = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadUsers();
  }

  // ============================================================
  // LOAD USERS
  // ============================================================

  Future<void> _loadUsers() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token =
      await _storage.read(
        key: 'access_token',
      );

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Authentication token not found. Please login again.',
        );
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/admin/users',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization':
          'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded =
        jsonDecode(response.body);

        List<dynamic> rawUsers = [];

        // --------------------------------------------------------
        // API can return:
        //
        // [ {...}, {...} ]
        //
        // OR
        //
        // { "users": [...] }
        // --------------------------------------------------------

        if (decoded is List) {
          rawUsers = decoded;
        } else if (decoded
        is Map<String, dynamic>) {
          final users =
          decoded['users'];

          if (users is List) {
            rawUsers = users;
          } else {
            // Try common alternative keys.
            final data =
            decoded['data'];

            if (data is List) {
              rawUsers = data;
            }
          }
        }

        final parsedUsers =
        rawUsers
            .whereType<Map>()
            .map(
              (user) =>
          Map<String, dynamic>.from(
            user,
          ),
        )
            .toList();

        if (!mounted) {
          return;
        }

        setState(() {
          _users = parsedUsers;
          _isLoading = false;
        });

        return;
      }

      if (response.statusCode == 401) {
        throw Exception(
          'Authentication expired. Please login again.',
        );
      }

      if (response.statusCode == 403) {
        throw Exception(
          'Admin access required.',
        );
      }

      String message =
          'Failed to load users.';

      try {
        final decoded =
        jsonDecode(response.body);

        if (decoded
        is Map<String, dynamic>) {
          final detail =
          decoded['detail'];

          if (detail != null) {
            message =
                detail.toString();
          }
        }
      } catch (_) {}

      throw Exception(
        '$message (${response.statusCode})',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _error = error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  // ============================================================
  // GET USER VALUE
  // ============================================================

  String _value(
      Map<String, dynamic> user,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = user[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return 'Not available';
  }

  // ============================================================
  // USER NAME
  // ============================================================

  String _userName(
      Map<String, dynamic> user,
      ) {
    final name = _value(
      user,
      [
        'name',
        'full_name',
        'username',
      ],
    );

    if (name != 'Not available') {
      return name;
    }

    return 'User';
  }

  // ============================================================
  // USER INITIAL
  // ============================================================

  String _initial(
      String name,
      ) {
    if (name.trim().isEmpty) {
      return 'U';
    }

    return name
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  // ============================================================
  // ROLE
  // ============================================================

  String _role(
      Map<String, dynamic> user,
      ) {
    return _value(
      user,
      [
        'role',
        'user_role',
      ],
    );
  }

  // ============================================================
  // EMAIL
  // ============================================================

  String _email(
      Map<String, dynamic> user,
      ) {
    return _value(
      user,
      [
        'email',
      ],
    );
  }

  // ============================================================
  // PHONE
  // ============================================================

  String _phone(
      Map<String, dynamic> user,
      ) {
    return _value(
      user,
      [
        'phone',
        'phone_number',
        'mobile',
      ],
    );
  }

  // ============================================================
  // USER ID
  // ============================================================

  String _id(
      Map<String, dynamic> user,
      ) {
    return _value(
      user,
      [
        'id',
        'user_id',
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _status(
      Map<String, dynamic> user,
      ) {
    final isActive =
    user['is_active'];

    if (isActive is bool) {
      return isActive
          ? 'Active'
          : 'Inactive';
    }

    final status =
    user['status'];

    if (status != null) {
      return status.toString();
    }

    return 'Active';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FB),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Users',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',

            onPressed:
            _isLoading
                ? null
                : _loadUsers,

            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: _loadUsers,

        child: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading &&
        _users.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: const [
          SizedBox(
            height: 280,
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_error != null &&
        _users.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding:
        const EdgeInsets.all(20),

        children: [
          const SizedBox(height: 100),

          Container(
            padding:
            const EdgeInsets.all(20),

            decoration:
            BoxDecoration(
              color: Colors.white,

              borderRadius:
              BorderRadius.circular(18),

              border: Border.all(
                color:
                const Color(0xFFE5E7EB),
              ),
            ),

            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,

                  alignment:
                  Alignment.center,

                  decoration:
                  const BoxDecoration(
                    color:
                    Color(0xFFFEF2F2),
                    shape:
                    BoxShape.circle,
                  ),

                  child:
                  const Icon(
                    Icons.error_outline,
                    color:
                    Color(0xFFDC2626),
                    size: 30,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(
                  'Unable to load users',

                  style:
                  TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  _error!,

                  textAlign:
                  TextAlign.center,

                  style:
                  const TextStyle(
                    color:
                    Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                ElevatedButton.icon(
                  onPressed:
                  _loadUsers,

                  icon:
                  const Icon(
                    Icons.refresh_rounded,
                  ),

                  label:
                  const Text(
                    'Retry',
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (_users.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [
          const SizedBox(height: 130),

          Icon(
            Icons.people_outline_rounded,
            size: 58,

            color:
            const Color(0xFF9CA3AF),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'No users found',

              style:
              TextStyle(
                color:
                Color(0xFF111827),
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              'There are currently no users in the database.',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                color:
                Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // USERS LIST
    // ----------------------------------------------------------

    return ListView.builder(
      physics:
      const AlwaysScrollableScrollPhysics(),

      padding:
      const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        30,
      ),

      itemCount:
      _users.length + 1,

      itemBuilder:
          (context, index) {
        // ======================================================
        // HEADER
        // ======================================================

        if (index == 0) {
          return Padding(
            padding:
            const EdgeInsets.only(
              bottom: 14,
            ),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'All Users',

                        style:
                        TextStyle(
                          color:
                          Color(0xFF111827),
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        '${_users.length} users found',

                        style:
                        const TextStyle(
                          color:
                          Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(0xFFEFF6FF),

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    _users.length.toString(),

                    style:
                    const TextStyle(
                      color:
                      Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // ======================================================
        // USER CARD
        // ======================================================

        final user =
        _users[index - 1];

        return _UserCard(
          user: user,

          name:
          _userName(user),

          initial:
          _initial(
            _userName(user),
          ),

          id:
          _id(user),

          email:
          _email(user),

          phone:
          _phone(user),

          role:
          _role(user),

          status:
          _status(user),

          onTap: () {
            _showUserDetails(
              context,
              user,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // USER DETAILS
  // ============================================================

  void _showUserDetails(
      BuildContext context,
      Map<String, dynamic> user,
      ) {
    final name =
    _userName(user);

    showModalBottomSheet(
      context: context,

      backgroundColor:
      Colors.transparent,

      isScrollControlled:
      true,

      builder: (context) {
        return Container(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            28,
          ),

          decoration:
          const BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFD1D5DB,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,

                      alignment:
                      Alignment.center,

                      decoration:
                      const BoxDecoration(
                        color:
                        Color(0xFFF3F4F6),
                        shape:
                        BoxShape.circle,
                      ),

                      child: Text(
                        _initial(name),

                        style:
                        const TextStyle(
                          color:
                          Color(0xFF111827),
                          fontSize: 21,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 13,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          Text(
                            name,

                            style:
                            const TextStyle(
                              color:
                              Color(0xFF111827),
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            _role(user),

                            style:
                            const TextStyle(
                              color:
                              Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 22,
                ),

                _DetailRow(
                  icon:
                  Icons.badge_outlined,

                  title: 'User ID',

                  value:
                  _id(user),
                ),

                _DetailRow(
                  icon:
                  Icons.email_outlined,

                  title: 'Email',

                  value:
                  _email(user),
                ),

                _DetailRow(
                  icon:
                  Icons.phone_outlined,

                  title: 'Phone',

                  value:
                  _phone(user),
                ),

                _DetailRow(
                  icon:
                  Icons.person_outline,

                  title: 'Role',

                  value:
                  _role(user),
                ),

                _DetailRow(
                  icon:
                  Icons.circle_outlined,

                  title: 'Status',

                  value:
                  _status(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// USER CARD
// ============================================================================

class _UserCard
    extends StatelessWidget {
  final Map<String, dynamic> user;

  final String name;
  final String initial;
  final String id;
  final String email;
  final String phone;
  final String role;
  final String status;

  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.name,
    required this.initial,
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final isActive =
        status.toLowerCase() ==
            'active';

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Material(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        child: InkWell(
          borderRadius:
          BorderRadius.circular(18),

          onTap: onTap,

          child: Container(
            padding:
            const EdgeInsets.all(15),

            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(18),

              border: Border.all(
                color:
                const Color(0xFFE5E7EB),
              ),
            ),

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // ==================================================
                // AVATAR
                // ==================================================

                Container(
                  width: 48,
                  height: 48,

                  alignment:
                  Alignment.center,

                  decoration:
                  const BoxDecoration(
                    color:
                    Color(0xFFF3F4F6),

                    shape:
                    BoxShape.circle,
                  ),

                  child: Text(
                    initial,

                    style:
                    const TextStyle(
                      color:
                      Color(0xFF111827),
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                // ==================================================
                // USER INFO
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,

                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,

                              style:
                              const TextStyle(
                                color:
                                Color(0xFF111827),
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            decoration:
                            BoxDecoration(
                              color: isActive
                                  ? const Color(
                                0xFFECFDF5,
                              )
                                  : const Color(
                                0xFFFEF2F2,
                              ),

                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                            ),

                            child: Text(
                              status,

                              style:
                              TextStyle(
                                color: isActive
                                    ? const Color(
                                  0xFF16A34A,
                                )
                                    : const Color(
                                  0xFFDC2626,
                                ),

                                fontSize: 9,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        email,

                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        const TextStyle(
                          color:
                          Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        phone,

                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        const TextStyle(
                          color:
                          Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFF3F4F6,
                              ),

                              borderRadius:
                              BorderRadius
                                  .circular(
                                8,
                              ),
                            ),

                            child: Text(
                              role,

                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFF374151,
                                ),

                                fontSize: 9,

                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),

                          const Spacer(),

                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,

                            size: 13,

                            color:
                            Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 19,
            color:
            const Color(0xFF6B7280),
          ),

          const SizedBox(
            width: 11,
          ),

          SizedBox(
            width: 70,

            child: Text(
              title,

              style:
              const TextStyle(
                color:
                Color(0xFF6B7280),
                fontSize: 11,
                fontWeight:
                FontWeight.w600,
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
                color:
                Color(0xFF111827),
                fontSize: 12,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}