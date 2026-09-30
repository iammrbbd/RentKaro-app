import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../auth/services/auth_service.dart';

class EditHostProfileScreen extends ConsumerStatefulWidget {
const EditHostProfileScreen({super.key});

@override
ConsumerState<EditHostProfileScreen> createState() =>
_EditHostProfileScreenState();
}

class _EditHostProfileScreenState
extends ConsumerState<EditHostProfileScreen> {
final _formKey = GlobalKey<FormState>();

late final TextEditingController _nameController;
late final TextEditingController _phoneController;
late final TextEditingController _emailController;

bool _isSaving = false;

@override
void initState() {
super.initState();

final user = ref.read(authUserProvider);

_nameController = TextEditingController(
text: user?.name ?? '',
);

_phoneController = TextEditingController(
text: user?.phone ?? '',
);

_emailController = TextEditingController(
text: user?.email ?? '',
);
}

@override
void dispose() {
_nameController.dispose();
_phoneController.dispose();
_emailController.dispose();

super.dispose();
}

// ==========================================================
// SAVE PROFILE
// ==========================================================

Future<void> _saveProfile() async {
FocusScope.of(context).unfocus();

if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
_isSaving = true;
});

try {
final authService = ref.read(authServiceProvider);

final updatedUser = await authService.updateProfile(
name: _nameController.text.trim(),
phone: _phoneController.text.trim(),
email: _emailController.text.trim().isEmpty
? null
    : _emailController.text.trim(),
);

if (!mounted) return;

// Update Riverpod user state immediately.
ref.read(authUserProvider.notifier).state = updatedUser;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Profile updated successfully',
),
behavior: SnackBarBehavior.floating,
),
);

context.pop();
} catch (error) {
if (!mounted) return;

String message = error.toString();

if (message.startsWith('Exception: ')) {
message = message.substring(11);
}

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
),
);
} finally {
if (!mounted) return;

setState(() {
_isSaving = false;
});
}
}

// ==========================================================
// NAME VALIDATION
// ==========================================================

String? _validateName(String? value) {
final name = value?.trim() ?? '';

if (name.isEmpty) {
return 'Please enter your name';
}

if (name.length < 2) {
return 'Name must contain at least 2 characters';
}

return null;
}

// ==========================================================
// PHONE VALIDATION
// ==========================================================

String? _validatePhone(String? value) {
final phone = value?.trim() ?? '';

if (phone.isEmpty) {
return 'Please enter your phone number';
}

if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
return 'Enter a valid 10-digit phone number';
}

return null;
}

// ==========================================================
// EMAIL VALIDATION
// ==========================================================

String? _validateEmail(String? value) {
final email = value?.trim() ?? '';

// Email is optional.
if (email.isEmpty) {
return null;
}

final emailRegex = RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
);

if (!emailRegex.hasMatch(email)) {
return 'Enter a valid email address';
}

return null;
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Scaffold(
appBar: AppBar(
title: const Text(
'Edit Profile',
style: TextStyle(
fontWeight: FontWeight.w700,
),
),
centerTitle: true,
),

body: SafeArea(
child: Form(
key: _formKey,
child: SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(
20,
20,
20,
32,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// HEADER
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: colorScheme.primaryContainer,
borderRadius: BorderRadius.circular(20),
),
child: Row(
children: [
Container(
width: 54,
height: 54,
decoration: BoxDecoration(
color: colorScheme.primary,
shape: BoxShape.circle,
),
child: Icon(
Icons.person_outline_rounded,
color: colorScheme.onPrimary,
size: 28,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Personal Information',
style: theme.textTheme.titleMedium
    ?.copyWith(
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
'Update your host account details',
style: theme.textTheme.bodySmall,
),
],
),
),
],
),
),

const SizedBox(height: 28),

// ==================================================
// NAME
// ==================================================

Text(
'Full Name',
style: theme.textTheme.titleSmall?.copyWith(
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 8),

TextFormField(
controller: _nameController,
textInputAction: TextInputAction.next,
keyboardType: TextInputType.name,
textCapitalization: TextCapitalization.words,
validator: _validateName,
decoration: InputDecoration(
hintText: 'Enter your full name',
prefixIcon: const Icon(
Icons.person_outline_rounded,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide(
color: colorScheme.primary,
width: 2,
),
),
),
),

const SizedBox(height: 20),

// ==================================================
// PHONE
// ==================================================

Text(
'Phone Number',
style: theme.textTheme.titleSmall?.copyWith(
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 8),

TextFormField(
controller: _phoneController,
textInputAction: TextInputAction.next,
keyboardType: TextInputType.phone,
maxLength: 10,
validator: _validatePhone,
decoration: InputDecoration(
counterText: '',
hintText: 'Enter 10-digit phone number',
prefixIcon: const Icon(
Icons.phone_outlined,
),
prefixText: '+91 ',
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide(
color: colorScheme.primary,
width: 2,
),
),
),
),

const SizedBox(height: 20),

// ==================================================
// EMAIL
// ==================================================

Text(
'Email Address',
style: theme.textTheme.titleSmall?.copyWith(
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 8),

TextFormField(
controller: _emailController,
textInputAction: TextInputAction.done,
keyboardType: TextInputType.emailAddress,
validator: _validateEmail,
onFieldSubmitted: (_) {
if (!_isSaving) {
_saveProfile();
}
},
decoration: InputDecoration(
hintText: 'Enter your email address',
helperText: 'Email is optional',
prefixIcon: const Icon(
Icons.email_outlined,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide(
color: colorScheme.primary,
width: 2,
),
),
),
),

const SizedBox(height: 30),

// ==================================================
// INFORMATION CARD
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: colorScheme.surfaceContainerHighest,
borderRadius: BorderRadius.circular(16),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.info_outline_rounded,
color: colorScheme.primary,
),

const SizedBox(width: 12),

Expanded(
child: Text(
'Make sure your phone number and email '
'address are correct. These details may '
'be used for important RentKaro account '
'communication.',
style: theme.textTheme.bodySmall?.copyWith(
height: 1.45,
),
),
),
],
),
),

const SizedBox(height: 30),

// ==================================================
// SAVE BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 54,
child: FilledButton(
onPressed: _isSaving
? null
    : _saveProfile,
style: FilledButton.styleFrom(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
child: _isSaving
? const SizedBox(
width: 23,
height: 23,
child: CircularProgressIndicator(
strokeWidth: 2.5,
),
)
    : const Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.save_outlined,
),
SizedBox(width: 8),
Text(
'Save Changes',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w700,
),
),
],
),
),
),

const SizedBox(height: 12),

// ==================================================
// CANCEL BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 52,
child: TextButton(
onPressed: _isSaving
? null
    : () => context.pop(),
child: const Text(
'Cancel',
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
),
),
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
// ```
//
// ### `app_router.dart` me ye route hona chahiye
//
// Import:
//
// ```dart
// import '../../features/host/profile/screens/edit_host_profile_screen.dart';
// ```
//
// Routes ke andar:
//
// ```dart
// GoRoute(
// path: '/host/edit-profile',
// builder: (context, state) {
// return const EditHostProfileScreen();
// },
// ),
// ```
//
// Bas. Ab flow:
//
// **Host Profile → Edit Profile → details change → Save Changes → `/api/auth/profile` → Riverpod user update → wapas Host Profile**
//
// Aur `context.pop()` previous profile screen par return karega.
