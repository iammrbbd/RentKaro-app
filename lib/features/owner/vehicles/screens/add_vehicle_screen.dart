// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../data/cloudinary_upload_service.dart';
// import '../models/owner_vehicle.dart';
// import '../providers/owner_vehicle_provider.dart';
//
// class AddVehicleScreen extends ConsumerStatefulWidget {
//   const AddVehicleScreen({
//     super.key,
//     this.vehicleId,
//   });
//
//   final int? vehicleId;
//
//   bool get isEditMode => vehicleId != null;
//
//   @override
//   ConsumerState<AddVehicleScreen> createState() =>
//       _AddVehicleScreenState();
// }
//
// class _AddVehicleScreenState
//     extends ConsumerState<AddVehicleScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   // ==========================================================
//   // CONTROLLERS
//   // ==========================================================
//
//   final _brandController = TextEditingController();
//   final _modelController = TextEditingController();
//   final _registrationController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _hourlyController = TextEditingController();
//   final _twelveHourController = TextEditingController();
//   final _dailyController = TextEditingController();
//   final _depositController = TextEditingController();
//
//   final _cityController = TextEditingController(
//     text: 'Vadodara',
//   );
//
//   final _areaController = TextEditingController();
//   final _seatsController = TextEditingController();
//
//   // ==========================================================
//   // DROPDOWN VALUES
//   // ==========================================================
//
//   String _vehicleType = 'car';
//   String _category = 'suv';
//   String _fuelType = 'petrol';
//   String _transmission = 'manual';
//
//   // ==========================================================
//   // IMAGES
//   // ==========================================================
//
//   /// Existing images / Cloudinary URLs.
//   List<String> _images = [];
//
//   /// Newly selected local images.
//   final List<File> _newImages = [];
//
//   final ImagePicker _imagePicker = ImagePicker();
//
//   // ==========================================================
//   // LOADING
//   // ==========================================================
//
//   bool _isLoadingVehicle = false;
//   bool _isSubmitting = false;
//   bool _isUploadingImages = false;
//
//   int _uploadedImageCount = 0;
//
//   OwnerVehicle? _existingVehicle;
//
//   // ==========================================================
//   // INIT
//   // ==========================================================
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.isEditMode) {
//       _loadVehicle();
//     }
//   }
//
//   // ==========================================================
//   // LOAD EXISTING VEHICLE
//   // ==========================================================
//
//   Future<void> _loadVehicle() async {
//     final vehicleId = widget.vehicleId;
//
//     if (vehicleId == null) {
//       return;
//     }
//
//     setState(() {
//       _isLoadingVehicle = true;
//     });
//
//     try {
//       final vehicle = await ref
//           .read(ownerVehiclesProvider.notifier)
//           .getVehicle(vehicleId);
//
//       if (!mounted) {
//         return;
//       }
//
//       if (vehicle == null) {
//         throw Exception(
//           'Unable to load vehicle details.',
//         );
//       }
//
//       _existingVehicle = vehicle;
//
//       _fillForm(vehicle);
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }
//
//       _showError(error);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingVehicle = false;
//         });
//       }
//     }
//   }
//
//   // ==========================================================
//   // FILL FORM
//   // ==========================================================
//
//   void _fillForm(OwnerVehicle vehicle) {
//     _brandController.text = vehicle.brand;
//     _modelController.text = vehicle.model;
//
//     _registrationController.text =
//         vehicle.registrationNumber;
//
//     _descriptionController.text =
//         vehicle.description ?? '';
//
//     _hourlyController.text =
//         _numberText(vehicle.hourlyPrice);
//
//     _twelveHourController.text =
//     vehicle.twelveHourPrice == null
//         ? ''
//         : _numberText(
//       vehicle.twelveHourPrice!,
//     );
//
//     _dailyController.text =
//         _numberText(vehicle.dailyPrice);
//
//     _depositController.text =
//         _numberText(
//           vehicle.securityDeposit,
//         );
//
//     _cityController.text = vehicle.city;
//     _areaController.text = vehicle.area;
//
//     _seatsController.text =
//         vehicle.seats?.toString() ?? '';
//
//     _vehicleType = _safeValue(
//       vehicle.vehicleType,
//       const [
//         'car',
//         'bike',
//         'scooter',
//       ],
//       'car',
//     );
//
//     _category = _safeValue(
//       vehicle.category,
//       const [
//         'suv',
//         'sedan',
//         'hatchback',
//         'luxury',
//         'bike',
//         'scooter',
//       ],
//       'suv',
//     );
//
//     _fuelType = _safeValue(
//       vehicle.fuelType,
//       const [
//         'petrol',
//         'diesel',
//         'cng',
//         'electric',
//       ],
//       'petrol',
//     );
//
//     _transmission = _safeValue(
//       vehicle.transmission,
//       const [
//         'manual',
//         'automatic',
//       ],
//       'manual',
//     );
//
//     _images = List<String>.from(
//       vehicle.images,
//     );
//
//     setState(() {});
//   }
//
//   // ==========================================================
//   // SAFE DROPDOWN VALUE
//   // ==========================================================
//
//   String _safeValue(
//       String? value,
//       List<String> allowed,
//       String fallback,
//       ) {
//     if (value != null &&
//         allowed.contains(
//           value.toLowerCase(),
//         )) {
//       return value.toLowerCase();
//     }
//
//     return fallback;
//   }
//
//   // ==========================================================
//   // NUMBER FORMAT
//   // ==========================================================
//
//   String _numberText(double value) {
//     if (value == value.roundToDouble()) {
//       return value
//           .toInt()
//           .toString();
//     }
//
//     return value.toString();
//   }
//
//   // ==========================================================
//   // IMAGE PICKER
//   // ==========================================================
//
//   Future<void> _showImageSourcePicker() async {
//     if (_isSubmitting ||
//         _isUploadingImages) {
//       return;
//     }
//
//     if (_images.length +
//         _newImages.length >=
//         10) {
//       _showError(
//         Exception(
//           'Maximum 10 vehicle images are allowed.',
//         ),
//       );
//       return;
//     }
//
//     await showModalBottomSheet<void>(
//       context: context,
//       builder: (sheetContext) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.fromLTRB(
//                   20,
//                   18,
//                   20,
//                   8,
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Add Vehicle Photo',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ),
//
//               ListTile(
//                 leading: const CircleAvatar(
//                   child: Icon(
//                     Icons.photo_library_outlined,
//                   ),
//                 ),
//                 title: const Text(
//                   'Choose from Gallery',
//                 ),
//                 subtitle: const Text(
//                   'Select multiple photos',
//                 ),
//                 onTap: () {
//                   Navigator.pop(sheetContext);
//                   _pickImages();
//                 },
//               ),
//
//               ListTile(
//                 leading: const CircleAvatar(
//                   child: Icon(
//                     Icons.camera_alt_outlined,
//                   ),
//                 ),
//                 title: const Text(
//                   'Take Photo',
//                 ),
//                 subtitle: const Text(
//                   'Use your camera',
//                 ),
//                 onTap: () {
//                   Navigator.pop(sheetContext);
//                   _takePhoto();
//                 },
//               ),
//
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ==========================================================
//   // PICK MULTIPLE IMAGES
//   // ==========================================================
//
//   Future<void> _pickImages() async {
//     if (_isSubmitting ||
//         _isUploadingImages) {
//       return;
//     }
//
//     try {
//       final selectedImages =
//       await _imagePicker.pickMultiImage(
//         imageQuality: 80,
//         maxWidth: 1920,
//         maxHeight: 1920,
//       );
//
//       if (selectedImages.isEmpty) {
//         return;
//       }
//
//       final currentCount =
//           _images.length +
//               _newImages.length;
//
//       final remainingSlots =
//           10 - currentCount;
//
//       if (remainingSlots <= 0) {
//         _showError(
//           Exception(
//             'Maximum 10 vehicle images are allowed.',
//           ),
//         );
//         return;
//       }
//
//       final files = selectedImages
//           .take(remainingSlots)
//           .map(
//             (image) => File(image.path),
//       )
//           .toList();
//
//       setState(() {
//         _newImages.addAll(files);
//       });
//
//       if (selectedImages.length >
//           remainingSlots) {
//         _showError(
//           Exception(
//             'Only $remainingSlots more images can be added.',
//           ),
//         );
//       }
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }
//
//       _showError(error);
//     }
//   }
//
//   // ==========================================================
//   // CAMERA
//   // ==========================================================
//
//   Future<void> _takePhoto() async {
//     if (_isSubmitting ||
//         _isUploadingImages) {
//       return;
//     }
//
//     if (_images.length +
//         _newImages.length >=
//         10) {
//       _showError(
//         Exception(
//           'Maximum 10 vehicle images are allowed.',
//         ),
//       );
//       return;
//     }
//
//     try {
//       final image =
//       await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//         maxWidth: 1920,
//         maxHeight: 1920,
//       );
//
//       if (image == null) {
//         return;
//       }
//
//       setState(() {
//         _newImages.add(
//           File(image.path),
//         );
//       });
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }
//
//       _showError(error);
//     }
//   }
//
//   // ==========================================================
//   // REMOVE EXISTING IMAGE
//   // ==========================================================
//
//   void _removeExistingImage(int index) {
//     if (index < 0 ||
//         index >= _images.length) {
//       return;
//     }
//
//     setState(() {
//       _images.removeAt(index);
//     });
//   }
//
//   // ==========================================================
//   // REMOVE NEW IMAGE
//   // ==========================================================
//
//   void _removeNewImage(int index) {
//     if (index < 0 ||
//         index >= _newImages.length) {
//       return;
//     }
//
//     setState(() {
//       _newImages.removeAt(index);
//     });
//   }
//
//   // ==========================================================
//   // VALIDATORS
//   // ==========================================================
//
//   String? _requiredValidator(
//       String? value,
//       String field,
//       ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return '$field is required';
//     }
//
//     return null;
//   }
//
//   String? _positiveNumberValidator(
//       String? value,
//       String field,
//       ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return '$field is required';
//     }
//
//     final number = double.tryParse(
//       value.trim(),
//     );
//
//     if (number == null ||
//         number <= 0) {
//       return 'Enter a valid $field';
//     }
//
//     return null;
//   }
//
//   String? _optionalPositiveNumberValidator(
//       String? value,
//       String field,
//       ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return null;
//     }
//
//     final number = double.tryParse(
//       value.trim(),
//     );
//
//     if (number == null ||
//         number <= 0) {
//       return 'Enter a valid $field';
//     }
//
//     return null;
//   }
//
//   String? _seatsValidator(
//       String? value,
//       ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'Seats are required';
//     }
//
//     final seats = int.tryParse(
//       value.trim(),
//     );
//
//     if (seats == null ||
//         seats <= 0) {
//       return 'Enter valid seats';
//     }
//
//     if (seats > 100) {
//       return 'Enter realistic seat count';
//     }
//
//     return null;
//   }
//
//   String? _registrationValidator(
//       String? value,
//       ) {
//     if (value == null ||
//         value.trim().isEmpty) {
//       return 'Registration number is required';
//     }
//
//     if (value.trim().length < 4) {
//       return 'Enter a valid registration number';
//     }
//
//     return null;
//   }
//
//   // ==========================================================
//   // UPLOAD NEW IMAGES
//   // ==========================================================
//
//   Future<void> _uploadNewImages(
//       String registrationNumber,
//       ) async {
//     if (_newImages.isEmpty) {
//       return;
//     }
//
//     setState(() {
//       _isUploadingImages = true;
//       _uploadedImageCount = 0;
//     });
//
//     final cloudinaryService =
//     CloudinaryUploadService();
//
//     final folder =
//         'rentkaro/vehicles/$registrationNumber';
//
//     try {
//       for (final file in _newImages) {
//         final imageUrl =
//         await cloudinaryService.uploadImage(
//           file: file,
//           folder: folder,
//         );
//
//         _images.add(imageUrl);
//
//         if (mounted) {
//           setState(() {
//             _uploadedImageCount++;
//           });
//         }
//       }
//
//       _newImages.clear();
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploadingImages = false;
//         });
//       }
//     }
//   }
//
//   // ==========================================================
//   // SUBMIT
//   // ==========================================================
//
//   Future<void> _submit() async {
//     FocusScope.of(context).unfocus();
//
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     if (_images.isEmpty &&
//         _newImages.isEmpty) {
//       _showError(
//         Exception(
//           'Please add at least one vehicle photo.',
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     try {
//       final brand =
//       _brandController.text.trim();
//
//       final model =
//       _modelController.text.trim();
//
//       final registrationNumber =
//       _registrationController.text
//           .trim()
//           .toUpperCase();
//
//       final description =
//       _descriptionController.text
//           .trim();
//
//       final hourlyPrice =
//       double.parse(
//         _hourlyController.text.trim(),
//       );
//
//       final twelveHourText =
//       _twelveHourController.text.trim();
//
//       final twelveHourPrice =
//       twelveHourText.isEmpty
//           ? null
//           : double.parse(
//         twelveHourText,
//       );
//
//       final dailyPrice =
//       double.parse(
//         _dailyController.text.trim(),
//       );
//
//       final securityDeposit =
//       double.parse(
//         _depositController.text.trim(),
//       );
//
//       final city =
//       _cityController.text.trim();
//
//       final area =
//       _areaController.text.trim();
//
//       final seats =
//       int.parse(
//         _seatsController.text.trim(),
//       );
//
//       // ========================================================
//       // CLOUDINARY UPLOAD
//       // ========================================================
//
//       if (_newImages.isNotEmpty) {
//         await _uploadNewImages(
//           registrationNumber,
//         );
//       }
//
//       if (_images.isEmpty) {
//         throw Exception(
//           'No vehicle image is available.',
//         );
//       }
//
//       // ========================================================
//       // PROVIDER
//       // ========================================================
//
//       final notifier =
//       ref.read(
//         ownerVehiclesProvider.notifier,
//       );
//
//       OwnerVehicle? vehicle;
//
//       // ========================================================
//       // EDIT
//       // ========================================================
//
//       if (widget.isEditMode) {
//         vehicle =
//         await notifier.updateVehicle(
//           vehicleId:
//           widget.vehicleId!,
//
//           brand: brand,
//
//           model: model,
//
//           vehicleType:
//           _vehicleType,
//
//           category:
//           _category,
//
//           registrationNumber:
//           registrationNumber,
//
//           description:
//           description.isEmpty
//               ? null
//               : description,
//
//           hourlyPrice:
//           hourlyPrice,
//
//           twelveHourPrice:
//           twelveHourPrice,
//
//           dailyPrice:
//           dailyPrice,
//
//           securityDeposit:
//           securityDeposit,
//
//           city: city,
//
//           area: area,
//
//           latitude:
//           _existingVehicle?.latitude,
//
//           longitude:
//           _existingVehicle?.longitude,
//
//           images:
//           _images,
//
//           seats:
//           seats,
//
//           fuelType:
//           _fuelType,
//
//           transmission:
//           _transmission,
//         );
//       }
//
//       // ========================================================
//       // ADD
//       // ========================================================
//
//       else {
//         vehicle =
//         await notifier.addVehicle(
//           brand: brand,
//
//           model: model,
//
//           vehicleType:
//           _vehicleType,
//
//           category:
//           _category,
//
//           registrationNumber:
//           registrationNumber,
//
//           description:
//           description.isEmpty
//               ? null
//               : description,
//
//           hourlyPrice:
//           hourlyPrice,
//
//           twelveHourPrice:
//           twelveHourPrice,
//
//           dailyPrice:
//           dailyPrice,
//
//           securityDeposit:
//           securityDeposit,
//
//           city: city,
//
//           area: area,
//
//           images:
//           _images,
//
//           seats:
//           seats,
//
//           fuelType:
//           _fuelType,
//
//           transmission:
//           _transmission,
//         );
//       }
//
//       if (!mounted) {
//         return;
//       }
//
//       // ========================================================
//       // PROVIDER ERROR
//       // ========================================================
//
//       if (vehicle == null) {
//         final currentState =
//         ref.read(
//           ownerVehiclesProvider,
//         );
//
//         final error =
//             currentState.error;
//
//         throw Exception(
//           error
//               ?.toString()
//               .replaceFirst(
//             'Exception: ',
//             '',
//           ) ??
//               (
//                   widget.isEditMode
//                       ? 'Unable to update vehicle.'
//                       : 'Unable to add vehicle.'
//               ),
//         );
//       }
//
//       // ========================================================
//       // SUCCESS
//       // ========================================================
//
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(
//         SnackBar(
//           content: Text(
//             widget.isEditMode
//                 ? 'Vehicle updated successfully.'
//                 : 'Vehicle added successfully. '
//                 'Waiting for admin approval.',
//           ),
//           behavior:
//           SnackBarBehavior.floating,
//         ),
//       );
//
//       context.pop();
//     } catch (error) {
//       if (!mounted) {
//         return;
//       }
//
//       _showError(error);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//           _isUploadingImages = false;
//         });
//       }
//     }
//   }
//
//   // ==========================================================
//   // ERROR
//   // ==========================================================
//
//   void _showError(
//       Object error,
//       ) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(
//       SnackBar(
//         content: Text(
//           error
//               .toString()
//               .replaceFirst(
//             'Exception: ',
//             '',
//           ),
//         ),
//         backgroundColor:
//         const Color(0xFFDC2626),
//         behavior:
//         SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   // ==========================================================
//   // BUILD
//   // ==========================================================
//
//   @override
//   Widget build(
//       BuildContext context,
//       ) {
//     if (_isLoadingVehicle) {
//       return Scaffold(
//         backgroundColor:
//         const Color(0xFFF8FAFC),
//         appBar: AppBar(
//           backgroundColor:
//           const Color(0xFFF8FAFC),
//           elevation: 0,
//           title: const Text(
//             'Edit Vehicle',
//           ),
//         ),
//         body: const Center(
//           child:
//           CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     final isEdit =
//         widget.isEditMode;
//
//     return Scaffold(
//       backgroundColor:
//       const Color(0xFFF8FAFC),
//
//       appBar: AppBar(
//         backgroundColor:
//         const Color(0xFFF8FAFC),
//         surfaceTintColor:
//         Colors.transparent,
//         elevation: 0,
//
//         title: Text(
//           isEdit
//               ? 'Edit Vehicle'
//               : 'Add Vehicle',
//           style:
//           const TextStyle(
//             color:
//             Color(0xFF111827),
//             fontSize: 21,
//             fontWeight:
//             FontWeight.w800,
//           ),
//         ),
//       ),
//
//       body: Form(
//         key: _formKey,
//
//         child: ListView(
//           padding:
//           const EdgeInsets.fromLTRB(
//             16,
//             8,
//             16,
//             32,
//           ),
//
//           children: [
//             // ==================================================
//             // HEADER
//             // ==================================================
//
//             Container(
//               padding:
//               const EdgeInsets.all(
//                 16,
//               ),
//
//               decoration:
//               BoxDecoration(
//                 color:
//                 const Color(
//                   0xFFEFF6FF,
//                 ),
//                 borderRadius:
//                 BorderRadius.circular(
//                   16,
//                 ),
//               ),
//
//               child: Row(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//
//                 children: [
//                   Icon(
//                     isEdit
//                         ? Icons.edit_rounded
//                         : Icons
//                         .directions_car_rounded,
//                     color:
//                     const Color(
//                       0xFF1565C0,
//                     ),
//                     size: 28,
//                   ),
//
//                   const SizedBox(
//                     width: 12,
//                   ),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                       CrossAxisAlignment.start,
//
//                       children: [
//                         Text(
//                           isEdit
//                               ? 'Update your vehicle'
//                               : 'List your vehicle',
//                           style:
//                           const TextStyle(
//                             fontSize: 16,
//                             fontWeight:
//                             FontWeight.w800,
//                             color:
//                             Color(
//                               0xFF111827,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(
//                           height: 4,
//                         ),
//
//                         Text(
//                           isEdit
//                               ? 'Update accurate vehicle details and pricing.'
//                               : 'Add accurate vehicle details and pricing. '
//                               'Your vehicle will be reviewed by RentKaro admin.',
//                           style:
//                           const TextStyle(
//                             fontSize: 12,
//                             height: 1.45,
//                             color:
//                             Color(
//                               0xFF475569,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ==================================================
//             // VEHICLE INFORMATION
//             // ==================================================
//
//             _sectionTitle(
//               'Vehicle Information',
//             ),
//
//             _textField(
//               controller:
//               _brandController,
//               label: 'Brand',
//               hint: 'e.g. Mahindra',
//               prefixIcon:
//               Icons.business_outlined,
//               validator:
//                   (value) =>
//                   _requiredValidator(
//                     value,
//                     'Brand',
//                   ),
//             ),
//
//             _textField(
//               controller:
//               _modelController,
//               label: 'Model',
//               hint: 'e.g. Thar',
//               prefixIcon:
//               Icons
//                   .directions_car_outlined,
//               validator:
//                   (value) =>
//                   _requiredValidator(
//                     value,
//                     'Model',
//                   ),
//             ),
//
//             _dropdown(
//               label: 'Vehicle Type',
//               value:
//               _vehicleType,
//               icon:
//               Icons
//                   .directions_car_outlined,
//               items: const [
//                 'car',
//                 'bike',
//                 'scooter',
//               ],
//               onChanged:
//                   (value) {
//                 if (value == null) {
//                   return;
//                 }
//
//                 setState(() {
//                   _vehicleType =
//                       value;
//                 });
//               },
//             ),
//
//             _dropdown(
//               label: 'Category',
//               value:
//               _category,
//               icon:
//               Icons
//                   .category_outlined,
//               items: const [
//                 'suv',
//                 'sedan',
//                 'hatchback',
//                 'luxury',
//                 'bike',
//                 'scooter',
//               ],
//               onChanged:
//                   (value) {
//                 if (value == null) {
//                   return;
//                 }
//
//                 setState(() {
//                   _category =
//                       value;
//                 });
//               },
//             ),
//
//             _textField(
//               controller:
//               _registrationController,
//               label:
//               'Registration Number',
//               hint:
//               'e.g. GJ06RK2026',
//               prefixIcon:
//               Icons
//                   .confirmation_number_outlined,
//               textCapitalization:
//               TextCapitalization
//                   .characters,
//               validator:
//               _registrationValidator,
//             ),
//
//             _textField(
//               controller:
//               _seatsController,
//               label: 'Seats',
//               hint: 'e.g. 5',
//               prefixIcon:
//               Icons
//                   .event_seat_outlined,
//               keyboardType:
//               TextInputType.number,
//               validator:
//               _seatsValidator,
//             ),
//
//             // ==================================================
//             // PRICING
//             // ==================================================
//
//             _sectionTitle(
//               'Pricing',
//             ),
//
//             _textField(
//               controller:
//               _hourlyController,
//               label:
//               'Hourly Price',
//               hint: 'e.g. 300',
//               prefixText:
//               '₹ ',
//               prefixIcon:
//               Icons
//                   .schedule_outlined,
//               keyboardType:
//               const TextInputType
//                   .numberWithOptions(
//                 decimal: true,
//               ),
//               validator:
//                   (value) =>
//                   _positiveNumberValidator(
//                     value,
//                     'hourly price',
//                   ),
//             ),
//
//             _textField(
//               controller:
//               _twelveHourController,
//               label:
//               '12 Hour Price',
//               hint: 'Optional',
//               prefixText:
//               '₹ ',
//               prefixIcon:
//               Icons
//                   .timelapse_outlined,
//               keyboardType:
//               const TextInputType
//                   .numberWithOptions(
//                 decimal: true,
//               ),
//               validator:
//                   (value) =>
//                   _optionalPositiveNumberValidator(
//                     value,
//                     '12 hour price',
//                   ),
//             ),
//
//             _textField(
//               controller:
//               _dailyController,
//               label:
//               'Daily Price',
//               hint: 'e.g. 5000',
//               prefixText:
//               '₹ ',
//               prefixIcon:
//               Icons
//                   .calendar_today_outlined,
//               keyboardType:
//               const TextInputType
//                   .numberWithOptions(
//                 decimal: true,
//               ),
//               validator:
//                   (value) =>
//                   _positiveNumberValidator(
//                     value,
//                     'daily price',
//                   ),
//             ),
//
//             _textField(
//               controller:
//               _depositController,
//               label:
//               'Security Deposit',
//               hint: 'e.g. 5000',
//               prefixText:
//               '₹ ',
//               prefixIcon:
//               Icons
//                   .account_balance_wallet_outlined,
//               keyboardType:
//               const TextInputType
//                   .numberWithOptions(
//                 decimal: true,
//               ),
//               validator:
//                   (value) =>
//                   _positiveNumberValidator(
//                     value,
//                     'security deposit',
//                   ),
//             ),
//
//             // ==================================================
//             // LOCATION
//             // ==================================================
//
//             _sectionTitle(
//               'Location',
//             ),
//
//             _textField(
//               controller:
//               _cityController,
//               label: 'City',
//               hint: 'Vadodara',
//               prefixIcon:
//               Icons
//                   .location_city_outlined,
//               validator:
//                   (value) =>
//                   _requiredValidator(
//                     value,
//                     'City',
//                   ),
//             ),
//
//             _textField(
//               controller:
//               _areaController,
//               label: 'Area',
//               hint: 'e.g. Gotri',
//               prefixIcon:
//               Icons
//                   .location_on_outlined,
//               validator:
//                   (value) =>
//                   _requiredValidator(
//                     value,
//                     'Area',
//                   ),
//             ),
//
//             // ==================================================
//             // VEHICLE DETAILS
//             // ==================================================
//
//             _sectionTitle(
//               'Vehicle Details',
//             ),
//
//             _dropdown(
//               label: 'Fuel Type',
//               value:
//               _fuelType,
//               icon:
//               Icons
//                   .local_gas_station_outlined,
//               items: const [
//                 'petrol',
//                 'diesel',
//                 'cng',
//                 'electric',
//               ],
//               onChanged:
//                   (value) {
//                 if (value == null) {
//                   return;
//                 }
//
//                 setState(() {
//                   _fuelType =
//                       value;
//                 });
//               },
//             ),
//
//             _dropdown(
//               label: 'Transmission',
//               value:
//               _transmission,
//               icon:
//               Icons.settings_outlined,
//               items: const [
//                 'manual',
//                 'automatic',
//               ],
//               onChanged:
//                   (value) {
//                 if (value == null) {
//                   return;
//                 }
//
//                 setState(() {
//                   _transmission =
//                       value;
//                 });
//               },
//             ),
//
//             _textField(
//               controller:
//               _descriptionController,
//               label:
//               'Description',
//               hint:
//               'Describe your vehicle',
//               prefixIcon:
//               Icons
//                   .description_outlined,
//               maxLines: 4,
//             ),
//
//             // ==================================================
//             // VEHICLE PHOTOS
//             // ==================================================
//
//             _sectionTitle(
//               'Vehicle Photos',
//             ),
//
//             _imageSection(),
//
//             const SizedBox(
//               height: 20,
//             ),
//
//             // ==================================================
//             // SUBMIT
//             // ==================================================
//
//             SizedBox(
//               height: 54,
//
//               child: FilledButton(
//                 onPressed:
//                 _isSubmitting ||
//                     _isUploadingImages
//                     ? null
//                     : _submit,
//
//                 style:
//                 FilledButton.styleFrom(
//                   backgroundColor:
//                   const Color(
//                     0xFF1565C0,
//                   ),
//                   foregroundColor:
//                   Colors.white,
//                   disabledBackgroundColor:
//                   const Color(
//                     0xFF94A3B8,
//                   ),
//                   shape:
//                   RoundedRectangleBorder(
//                     borderRadius:
//                     BorderRadius.circular(
//                       14,
//                     ),
//                   ),
//                 ),
//
//                 child:
//                 _isSubmitting ||
//                     _isUploadingImages
//                     ? const SizedBox(
//                   height: 23,
//                   width: 23,
//                   child:
//                   CircularProgressIndicator(
//                     strokeWidth:
//                     2.5,
//                     color:
//                     Colors.white,
//                   ),
//                 )
//                     : Text(
//                   isEdit
//                       ? 'Update Vehicle'
//                       : 'Submit Vehicle',
//                   style:
//                   const TextStyle(
//                     fontSize: 16,
//                     fontWeight:
//                     FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(
//               height: 14,
//             ),
//
//             // ==================================================
//             // APPROVAL INFO
//             // ==================================================
//
//             Container(
//               padding:
//               const EdgeInsets.all(
//                 14,
//               ),
//
//               decoration:
//               BoxDecoration(
//                 color:
//                 const Color(
//                   0xFFFFF7ED,
//                 ),
//                 borderRadius:
//                 BorderRadius.circular(
//                   12,
//                 ),
//                 border:
//                 Border.all(
//                   color:
//                   const Color(
//                     0xFFFED7AA,
//                   ),
//                 ),
//               ),
//
//               child: Row(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//
//                 children: [
//                   const Icon(
//                     Icons
//                         .info_outline_rounded,
//                     size: 20,
//                     color:
//                     Color(
//                       0xFFC2410C,
//                     ),
//                   ),
//
//                   const SizedBox(
//                     width: 9,
//                   ),
//
//                   Expanded(
//                     child: Text(
//                       isEdit
//                           ? 'Updated vehicle details may require admin review '
//                           'before the vehicle is listed again.'
//                           : 'Your vehicle will remain pending until '
//                           'it is reviewed and approved by RentKaro admin.',
//                       style:
//                       const TextStyle(
//                         fontSize: 12,
//                         height: 1.45,
//                         color:
//                         Color(
//                           0xFF9A3412,
//                         ),
//                         fontWeight:
//                         FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================
//   // IMAGE SECTION
//   // ==========================================================
//
//   Widget _imageSection() {
//     final totalImages =
//         _images.length +
//             _newImages.length;
//
//     return Container(
//       padding:
//       const EdgeInsets.all(16),
//
//       decoration:
//       BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//         BorderRadius.circular(
//           16,
//         ),
//         border:
//         Border.all(
//           color:
//           const Color(
//             0xFFE2E8F0,
//           ),
//         ),
//       ),
//
//       child: Column(
//         crossAxisAlignment:
//         CrossAxisAlignment.start,
//
//         children: [
//           const Text(
//             'Add vehicle photos',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight:
//               FontWeight.w800,
//               color:
//               Color(
//                 0xFF111827,
//               ),
//             ),
//           ),
//
//           const SizedBox(
//             height: 6,
//           ),
//
//           const Text(
//             'Upload clear photos of your vehicle. '
//                 'You can add up to 10 photos.',
//             style: TextStyle(
//               fontSize: 12,
//               height: 1.4,
//               color:
//               Color(
//                 0xFF64748B,
//               ),
//             ),
//           ),
//
//           const SizedBox(
//             height: 14,
//           ),
//
//           if (totalImages > 0)
//             GridView.builder(
//               shrinkWrap: true,
//               physics:
//               const NeverScrollableScrollPhysics(),
//
//               itemCount:
//               totalImages,
//
//               gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 1,
//               ),
//
//               itemBuilder:
//                   (
//                   context,
//                   index,
//                   ) {
//                 // ------------------------------------------------
//                 // EXISTING CLOUDINARY IMAGE
//                 // ------------------------------------------------
//
//                 if (index <
//                     _images.length) {
//                   final imageUrl =
//                   _images[index];
//
//                   return Stack(
//                     children: [
//                       Positioned.fill(
//                         child:
//                         ClipRRect(
//                           borderRadius:
//                           BorderRadius.circular(
//                             12,
//                           ),
//
//                           child:
//                           Image.network(
//                             imageUrl,
//                             fit:
//                             BoxFit.cover,
//
//                             loadingBuilder:
//                                 (
//                                 context,
//                                 child,
//                                 loadingProgress,
//                                 ) {
//                               if (loadingProgress ==
//                                   null) {
//                                 return child;
//                               }
//
//                               return Container(
//                                 color:
//                                 const Color(
//                                   0xFFF1F5F9,
//                                 ),
//                                 child:
//                                 const Center(
//                                   child:
//                                   CircularProgressIndicator(
//                                     strokeWidth:
//                                     2,
//                                   ),
//                                 ),
//                               );
//                             },
//
//                             errorBuilder:
//                                 (
//                                 context,
//                                 error,
//                                 stackTrace,
//                                 ) {
//                               return Container(
//                                 color:
//                                 const Color(
//                                   0xFFF1F5F9,
//                                 ),
//                                 child:
//                                 const Center(
//                                   child:
//                                   Icon(
//                                     Icons
//                                         .broken_image_outlined,
//                                     color:
//                                     Color(
//                                       0xFF94A3B8,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//
//                       Positioned(
//                         top: 5,
//                         right: 5,
//                         child:
//                         GestureDetector(
//                           onTap:
//                               () =>
//                               _removeExistingImage(
//                                 index,
//                               ),
//
//                           child:
//                           Container(
//                             width: 28,
//                             height: 28,
//
//                             decoration:
//                             const BoxDecoration(
//                               color:
//                               Colors.black54,
//                               shape:
//                               BoxShape.circle,
//                             ),
//
//                             child:
//                             const Icon(
//                               Icons.close,
//                               color:
//                               Colors.white,
//                               size: 17,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       Positioned(
//                         left: 5,
//                         bottom: 5,
//                         child:
//                         Container(
//                           padding:
//                           const EdgeInsets
//                               .symmetric(
//                             horizontal: 6,
//                             vertical: 3,
//                           ),
//
//                           decoration:
//                           BoxDecoration(
//                             color:
//                             Colors.black54,
//                             borderRadius:
//                             BorderRadius.circular(
//                               6,
//                             ),
//                           ),
//
//                           child:
//                           const Text(
//                             'SAVED',
//                             style:
//                             TextStyle(
//                               color:
//                               Colors.white,
//                               fontSize: 8,
//                               fontWeight:
//                               FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//
//                 // ------------------------------------------------
//                 // NEW LOCAL IMAGE
//                 // ------------------------------------------------
//
//                 final newImageIndex =
//                     index -
//                         _images.length;
//
//                 final file =
//                 _newImages[
//                 newImageIndex];
//
//                 return Stack(
//                   children: [
//                     Positioned.fill(
//                       child:
//                       ClipRRect(
//                         borderRadius:
//                         BorderRadius.circular(
//                           12,
//                         ),
//
//                         child:
//                         Image.file(
//                           file,
//                           fit:
//                           BoxFit.cover,
//                         ),
//                       ),
//                     ),
//
//                     Positioned(
//                       top: 5,
//                       right: 5,
//                       child:
//                       GestureDetector(
//                         onTap:
//                             () =>
//                             _removeNewImage(
//                               newImageIndex,
//                             ),
//
//                         child:
//                         Container(
//                           width: 28,
//                           height: 28,
//
//                           decoration:
//                           const BoxDecoration(
//                             color:
//                             Colors.black54,
//                             shape:
//                             BoxShape.circle,
//                           ),
//
//                           child:
//                           const Icon(
//                             Icons.close,
//                             color:
//                             Colors.white,
//                             size: 17,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     Positioned(
//                       left: 5,
//                       bottom: 5,
//                       child:
//                       Container(
//                         padding:
//                         const EdgeInsets
//                             .symmetric(
//                           horizontal: 6,
//                           vertical: 3,
//                         ),
//
//                         decoration:
//                         BoxDecoration(
//                           color:
//                           const Color(
//                             0xFF1565C0,
//                           ),
//                           borderRadius:
//                           BorderRadius.circular(
//                             6,
//                           ),
//                         ),
//
//                         child:
//                         const Text(
//                           'NEW',
//                           style:
//                           TextStyle(
//                             color:
//                             Colors.white,
//                             fontSize: 8,
//                             fontWeight:
//                             FontWeight.w800,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//
//           if (totalImages > 0)
//             const SizedBox(
//               height: 12,
//             ),
//
//           // ======================================================
//           // ADD PHOTO BUTTON
//           // ======================================================
//
//           OutlinedButton.icon(
//             onPressed:
//             totalImages >= 10 ||
//                 _isSubmitting ||
//                 _isUploadingImages
//                 ? null
//                 : _showImageSourcePicker,
//
//             icon:
//             const Icon(
//               Icons
//                   .add_photo_alternate_outlined,
//             ),
//
//             label:
//             Text(
//               totalImages >= 10
//                   ? 'Maximum Photos Added'
//                   : 'Add Photos',
//             ),
//
//             style:
//             OutlinedButton.styleFrom(
//               minimumSize:
//               const Size(
//                 double.infinity,
//                 48,
//               ),
//
//               shape:
//               RoundedRectangleBorder(
//                 borderRadius:
//                 BorderRadius.circular(
//                   12,
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(
//             height: 8,
//           ),
//
//           Text(
//             '$totalImages / 10 photos selected',
//             style:
//             const TextStyle(
//               fontSize: 11,
//               color:
//               Color(
//                 0xFF64748B,
//               ),
//             ),
//           ),
//
//           // ======================================================
//           // CLOUDINARY UPLOAD PROGRESS
//           // ======================================================
//
//           if (_isUploadingImages) ...[
//             const SizedBox(
//               height: 16,
//             ),
//
//             LinearProgressIndicator(
//               value:
//               _newImages.isEmpty
//                   ? null
//                   : _uploadedImageCount /
//                   (_uploadedImageCount +
//                       _newImages.length),
//             ),
//
//             const SizedBox(
//               height: 8,
//             ),
//
//             Text(
//               'Uploading images to Cloudinary... '
//                   '$_uploadedImageCount uploaded',
//               style:
//               const TextStyle(
//                 fontSize: 12,
//                 fontWeight:
//                 FontWeight.w600,
//                 color:
//                 Color(
//                   0xFF475569,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ==========================================================
//   // SECTION TITLE
//   // ==========================================================
//
//   Widget _sectionTitle(
//       String title,
//       ) {
//     return Padding(
//       padding:
//       const EdgeInsets.only(
//         top: 20,
//         bottom: 10,
//       ),
//
//       child: Text(
//         title,
//         style:
//         const TextStyle(
//           fontSize: 18,
//           fontWeight:
//           FontWeight.w800,
//           color:
//           Color(
//             0xFF111827,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================
//   // TEXT FIELD
//   // ==========================================================
//
//   Widget _textField({
//     required TextEditingController
//     controller,
//     required String label,
//     required String hint,
//     IconData? prefixIcon,
//     String? prefixText,
//     TextInputType? keyboardType,
//     TextCapitalization
//     textCapitalization =
//         TextCapitalization.none,
//     String? Function(String?)?
//     validator,
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding:
//       const EdgeInsets.only(
//         bottom: 12,
//       ),
//
//       child:
//       TextFormField(
//         controller:
//         controller,
//
//         keyboardType:
//         keyboardType,
//
//         textCapitalization:
//         textCapitalization,
//
//         validator:
//         validator,
//
//         maxLines:
//         maxLines,
//
//         decoration:
//         InputDecoration(
//           labelText:
//           label,
//
//           hintText:
//           hint,
//
//           prefixIcon:
//           prefixIcon != null
//               ? Icon(
//             prefixIcon,
//           )
//               : null,
//
//           prefixText:
//           prefixText,
//
//           filled:
//           true,
//
//           fillColor:
//           Colors.white,
//
//           contentPadding:
//           const EdgeInsets
//               .symmetric(
//             horizontal: 14,
//             vertical: 15,
//           ),
//
//           border:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//           ),
//
//           enabledBorder:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//
//             borderSide:
//             const BorderSide(
//               color:
//               Color(
//                 0xFFE2E8F0,
//               ),
//             ),
//           ),
//
//           focusedBorder:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//
//             borderSide:
//             const BorderSide(
//               color:
//               Color(
//                 0xFF1565C0,
//               ),
//               width: 1.5,
//             ),
//           ),
//
//           errorBorder:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//
//             borderSide:
//             const BorderSide(
//               color:
//               Color(
//                 0xFFDC2626,
//               ),
//             ),
//           ),
//
//           focusedErrorBorder:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//
//             borderSide:
//             const BorderSide(
//               color:
//               Color(
//                 0xFFDC2626,
//               ),
//               width: 1.5,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================
//   // DROPDOWN
//   // ==========================================================
//
//   Widget _dropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?>
//     onChanged,
//     IconData? icon,
//   }) {
//     return Padding(
//       padding:
//       const EdgeInsets.only(
//         bottom: 12,
//       ),
//
//       child:
//       DropdownButtonFormField<
//           String>(
//         initialValue:
//         value,
//
//         items:
//         items.map(
//               (item) {
//             return DropdownMenuItem<
//                 String>(
//               value:
//               item,
//
//               child:
//               Text(
//                 _formatDropdownLabel(
//                   item,
//                 ),
//               ),
//             );
//           },
//         ).toList(),
//
//         onChanged:
//         onChanged,
//
//         decoration:
//         InputDecoration(
//           labelText:
//           label,
//
//           prefixIcon:
//           icon != null
//               ? Icon(
//             icon,
//           )
//               : null,
//
//           filled:
//           true,
//
//           fillColor:
//           Colors.white,
//
//           contentPadding:
//           const EdgeInsets
//               .symmetric(
//             horizontal: 14,
//             vertical: 4,
//           ),
//
//           border:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//           ),
//
//           enabledBorder:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//
//             borderSide:
//             const BorderSide(
//               color:
//               Color(
//                 0xFFE2E8F0,
//               ),
//             ),
//           ),
//
//           focusedBorder:
//           OutlineInputBorder(
//             borderRadius:
//             BorderRadius.circular(
//               14,
//             ),
//
//             borderSide:
//             const BorderSide(
//               color:
//               Color(
//                 0xFF1565C0,
//               ),
//               width: 1.5,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================
//   // DROPDOWN LABEL
//   // ==========================================================
//
//   String _formatDropdownLabel(
//       String value,
//       ) {
//     if (value.isEmpty) {
//       return value;
//     }
//
//     return value[0].toUpperCase() +
//         value.substring(1);
//   }
//
//   // ==========================================================
//   // DISPOSE
//   // ==========================================================
//
//   @override
//   void dispose() {
//     _brandController.dispose();
//     _modelController.dispose();
//     _registrationController.dispose();
//     _descriptionController.dispose();
//     _hourlyController.dispose();
//     _twelveHourController.dispose();
//     _dailyController.dispose();
//     _depositController.dispose();
//     _cityController.dispose();
//     _areaController.dispose();
//     _seatsController.dispose();
//
//     super.dispose();
//   }
// }



import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../data/cloudinary_upload_service.dart';
import '../models/owner_vehicle.dart';
import '../providers/owner_vehicle_provider.dart';
import 'vehicle_location_picker_screen.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({
    super.key,
    this.vehicleId,
  });

  final int? vehicleId;

  bool get isEditMode => vehicleId != null;

  @override
  ConsumerState<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends ConsumerState<AddVehicleScreen> {
final _formKey = GlobalKey<FormState>();

// ==========================================================
// CONTROLLERS
// ==========================================================

final _brandController = TextEditingController();
final _modelController = TextEditingController();
final _registrationController = TextEditingController();
final _descriptionController = TextEditingController();
final _hourlyController = TextEditingController();
final _twelveHourController = TextEditingController();
final _dailyController = TextEditingController();
final _depositController = TextEditingController();

final _cityController = TextEditingController(
text: 'Vadodara',
);

final _areaController = TextEditingController();
final _seatsController = TextEditingController();

// ==========================================================
// DROPDOWN VALUES
// ==========================================================

String _vehicleType = 'car';
String _category = 'suv';
String _fuelType = 'petrol';
String _transmission = 'manual';

// ==========================================================
// LOCATION
// ==========================================================

double? _latitude;
double? _longitude;

// ==========================================================
// IMAGES
// ==========================================================

/// Existing Cloudinary image URLs.
List<String> _images = [];

/// Newly selected local images.
final List<File> _newImages = [];

final ImagePicker _imagePicker = ImagePicker();

// ==========================================================
// LOADING
// ==========================================================

bool _isLoadingVehicle = false;
bool _isSubmitting = false;
bool _isUploadingImages = false;

int _uploadedImageCount = 0;

OwnerVehicle? _existingVehicle;

// ==========================================================
// INIT
// ==========================================================

@override
void initState() {
super.initState();

if (widget.isEditMode) {
_loadVehicle();
}
}

// ==========================================================
// LOAD EXISTING VEHICLE
// ==========================================================

Future<void> _loadVehicle() async {
final vehicleId = widget.vehicleId;

if (vehicleId == null) {
return;
}

setState(() {
_isLoadingVehicle = true;
});

try {
final vehicle = await ref
.read(ownerVehiclesProvider.notifier)
.getVehicle(vehicleId);

if (!mounted) {
return;
}

if (vehicle == null) {
throw Exception(
'Unable to load vehicle details.',
);
}

_existingVehicle = vehicle;

_fillForm(vehicle);
} catch (error) {
if (!mounted) {
return;
}

_showError(error);
} finally {
if (mounted) {
setState(() {
_isLoadingVehicle = false;
});
}
}
}

// ==========================================================
// FILL FORM
// ==========================================================

void _fillForm(OwnerVehicle vehicle) {
_brandController.text = vehicle.brand;

_modelController.text = vehicle.model;

_registrationController.text =
vehicle.registrationNumber;

_descriptionController.text =
vehicle.description ?? '';

_hourlyController.text =
_numberText(vehicle.hourlyPrice);

_twelveHourController.text =
vehicle.twelveHourPrice == null
? ''
: _numberText(
vehicle.twelveHourPrice!,
);

_dailyController.text =
_numberText(vehicle.dailyPrice);

_depositController.text =
_numberText(
vehicle.securityDeposit,
);

_cityController.text = vehicle.city;

_areaController.text = vehicle.area;

_seatsController.text =
vehicle.seats?.toString() ?? '';

_vehicleType = _safeValue(
vehicle.vehicleType,
const [
'car',
'bike',
'scooter',
],
'car',
);

_category = _safeValue(
vehicle.category,
const [
'suv',
'sedan',
'hatchback',
'luxury',
'bike',
'scooter',
],
'suv',
);

_fuelType = _safeValue(
vehicle.fuelType,
const [
'petrol',
'diesel',
'cng',
'electric',
],
'petrol',
);

_transmission = _safeValue(
vehicle.transmission,
const [
'manual',
'automatic',
],
'manual',
);

_images = List<String>.from(
vehicle.images,
);

// ========================================================
// EXISTING LOCATION
// ========================================================

_latitude = vehicle.latitude;
_longitude = vehicle.longitude;

setState(() {});
}

// ==========================================================
// SAFE DROPDOWN VALUE
// ==========================================================

String _safeValue(
String? value,
List<String> allowed,
String fallback,
) {
if (value != null &&
allowed.contains(
value.toLowerCase(),
)) {
return value.toLowerCase();
}

return fallback;
}

// ==========================================================
// NUMBER FORMAT
// ==========================================================

String _numberText(double value) {
if (value == value.roundToDouble()) {
return value
.toInt()
.toString();
}

return value.toString();
}

// ==========================================================
// SELECT LOCATION ON MAP
// ==========================================================

Future<void> _selectVehicleLocation() async {
if (_isSubmitting ||
_isUploadingImages) {
return;
}

final result =
await Navigator.of(context).push<
Map<String, double>>(
MaterialPageRoute(
builder: (_) =>
VehicleLocationPickerScreen(
initialLatitude: _latitude,
initialLongitude: _longitude,
),
),
);

if (!mounted || result == null) {
return;
}

final latitude =
result['latitude'];

final longitude =
result['longitude'];

if (latitude == null ||
longitude == null) {
return;
}

setState(() {
_latitude = latitude;
_longitude = longitude;
});
}

// ==========================================================
// LOCATION CARD
// ==========================================================

Widget _locationPickerCard() {
final hasLocation =
_latitude != null &&
_longitude != null;

return Container(
width: double.infinity,
padding:
const EdgeInsets.all(16),

decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
border:
Border.all(
color:
const Color(
0xFFE2E8F0,
),
),
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
Container(
width: 44,
height: 44,

decoration:
BoxDecoration(
color:
const Color(
0xFFEFF6FF,
),
borderRadius:
BorderRadius.circular(
12,
),
),

child:
const Icon(
Icons
.location_on_rounded,
color:
Color(
0xFF1565C0,
),
size: 24,
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
const Text(
'Vehicle Location',
style:
TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w800,
color:
Color(
0xFF111827,
),
),
),

const SizedBox(
height: 4,
),

Text(
hasLocation
? 'Exact pickup location selected'
: 'Select the exact pickup location on map',

style:
const TextStyle(
fontSize: 12,
height: 1.4,
color:
Color(
0xFF64748B,
),
),
),
],
),
),
],
),

const SizedBox(
height: 14,
),

if (hasLocation) ...[
Container(
width: double.infinity,
padding:
const EdgeInsets.all(
12,
),

decoration:
BoxDecoration(
color:
const Color(
0xFFF8FAFC,
),
borderRadius:
BorderRadius.circular(
12,
),
),

child: Row(
children: [
const Icon(
Icons
.my_location_rounded,
size: 18,
color:
Color(
0xFF16A34A,
),
),

const SizedBox(
width: 8,
),

Expanded(
child: Text(
'Lat: ${_latitude!.toStringAsFixed(6)}\n'
'Lng: ${_longitude!.toStringAsFixed(6)}',

style:
const TextStyle(
fontSize: 12,
height: 1.5,
fontWeight:
FontWeight.w600,
color:
Color(
0xFF334155,
),
),
),
),
],
),
),

const SizedBox(
height: 10,
),
],

SizedBox(
width: double.infinity,

child:
OutlinedButton.icon(
onPressed:
_selectVehicleLocation,

icon: Icon(
hasLocation
? Icons
.edit_location_alt_outlined
: Icons
.map_outlined,
),

label: Text(
hasLocation
? 'Change Location'
: 'Select Location on Map',
),

style:
OutlinedButton.styleFrom(
minimumSize:
const Size(
double.infinity,
48,
),

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
),
),
],
),
);
}

