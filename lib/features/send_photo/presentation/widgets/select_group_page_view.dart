import 'dart:ui';

import 'package:flip_camera_challenge/features/send_photo/presentation/notifiers/inherited_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class SelectGroupPageView extends StatefulWidget {
  const SelectGroupPageView({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  final int itemCount;
  final Widget Function(int index, bool isSelected) itemBuilder;

  @override
  State<SelectGroupPageView> createState() => _SelectGroupPageViewState();
}

class _SelectGroupPageViewState extends State<SelectGroupPageView>
    with TickerProviderStateMixin {
  late final PageController pageController;
  double page = 0;

  void _pageListener() {
    page = pageController.page!;
    setState(() {});
  }

  @override
  void initState() {
    pageController = PageController(viewportFraction: .27)
      ..addListener(_pageListener);
    super.initState();
  }

  @override
  void dispose() {
    pageController
      ..removeListener(_pageListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: widget.itemCount,
      allowImplicitScrolling: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final percent = (index - page).abs().clamp(0.0, 1.0);
        final isSelected = index == page.toInt();

        return ValueListenableBuilder<double>(
          valueListenable: InheritedNotifiers.getDragPercent(context),
          builder: (context, value, child) => Transform.translate(
            offset: Offset(
              isSelected
                  ? 0
                  : index < page.toInt()
                      ? lerpDouble(0, -.75.sw, value)!
                      : lerpDouble(0, .75.sw, value)!,
              0,
            ),
            child: child,
          ),
          child: Transform.scale(
            scale: lerpDouble(1.3, 1, percent),
            child: widget.itemBuilder(index, isSelected),
          ),
        );
      },
    );
  }
}
