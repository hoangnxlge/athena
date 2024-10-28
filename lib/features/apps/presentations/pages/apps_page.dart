import 'dart:async';

import 'package:athena/features/apps/presentations/shared/widgets/app_card.dart';
import 'package:athena/features/apps/presentations/shared/widgets/section.dart';
import 'package:athena/features/apps/presentations/shared/widgets/section_title.dart';
import 'package:athena/shared/widgets/app_snack_bar.dart';
import 'package:athena/shared/widgets/edit_text_widget.dart';
import 'package:athena/shared/widgets/launch_by_id_widget.dart';
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
  late final _bloc = context.read<AppsBloc>();
  final _appIdController = TextEditingController();
  String _customVoice = 'Select Home Hub';
  String _languageVoice = 'en-GB';
  final _mapAppIds = {
    'Home': 'com.webos.app.home',
    'Hdmi 1': 'com.webos.app.hdmi1',
    'Hdmi 2': 'com.webos.app.hdmi2',
    'Hdmi 3': 'com.webos.app.hdmi3',
    'Hdmi 4': 'com.webos.app.hdmi4',
    'Lg Channels': 'com.webos.app.lgchannels',
    'Live TV': 'com.webos.app.livetv',
    'Channel Manager': 'com.webos.app.channeledit',
    'Channel Tunning': 'com.webos.app.channelsetting',
    'Socket': 'com.app.ls2bridge',
  };
  final _move = [
    'Left',
    'Right',
    'Bottom',
    'Top',
    'Up',
    'Down',
  ];
  final _scroll = [
    'up',
    'down',
    'top',
    'bottom',
    'left',
    'right',
    'leftmost',
    'rightmost',
    'next',
    'previous',
    'first',
    'last',
  ];
  @override
  void initState() {
    _bloc
      ..add(const AppsEvent.getDeviceList())
      ..add(const AppsEvent.captureScreen());
    super.initState();
  }

  @override
  void dispose() {
    _appIdController.dispose();
    super.dispose();
  }

  late final Map<SingleActivator, VoidCallback> keyMaps = {
    LogicalKeyboardKey.keyK: RemoteKey.up,
    LogicalKeyboardKey.keyJ: RemoteKey.down,
    LogicalKeyboardKey.keyH: RemoteKey.left,
    LogicalKeyboardKey.keyL: RemoteKey.right,
    LogicalKeyboardKey.keyO: RemoteKey.enter,
    LogicalKeyboardKey.keyB: RemoteKey.back,
    LogicalKeyboardKey.escape: RemoteKey.exit,
    LogicalKeyboardKey.f1: RemoteKey.home,
    LogicalKeyboardKey.keyM: RemoteKey.menu,
  }.map(
    (key, value) => MapEntry(
      SingleActivator(key),
      () => _bloc.add(AppsEvent.sendKey(value)),
    ),
  );
  late final Map<SingleActivator, VoidCallback> appShortcuts = {
    LogicalKeyboardKey.digit1: 'com.webos.app.hdmi1',
    LogicalKeyboardKey.digit2: 'com.webos.app.hdmi2',
    LogicalKeyboardKey.digit3: 'com.webos.app.hdmi3',
    LogicalKeyboardKey.digit4: 'com.webos.app.hdmi4',
    LogicalKeyboardKey.digit5: 'com.webos.app.livetv',
    LogicalKeyboardKey.digit6: 'com.webos.app.lgchannels',
  }.map(
    (key, value) => MapEntry(
      SingleActivator(key),
      () {
        _bloc.add(
          AppsEvent.launchApp(value),
        );
      },
    ),
  );

  bool _enabledPromotion = false;
  bool _enabledRecommend = false;
  bool _enabledNetWork = false;
  bool _enabledAudioGuidance = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CallbackShortcuts(
      bindings: {...keyMaps, ...appShortcuts},
      child: FocusScope(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 180,
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
                              _bloc.add(const AppsEvent.getDeviceList());
                            },
                            icon: const Icon(Icons.replay_outlined),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddDeviceDialog(
                                  onAddDevice: (device) {
                                    _bloc.add(AppsEvent.addDevice(device));
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
                                      onTap: () => _bloc.add(
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
                                                  _bloc.add(
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
                          Section(title: 'Ads', children: [
                            ActionButton(
                              event: _enabledPromotion
                                  ? const AppsEvent.promotionOff()
                                  : const AppsEvent.promotionOn(),
                              title: 'Promotion',
                              callback: () {
                                setState(() {
                                  _enabledPromotion = !_enabledPromotion;
                                });
                              },
                              enable: _enabledPromotion,
                            ),
                            ActionButton(
                              event: _enabledRecommend
                                  ? const AppsEvent.recommendOff()
                                  : const AppsEvent.recommendOn(),
                              title: 'Recommendation',
                              enable: _enabledRecommend,
                              callback: () {
                                setState(() {
                                  _enabledRecommend = !_enabledRecommend;
                                });
                              },
                            ),
                          ]),
                          const Section(title: 'Power On Screen', children: [
                            ActionButton(
                              event: AppsEvent.powerOnRecentInput(),
                              title: 'Recent input',
                            ),
                            ActionButton(
                              event: AppsEvent.powerOnHomeApp(),
                              title: 'Home App',
                            ),
                            ActionButton(
                              event: AppsEvent.changeServerQA2(),
                              title: 'QA2',
                            ),
                          ]),
                          Section(
                            title: 'Input Apps',
                            children: _mapAppIds.entries
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
                                      _appIdController.text = 'com.webos.app.';
                                      return LaunchByIdWidget(
                                        appIdController: _appIdController,
                                        bloc: _bloc,
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
                          Section(
                            title: 'Utils',
                            children: [
                              const ActionButton(
                                  event: AppsEvent.rotateScreen()),
                              const ActionButton(
                                  event: AppsEvent.acceptUserAgrements()),
                              const ActionButton(
                                  event: AppsEvent.factoryReset()),
                              const ActionButton(
                                  event: AppsEvent.activateDevMode()),
                              const ActionButton(
                                  event: AppsEvent.rebootDevice()),
                              const ActionButton(
                                event: AppsEvent.getForegroundAppName(),
                              ),
                              const ActionButton(
                                  event: AppsEvent.turnOnScreenSaver()),
                              ActionButton(
                                title: 'Network',
                                event: _enabledNetWork
                                    ? const AppsEvent.changeDNS('127.0.0.0')
                                    : const AppsEvent.changeDNS('192.168.0.1'),
                                enable: _enabledNetWork,
                                callback: () {
                                  setState(() {
                                    _enabledNetWork = !_enabledNetWork;
                                  });
                                },
                              ),
                              const ActionButton(
                                  event: AppsEvent.getSoftwareVersion()),
                              ActionButton(
                                event: _enabledAudioGuidance
                                    ? const AppsEvent.switchAudioGuidance(false)
                                    : const AppsEvent.switchAudioGuidance(true),
                                title: 'Audio guidance',
                                enable: _enabledAudioGuidance,
                                callback: () {
                                  setState(() {
                                    _enabledAudioGuidance =
                                        !_enabledAudioGuidance;
                                  });
                                },
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
                          Section(
                            title: 'Voice control',
                            children: [
                              Section(title: 'Language', children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditTextWidget(
                                          text: _languageVoice,
                                        );
                                      },
                                    );
                                    if (result != null) {
                                      setState(() {
                                        _languageVoice = result;
                                      });
                                    }
                                  },
                                  child: Text(_languageVoice),
                                ),
                              ]),
                              Section(
                                title: 'Custom text',
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditTextWidget(
                                            text: _customVoice,
                                          );
                                        },
                                      );
                                      if (result != null) {
                                        setState(() {
                                          _customVoice = result;
                                        });
                                      }
                                    },
                                    child: Text(_customVoice),
                                  ),
                                  ActionButton(
                                    event: AppsEvent.voiceControl(
                                      _customVoice,
                                      _languageVoice,
                                    ),
                                    title: 'Go',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Section(
                            title: 'Move',
                            children: List.generate(
                              _move.length,
                              (index) {
                                final value = _move[index];
                                return ActionButton(
                                  event: AppsEvent.voiceControl(
                                    'move $value',
                                    _languageVoice,
                                  ),
                                  title: value.toUpperCase(),
                                );
                              },
                            ),
                          ),
                          Section(
                            title: 'Scroll',
                            children: List.generate(
                              _scroll.length,
                              (index) {
                                final value = _scroll[index];
                                return ActionButton(
                                  event: AppsEvent.voiceControl(
                                    'Scroll $value',
                                    _languageVoice,
                                  ),
                                  title: value.toUpperCase(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 50,
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
            IconButton(
              onPressed: () => bloc.add(const AppsEvent.rebootDevice()),
              icon: const Icon(Icons.power_settings_new),
            ),
            IconButton(
              onPressed: () => bloc.add(const AppsEvent.reloadHomeApp()),
              icon: const Icon(Icons.replay_outlined),
            ),
          ],
        ),
      ],
    );
  }
}