// ==========================================================
// IMAGE PICKER
// ==========================================================

Future<void> _showImageSourcePicker() async {
if (_isSubmitting ||
_isUploadingImages) {
return;
}

if (_images.length +
_newImages.length >=
10) {
_showError(
Exception(
'Maximum 10 vehicle images are allowed.',
),
);

return;
}

await showModalBottomSheet<void>(
context: context,

builder: (sheetContext) {
return SafeArea(
child: Column(
mainAxisSize:
MainAxisSize.min,

children: [
const Padding(
padding:
EdgeInsets.fromLTRB(
20,
18,
20,
8,
),

child: Align(
alignment:
Alignment.centerLeft,

child: Text(
'Add Vehicle Photo',

style:
TextStyle(
fontSize: 18,
fontWeight:
FontWeight.w800,
),
),
),
),

ListTile(
leading:
const CircleAvatar(
child:
Icon(
Icons
.photo_library_outlined,
),
),

title:
const Text(
'Choose from Gallery',
),

subtitle:
const Text(
'Select multiple photos',
),

onTap: () {
Navigator.pop(
sheetContext,
);

_pickImages();
},
),

ListTile(
leading:
const CircleAvatar(
child:
Icon(
Icons
.camera_alt_outlined,
),
),

title:
const Text(
'Take Photo',
),

subtitle:
const Text(
'Use your camera',
),

onTap: () {
Navigator.pop(
sheetContext,
);

_takePhoto();
},
),

const SizedBox(
height: 12,
),
],
),
);
},
);
}

