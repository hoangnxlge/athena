// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';

import 'package:athena/features/apps/data/models/custom_device.dart';
import 'package:athena/features/apps/presentations/bloc/apps_bloc_mixin.dart';
import 'package:athena/utils/extensions/string_ext.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'apps_bloc.freezed.dart';
part 'apps_event.dart';
part 'apps_state.dart';

typedef CommandResult = ({
  String output,
  String err,
  Map<String, dynamic> outputMap
});

enum CountryData {
  gb(
    countryCode: '3122',
    code2: 'GB',
    code3: 'GBR',
    countryName: 'United Kingdom',
  ),
  kr(
    countryCode: '18048',
    code2: 'KR',
    code3: 'KOR',
    countryName: 'Korean',
  ),
  other(
    countryCode: '3122',
    code2: 'EU7',
    code3: 'EU7',
    countryName: 'Other',
  );

  const CountryData({
    required this.countryCode,
    required this.code2,
    required this.code3,
    required this.countryName,
  });
  final String countryCode, code2, code3, countryName;
}

enum TVMode {
  store,
  home;

  String get title => name.toTitle();
}

Map<String, dynamic> panelResolutions = {
  'UD': {'width': 1920, 'height': 1080},
  'WQHD': {'width': 1920, 'height': 804}
};

class AppsBloc extends Bloc<AppsEvent, AppsState> with AppsBlocMixin {
  AppsBloc() : super(const _Initial()) {
    on<_LaunchApp>(_onLaunchApp);
    on<_CloseApp>(_onCloseApp);
    on<_AddDevice>(_onAddDevice);
    on<_GetDeviceList>(_onGetDeviceList);
    on<_SelectDevice>(_onSelectDevice);
    on<_RemoveDevice>(_onRemoveDevice);
    on<_ActivateDevMode>(_onActivateDevMode);
    on<_ReloadHomeApp>(_onReloadHomeApp);
    on<_OpenSocketApp>(_onOpenSocketApp);
    on<_OpenNewSocketApp>(_onOpenNewSocketApp);
    on<_FactoryReset>(_onFactoryReset);
    on<_RebootDevice>(_onRebootDevice);
    on<_ChangeLanguage>(_onChangeLanguage);
    on<_SendKey>(_onSendKey);
    on<_ChangeServiceCountry>(_onChangeCountryCode);
    on<_GetForegroundAppName>(_onGetForegroundAppname);
    on<_CaptureScreen>(_onCaptureScreen);
    on<_ChangeTVMode>(_onChangeTVMode);
    on<_AcceptUserAgreements>(_onAcceptUserAgreements);
    on<_TurnOnScreenSaver>(_onTurnOnScreenSaver);
    on<_ChangeDNS>(_onChangeDNS);
    on<_GetSoftwareVersion>(_onGetSoftwareVersion);
    on<_SwitchAudioGuidance>(_onSwitchAudioGuidance);
    on<_ChangeCountry>(_onChangeCountry);
    on<_RecommendOn>(_onRecommend);
    on<_RecommendOff>(_offRecommend);
    on<_PromotionOn>(_onPromotion);
    on<_PromotionOff>(_offPromotion);
  }

  Future<void> safeCall(AsyncCallback function,
      {bool defaultState = true}) async {
    try {
      if (defaultState) emit(const _Loading());
      await function.call();
      if (defaultState) emit(const _Success());
    } catch (e) {
      emit(_Error(e.toString()));
    }
  }

  Future<void> _onAddDevice(_AddDevice event, Emitter<AppsState> emit) async {
    try {
      emit(const _Loading());
      final device = event.device;
      final result = await startProcess(
        'ares-setup-device.cmd',
        [
          '-a',
          event.device.name,
          '-i',
          'host=${device.ipAddress}',
          '-i',
          'port=${device.port}'
        ],
      );
      final deviceList = _getListDeviceFromDevicesString(result.output);
      emit(_GetDeviceListSuccess(deviceList));
    } catch (e) {
      emit(_Error(e.toString()));
    }
  }

