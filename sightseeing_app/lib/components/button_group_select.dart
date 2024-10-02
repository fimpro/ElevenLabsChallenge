
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';

typedef ButtonGroupSelectBuilder<T> = Widget Function(T item, BuildContext context);

class ButtonGroupSelect<T> extends StatefulWidget {
  final List<T> items;
  final ButtonGroupSelectBuilder<T> builder;
  final int? selectedIndex;
  final List<int>? selectedIndexes;
  final void Function(int index, T item)? onSelected;
  final void Function(List<int>)? onSelectedMultiple;
  final bool radio;

  const ButtonGroupSelect({super.key, this.selectedIndex, this.selectedIndexes, required this.items, required this.builder, this.onSelected, this.onSelectedMultiple, this.radio = true});

  @override
  State<ButtonGroupSelect<T>> createState() => _ButtonGroupSelectState();
}

class _ButtonGroupSelectState<T> extends State<ButtonGroupSelect<T>> {
  final GroupButtonController _buttonController = GroupButtonController();

  @override
  void initState() {
    super.initState();

    if(widget.selectedIndex != null) {
      _buttonController.selectIndex(widget.selectedIndex!);
    }

    if(widget.selectedIndexes != null) {
      _buttonController.selectIndexes(widget.selectedIndexes!);
    }
  }

  @override
  void didUpdateWidget(covariant ButtonGroupSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex && widget.selectedIndex != null) {
      _buttonController.selectIndex(widget.selectedIndex!);
    }

    if(oldWidget.selectedIndexes != widget.selectedIndexes && widget.selectedIndexes != null) {
      _buttonController.selectIndexes(widget.selectedIndexes!);
    }
  }

  void select(int index) {
    if(widget.radio) {
      _buttonController.selectIndex(index);
      widget.onSelected?.call(index, widget.items[index]);
    } else {
      if(_buttonController.selectedIndexes.contains(index)) {
        _buttonController.unselectIndex(index);
      } else {
        _buttonController.selectIndex(index);
      }

      widget.onSelectedMultiple?.call(_buttonController.selectedIndexes.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GroupButton(
        controller: _buttonController,
        isRadio: widget.radio,
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