// ==========================================================
// PICK MULTIPLE IMAGES
// ==========================================================

Future<void> _pickImages() async {
if (_isSubmitting ||
_isUploadingImages) {
return;
}

try {
final selectedImages =
await _imagePicker.pickMultiImage(
imageQuality: 80,
maxWidth: 1920,
maxHeight: 1920,
);

if (selectedImages.isEmpty) {
return;
}

final currentCount =
_images.length +
_newImages.length;

final remainingSlots =
10 - currentCount;

if (remainingSlots <= 0) {
_showError(
Exception(
'Maximum 10 vehicle images are allowed.',
),
);

return;
}

final files = selectedImages
.take(remainingSlots)
.map(
(image) =>
File(image.path),
)
.toList();

setState(() {
_newImages.addAll(files);
});

if (selectedImages.length >
remainingSlots) {
_showError(
Exception(
'Only $remainingSlots more images can be added.',
),
);
}
} catch (error) {
if (!mounted) {
return;
}

_showError(error);
}
}

// ==========================================================
// CAMERA
// ==========================================================

Future<void> _takePhoto() async {
if (_isSubmitting ||
_isUploadingImages) {
return;
}

if (_images.length +
_newImages.length >=
10) {
_showError(
Exception(
'Maximum 10 vehicle images are allowed.',
),
);

return;
}

try {
final image =
await _imagePicker.pickImage(
source:
ImageSource.camera,

imageQuality: 80,

maxWidth: 1920,

maxHeight: 1920,
);

if (image == null) {
return;
}

setState(() {
_newImages.add(
File(image.path),
);
});
} catch (error) {
if (!mounted) {
return;
}

_showError(error);
}
}

