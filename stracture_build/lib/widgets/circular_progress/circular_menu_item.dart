import 'package:flutter/material.dart';

class CircularMenuItem extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;
  final double iconSize;
  final double padding;
  final double margin;
  final List<BoxShadow>? boxShadow;
  final bool enableBadge;
  final double? badgeRightOffset;
  final double? badgeLeftOffset;
  final double? badgeTopOffset;
  final double? badgeBottomOffset;
  final double? badgeRadius;
  final TextStyle? badgeTextStyle;
  final String? badgeLabel;
  final Color? badgeTextColor;
  final Color? badgeColor;
  final Widget? imageIcon;
  final AnimatedIcon? animatedIcon;

  const CircularMenuItem({super.key,
    required this.onTap,
    this.icon,
    this.imageIcon,
    this.color,
    this.iconSize = 30,
    this.boxShadow,
    this.iconColor,
    this.animatedIcon,
    this.padding = 10,
    this.margin = 10,
    this.enableBadge = false,
    this.badgeBottomOffset,
    this.badgeLeftOffset,
    this.badgeRightOffset,
    this.badgeTopOffset,
    this.badgeRadius,
    this.badgeTextStyle,
    this.badgeLabel,
    this.badgeTextColor,
    this.badgeColor,
  })  : assert(padding >= 0.0),
        assert(margin >= 0.0);

  Widget _buildCircularMenuItem(BuildContext context) {
    return Container(
      key: const Key('key_container'),
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: color ?? Theme.of(context).primaryColor,
                blurRadius: 0,
              ),
            ],
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        key: const Key('key_clip_oval'),
        child: Material(
          color: color ?? Theme.of(context).primaryColor,
          child: InkWell(
            onTap: onTap,
            child: imageIcon,
          ),
        ),
      ),
    );
  }

  Widget _buildCircularMenuItemWithBadge(BuildContext context) {
    return CBadge(
      color: badgeColor,
      bottomOffset: badgeBottomOffset,
      rightOffset: badgeRightOffset,
      leftOffset: badgeLeftOffset,
      topOffset: badgeTopOffset,
      radius: badgeRadius,
      textStyle: badgeTextStyle,
      onTap: onTap,
      textColor: badgeTextColor,
      label: badgeLabel,
      child: _buildCircularMenuItem(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return enableBadge
        ? _buildCircularMenuItemWithBadge(context)
        : _buildCircularMenuItem(context);
  }
}

@visibleForTesting
class CBadge extends StatelessWidget {
  const CBadge({
    Key? key,
    required this.child,
    required this.label,
    this.color,
    this.textColor,
    this.onTap,
    this.radius,
    this.bottomOffset,
    this.leftOffset,
    this.rightOffset,
    this.topOffset,
    this.textStyle,
  }) : super(key: key);

  final Widget child;
  final String? label;
  final Color? color;
  final Color? textColor;
  final Function? onTap;
  final double? rightOffset;
  final double? leftOffset;
  final double? topOffset;
  final double? bottomOffset;
  final double? radius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('key_stack_circular_menu_item'),
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          key: const Key('key_positioned_circular_menu_item'),
          right: (leftOffset == null && rightOffset == null) ? 8 : rightOffset,
          top: (topOffset == null && bottomOffset == null) ? 8 : topOffset,
          left: leftOffset,
          bottom: bottomOffset,
          child: FittedBox(
            key: const Key('key_fitted_box_circular_menu_item'),
            child: GestureDetector(
              onTap: onTap as void Function()? ?? () {},
              child: CircleAvatar(
                key: const Key('key_circle_avatar_circular_menu_item'),
                maxRadius: radius ?? 10,
                minRadius: radius ?? 10,
                backgroundColor: color ?? Theme.of(context).primaryColor,
                child: Text(
                  label ?? '',
                  textAlign: TextAlign.center,
                  style: textStyle ??
                      TextStyle(
                          fontSize: 10,
                          color: textColor ??
                              Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}