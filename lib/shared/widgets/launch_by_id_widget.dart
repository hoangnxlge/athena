import 'package:athena/features/apps/presentations/bloc/apps_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LaunchByIdWidget extends StatelessWidget {
  const LaunchByIdWidget({
    super.key,
    required TextEditingController appIdController,
    required AppsBloc bloc,
  })  : _appIdController = appIdController,
        _bloc = bloc;

  final TextEditingController _appIdController;
  final AppsBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () {
                if (_appIdController.text.isNotEmpty) {
                  _bloc.add(
                    AppsEvent.launchApp(_appIdController.text),
                  );
                }
              }
            },
            child: TextField(
              autofocus: true,
              controller: _appIdController,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _bloc.add(
                    AppsEvent.launchApp(_appIdController.text),
                  );
                },
                child: const Text('Launch'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _bloc.add(
                    AppsEvent.closeApp(_appIdController.text),
                  );
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}