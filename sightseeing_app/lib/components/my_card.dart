import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Color? shadowColor;

  const MyCard({super.key, required this.child, this.height = 100, this.width, this.margin, this.padding, this.shadowColor, this.elevation = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height,
      child: Card(
        margin: margin ?? EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: elevation,
        shadowColor: shadowColor,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(25),
          child: child,
        )
      ),
    );
  }
}