// ==========================================================
// REMOVE EXISTING IMAGE
// ==========================================================

void _removeExistingImage(
int index,
) {
if (index < 0 ||
index >= _images.length) {
return;
}

setState(() {
_images.removeAt(index);
});
}

// ==========================================================
// REMOVE NEW IMAGE
// ==========================================================

void _removeNewImage(
int index,
) {
if (index < 0 ||
index >= _newImages.length) {
return;
}

setState(() {
_newImages.removeAt(index);
});
}

// ==========================================================
// VALIDATORS
// ==========================================================

String? _requiredValidator(
String? value,
String field,
) {
if (value == null ||
value.trim().isEmpty) {
return '$field is required';
}

// Backend also requires minimum 2 characters.
if (value.trim().length < 2) {
return '$field must be at least 2 characters';
}

return null;
}

String? _positiveNumberValidator(
String? value,
String field,
) {
if (value == null ||
value.trim().isEmpty) {
return '$field is required';
}

final number =
double.tryParse(
value.trim(),
);

if (number == null ||
number <= 0) {
return 'Enter a valid $field';
}

return null;
}

String? _optionalPositiveNumberValidator(
String? value,
String field,
) {
if (value == null ||
value.trim().isEmpty) {
return null;
}

final number =
double.tryParse(
value.trim(),
);

if (number == null ||
number <= 0) {
return 'Enter a valid $field';
}

return null;
}

