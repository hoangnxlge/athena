import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_device.g.dart';
part 'custom_device.freezed.dart';

@freezed
class CustomDevice with _$CustomDevice {
  const CustomDevice._();
  const factory CustomDevice({
    @Default('') String name,
    @Default('') String ipAddress,
    @Default(0) int port,
    @Default(false) bool isSelected,
  }) = _CustomDevice;
  factory CustomDevice.fromJson(Map<String, dynamic> json) =>
      _$CustomDeviceFromJson(json);
}
