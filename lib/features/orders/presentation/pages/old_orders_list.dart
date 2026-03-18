// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/providers/order_provider.dart';
// import 'order_details_page.dart';
// import 'order_list_item.dart';
//
// class OldOrdersList extends StatelessWidget {
//   const OldOrdersList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderProvider>(
//       builder: (context, orderProvider, child) {
//         final oldOrders = orderProvider.oldOrders;
//
//         if (oldOrders.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(
//                   Icons.history,
//                   color: AppColors.greyLight,
//                   size: 60,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'Your job history is empty.',
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
//             itemCount: oldOrders.length,
//             itemBuilder: (context, index) {
//               final order = oldOrders[index];
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