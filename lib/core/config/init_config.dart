import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flip_camera_challenge/core/global/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> config() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  try {
    deviceCameras = await availableCameras();
  } on CameraException catch (e, s) {
    log('Error when execute availableCameras()', error: e, stackTrace: s);
  }
}