String? _seatsValidator(
String? value,
) {
if (value == null ||
value.trim().isEmpty) {
return 'Seats are required';
}

final seats =
int.tryParse(
value.trim(),
);

if (seats == null ||
seats <= 0) {
return 'Enter valid seats';
}

if (seats > 100) {
return 'Enter realistic seat count';
}

return null;
}

String? _registrationValidator(
String? value,
) {
if (value == null ||
value.trim().isEmpty) {
return 'Registration number is required';
}

if (value.trim().length < 4) {
return 'Enter a valid registration number';
}

return null;
}
// ==========================================================
// UPLOAD NEW IMAGES
// ==========================================================

Future<void> _uploadNewImages(
String registrationNumber,
) async {
if (_newImages.isEmpty) {
return;
}

setState(() {
_isUploadingImages = true;
_uploadedImageCount = 0;
});

final cloudinaryService =
CloudinaryUploadService();

final folder =
'rentkaro/vehicles/$registrationNumber';

try {
for (final file in _newImages) {
final imageUrl =
await cloudinaryService.uploadImage(
file: file,
folder: folder,
);

_images.add(imageUrl);

if (mounted) {
setState(() {
_uploadedImageCount++;
});
}
}

_newImages.clear();
} finally {
if (mounted) {
setState(() {
_isUploadingImages = false;
});
}
}
}

