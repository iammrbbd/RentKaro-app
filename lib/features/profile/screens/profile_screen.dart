import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../bookings/screens/bookings_screen.dart';

class ProfileScreen extends ConsumerWidget {
const ProfileScreen({super.key});

static const FlutterSecureStorage _storage =
FlutterSecureStorage();

Future<void> _logout(
BuildContext context,
WidgetRef ref,
) async {
final shouldLogout = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text(
'Logout',
),
content: const Text(
'Are you sure you want to logout?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
false,
);
},
child: const Text(
'Cancel',
),
),
TextButton(
onPressed: () {
Navigator.pop(
dialogContext,
true,
);
},
child: const Text(
'Logout',
style: TextStyle(
color: Color(0xFFDC2626),
),
),
),
],
);
},
);

if (shouldLogout != true) {
return;
}

await _storage.delete(
key: 'access_token',
);

ref.read(
authUserProvider.notifier,
).state = null;

if (!context.mounted) {
return;
}

context.go('/login');
}

@override
Widget build(
BuildContext context,
WidgetRef ref,
) {
final user = ref.watch(
authUserProvider,
);

final userName =
user?.name.trim().isNotEmpty == true
? user!.name
    : 'RentKaro User';

final firstLetter =
userName.isNotEmpty
? userName[0].toUpperCase()
    : 'R';

return Scaffold(
backgroundColor:
const Color(0xFFF8FAFC),

appBar: AppBar(
backgroundColor:
const Color(0xFFF8FAFC),
elevation: 0,
automaticallyImplyLeading: false,
title: const Text(
'Profile',
style: TextStyle(
color: Color(0xFF111827),
fontSize: 22,
fontWeight: FontWeight.w700,
),
),
),

body: SafeArea(
top: false,
child: SingleChildScrollView(
padding:
const EdgeInsets.fromLTRB(
14,
20,
14,
24,
),
child: Column(
children: [
// ==========================================
// PROFILE CARD
// ==========================================

Container(
width: double.infinity,
padding:
const EdgeInsets.symmetric(
vertical: 18,
horizontal: 20,
),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
18,
),
boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.06),
blurRadius: 20,
offset:
const Offset(
0,
6,
),
),
],
),
child: Column(
children: [
// AVATAR

Container(
height: 64,
width: 64,
alignment:
Alignment.center,
decoration:
const BoxDecoration(
shape: BoxShape.circle,
gradient:
LinearGradient(
colors: [
Color(
0xFF1E4FA3,
),
Color(
0xFF3B73D1,
),
],
),
),
child: Text(
firstLetter,
style:
const TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight:
FontWeight.w700,
),
),
),

const SizedBox(
height: 10,
),

// NAME

Text(
userName,
style:
const TextStyle(
color:
Color(0xFF1F2937),
fontSize: 16,
fontWeight:
FontWeight.w700,
),
),

const SizedBox(
height: 6,
),

// ROLE

Text(
(user?.role ??
'customer')
    .toUpperCase(),
style:
const TextStyle(
color:
Color(0xFF2563EB),
fontSize: 10,
fontWeight:
FontWeight.w700,
letterSpacing: 0.4,
),
),
],
),
),

const SizedBox(
height: 16,
),

// ==========================================
// PERSONAL INFORMATION
// ==========================================

_ProfileMenuItem(
icon:
Icons.person_outline_rounded,
title:
'Personal Information',
subtitle:
'View your account details',
onTap: () {
context.push(
'/profile/personal-information',
);
},
),

const SizedBox(
height: 10,
),

// ==========================================
// KYC VERIFICATION
// ==========================================

_ProfileMenuItem(
icon:
Icons.verified_user_outlined,
title:
'KYC Verification',
subtitle:
'Verify your identity and driving licence',
onTap: () {
context.push('/kyc');
},
),

const SizedBox(
height: 10,
),

// ==========================================
// MY BOOKINGS
// ==========================================

_ProfileMenuItem(
icon:
Icons.receipt_long_outlined,
title:
'My Bookings',
subtitle:
'View your booking history',
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const BookingsScreen(),
),
);
},
),

const SizedBox(
height: 10,
),

// ==========================================
// FAVORITES
// ==========================================

_ProfileMenuItem(
icon:
Icons.favorite_border_rounded,
title:
'Favorites',
subtitle:
'Your saved vehicles',
onTap: () {
context.push('/favorites');
},
),

const SizedBox(
height: 10,
),

// ==========================================
// HELP & SUPPORT
// ==========================================

_ProfileMenuItem(
icon:
Icons.help_outline_rounded,
title:
'Help & Support',
subtitle:
'Get help with RentKaro',
onTap: () {
ScaffoldMessenger.of(
context,
).showSnackBar(
const SnackBar(
content: Text(
'Help & Support coming soon.',
),
),
);
},
),

const SizedBox(
height: 26,
),

// ==========================================
// LOGOUT BUTTON
// ==========================================

SizedBox(
width: double.infinity,
height: 52,
child: OutlinedButton.icon(
onPressed: () {
_logout(
context,
ref,
);
},
icon: const Icon(
Icons.logout_rounded,
size: 18,
),
label: const Text(
'Logout',
style: TextStyle(
fontSize: 14,
fontWeight:
FontWeight.w600,
),
),
style:
OutlinedButton.styleFrom(
foregroundColor:
const Color(
0xFFDC2626,
),
side:
const BorderSide(
color:
Color(0xFFDC2626),
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
10,
),
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

// ==========================================================
// PROFILE MENU ITEM
// ==========================================================

class _ProfileMenuItem
extends StatelessWidget {
final IconData icon;
final String title;
final String subtitle;
final VoidCallback onTap;

const _ProfileMenuItem({
required this.icon,
required this.title,
required this.subtitle,
required this.onTap,
});

@override
Widget build(
BuildContext context,
) {
return Material(
color: Colors.transparent,
child: InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(
14,
),
child: Ink(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 12,
),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
14,
),
boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.025),
blurRadius: 12,
offset:
const Offset(
0,
4,
),
),
],
),
child: Row(
children: [
// ICON

Container(
height: 42,
width: 42,
decoration:
BoxDecoration(
color:
const Color(
0xFFF1F5F9,
),
borderRadius:
BorderRadius.circular(
12,
),
),
child: Icon(
icon,
color:
const Color(
0xFF2563EB,
),
size: 21,
),
),

const SizedBox(
width: 12,
),

// TEXT

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
Color(0xFF1F2937),
fontSize: 14,
fontWeight:
FontWeight.w600,
),
),

const SizedBox(
height: 3,
),

Text(
subtitle,
style:
const TextStyle(
color:
Color(0xFF6B7280),
fontSize: 11,
),
),
],
),
),

const Icon(
Icons
    .chevron_right_rounded,
color:
Color(0xFF94A3B8),
size: 20,
),
],
),
),
),
);
}
}