  List<CustomDevice> _getListDeviceFromDevicesString(String devicesString) {
    List<String> rawData = devicesString.split('\n')
      ..removeRange(0, 2)
      ..removeLast();
    final data = rawData
        .map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' ').split(' '))
        .toList()
      ..removeLast();

    final List<CustomDevice> deviceList = data.map(
      (e) {
        final bool defaultDevice = e.contains('(default)');
        final data = e[defaultDevice ? 2 : 1].split('@').last.split(':');
        return CustomDevice(
          isSelected: defaultDevice,
          ipAddress: data.first,
          name: e.first,
          port: int.tryParse(data.last) ?? 0,
        );
      },
    ).toList();
    if (deviceList.isNotEmpty) deviceList.removeLast();
    return deviceList;
  }

  Future<void> _sendMacroKeys(List<RemoteKey> keys, {int delay = 500}) async {
    for (var key in keys) {
      await Future.delayed(Duration(milliseconds: delay));
      add(_SendKey(key));
    }
  }

  Future<void> _onGetDeviceList(
      _GetDeviceList event, Emitter<AppsState> emit) async {
    await safeCall(
      () async {
        emit(const _Loading());
        final result = await startProcess('ares-setup-device.cmd', ['-l']);
        final List<CustomDevice> deviceList =
            _getListDeviceFromDevicesString(result.output);
        emit(_GetDeviceListSuccess(deviceList));
      },
      defaultState: false,
    );
  }

  Future<void> _onSelectDevice(event, Emitter<AppsState> emit) async {
    await safeCall(
      () async {
        emit(const _Loading());
        await startProcess('ares-config.cmd', ['-p', 'ose']);
        final result = await startProcess(
            'ares-setup-device.cmd', ['-f', event.deviceName]);
        final deviceList = _getListDeviceFromDevicesString(result.output);
        defaultDeviceName = event.deviceName;
        emit(_GetDeviceListSuccess(deviceList));
      },
      defaultState: false,
    );
  }

  Future<void> _onRemoveDevice(event, Emitter<AppsState> emit) async {
    await safeCall(
      () async {
        emit(const _Loading());
        final result = await startProcess(
            'ares-setup-device.cmd', ['-r', event.deviceName]);
        final deviceList = _getListDeviceFromDevicesString(result.output);
        emit(_GetDeviceListSuccess(deviceList));
      },
      defaultState: false,
    );
  }

  Future<void> _onActivateDevMode(
      _ActivateDevMode event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await sendShellCommand(
        'touch /var/luna/preferences/devmode_enabled && touch /var/luna/preferences/debug_system_apps && touch /var/luna/preferences/debug_system_services && reboot',
      );
    });
  }

  Future<void> _onReloadHomeApp(
      _ReloadHomeApp event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await sendShellCommand('kill \$(pgrep flutter-client)');
    });
  }

  Future<void> _onOpenNewSocketApp(
      _OpenNewSocketApp event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.service.applicationmanager/launch',
        param: '{"id":"com.app.ls2bridge"}',
      );
    });
  }

  Future<void> _onOpenNewSocketApp(
      _OpenNewSocketApp event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.service.applicationmanager/launch',
        param: '{"id":"com.app.ls2bridge"}',
      );
    });
  }

  Future<void> _onOpenSocketApp(
      _OpenSocketApp event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      try {
        await callLunaApi(
          'luna://com.webos.service.applicationmanager/closeByAppId',
          param: '{"id":"com.webos.app.ls2bridge"}',
        );
      } catch (_) {}
      await callLunaApi(
        'luna://com.webos.service.applicationmanager/launch',
        param: '{"id":"com.webos.app.ls2bridge"}',
      );
      await Future.delayed(const Duration(seconds: 3));
      await _sendMacroKeys([RemoteKey.up, RemoteKey.enter, RemoteKey.enter]);
    });
  }

  Future<void> _onLaunchApp(_LaunchApp event, Emitter<AppsState> emit) async {
    await safeCall(
      () async {
        await startProcess(
          'ares-launch.cmd',
          ['-d', defaultDeviceName, event.appId],
        );
      },
    );
  }

  Future<void> _onCloseApp(_CloseApp event, Emitter<AppsState> emit) async {
    emit(const _Loading());
    await safeCall(() async {
      await Process.run(
        'ares-launch.cmd',
        ['-d', defaultDeviceName, '--close', event.appId],
      );
    });
  }

  Future<void> _onFactoryReset(
      _FactoryReset event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.service.devicereset/doReset',
        param: '{ "resetType" : "instop", "reboot" : true, "osdNeed":true }',
      );
    });
  }

  Future<void> _onRebootDevice(
      _RebootDevice event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await sendShellCommand('reboot');
    });
  }

  Future<void> _onChangeLanguage(
      _ChangeLanguage event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param:
            '{"settings":{"localeInfo":{"locales":{"UI": "${event.language}" }}}}',
      );
    });
  }

  Future<void> _onSendKey(_SendKey event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.service.networkinput/sendSpecialKey',
        param: '{"key" : "${event.remoteKey.key}"}',
      );
    }, defaultState: false);
  }

  Future<void> _onChangeCountryCode(
      _ChangeServiceCountry event, Emitter<AppsState> emit) async {
    final countryData = event.countryData;
    await safeCall(
      () async {
        await callLunaApi(
          'luna://com.webos.service.factorymanager/test',
          param: '{"test_id" : "area", "pwd" : 1206}',
        );
        await callLunaApi(
          'luna://com.webos.service.factorymanager/setFactoryOpt',
          param: '{"contiArea2All" : ${countryData.countryCode}}',
        );
        await callLunaApi(
          'luna://com.webos.service.sdx/setCountrySettingByManual',
          param:
              '{"code2" :"${countryData.code2}","code3" : "${countryData.code3}", "type" : "smart", "uniqueIndex" : 1234}',
        );
      },
    );
  }

  Future<void> _onGetForegroundAppname(
      _GetForegroundAppName event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      emit(const _Loading());
      final result = await callLunaApi(
        'luna://com.webos.applicationManager/getForegroundAppInfo',
      );
      final resultMap = result.outputMap;
      emit(_GetForegroundAppNameSuccess(resultMap['appId'] ?? ''));
    }, defaultState: false);
  }

  Future<void> _onCaptureScreen(
      _CaptureScreen event, Emitter<AppsState> emit) async {
    await safeCall(defaultState: false, () async {
      emit(const _Initial());
      final resolutionResult = await callLunaApi(
        'luna://com.webos.service.panelcontroller/getPanelResolution',
      );
      final resolutionStr = resolutionResult.outputMap['resolution'];
      final resolution = panelResolutions[resolutionStr];
      if (resolution == null) {
        add(const _CaptureScreen());
        return;
      }
      await callLunaApi(
        'luna://com.webos.service.capture/executeOneShot',
        param:
            '{"path":"/home/root/screenshot.jpeg", "method":"DISPLAY", "width":${resolution['width']}, "height":${resolution['height']}, "format":"JPEG"}',
      );
      final tempPath = Directory.systemTemp.path;
      await startProcess('ares-pull.cmd', [
        '-d',
        defaultDeviceName,
        '/home/root/screenshot.jpeg',
        tempPath,
      ]);
      final image = File('$tempPath\\screenshot.jpeg');
      emit(_CaptureScreenSuccess(image.readAsBytesSync()));
    });
  }

  Future<void> _onChangeTVMode(
      _ChangeTVMode event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param:
            '{"settings":{"storeMode":"${event.mode.name}"} ,"category":"option"}',
      );
    });
  }

  Future<void> _onAcceptUserAgreements(
      _AcceptUserAgreements event, Emitter<AppsState> emit) async {
    await safeCall(
      () async {
        await callLunaApi(
          'luna://com.lge.settingsservice/setSystemSettings',
          param:
              '{"settings":{"eulaStatus": {"acrAllowed": true,"additionalDataAllowed": true,"cookiesAllowed": true,"customAdAllowed": true,"customadsAllowed": true,"generalTermsAllowed": true,"networkAllowed": true,"remoteDiagAllowed": true,"voiceAllowed": true }}}',
        );
      },
    );
  }

  Future<void> _onTurnOnScreenSaver(
      _TurnOnScreenSaver event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.service.tvpower/power/turnOnScreenSaver',
      );
    });
  }

  Future<void> _onChangeDNS(_ChangeDNS event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'palm://com.palm.connectionmanager/setdns',
        param: '{"dns":["${event.dns}"]}',
      );
    });
  }

  Future<FutureOr<void>> _onGetSoftwareVersion(
      _GetSoftwareVersion event, Emitter<AppsState> emit) async {
    await safeCall(
      () async {
        emit(const _Initial());
        final result = await callLunaApi(
            'luna://com.webos.service.systemservice/osInfo/query');
        final String buildId = result.outputMap['webos_build_id'];
        emit(_GetSoftwareVersionSuccess(buildId));
      },
      defaultState: false,
    );
  }

  Future<void> _onSwitchAudioGuidance(
      _SwitchAudioGuidance event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param: '{"category" :"option", "settings":{"audioGuidance":"off"}}',
      );
    });
  }

  FutureOr<void> _onChangeCountry(
      _ChangeCountry event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param:
            '{"category" :"option", "settings":{"country":"${event.country.code3}"}}',
      );
    });
  }

  FutureOr<void> _onRecommend(
      _RecommendOn event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param:
            '{"category":"other", "settings":{"contentRecommendation": "on"}}',
      );
    });
  }

  FutureOr<void> _offRecommend(
      _RecommendOff event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param:
            '{"category":"other", "settings":{"contentRecommendation": "off"}}',
      );
    });
  }

  FutureOr<void> _onPromotion(
      _PromotionOn event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param: '{"category":"general", "settings":{"homePromotion":"on"}}',
      );
    });
  }

  FutureOr<void> _offPromotion(
      _PromotionOff event, Emitter<AppsState> emit) async {
    await safeCall(() async {
      await callLunaApi(
        'luna://com.webos.settingsservice/setSystemSettings',
        param: '{"category":"general", "settings":{"homePromotion":"off"}}',
      );
    });
  }
}
