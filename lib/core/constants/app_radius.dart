import 'package:flutter/material.dart';
import '../utils/app_responsive.dart';

class AppRadii {
  // Very small radius (chips, tags)
  static Radius xs(BuildContext context) => Radius.circular(rs(context, 4));

  // Small radius (buttons, small cards)
  static Radius sm(BuildContext context) => Radius.circular(rs(context, 8));

  // Medium radius (cards, containers)
  static Radius md(BuildContext context) => Radius.circular(rs(context, 12));

  static Radius md_lg(BuildContext context) => Radius.circular(rs(context, 16));

  // Large radius (bottom sheets, dialogs)
  static Radius lg(BuildContext context) => Radius.circular(rs(context, 20));

  // Extra large (big modals, rounded screens)
  static Radius xl(BuildContext context) => Radius.circular(rs(context, 30));

  static Radius xxl(BuildContext context) => Radius.circular(rs(context, 50));

  static Radius xxxl(BuildContext context) => Radius.circular(rs(context, 80));

  // Full BorderRadius presets
  static BorderRadius button(BuildContext context) => BorderRadius.all(Radius.circular(rs(context, 12)));

  static BorderRadius card(BuildContext context) => BorderRadius.all(Radius.circular(rs(context, 16)));

  static BorderRadius sheet(BuildContext context) => BorderRadius.vertical(top: Radius.circular(rs(context, 24)));

  // SIDE-SPECIFIC RADIUS SETS
  static BorderRadius top(BuildContext context, Radius radius) => BorderRadius.vertical(top: radius);

  static BorderRadius bottom(BuildContext context, Radius radius) => BorderRadius.vertical(bottom: radius);

  static BorderRadius left(BuildContext context, Radius radius) => BorderRadius.horizontal(left: radius);

  static BorderRadius right(BuildContext context, Radius radius) => BorderRadius.horizontal(right: radius);

  // Optional presets with `xl`
  static BorderRadius topXL(BuildContext context) => BorderRadius.vertical(top: xl(context));

  static BorderRadius bottomXL(BuildContext context) => BorderRadius.vertical(bottom: xl(context));

  static BorderRadius leftXL(BuildContext context) => BorderRadius.horizontal(left: xl(context));

  static BorderRadius rightXL(BuildContext context) => BorderRadius.horizontal(right: xl(context));
}
