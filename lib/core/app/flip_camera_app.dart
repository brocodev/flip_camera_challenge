import 'package:flip_camera_challenge/features/send_photo/presentation/screens/take_photo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_common/ui_common.dart';

class FlipCameraApp extends StatelessWidget {
  const FlipCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (__, child) => child!,
      child: MaterialApp(
        title: 'Material App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.amber,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.amber,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
        home: const TakePhotoScreen(),
      ),
    );
  }
}
