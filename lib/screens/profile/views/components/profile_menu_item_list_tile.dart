import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce/components/list_tile/divider_list_tile.dart';

class ProfileMenuListTile extends StatelessWidget {
  const ProfileMenuListTile({
    super.key,
    required this.text,
    required this.svgSrc,
    required this.onTap,
    this.showDivider = true,
  });

  final String text;
  final String svgSrc;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color ?? Colors.black87;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.0,
        ) ??
        const TextStyle(fontSize: 14, height: 1.0);

    return DividerListTile(
      minLeadingWidth: 24,
      leading: SvgPicture.asset(
        svgSrc,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        semanticsLabel: '$text icon',
      ),
      title: Text(
        text,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        semanticsLabel: text,
      ),
      press: onTap,
      isShowDivider: showDivider,
    );
  }
}
