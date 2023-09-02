import 'dart:io';

import 'package:flutter/cupertino.dart';

class InheritedNotifiers extends InheritedWidget {
  const InheritedNotifiers({
    required this.readyToRelease,
    required this.cameraReady,
    required this.photoFile,
    required this.dragPercent,
    required super.child,
    super.key,
  });

  final ValueNotifier<double> dragPercent;
  final ValueNotifier<bool> readyToRelease;
  final ValueNotifier<bool> cameraReady;
  final ValueNotifier<File?> photoFile;

  static ValueNotifier<double> getDragPercent(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedNotifiers>()!
      .dragPercent;

  static ValueNotifier<bool> getCameraReady(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedNotifiers>()!
      .cameraReady;

  static ValueNotifier<bool> getReadyToRelease(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedNotifiers>()!
      .readyToRelease;

  static ValueNotifier<File?> getPhotoFile(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedNotifiers>()!
      .photoFile;

  @override
  bool updateShouldNotify(InheritedNotifiers oldWidget) =>
      dragPercent != oldWidget.dragPercent;
}
