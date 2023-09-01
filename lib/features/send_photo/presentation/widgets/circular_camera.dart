import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flip_camera_challenge/core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class CircularCamera extends StatefulWidget {
  const CircularCamera({
    required this.movePercent,
    required this.rotateAnimation,
    required this.takePhotoNotifier,
    required this.readyToReleaseNotifier,
    super.key,
  });

  final double movePercent;
  final Animation<double> rotateAnimation;
  final ValueNotifier<(bool, int)> takePhotoNotifier;
  final ValueNotifier<bool> readyToReleaseNotifier;

  @override
  State<CircularCamera> createState() => _CircularCameraState();
}

class _CircularCameraState extends State<CircularCamera>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  int selectedCamera = 0;

  void rotationListener() {
    if (widget.rotateAnimation.status == AnimationStatus.completed) {
      selectedCamera = 1;
      initCamera();
    }
    if (widget.rotateAnimation.status == AnimationStatus.dismissed) {
      selectedCamera = 0;
      initCamera();
    }
  }

  void initCamera() {
    if (deviceCameras.isEmpty) return;
    cameraController = CameraController(
      deviceCameras[selectedCamera],
      ResolutionPreset.max,
      enableAudio: false,
    );
    cameraController?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError(
      (Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              context.showSnackBar(
                const SnackBar(content: Text('Camera Access Denied')),
              );
            default:
              context.showSnackBar(
                const SnackBar(content: Text('Something went wrong')),
              );
              break;
          }
        }
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    widget.rotateAnimation.addListener(rotationListener);
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    widget.rotateAnimation.removeListener(rotationListener);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = lerpDouble(.2.sh, .4.sh, widget.movePercent);
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
          child: Center(
            child: ClipRRect(
              borderRadius: size!.borderRadiusA,
              child: ColoredBox(
                color: Colors.black,
                child: SizedOverflowBox(
                  size: Size(size, size),
                  child: cameraController != null
                      ? CameraPreview(cameraController!)
                      : null,
                ),
              ),
            ),
          ),
        ),
        height28,
        ValueListenableBuilder<bool>(
          valueListenable: widget.readyToReleaseNotifier,
          builder: (__, value, _) {
            return AnimatedSwitcher(
              duration: kThemeAnimationDuration,
              child: value
                  ? const Text(
                      'Release to take a photo',
                      key: Key('key1'),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )
                  : const Text('Flick to flip the camera'),
            );
          },
        ),
      ],
    );
  }
}
