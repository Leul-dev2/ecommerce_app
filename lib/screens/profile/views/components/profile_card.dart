import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.imageSrc,
    this.proLabelText = "Pro",
    this.isPro = false,
    this.onTap,
    this.showGreeting = true,
    this.showArrow = true,
  });

  final String name;
  final String email;
  final String imageSrc;
  final String proLabelText;
  final bool isPro;
  final bool showGreeting;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: NetworkImageWithLoader(
            imageSrc,
            radius: 56,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              showGreeting ? "Hi, $name" : name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              softWrap: false,
              semanticsLabel: 'User name',
            ),
          ),
          const SizedBox(width: defaultPadding / 2),
          if (isPro)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2,
                vertical: defaultPadding / 4,
              ),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                proLabelText,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.7,
                  height: 1,
                ),
                semanticsLabel: 'Pro user badge',
              ),
            ),
        ],
      ),
      subtitle: Text(
        email,
        style: theme.textTheme.bodyMedium?.copyWith(color: textColor?.withOpacity(0.7)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        semanticsLabel: 'User email',
      ),
      trailing: showArrow
          ? SvgPicture.asset(
              "assets/icons/miniRight.svg",
              color: theme.iconTheme.color?.withOpacity(0.4),
              semanticsLabel: 'Navigate to profile details',
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      horizontalTitleGap: 12,
      minLeadingWidth: 56,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      tileColor: theme.cardColor,
      mouseCursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
    );
  }
}
