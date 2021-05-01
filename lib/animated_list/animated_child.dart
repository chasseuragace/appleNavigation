import 'dart:math';

import 'package:flutter/material.dart';

class CustomAnimatedList extends StatefulWidget {
  final List<AnimatedChild> children;
  final AnimationController controller;
  final bool useRow;
  final bool useWrap;
  final bool useSlide;
  const CustomAnimatedList(
      {required this.children,
      required this.controller,
      required this.useRow,
      required this.useSlide,
      required this.useWrap});

  factory CustomAnimatedList.row(
      {required List<AnimatedChild> children,
      required AnimationController controller,
      bool useSlide = false}) {
    return CustomAnimatedList(
      children: children,
      controller: controller,
      useRow: true,
      useSlide: useSlide,
      useWrap: false,
    );
  }

  factory CustomAnimatedList.wrap(
      {required List<AnimatedChild> children,
      required AnimationController controller,
      bool useSlide = false}) {
    return CustomAnimatedList(
      children: children,
      controller: controller,
      useRow: true,
      useSlide: useSlide,
      useWrap: true,
    );
  }

  factory CustomAnimatedList.column(
      {required List<AnimatedChild> children,
      required AnimationController controller,
      bool useSlide = false}) {
    return CustomAnimatedList(
      useWrap: false,
      children: children,
      controller: controller,
      useRow: false,
      useSlide: useSlide,
    );
  }
  @override
  _CustomAnimatedListState createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState extends State<CustomAnimatedList> {
  Animation<double> getScaleAnimation(int index) {
    final int childrenLength = widget.children.length;
    final double intervalForEachChild = 1 / childrenLength;
    final double start = index * intervalForEachChild;
    final double end = min(1, (index + 1) * intervalForEachChild);

    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(
          max(0, (widget.children[index].interval?.start ?? start) - 0.5),
          min(1, (widget.children[index].interval?.end ?? end) + 0.2),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  Animation<Offset> getSlideAnimation(int index) {
    final int childrenLength = widget.children.length;
    final double intervalForEachChild = 1 / childrenLength;
    final double start = index * intervalForEachChild;
    final double end = min(1, (index + 1) * intervalForEachChild);

    return Tween<Offset>(
      begin: const Offset(60, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(
          max(0, (widget.children[index].interval?.start ?? start) - 0.5),
          min(1, (widget.children[index].interval?.end ?? end) + 0.2),
          curve: Curves.easeOutSine,
        ),
      ),
    );
  }

  List<Widget> childrenBuilder() {
    return <Widget>[
      for (int i = 0; i < widget.children.length; i++)
        AnimatedBuilder(
          animation: widget.controller,
          builder: (context, Widget? child) {
            final scaleAnimation = getScaleAnimation(i);
            final slideAnimation = getSlideAnimation(i);

            return widget.useSlide
                ? Transform.translate(
                    offset: slideAnimation.value,
                    child: Opacity(
                        opacity: scaleAnimation.value * .8, child: child),
                  )
                : Transform.scale(
                    scale: scaleAnimation.value,
                    child: Opacity(
                        opacity: scaleAnimation.value * .9, child: child),
                  );

            child ?? const SizedBox.shrink();
          },
          child: widget.children[i].child,
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return widget.useWrap
        ? Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            spacing: 8,
            children: childrenBuilder(),
          )
        : widget.useRow
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: childrenBuilder(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: childrenBuilder(),
              );
    /* :
      ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.children.length,
      itemBuilder: (BuildContext context, int index) {
        var current_child =widget.children[index];
        return AnimatedBuilder(animation: widget.controller, builder: (context,Widget? child){
          return
            Transform.scale(scale:  getAnimation(index).value,child: child,);

            child??const SizedBox.shrink();
        },child: current_child.child,);
      },
    );*/
  }
}

class AnimatedChild {
  Widget child;
  AnimationInterval? interval;

  AnimatedChild({required this.child, this.interval});
}

class AnimationInterval {
  final double start, end;

  const AnimationInterval({this.start = 0.0, this.end = 1.0});
}

extension animatedChild on List<Widget> {
  List<AnimatedChild> toAnimatedChildren() {
    return map((e) => AnimatedChild(
          child: e,
        )).toList();
  }
}
