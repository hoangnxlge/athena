import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'luna_event.dart';
part 'luna_state.dart';
part 'luna_bloc.freezed.dart';

class LunaBloc extends Bloc<LunaEvent, LunaState> {
  Future<String> callLunaApi(String endpoint, String? params) async {
    final process = await Process.start('ares-shell.cmd', [
      '-r',
      'luna-send -n 1 -f $endpoint \'${params ?? '{}'}\'',
    ]);
    String result = '';
    await process.stdout.transform(utf8.decoder).forEach((e) {
      result += e;
    });
    if (result.isEmpty) {
      await process.stderr.transform(utf8.decoder).forEach((e) {
        result += e;
      });
    }
    return result;
  }

  LunaBloc() : super(const _Initial()) {
    on<_CallApi>((event, emit) async {
      try {
        emit(const _Loading());
        final response = await callLunaApi(event.endpoint, event.params);
        emit(_Success(response));
      } catch (e) {
        emit(_Error(e.toString()));
      }
    });
  }
}
