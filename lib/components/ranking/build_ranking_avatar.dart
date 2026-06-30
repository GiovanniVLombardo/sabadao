import 'package:flutter/material.dart';

class BuildRankingAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  final Color borderColor;

  const BuildRankingAvatar({
    super.key,
    this.url,
    required this.name,
    required this.radius,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: borderColor.withValues(alpha: 0.2),
      backgroundImage: url != null && url!.isNotEmpty
          ? NetworkImage(url!)
          : null,
      child: url == null || url!.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
