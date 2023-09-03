import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 60.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://source.unsplash.com/featured/300x20$index',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        height4,
        Text(
          'group $index',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
