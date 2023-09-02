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
    this.cameraController,
    super.key,
  });

  final Animation<double> rotateAnimation;
  final CameraController? cameraController;

  @override
  State<CircularCamera> createState() => _CircularCameraState();
}

class _CircularCameraState extends State<CircularCamera>
    with WidgetsBindingObserver {
  int selectedCamera = 0;
  XFile? xFile;

  // void rotationListener() {
  //   if (widget.rotateAnimation.status == AnimationStatus.completed) {
  //     selectedCamera = 1;
  //     initCamera();
  //   }
  //   if (widget.rotateAnimation.status == AnimationStatus.dismissed) {
  //     selectedCamera = 0;
  //     initCamera();
  //   }
  // }

  // Future<void> takePhotoListener() async {
  //   if (widget.takePhotoNotifier.value.$1) {
  //     xFile = await cameraController?.takePicture();
  //     setState(() {});
  //   }
  // }
  //
  // @override
  // void initState() {
  //   WidgetsBinding.instance.addObserver(this);
  //   widget.rotateAnimation.addListener(rotationListener);
  //   widget.readyToReleaseNotifier.addListener(() {
  //     xFile = null;
  //     setState(() {});
  //   });
  //   initCamera();
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   widget.rotateAnimation.removeListener(rotationListener);
  //   cameraController?.dispose();
  //   super.dispose();
  // }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (cameraController == null || !cameraController!.value.isInitialized) {
  //     return;
  //   }
  //   if (state == AppLifecycleState.inactive) {
  //     cameraController?.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     initCamera();
  //   }
  // }

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
            valueListenable: InheritedNotifiers.getReadyToRelease(context),
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
                valueListenable: InheritedNotifiers.getDragPercent(context),
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
                child: xFile != null
                    ? Image.file(File(xFile!.path))
                    : widget.cameraController != null
                        ? CameraPreview(widget.cameraController!)
                        : null,
              ),
            ),
          ),
        ),
        height28,
        ValueListenableBuilder<bool>(
          valueListenable: InheritedNotifiers.getReadyToRelease(context),
          builder: (__, value, _) {
            return AnimatedSwitcher(
              duration: kThemeAnimationDuration,
              child: value
                  ? xFile == null
                      ? const Text(
                          'Release to take a photo',
                          key: Key('key1'),
                        )
                      : const Text('Cool!')
                  : const Text('Flick to flip the camera'),
            );
          },
        ),
      ],
    );
  }
}
