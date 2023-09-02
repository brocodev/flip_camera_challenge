import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flip_camera_challenge/core/global/variables.dart';
import 'package:flip_camera_challenge/features/send_photo/presentation/notifiers/inherited_notifiers.dart';
import 'package:flip_camera_challenge/features/send_photo/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class TakePhotoScreen extends StatelessWidget {
  const TakePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedNotifiers(
      dragPercent: ValueNotifier(0),
      readyToRelease: ValueNotifier(false),
      photoFile: ValueNotifier(null),
      cameraIndex: ValueNotifier(0),
      child: const Scaffold(body: _TakePhotoBodyWidget()),
    );
  }
}

class _TakePhotoBodyWidget extends StatefulWidget {
  const _TakePhotoBodyWidget();

  @override
  State<_TakePhotoBodyWidget> createState() => _TakePhotoBodyWidgetState();
}

class _TakePhotoBodyWidgetState extends State<_TakePhotoBodyWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController rotateController;
  late final AnimationController deliveredController;
  bool switcher = false;
  CameraController? cameraController;

  Future<void> onFlickItem() async {
    if (rotateController.isAnimating) return;
    switcher = !switcher;
    if (switcher) {
      context.cameraIndexNotifier.value = 1;
      await rotateController.forward();
      initCamera();
    } else {
      context.cameraIndexNotifier.value = 0;
      await rotateController.reverse();
      initCamera();
    }
  }

  void initCamera() {
    if (deviceCameras.isEmpty) return;
    cameraController = CameraController(
      deviceCameras[context.cameraIndexNotifier.value],
      ResolutionPreset.max,
      enableAudio: false,
    );
    cameraController?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        handleCameraException(e);
      }
    });
  }

  void handleCameraException(CameraException e) {
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

  void deliveredAnimationListener() {
    if (deliveredController.status == AnimationStatus.completed) {
      Future.delayed(
        const Duration(milliseconds: 600),
        () => deliveredController.reverse(),
      );
    }
  }

  Future<void> onDragReleased() async {
    final xFile = await cameraController?.takePicture();
    if (!mounted && xFile != null) return;
    context.photoFileNotifier.value = File(xFile!.path);
    await Future<void>.delayed(const Duration(seconds: 1));
    // restore photo file notifier
    Future.delayed(
      kThemeChangeDuration,
      () => context.photoFileNotifier.value = null,
    );
    // fake delivered action
    Future.delayed(
      const Duration(seconds: 2),
      () => deliveredController.forward(),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) => initCamera());
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    deliveredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(deliveredAnimationListener);
    super.initState();
  }

  @override
  void dispose() {
    rotateController.dispose();
    deliveredController
      ..removeListener(deliveredAnimationListener)
      ..dispose();
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
    return Stack(
      children: [
        Positioned.fill(
          top: 50 + context.mediaQuery.padding.top,
          bottom: 0.6.sh,
          child: const PullToRevealCameraArrow(),
        ),
        ValueListenableBuilder<double>(
          valueListenable: context.dragPercentNotifier,
          builder: (__, value, child) => Positioned.fill(
            top: lerpDouble(-.5.sh, 70.h, value),
            bottom: null,
            child: child!,
          ),
          child: CircularCamera(
            controller: cameraController,
            rotateAnimation: CurvedAnimation(
              curve: Curves.fastOutSlowIn,
              parent: rotateController,
            ),
          ),
        ),
        DeliveredAnimatedChip(
          animation: CurvedAnimation(
            parent: deliveredController,
            curve: Curves.easeOutBack,
          ),
        ),
        SelectGroupPageView(
          itemCount: 10,
          itemBuilder: (index, isSelected) {
            return VerticalDraggableWidget(
              onReleased: onDragReleased,
              onFlickUp: onFlickItem,
              onReleaseReady: (value) =>
                  context.readyToReleaseNotifier.value = value,
              onDragPercentChanged: (value) =>
                  context.dragPercentNotifier.value = value,
              enableDrag: isSelected,
              child: GroupAvatar(index: index),
            );
          },
        ),
      ],
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
