part of 'luna_bloc.dart';

@freezed
class LunaEvent with _$LunaEvent {
  const factory LunaEvent.started() = _Started;
  const factory LunaEvent.callApi({
    required String endpoint,
    String? params,
  }) = _CallApi;
}
