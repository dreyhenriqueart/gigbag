import 'package:flutter/material.dart';

class FixedHeightCard extends StatelessWidget {
  const FixedHeightCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class FixedListTile extends StatelessWidget {
  const FixedListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      minVerticalPadding: 0,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: leading,
      title: title,
      trailing: trailing,
      subtitle: subtitle,
      isThreeLine: isThreeLine,
    );
  }
}
