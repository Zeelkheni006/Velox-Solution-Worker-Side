// // lib/features/orders/presentation/pages/photo_upload_page.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/providers/order_provider.dart';
//
// class PhotoUploadPage extends StatefulWidget {
//   final String orderId;
//   const PhotoUploadPage({super.key, required this.orderId});
//
//   @override
//   State<PhotoUploadPage> createState() => _PhotoUploadPageState();
// }
//
// class _PhotoUploadPageState extends State<PhotoUploadPage> {
//   final List<File> _uploadedImages = [];
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;
//
//   Future<void> _pickAndUploadImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _isUploading = true;
//         });
//
//         // Simulate upload delay
//         await Future.delayed(const Duration(seconds: 1));
//
//         setState(() {
//           _uploadedImages.add(File(pickedFile.path));
//           _isUploading = false;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Photo added successfully'),
//             backgroundColor: AppColors.success,
//             duration: Duration(seconds: 1),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isUploading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error picking image: $e'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }
//
//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt, color: AppColors.secondary),
//                 title: const Text('Take Photo'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickAndUploadImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library, color: AppColors.primary),
//                 title: const Text('Choose from Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickAndUploadImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _removeImage(int index) {
//     setState(() {
//       _uploadedImages.removeAt(index);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Photo removed'),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }
//
//   void _completeJob() {
//     if (_uploadedImages.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please upload at least one photo before completing'),
//           backgroundColor: AppColors.warning,
//         ),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Complete Service?'),
//         content: Text(
//           'You have uploaded ${_uploadedImages.length} photo(s). Mark this service as completed?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//
//               final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//
//               // In production, upload images to server and get URL
//               final photoUrl = 'photo_${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}';
//
//               orderProvider.completeOrder(widget.orderId, photoUrl: photoUrl);
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Service completed successfully!'),
//                   backgroundColor: AppColors.success,
//                 ),
//               );
//
//               // Return to dashboard
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.success,
//             ),
//             child: const Text('Complete Service'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Work Verification'),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Header Section
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primary.withOpacity(0.1),
//                   AppColors.secondary.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.camera_alt,
//                   size: 60,
//                   color: AppColors.secondary,
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Job Completion Photos',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Upload clear photos of the completed work\nfor quality verification',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Photo Grid
//           Expanded(
//             child: _uploadedImages.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.add_photo_alternate_outlined,
//                     size: 80,
//                     color: AppColors.greyLight,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'No photos uploaded yet',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Tap the + button below to add photos',
//                     style: TextStyle(
//                       color: AppColors.grey,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : GridView.builder(
//               padding: const EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//               ),
//               itemCount: _uploadedImages.length,
//               itemBuilder: (context, index) {
//                 return _buildPhotoPreview(_uploadedImages[index], index);
//               },
//             ),
//           ),
//
//           // Bottom Action Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Add Photo Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: OutlinedButton.icon(
//                     onPressed: _isUploading ? null : _showImageSourceDialog,
//                     icon: _isUploading
//                         ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.secondary,
//                       ),
//                     )
//                         : const Icon(Icons.add_a_photo),
//                     label: Text(
//                       _isUploading ? 'Adding Photo...' : 'Add Photo',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.secondary,
//                       side: const BorderSide(color: AppColors.secondary, width: 2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Complete Job Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _uploadedImages.isEmpty ? null : _completeJob,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _uploadedImages.isNotEmpty
//                           ? AppColors.success
//                           : AppColors.grey,
//                       disabledBackgroundColor: AppColors.greyLight,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       'COMPLETE SERVICE (${_uploadedImages.length} ${_uploadedImages.length == 1 ? 'Photo' : 'Photos'})',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPhotoPreview(File imageFile, int index) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.file(
//             imageFile,
//             fit: BoxFit.cover,
//           ),
//         ),
//         // Overlay gradient for better visibility of icons
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.transparent,
//                 Colors.black.withOpacity(0.3),
//               ],
//             ),
//           ),
//         ),
//         // Remove button
//         Positioned(
//           top: 8,
//           right: 8,
//           child: GestureDetector(
//             onTap: () => _removeImage(index),
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: AppColors.error,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 4,
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.close,
//                 size: 20,
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//         ),
//         // Photo number badge
//         Positioned(
//           bottom: 8,
//           left: 8,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: AppColors.secondary,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               'Photo ${index + 1}',
//               style: const TextStyle(
//                 color: AppColors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }