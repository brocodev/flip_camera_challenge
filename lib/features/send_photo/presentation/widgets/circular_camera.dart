import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flip_camera_challenge/features/send_photo/presentation/notifiers/inherited_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class CircularCamera extends StatefulWidget {
  const CircularCamera({
    required this.rotateAnimation,
    this.controller,
    super.key,
  });

  final Animation<double> rotateAnimation;
  final CameraController? controller;

  @override
  State<CircularCamera> createState() => _CircularCameraState();
}

class _CircularCameraState extends State<CircularCamera> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: widget.rotateAnimation,
          builder: (_, child) {
            final animation = widget.rotateAnimation;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0001)
                ..rotateX((pi * 2) * animation.value),
              child: child,
            );
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: context.readyToReleaseNotifier,
            builder: (_, value, child) => DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? Colors.white : Colors.transparent,
              ),
              child: child,
            ),
            child: Padding(
              padding: 4.edgeInsetsA,
              child: ValueListenableBuilder<double>(
                valueListenable: context.dragPercentNotifier,
                builder: (_, value, child) {
                  final size = lerpDouble(.2.sh, .4.sh, value)!;
                  return ClipRRect(
                    borderRadius: size.borderRadiusA,
                    child: ColoredBox(
                      color: Colors.white,
                      child: SizedOverflowBox(
                        size: Size(size, size),
                        child: child,
                      ),
                    ),
                  );
                },
                child: ValueListenableBuilder<File?>(
                  valueListenable: context.photoFileNotifier,
                  builder: (_, file, child) =>
                      file != null ? Image.file(file) : child!,
                  child: widget.controller != null
                      ? CameraPreview(widget.controller!)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
        height28,
        ValueListenableBuilder<bool>(
          valueListenable: context.readyToReleaseNotifier,
          builder: (__, value, child) => AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: value ? child : const Text('Flick to flip the camera'),
          ),
          child: ValueListenableBuilder(
            valueListenable: context.photoFileNotifier,
            builder: (_, file, __) => file == null
                ? const Text('Release to take a photo', key: Key('key1'))
                : const Text('Cool!'),
          ),
        ),
      ],
    );
  }
}
