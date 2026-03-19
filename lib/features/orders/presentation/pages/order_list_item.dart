import 'package:flutter/material.dart';

import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';

class OrderListItem extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPaid = order.isPaid;

    final Color paymentColor =
    isPaid ? AppColors.success : AppColors.warning;

    final IconData paymentIcon =
    isPaid ? Icons.verified_rounded : Icons.payments_rounded;

    // 👉 only start time
    final String displayTime =
    order.slotTime.split(' - ').first.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 10)),
      child: CustomContainer(
        onTap: onTap,
        padding: EdgeInsets.all(rs(context, 10)),
        backgroundColor: AppColors.white,
        borderRadius: AppRadii.card(context),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 0),
          )
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: rs(context, 8),
                        vertical: rs(context, 4),
                      ),
                      backgroundColor: AppColors.primary,
                      borderRadius: BorderRadius.all(AppRadii.sm(context)),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: rs(context, 16),
                              color: AppColors.white),
                          SizedBox(width: rs(context, 6)),
                          Text(
                            displayTime,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range,
                            size: rs(context, 16),
                            color: AppColors.secondary),
                        SizedBox(width: rs(context, 6)),
                        Text(
                          order.serviceDate,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      
            SizedBox(height: rs(context, 8)),
      
            // ================= SERVICES =================
            Text(
              order.services.join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.bold),
            ),
      
            SizedBox(height: rs(context, 4)),
            Divider(color: AppColors.border),
            SizedBox(height: rs(context, 2)),
      
            // ================= AMOUNT & PAYMENT =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount
                Row(
                  children: [
                    CustomContainer(
                      padding: EdgeInsets.all(rs(context, 8)),
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                      child: Icon(
                        Icons.currency_rupee,
                        size: rs(context, 18),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: rs(context, 10)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total",
                          style: AppTextStyles.caption(context),
                        ),
                        Text(
                          "₹${order.totalAmount.toStringAsFixed(2)}",
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      
                // Payment Status
                CustomContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: rs(context, 8),
                    vertical: rs(context, 8),
                  ),
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.all(AppRadii.sm(context)),
                  child: Row(
                    children: [
                      Text(
                        isPaid ? "Paid" : "Unpaid",
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
