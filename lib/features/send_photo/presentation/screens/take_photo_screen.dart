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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController rotateController;
  bool switcher = false;
  int selectedCamera = 0;
  CameraController? cameraController;

  Future<void> onFlickItem() async {
    if (rotateController.isAnimating) return;
    switcher = !switcher;
    if (switcher) {
      await rotateController.forward();
      selectedCamera = 1;
      initCamera();
    } else {
      await rotateController.reverse();
      selectedCamera = 0;
      initCamera();
    }
  }

  void initCamera() {
    if (deviceCameras.isEmpty) return;
    cameraController =
        CameraController(deviceCameras[selectedCamera], ResolutionPreset.max);
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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    rotateController.dispose();
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
        SelectGroupPageView(
          itemCount: 10,
          itemBuilder: (index, isSelected) {
            return VerticalDraggableWidget(
              onReleased: () async {
                final xFile = await cameraController?.takePicture();
                if (!mounted && xFile != null) return;
                context.photoFileNotifier.value = File(xFile!.path);
                // await Future<void>.delayed(const Duration(seconds: 1));
              },
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
