import 'dart:async';

import 'package:athena/features/apps/presentations/shared/widgets/app_card.dart';
import 'package:athena/features/apps/presentations/shared/widgets/section.dart';
import 'package:athena/features/apps/presentations/shared/widgets/section_title.dart';
import 'package:athena/shared/widgets/app_snack_bar.dart';
import 'package:athena/shared/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/apps_bloc.dart';
import '../shared/widgets/action_button.dart';
import '../shared/widgets/add_device_form.dart';

class AppsRoute {
  static Widget get route => BlocProvider(
        create: (context) => AppsBloc(),
        child: BlocListener<AppsBloc, AppsState>(
          listener: (context, state) {
            final bloc = context.read<AppsBloc>();
            LoadingDialog.hide();
            state.whenOrNull(
              loading: LoadingDialog.show,
              error: (err) => AppSnackBar.show(
                message: err,
                duration: 5,
              ),
              getForegroundAppNameSuccess: (appId) =>
                  AppSnackBar.show(message: appId),
              showSnackbar: (message) => AppSnackBar.show(message: message),
              getDeviceListSuccess: (_) =>
                  bloc.add(const AppsEvent.getSoftwareVersion()),
              captureScreenSuccess: (_) {
                Timer(const Duration(seconds: 3), () {
                  bloc.add(const AppsEvent.captureScreen());
                });
              },
            );
          },
          child: const AppsPage(),
        ),
      );
}

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage>
    with AutomaticKeepAliveClientMixin {
  late final bloc = context.read<AppsBloc>();
  final appIdController = TextEditingController();
  final mapAppIds = {
    'Home': 'com.webos.app.home',
    'Hdmi 1': 'com.webos.app.hdmi1',
    'Lg Channels': 'com.webos.app.lgchannels',
    'Live TV': 'com.webos.app.livetv',
    'Channel Manager': 'com.webos.app.channeledit',
    'Channel Tunning': 'com.webos.app.channelsetting',
  };
  @override
  void initState() {
    bloc
      ..add(const AppsEvent.getDeviceList())
      ..add(const AppsEvent.captureScreen());
    super.initState();
  }

  @override
  void dispose() {
    appIdController.dispose();
    super.dispose();
  }

  final keyMaps = {
    LogicalKeyboardKey.keyK: RemoteKey.up,
    LogicalKeyboardKey.keyJ: RemoteKey.down,
    LogicalKeyboardKey.keyH: RemoteKey.left,
    LogicalKeyboardKey.keyL: RemoteKey.right,
    LogicalKeyboardKey.keyO: RemoteKey.enter,
    LogicalKeyboardKey.keyB: RemoteKey.back,
    LogicalKeyboardKey.escape: RemoteKey.exit,
    LogicalKeyboardKey.f1: RemoteKey.home,
    LogicalKeyboardKey.keyM: RemoteKey.menu,
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CallbackShortcuts(
      bindings: keyMaps.map(
        (key, value) => MapEntry(
          SingleActivator(key),
          () {
            bloc.add(AppsEvent.sendKey(value));
          },
        ),
      ),
      child: FocusScope(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: ListView(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Devices'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              bloc.add(const AppsEvent.getDeviceList());
                            },
                            icon: const Icon(Icons.replay_outlined),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddDeviceDialog(
                                  onAddDevice: (device) {
                                    bloc.add(AppsEvent.addDevice(device));
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<AppsBloc, AppsState>(
                      buildWhen: (_, current) => current.maybeWhen(
                        getDeviceListSuccess: (_) => true,
                        orElse: () => false,
                      ),
                      builder: (context, state) {
                        return state.maybeWhen(
                          getDeviceListSuccess: (devicies) => Wrap(
                            children: devicies
                                .map((device) => AppCard(
                                      '${device.name}\n${device.ipAddress}:${device.port}',
                                      onTap: () => bloc.add(
                                        AppsEvent.selectDevice(device.name),
                                      ),
                                      onRemove: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: const Text(
                                                'Are you sure you want to remove this device?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  bloc.add(
                                                    AppsEvent.removeDevice(
                                                      device.name,
                                                    ),
                                                  );
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      isSelected: device.isSelected,
                                      width: 150,
                                    ))
                                .toList(),
                          ),
                          orElse: () => const SizedBox(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _RemoteEmulator(),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<AppsBloc, AppsState>(
                                buildWhen: (previous, current) =>
                                    current.maybeWhen(
                                  captureScreenSuccess: (_) => true,
                                  orElse: () => false,
                                ),
                                builder: (context, state) {
                                  final Widget placeHolder = Container(
                                    color: Colors.grey,
                                    height: 200,
                                  );
                                  Widget content(Uint8List image) =>
                                      Image.memory(
                                        image,
                                        key: ValueKey(image),
                                        errorBuilder: (_, __, ___) =>
                                            placeHolder,
                                      );
                                  return state.maybeWhen(
                                    captureScreenSuccess: (image) =>
                                        GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: content(image),
                                          ),
                                        );
                                      },
                                      child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 200,
                                          ),
                                          child: content(image)),
                                    ),
                                    orElse: () => placeHolder,
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<AppsBloc, AppsState>(
                                    buildWhen: (previous, current) =>
                                        current.maybeWhen(
                                      getSoftwareVersionSuccess: (_) => true,
                                      orElse: () => false,
                                    ),
                                    builder: (context, state) {
                                      return state.maybeWhen(
                                        getSoftwareVersionSuccess: (buildId) =>
                                            Text.rich(
                                          TextSpan(
                                            text: 'Webos build id: ',
                                            children: [TextSpan(text: buildId)],
                                          ),
                                        ),
                                        orElse: () => const SizedBox(),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        children: [
                          Section(
                            title: 'Input Apps',
                            children: mapAppIds.entries
                                .map((e) => ActionButton(
                                      event: AppsEvent.launchApp(e.value),
                                      title: e.key,
                                    ))
                                .toList(),
                          ),
                          Section(
                            title: 'Change Country',
                            children: CountryData.values
                                .map((countryData) => ActionButton(
                                      event:
                                          AppsEvent.changeCountry(countryData),
                                      title: countryData.countryName,
                                    ))
                                .toList(),
                          ),
                          Section(
                            title: 'Apps',
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      appIdController.text = 'com.webos.app.';
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CallbackShortcuts(
                                              bindings: {
                                                const SingleActivator(
                                                    LogicalKeyboardKey
                                                        .enter): () {
                                                  if (appIdController
                                                      .text.isNotEmpty) {
                                                    bloc.add(
                                                      AppsEvent.launchApp(
                                                          appIdController.text),
                                                    );
                                                  }
                                                }
                                              },
                                              child: TextField(
                                                autofocus: true,
                                                controller: appIdController,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    bloc.add(
                                                      AppsEvent.launchApp(
                                                          appIdController.text),
                                                    );
                                                  },
                                                  child: const Text('Launch'),
                                                ),
                                                const SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    bloc.add(
                                                      AppsEvent.closeApp(
                                                          appIdController.text),
                                                    );
                                                  },
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child:
                                    const Text('Launch or close app by AppId'),
                              ),
                              const ActionButton(
                                  event: AppsEvent.launchSocketApp()),
                              const ActionButton(
                                  event: AppsEvent.reloadHomeApp()),
                            ],
                          ),
                          const Section(
                            title: 'Utils',
                            children: [
                              ActionButton(
                                event: AppsEvent.acceptUserAgrements(),
                              ),
                              ActionButton(event: AppsEvent.factoryReset()),
                              ActionButton(event: AppsEvent.activateDevMode()),
                              ActionButton(event: AppsEvent.rebootDevice()),
                              ActionButton(
                                event: AppsEvent.getForegroundAppName(),
                              ),
                              ActionButton(
                                  event: AppsEvent.turnOnScreenSaver()),
                              ActionButton(event: AppsEvent.updateDNS()),
                              ActionButton(
                                  event: AppsEvent.getSoftwareVersion()),
                              ActionButton(
                                event: AppsEvent.switchAudioGuidance(true),
                                title: 'Audio guidance on',
                              ),
                              ActionButton(
                                event: AppsEvent.switchAudioGuidance(false),
                                title: 'Audio guidance off',
                              ),
                            ],
                          ),
                          const Section(title: 'UI Language', children: [
                            ActionButton(
                              event: AppsEvent.changeLanguage('en-GB'),
                              title: 'English UK (GB)',
                            ),
                            ActionButton(
                              event: AppsEvent.changeLanguage('ko-KR'),
                              title: 'Korean',
                            ),
                            ActionButton(
                              event: AppsEvent.changeLanguage('ar-SA'),
                              title: 'Arabic',
                            )
                          ]),
                          Section(
                            title: 'Country code and Services Country',
                            children: CountryData.values
                                .map(
                                  (e) => ActionButton(
                                    event: AppsEvent.changeServiceCountry(e),
                                    title: e.countryName,
                                  ),
                                )
                                .toList(),
                          ),
                          Section(
                            title: 'TV Modes',
                            children: TVMode.values
                                .map(
                                  (mode) => ActionButton(
                                    event: AppsEvent.changeTVMode(mode),
                                    title: mode.title,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _RemoteEmulator extends StatelessWidget {
  const _RemoteEmulator();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppsBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SectionTitle('Remote'),
        IconButton(
          onPressed: () => bloc.add(const AppsEvent.sendKey(RemoteKey.up)),
          icon: const Icon(Icons.arrow_drop_up),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () =>
                  bloc.add(const AppsEvent.sendKey(RemoteKey.left)),
              icon: const Icon(Icons.arrow_left),
            ),
            IconButton(
              onPressed: () =>
                  bloc.add(const AppsEvent.sendKey(RemoteKey.enter)),
              icon: const Icon(Icons.check_circle),
            ),
            IconButton(
              onPressed: () =>
                  bloc.add(const AppsEvent.sendKey(RemoteKey.right)),
              icon: const Icon(Icons.arrow_right),
            ),
          ],
        ),
        IconButton(
          onPressed: () => bloc.add(const AppsEvent.sendKey(RemoteKey.down)),
          icon: const Icon(Icons.arrow_drop_down),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () =>
                  bloc.add(const AppsEvent.sendKey(RemoteKey.back)),
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () =>
                  bloc.add(const AppsEvent.sendKey(RemoteKey.home)),
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () =>
                  bloc.add(const AppsEvent.sendKey(RemoteKey.menu)),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ],
    );
  }
}