// ==========================================================
// SUBMIT
// ==========================================================

Future<void> _submit() async {
FocusScope.of(context).unfocus();

if (!_formKey.currentState!.validate()) {
return;
}

// ========================================================
// IMAGE VALIDATION
// ========================================================

if (_images.isEmpty &&
_newImages.isEmpty) {
_showError(
Exception(
'Please add at least one vehicle photo.',
),
);
return;
}

// ========================================================
// LOCATION VALIDATION
// ========================================================

if (_latitude == null ||
_longitude == null) {
_showError(
Exception(
'Please select the exact vehicle location on the map.',
),
);
return;
}

setState(() {
_isSubmitting = true;
});

try {
final brand =
_brandController.text.trim();

final model =
_modelController.text.trim();

final registrationNumber =
_registrationController.text
.trim()
.toUpperCase();

final description =
_descriptionController.text
.trim();

final hourlyPrice =
double.parse(
_hourlyController.text.trim(),
);

final twelveHourText =
_twelveHourController.text.trim();

final twelveHourPrice =
twelveHourText.isEmpty
? null
: double.parse(
twelveHourText,
);

final dailyPrice =
double.parse(
_dailyController.text.trim(),
);

final securityDeposit =
double.parse(
_depositController.text.trim(),
);

final city =
_cityController.text.trim();

final area =
_areaController.text.trim();

final seats =
int.parse(
_seatsController.text.trim(),
);

// ========================================================
// CLOUDINARY UPLOAD
// ========================================================

if (_newImages.isNotEmpty) {
await _uploadNewImages(
registrationNumber,
);
}

if (_images.isEmpty) {
throw Exception(
'No vehicle image is available.',
);
}

// ========================================================
// PROVIDER
// ========================================================

final notifier =
ref.read(
ownerVehiclesProvider.notifier,
);

OwnerVehicle? vehicle;

// ========================================================
// EDIT VEHICLE
// ========================================================

if (widget.isEditMode) {
vehicle =
await notifier.updateVehicle(
vehicleId:
widget.vehicleId!,

brand:
brand,

model:
model,

vehicleType:
_vehicleType,

category:
_category,

registrationNumber:
registrationNumber,

description:
description.isEmpty
? null
: description,

hourlyPrice:
hourlyPrice,

twelveHourPrice:
twelveHourPrice,

dailyPrice:
dailyPrice,

securityDeposit:
securityDeposit,

city:
city,

area:
area,

latitude:
_latitude,

longitude:
_longitude,

images:
_images,

seats:
seats,

fuelType:
_fuelType,

transmission:
_transmission,
);
}

// ========================================================
// ADD VEHICLE
// ========================================================

else {
vehicle =
await notifier.addVehicle(
brand:
brand,

model:
model,

vehicleType:
_vehicleType,

category:
_category,

registrationNumber:
registrationNumber,

description:
description.isEmpty
? null
: description,

hourlyPrice:
hourlyPrice,

twelveHourPrice:
twelveHourPrice,

dailyPrice:
dailyPrice,

securityDeposit:
securityDeposit,

city:
city,

area:
area,

latitude:
_latitude,

longitude:
_longitude,

images:
_images,

seats:
seats,

fuelType:
_fuelType,

transmission:
_transmission,
);
}

if (!mounted) {
return;
}

// ========================================================
// PROVIDER ERROR
// ========================================================

if (vehicle == null) {
final currentState =
ref.read(
ownerVehiclesProvider,
);

final error =
currentState.error;

throw Exception(
error
?.toString()
.replaceFirst(
'Exception: ',
'',
) ??
(
widget.isEditMode
? 'Unable to update vehicle.'
: 'Unable to add vehicle.'
),
);
}

// ========================================================
// SUCCESS
// ========================================================

ScaffoldMessenger.of(
context,
).showSnackBar(
SnackBar(
content: Text(
widget.isEditMode
? 'Vehicle updated successfully.'
: 'Vehicle added successfully. '
'Waiting for admin approval.',
),
behavior:
SnackBarBehavior.floating,
),
);

context.pop();
} catch (error) {
if (!mounted) {
return;
}

_showError(error);
} finally {
if (mounted) {
setState(() {
_isSubmitting = false;
_isUploadingImages = false;
});
}
}
}

