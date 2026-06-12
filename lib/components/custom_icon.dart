
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIcon extends StatelessWidget {
  final String iconUrl;

  const CustomIcon({super.key, required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 5,
      height: 5,
      child: SvgPicture.asset(
        iconUrl,
        width: 5,
        height: 5,
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color ?? Colors.black,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}