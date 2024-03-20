import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/custom_device.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(CustomDevice)? onAddDevice;
  const AddDeviceDialog({
    super.key,
    this.onAddDevice,
  });

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final deviceNameController = TextEditingController();
  final ipAddressController = TextEditingController();
  final portController = TextEditingController();
  @override
  void initState() {
    portController.text = '22';
    super.initState();
  }

  @override
  void dispose() {
    deviceNameController.dispose();
    ipAddressController.dispose();
    portController.dispose();
    super.dispose();
  }

  void addDevice() {
    final device = CustomDevice(
      name: deviceNameController.text,
      ipAddress: ipAddressController.text,
      port: int.tryParse(portController.text) ?? 0,
    );
    widget.onAddDevice?.call(device);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.enter): addDevice},
      child: AlertDialog(
        content: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add new device'),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                controller: deviceNameController,
                decoration: const InputDecoration(
                  hintText: 'Device name',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: ipAddressController,
                      decoration: const InputDecoration(
                        hintText: 'Ip address',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: portController,
                      decoration: const InputDecoration(
                        hintText: 'Port',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addDevice,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
