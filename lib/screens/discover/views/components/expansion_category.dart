import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce/route/screen_export.dart';

import '../../../../constants.dart';
import '../../../../models/category_model.dart';

class ExpansionCategory extends StatelessWidget {
  const ExpansionCategory({
    super.key,
    required this.title,
    this.svgSrc,
    this.image,
    this.label,
    required this.subCategory,
  });

  final String title;
  final String? svgSrc;
  final String? image;
  final String? label;
  final List<CategoryModel> subCategory;

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;

    if (svgSrc != null) {
      leadingWidget = SvgPicture.asset(
        svgSrc!,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
      );
    } else if (image != null) {
      leadingWidget = Image.network(
        image!,
        height: 24,
        width: 24,
        fit: BoxFit.cover,
      );
    } else {
      leadingWidget = const SizedBox(width: 24, height: 24);
    }

    // Badge widget for label
    Widget? badge;
    if (label != null) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label!.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ExpansionTile(
      iconColor: Theme.of(context).textTheme.bodyLarge!.color,
      collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
      leading: leadingWidget,
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            badge,
          ]
        ],
      ),
      textColor: Theme.of(context).textTheme.bodyLarge!.color,
      childrenPadding: const EdgeInsets.only(left: defaultPadding * 3.5),
      children: subCategory.map((sub) {
        return Column(
          children: [
            ListTile(
              onTap: () {
                // You can customize navigation per subcategory here
                Navigator.pushNamed(context, onSaleScreenRoute);
              },
              leading: (sub.thumbnail != null)
                  ? Image.network(
                      sub.thumbnail!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    )
                  : null,
              title: Text(
                sub.title,
                style: const TextStyle(fontSize: 14),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }
}
