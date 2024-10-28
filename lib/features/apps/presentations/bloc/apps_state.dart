part of 'apps_bloc.dart';

@freezed
class AppsState with _$AppsState {
  const factory AppsState.initial() = _Initial;
  const factory AppsState.loading() = _Loading;
  const factory AppsState.activateDevModeSuccess() = _ActivateDevModeSuccess;
  const factory AppsState.launchAppSuccess() = _LaunchAppSuccess;
  const factory AppsState.closeAppSuccess() = _CloseAppSuccess;
  const factory AppsState.success() = _Success;
  const factory AppsState.getAppListSuccess(List<String> appList) =
      _GetAppListSuccess;
  const factory AppsState.error(String err) = _Error;
  const factory AppsState.getDeviceListSuccess(List<CustomDevice> devicies) =
      _GetDeviceListSuccess;
  const factory AppsState.getForegroundAppNameSuccess(String appId) =
      _GetForegroundAppNameSuccess;
  const factory AppsState.showSnackbar(String message) =
      _ShowSnackbar;
  const factory AppsState.captureScreenSuccess(Uint8List image) =
      _CaptureScreenSuccess;
  const factory AppsState.getSoftwareVersionSuccess(String version) =
      _GetSoftwareVersionSuccess;
   const factory AppsState.getPromotionSuccess(bool enable) =
      _GetPromotionSuccess;
}
