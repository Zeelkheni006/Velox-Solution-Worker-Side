// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/providers/order_provider.dart';
// import 'order_details_page.dart';
// import 'order_list_item.dart';
//
// class CurrentOrdersList extends StatelessWidget {
//   const CurrentOrdersList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderProvider>(
//       builder: (context, orderProvider, child) {
//         final currentOrders = orderProvider.currentOrders;
//
//         if (currentOrders.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(
//                   Icons.access_time_filled,
//                   color: AppColors.greyLight,
//                   size: 60,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'No current orders.',
//                   style: TextStyle(color: AppColors.textDisabled),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return RefreshIndicator(
//           onRefresh: () async {
//             // In production, fetch from API
//             await Future.delayed(const Duration(seconds: 1));
//           },
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: currentOrders.length,
//             itemBuilder: (context, index) {
//               final order = currentOrders[index];
//               return OrderListItem(
//                 order: order,
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => OrderDetailsPage(order: order),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }