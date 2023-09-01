import 'dart:ui';

import 'package:flip_camera_challenge/features/send_photo/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({super.key});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController rotateController;
  bool switcher = false;
  double dragPercent = 0;

  /// [ValueNotifier] to listen the flag to take a photo and index of the group
  /// to be sent
  final ValueNotifier<(bool, int)> takePhotoNotifier =
      ValueNotifier((false, -1));

  /// [ValueNotifier] to listen when the user is ready to take a photo
  final ValueNotifier<bool> readyToReleaseNotifier = ValueNotifier(false);

  void onFlickItem() {
    if (rotateController.isAnimating) return;
    switcher = !switcher;
    if (switcher) {
      rotateController.forward();
    } else {
      rotateController.reverse();
    }
  }

  @override
  void initState() {
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    super.initState();
  }

  @override
  void dispose() {
    rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            top: 50 + context.mediaQuery.padding.top,
            bottom: 0.6.sh,
            child: PullToRevealCameraArrow(hide: dragPercent > .1),
          ),
          Positioned.fill(
            top: lerpDouble(-.5.sh, 70, dragPercent),
            bottom: null,
            child: CircularCamera(
              movePercent: dragPercent,
              takePhotoNotifier: takePhotoNotifier,
              readyToReleaseNotifier: readyToReleaseNotifier,
              rotateAnimation: CurvedAnimation(
                curve: Curves.fastOutSlowIn,
                parent: rotateController,
              ),
            ),
          ),
          SelectGroupPageView(
            itemCount: 10,
            hideItemsPercent: dragPercent,
            itemBuilder: (index, isSelected) {
              return VerticalDraggableWidget(
                onFlickUp: onFlickItem,
                onReleaseReady: (value) {
                  readyToReleaseNotifier.value = value;
                },
                onReleased: () async {
                  await Future<void>.delayed(const Duration(seconds: 1));
                },
                onDragPercentChanged: (value) =>
                    setState(() => dragPercent = value),
                enableDrag: isSelected,
                child: GroupAvatar(index: index),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
                image: NetworkImage(
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
