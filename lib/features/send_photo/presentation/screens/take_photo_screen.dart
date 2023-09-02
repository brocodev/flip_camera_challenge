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
      cameraReady: ValueNotifier(false),
      readyToRelease: ValueNotifier(false),
      photoFile: ValueNotifier(null),
      child: const Scaffold(body: _TakePhotoBodyWidget()),
    );
  }
}

class _TakePhotoBodyWidget extends StatefulWidget {
  const _TakePhotoBodyWidget({super.key});

  @override
  State<_TakePhotoBodyWidget> createState() => _TakePhotoBodyWidgetState();
}

class _TakePhotoBodyWidgetState extends State<_TakePhotoBodyWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController rotateController;
  bool switcher = false;
  CameraController? cameraController;

  Future<void> onFlickItem() async {
    if (rotateController.isAnimating) return;
    switcher = !switcher;
    if (switcher) {
      await rotateController.forward();
      initCamera(1);
    } else {
      await rotateController.reverse();
      initCamera(0);
    }
  }

  void initCamera(int index) {
    if (deviceCameras.isEmpty) return;
    cameraController = CameraController(
      deviceCameras[index],
      ResolutionPreset.max,
      enableAudio: false,
    );
    try {
      cameraController?.initialize();
      if (!mounted) return;
      setState(() {});
    } on CameraException catch (e) {
      handleCameraException(e);
    }
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
    initCamera(0);
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
      initCamera(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: InheritedNotifiers.getDragPercent(context),
      builder: (context, dragPercent, child) => Stack(
        children: [
          Positioned.fill(
            top: 50 + context.mediaQuery.padding.top,
            bottom: 0.6.sh,
            child: const PullToRevealCameraArrow(),
          ),
          Positioned.fill(
            top: lerpDouble(-.5.sh, 70.h, dragPercent),
            bottom: null,
            child: CircularCamera(
              cameraController: cameraController,
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
                  File(xFile!.path);
                },
                onFlickUp: onFlickItem,
                onReleaseReady: (value) =>
                    InheritedNotifiers.getReadyToRelease(context).value = value,
                onDragPercentChanged: (value) =>
                    InheritedNotifiers.getDragPercent(context).value = value,
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
