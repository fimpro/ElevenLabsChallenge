
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';

typedef ButtonGroupSelectBuilder<T> = Widget Function(T item, BuildContext context);

class ButtonGroupSelect<T> extends StatefulWidget {
  final List<T> items;
  final ButtonGroupSelectBuilder<T> builder;
  final int selectedIndex;
  final void Function(int index, T item)? onSelected;

  const ButtonGroupSelect({super.key, required this.selectedIndex, required this.items, required this.builder, this.onSelected});

  @override
  State<ButtonGroupSelect<T>> createState() => _ButtonGroupSelectState();
}

class _ButtonGroupSelectState<T> extends State<ButtonGroupSelect<T>> {
  final GroupButtonController _buttonController = GroupButtonController();

  @override
  void initState() {
    super.initState();

    _buttonController.selectIndex(widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant ButtonGroupSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _buttonController.selectIndex(widget.selectedIndex);
    }
  }

  void select(int index) {
    _buttonController.selectIndex(index);
    widget.onSelected?.call(index, widget.items[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GroupButton(
        controller: _buttonController,
        isRadio: true,
        enableDeselect: false,
        buttons: widget.items,
        options: const GroupButtonOptions(
          direction: Axis.horizontal,
          runSpacing: 0.0,
          spacing: 5.0,
        ),
        buttonIndexedBuilder: (selected, index, context) =>
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: selected
                  ? FilledButton(
                key: const ValueKey("filled"),
                onPressed: () => select(index),
                child: widget.builder(widget.items[index], context),
              )
                  : OutlinedButton(
                key: const ValueKey("outlined"),
                onPressed: () => select(index),
                child: widget.builder(widget.items[index], context),
              ),
            ),
      ),
    ],);
  }
}
