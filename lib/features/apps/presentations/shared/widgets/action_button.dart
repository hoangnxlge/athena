import 'package:athena/features/apps/presentations/bloc/apps_bloc.dart';
import 'package:athena/utils/extensions/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.title,
    required this.event,
  });
  final String? title;
  final AppsEvent event;

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
      },
      child: Text(label),
    );
  }
}
