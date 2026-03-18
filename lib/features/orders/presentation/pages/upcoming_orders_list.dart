// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/providers/order_provider.dart';
// import 'order_details_page.dart';
// import 'order_list_item.dart';
//
// class UpcomingOrdersList extends StatelessWidget {
//   const UpcomingOrdersList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderProvider>(
//       builder: (context, orderProvider, child) {
//         final upcomingOrders = orderProvider.upcomingOrders;
//
//         if (upcomingOrders.isEmpty) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.schedule,
//                     color: AppColors.greyLight,
//                     size: 60,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No Upcoming Orders',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'New service requests will appear here',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: AppColors.textSecondary),
//                   ),
//                 ],
//               ),
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
//             itemCount: upcomingOrders.length,
//             itemBuilder: (context, index) {
//               final order = upcomingOrders[index];
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