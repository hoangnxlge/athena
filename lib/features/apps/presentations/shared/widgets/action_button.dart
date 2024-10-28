import 'package:athena/features/apps/presentations/bloc/apps_bloc.dart';
import 'package:athena/utils/extensions/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.title,
    required this.event,
    this.enable = false,
    this.callback,
  });
  final String? title;
  final AppsEvent event;
  final bool enable;
  final Function? callback;

  @override
  Widget build(BuildContext context) {
    final label = title ??
        event
            .toString()
            .substring(0, event.toString().length - 2)
            .split('.')
            .last
            .camelToNormal();
    return ElevatedButton(
      onPressed: () {
        context.read<AppsBloc>().add(event);
        callback?.call();
      },
      style: ButtonStyle(
          backgroundColor:
              enable ? WidgetStateProperty.all(Colors.teal) : null),
      child: Text(label),
    );
  }
}