// ==========================================================
// ERROR
// ==========================================================

void _showError(
Object error,
) {
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
backgroundColor:
const Color(
0xFFDC2626,
),
behavior:
SnackBarBehavior.floating,
),
);
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(
BuildContext context,
) {
if (_isLoadingVehicle) {
return Scaffold(
backgroundColor:
const Color(0xFFF8FAFC),

appBar: AppBar(
backgroundColor:
const Color(0xFFF8FAFC),

elevation: 0,

title: const Text(
'Edit Vehicle',
),
),

body:
const Center(
child:
CircularProgressIndicator(),
),
);
}

final isEdit =
widget.isEditMode;

return Scaffold(
backgroundColor:
const Color(0xFFF8FAFC),

appBar: AppBar(
backgroundColor:
const Color(0xFFF8FAFC),

surfaceTintColor:
Colors.transparent,

elevation: 0,

title: Text(
isEdit
? 'Edit Vehicle'
: 'Add Vehicle',

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

body: Form(
key: _formKey,

child: ListView(
padding:
const EdgeInsets.fromLTRB(
16,
8,
16,
32,
),

children: [
// ==================================================
// HEADER
// ==================================================

Container(
padding:
const EdgeInsets.all(
16,
),

decoration:
BoxDecoration(
color:
const Color(
0xFFEFF6FF,
),

borderRadius:
BorderRadius.circular(
16,
),
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment
.start,

children: [
Icon(
isEdit
? Icons
.edit_rounded
: Icons
.directions_car_rounded,

color:
const Color(
0xFF1565C0,
),

size: 28,
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
isEdit
? 'Update your vehicle'
: 'List your vehicle',

style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
color:
Color(
0xFF111827,
),
),
),

const SizedBox(
height: 4,
),

Text(
isEdit
? 'Update accurate vehicle details and pricing.'
: 'Add accurate vehicle details and pricing. '
'Your vehicle will be reviewed by RentKaro admin.',

style:
const TextStyle(
fontSize: 12,
height: 1.45,
color:
Color(
0xFF475569,
),
),
),
],
),
),
],
),
),

// ==================================================
// VEHICLE INFORMATION
// ==================================================

_sectionTitle(
'Vehicle Information',
),

_textField(
controller:
_brandController,

label:
'Brand',

hint:
'e.g. Mahindra',

prefixIcon:
Icons
.business_outlined,

validator:
(value) =>
_requiredValidator(
value,
'Brand',
),
),

_textField(
controller:
_modelController,

label:
'Model',

hint:
'e.g. Thar',

prefixIcon:
Icons
.directions_car_outlined,

validator:
(value) =>
_requiredValidator(
value,
'Model',
),
),

_dropdown(
label:
'Vehicle Type',

value:
_vehicleType,

icon:
Icons
.directions_car_outlined,

items: const [
'car',
'bike',
'scooter',
],

onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_vehicleType =
value;
});
},
),

_dropdown(
label:
'Category',

value:
_category,

icon:
Icons
.category_outlined,

items: const [
'suv',
'sedan',
'hatchback',
'luxury',
'bike',
'scooter',
],

onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_category =
value;
});
},
),

_textField(
controller:
_registrationController,

label:
'Registration Number',

hint:
'e.g. GJ06RK2026',

prefixIcon:
Icons
.confirmation_number_outlined,

textCapitalization:
TextCapitalization
.characters,

validator:
_registrationValidator,
),

_textField(
controller:
_seatsController,

label:
'Seats',

hint:
'e.g. 5',

prefixIcon:
Icons
.event_seat_outlined,

keyboardType:
TextInputType.number,

validator:
_seatsValidator,
),

// ==================================================
// PRICING
// ==================================================

_sectionTitle(
'Pricing',
),

_textField(
controller:
_hourlyController,

label:
'Hourly Price',

hint:
'e.g. 300',

prefixText:
'₹ ',

prefixIcon:
Icons
.schedule_outlined,

keyboardType:
const TextInputType
.numberWithOptions(
decimal: true,
),

validator:
(value) =>
_positiveNumberValidator(
value,
'hourly price',
),
),

_textField(
controller:
_twelveHourController,

label:
'12 Hour Price',

hint:
'Optional',

prefixText:
'₹ ',

prefixIcon:
Icons
.timelapse_outlined,

keyboardType:
const TextInputType
.numberWithOptions(
decimal: true,
),

validator:
(value) =>
_optionalPositiveNumberValidator(
value,
'12 hour price',
),
),

_textField(
controller:
_dailyController,

label:
'Daily Price',

hint:
'e.g. 5000',

prefixText:
'₹ ',

prefixIcon:
Icons
.calendar_today_outlined,

keyboardType:
const TextInputType
.numberWithOptions(
decimal: true,
),

validator:
(value) =>
_positiveNumberValidator(
value,
'daily price',
),
),

_textField(
controller:
_depositController,

label:
'Security Deposit',

hint:
'e.g. 5000',

prefixText:
'₹ ',

prefixIcon:
Icons
.account_balance_wallet_outlined,

keyboardType:
const TextInputType
.numberWithOptions(
decimal: true,
),

validator:
(value) =>
_positiveNumberValidator(
value,
'security deposit',
),
),

// ==================================================
// LOCATION
// ==================================================

_sectionTitle(
'Location',
),

_textField(
controller:
_cityController,

label:
'City',

hint:
'Vadodara',

prefixIcon:
Icons
.location_city_outlined,

validator:
(value) =>
_requiredValidator(
value,
'City',
),
),

_textField(
controller:
_areaController,

label:
'Area',

hint:
'e.g. Gotri',

prefixIcon:
Icons
.location_on_outlined,

validator:
(value) =>
_requiredValidator(
value,
'Area',
),
),

const SizedBox(
height: 4,
),

_locationPickerCard(),

// ==================================================
// VEHICLE DETAILS
// ==================================================

_sectionTitle(
'Vehicle Details',
),

_dropdown(
label:
'Fuel Type',

value:
_fuelType,

icon:
Icons
.local_gas_station_outlined,

items: const [
'petrol',
'diesel',
'cng',
'electric',
],

onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_fuelType =
value;
});
},
),

_dropdown(
label:
'Transmission',

value:
_transmission,

icon:
Icons.settings_outlined,

items: const [
'manual',
'automatic',
],

onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_transmission =
value;
});
},
),

