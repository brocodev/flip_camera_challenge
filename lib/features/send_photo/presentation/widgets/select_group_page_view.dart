import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class SelectGroupPageView extends StatefulWidget {
  const SelectGroupPageView({
    required this.hideItemsPercent,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
  });

  final double hideItemsPercent;
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
        final dragPercent = widget.hideItemsPercent;
        return Transform.translate(
          offset: Offset(
            isSelected
                ? 0
                : index < page.toInt()
                    ? lerpDouble(0, -.75.sw, dragPercent)!
                    : lerpDouble(0, .75.sw, dragPercent)!,
            0,
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
