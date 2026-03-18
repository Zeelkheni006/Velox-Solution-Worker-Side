// // lib/features/orders/presentation/pages/new_orders_list.dart
//
// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../data/models/order_model.dart';
// import 'order_details_page.dart';
// import 'order_list_item.dart';
//
// class NewOrdersList extends StatefulWidget {
//   const NewOrdersList({super.key});
//
//   @override
//   State<NewOrdersList> createState() => _NewOrdersListState();
// }
//
// class _NewOrdersListState extends State<NewOrdersList> {
//   // Simulate a list of new incoming orders
//   List<OrderModel> newOrders = [
//     OrderModel(
//       id: 'ORD1005',
//       serviceName: 'Refrigerator Repair (Urgent)',
//       customerName: 'Manoj Joshi',
//       customerPhone: '9000700070',
//       status: 'NEW',
//       scheduledTime: (null as DateTime?) ?? DateTime.now().add(Duration(minutes: 60)),
//       customerLat: 21.1750, customerLon: 72.8250,
//       customerAddress: 'C-7, Rajhans Complex, Athwa Gate, Surat.',
//       totalAmount: 1800.00,
//       paymentStatus: 'CASH_COLLECT',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     if (newOrders.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.notifications_active, color: AppColors.secondary, size: 60),
//               const SizedBox(height: 16),
//               Text('Awaiting New Orders', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 8),
//               Text(
//                 'Stay online to receive immediate notifications for nearby service requests.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: AppColors.textSecondary),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // Display the list of new incoming orders
//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: newOrders.length,
//       itemBuilder: (context, index) {
//         final order = newOrders[index];
//         return OrderListItem(
//           order: order,
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => OrderDetailsPage(order: order)),
//             );
//           },
//         );
//       },
//     );
//   }
// }
// // // lib/features/orders/presentation/pages/new_orders_list.dart
// // import 'package:flutter/material.dart';
// // import '../../../../core/constants/app_colors.dart';
// //
// // class NewOrdersList extends StatelessWidget {
// //   const NewOrdersList({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(32.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.notifications_active,
// //               color: AppColors.secondary,
// //               size: 60,
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               'Awaiting New Orders',
// //               style: Theme.of(context).textTheme.titleLarge,
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'Stay online to receive immediate notifications for nearby service requests.',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(color: AppColors.textSecondary),
// //             ),
// //             // TODO: In a real app, this screen would listen to a real-time stream
// //             // (like WebSockets or Firebase) for new job alerts.
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }