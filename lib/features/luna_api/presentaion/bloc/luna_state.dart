part of 'luna_bloc.dart';

@freezed
class LunaState with _$LunaState {
  const factory LunaState.initial() = _Initial;
  const factory LunaState.loading() = _Loading;
  const factory LunaState.success(String result) = _Success;
  const factory LunaState.error(String err) = _Error;
}