_textField(
controller:
_descriptionController,

label:
'Description',

hint:
'Describe your vehicle',

prefixIcon:
Icons
.description_outlined,

maxLines: 4,
),

// ==================================================
// VEHICLE PHOTOS
// ==================================================

_sectionTitle(
'Vehicle Photos',
),

_imageSection(),

const SizedBox(
height: 20,
),

// ==================================================
// SUBMIT
// ==================================================

SizedBox(
height: 54,

child:
FilledButton(
onPressed:
_isSubmitting ||
_isUploadingImages
? null
: _submit,

style:
FilledButton.styleFrom(
backgroundColor:
const Color(
0xFF1565C0,
),

foregroundColor:
Colors.white,

disabledBackgroundColor:
const Color(
0xFF94A3B8,
),

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
14,
),
),
),

child:
_isSubmitting ||
_isUploadingImages
? const SizedBox(
height: 23,
width: 23,

child:
CircularProgressIndicator(
strokeWidth:
2.5,
color:
Colors.white,
),
)
: Text(
isEdit
? 'Update Vehicle'
: 'Submit Vehicle',

style:
const TextStyle(
fontSize: 16,
fontWeight:
FontWeight.w800,
),
),
),
),

const SizedBox(
height: 14,
),

// ==================================================
// APPROVAL INFO
// ==================================================

Container(
padding:
const EdgeInsets.all(
14,
),

decoration:
BoxDecoration(
color:
const Color(
0xFFFFF7ED,
),

borderRadius:
BorderRadius.circular(
12,
),

border:
Border.all(
color:
const Color(
0xFFFED7AA,
),
),
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment
.start,

children: [
const Icon(
Icons
.info_outline_rounded,

size: 20,

color:
Color(
0xFFC2410C,
),
),

const SizedBox(
width: 9,
),

Expanded(
child: Text(
isEdit
? 'Updated vehicle details may require admin review '
'before the vehicle is listed again.'
: 'Your vehicle will remain pending until '
'it is reviewed and approved by RentKaro admin.',

style:
const TextStyle(
fontSize: 12,
height: 1.45,
color:
Color(
0xFF9A3412,
),
fontWeight:
FontWeight.w500,
),
),
),
],
),
),
],
),
),
);
}
  // ==========================================================
  // IMAGE SECTION
  // ==========================================================

  Widget _imageSection() {
    final totalImages =
        _images.length +
            _newImages.length;

    return Container(
      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border:
        Border.all(
          color:
          const Color(0xFFE2E8F0),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          const Text(
            'Add vehicle photos',
            style: TextStyle(
              fontSize: 15,
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
            'Upload clear photos of your vehicle. '
                'You can add up to 10 photos.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color:
              Color(0xFF64748B),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          if (totalImages > 0)
            GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),

              itemCount:
              totalImages,

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                // ==================================================
                // EXISTING CLOUDINARY IMAGE
                // ==================================================

                if (index <
                    _images.length) {
                  final imageUrl =
                  _images[index];

                  return Stack(
                    children: [
                      Positioned.fill(
                        child:
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),

                          child:
                          Image.network(
                            imageUrl,
                            fit:
                            BoxFit.cover,

                            loadingBuilder:
                                (
                                context,
                                child,
                                loadingProgress,
                                ) {
                              if (loadingProgress ==
                                  null) {
                                return child;
                              }

                              return Container(
                                color:
                                const Color(
                                  0xFFF1F5F9,
                                ),

                                child:
                                const Center(
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2,
                                  ),
                                ),
                              );
                            },

                            errorBuilder:
                                (
                                context,
                                error,
                                stackTrace,
                                ) {
                              return Container(
                                color:
                                const Color(
                                  0xFFF1F5F9,
                                ),

                                child:
                                const Center(
                                  child:
                                  Icon(
                                    Icons
                                        .broken_image_outlined,
                                    color:
                                    Color(
                                      0xFF94A3B8,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      Positioned(
                        top: 5,
                        right: 5,

                        child:
                        GestureDetector(
                          onTap:
                              () =>
                              _removeExistingImage(
                                index,
                              ),

                          child:
                          Container(
                            width: 28,
                            height: 28,

                            decoration:
                            const BoxDecoration(
                              color:
                              Colors.black54,
                              shape:
                              BoxShape.circle,
                            ),

                            child:
                            const Icon(
                              Icons.close,
                              color:
                              Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 5,
                        bottom: 5,

                        child:
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            Colors.black54,
                            borderRadius:
                            BorderRadius.circular(
                              6,
                            ),
                          ),

                          child:
                          const Text(
                            'SAVED',
                            style:
                            TextStyle(
                              color:
                              Colors.white,
                              fontSize: 8,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // ==================================================
                // NEW LOCAL IMAGE
                // ==================================================

                final newImageIndex =
                    index -
                        _images.length;

                final file =
                _newImages[
                newImageIndex];

                return Stack(
                  children: [
                    Positioned.fill(
                      child:
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),

                        child:
                        Image.file(
                          file,
                          fit:
                          BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 5,
                      right: 5,

                      child:
                      GestureDetector(
                        onTap:
                            () =>
                            _removeNewImage(
                              newImageIndex,
                            ),

                        child:
                        Container(
                          width: 28,
                          height: 28,

                          decoration:
                          const BoxDecoration(
                            color:
                            Colors.black54,
                            shape:
                            BoxShape.circle,
                          ),

                          child:
                          const Icon(
                            Icons.close,
                            color:
                            Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 5,
                      bottom: 5,

                      child:
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFF1565C0,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            6,
                          ),
                        ),

                        child:
                        const Text(
                          'NEW',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize: 8,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          if (totalImages > 0)
            const SizedBox(
              height: 12,
            ),

          // ==================================================
          // ADD PHOTO BUTTON
          // ==================================================

          OutlinedButton.icon(
            onPressed:
            totalImages >= 10 ||
                _isSubmitting ||
                _isUploadingImages
                ? null
                : _showImageSourcePicker,

            icon:
            const Icon(
              Icons
                  .add_photo_alternate_outlined,
            ),

            label:
            Text(
              totalImages >= 10
                  ? 'Maximum Photos Added'
                  : 'Add Photos',
            ),

            style:
            OutlinedButton.styleFrom(
              minimumSize:
              const Size(
                double.infinity,
                48,
              ),

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '$totalImages / 10 photos selected',
            style:
            const TextStyle(
              fontSize: 11,
              color:
              Color(0xFF64748B),
            ),
          ),

          // ==================================================
          // CLOUDINARY UPLOAD PROGRESS
          // ==================================================

          if (_isUploadingImages) ...[
            const SizedBox(
              height: 16,
            ),

            LinearProgressIndicator(
              value:
              _newImages.isEmpty
                  ? null
                  : _uploadedImageCount /
                  (_uploadedImageCount +
                      _newImages.length),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Uploading images to Cloudinary... '
                  '$_uploadedImageCount uploaded',

              style:
              const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.w600,
                color:
                Color(0xFF475569),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),

      child: Text(
        title,

        style:
        const TextStyle(
          fontSize: 18,
          fontWeight:
          FontWeight.w800,
          color:
          Color(0xFF111827),
        ),
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _textField({
    required TextEditingController
    controller,

    required String label,

    required String hint,

    IconData? prefixIcon,

    String? prefixText,

    TextInputType? keyboardType,

    TextCapitalization
    textCapitalization =
        TextCapitalization.none,

    String? Function(String?)?
    validator,

    int maxLines = 1,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child:
      TextFormField(
        controller:
        controller,

        keyboardType:
        keyboardType,

        textCapitalization:
        textCapitalization,

        validator:
        validator,

        maxLines:
        maxLines,

        decoration:
        InputDecoration(
          labelText:
          label,

          hintText:
          hint,

          prefixIcon:
          prefixIcon != null
              ? Icon(
            prefixIcon,
          )
              : null,

          prefixText:
          prefixText,

          filled:
          true,

          fillColor:
          Colors.white,

          contentPadding:
          const EdgeInsets
              .symmetric(
            horizontal: 14,
            vertical: 15,
          ),

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(0xFFE2E8F0),
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(0xFF1565C0),
              width: 1.5,
            ),
          ),

          errorBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(0xFFDC2626),
            ),
          ),

          focusedErrorBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(0xFFDC2626),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DROPDOWN
  // ==========================================================

  Widget _dropdown({
    required String label,

    required String value,

    required List<String> items,

    required ValueChanged<String?>
    onChanged,

    IconData? icon,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child:
      DropdownButtonFormField<
          String>(
        initialValue:
        value,

        items:
        items.map(
              (item) {
            return DropdownMenuItem<
                String>(
              value:
              item,

              child:
              Text(
                _formatDropdownLabel(
                  item,
                ),
              ),
            );
          },
        ).toList(),

        onChanged:
        onChanged,

        decoration:
        InputDecoration(
          labelText:
          label,

          prefixIcon:
          icon != null
              ? Icon(
            icon,
          )
              : null,

          filled:
          true,

          fillColor:
          Colors.white,

          contentPadding:
          const EdgeInsets
              .symmetric(
            horizontal: 14,
            vertical: 4,
          ),

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(0xFFE2E8F0),
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(0xFF1565C0),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DROPDOWN LABEL
  // ==========================================================

  String _formatDropdownLabel(
      String value,
      ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _brandController.dispose();

    _modelController.dispose();

    _registrationController.dispose();

    _descriptionController.dispose();

    _hourlyController.dispose();

    _twelveHourController.dispose();

    _dailyController.dispose();

    _depositController.dispose();

    _cityController.dispose();

    _areaController.dispose();

    _seatsController.dispose();

    super.dispose();
  }
}