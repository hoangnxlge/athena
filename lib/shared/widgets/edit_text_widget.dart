import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditTextWidget extends StatefulWidget {
  const EditTextWidget({super.key, required this.text});

  final String text;

  @override
  State<EditTextWidget> createState() => _EditTextWidgetState();
}

class _EditTextWidgetState extends State<EditTextWidget> {
  late final _languageController = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () {
                if (_languageController.text.isNotEmpty) {
                  Navigator.pop(context, _languageController.text);
                }
              }
            },
            child: TextField(
              autofocus: true,
              controller: _languageController,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _languageController.text);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
