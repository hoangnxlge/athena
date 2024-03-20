import 'dart:convert';
import 'dart:io';

import 'package:athena/core/error/exceptions.dart';
import 'package:athena/features/apps/presentations/bloc/apps_bloc.dart';

mixin AppsBlocMixin {
  String defaultDeviceName = '';

  void throwException() {}

  Future<CommandResult> sendShellCommand(String command) async {
    try {
      final process = await Process.start(
        'ares-shell.cmd',
        [
          '-d',
          defaultDeviceName,
          '-r',
          command,
        ],
      );
      String output = '';
      String error = '';
      await process.stdout.transform(utf8.decoder).forEach((out) {
        output += out;
      });
      await process.stderr.transform(utf8.decoder).forEach((err) {
        error += err;
      });
      process.kill();
      Map<String, dynamic> outputMap = {};
      try {
        outputMap = jsonDecode(output);
      } catch (_) {}
      if (outputMap['returnValue'] == false) {
        throw LunaException(outputMap['errorText']);
      } else if (error.isNotEmpty && !error.contains('warning')) {
        throw LocalException(error);
      }
      return (output: output, err: error, outputMap: outputMap);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CommandResult> callLunaApi(
    String endpoint, {
    String param = '{}',
  }) async {
    try {
      final process = await Process.start(
        'ares-shell.cmd',
        [
          '-r',
          'luna-send -n 1 -f $endpoint \'$param\'',
        ],
      );
      String output = '';
      String error = '';
      await process.stdout.transform(utf8.decoder).forEach((out) {
        output += out;
      });
      await process.stderr.transform(utf8.decoder).forEach((err) {
        error += err;
      });
      process.kill();
      Map<String, dynamic> outputMap = {};
      try {
        outputMap = jsonDecode(output);
      } catch (_) {}
      if (outputMap['returnValue'] == false) {
        throw LunaException(outputMap['errorText']);
      } else if (error.isNotEmpty && !error.contains('warning')) {
        throw LocalException(error);
      }
      return (output: output, err: error, outputMap: outputMap);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CommandResult> startProcess(
    String command, [
    List<String> arguments = const [],
  ]) async {
    try {
      final process = await Process.start(
        command,
        arguments,
      );
      String output = '';
      String error = '';
      await process.stdout.transform(utf8.decoder).forEach((out) {
        output += out;
      });
      await process.stderr.transform(utf8.decoder).forEach((err) {
        error += err;
      });
      process.kill();
      Map<String, dynamic> outputMap = {};
      try {
        outputMap = jsonDecode(output);
      } catch (_) {}
      if (outputMap['returnValue'] == false) {
        throw LunaException(outputMap['errorText']);
      } else if (error.isNotEmpty && !error.contains('warning')) {
        throw LocalException(error);
      }
      return (output: output, err: error, outputMap: outputMap);
    } catch (e) {
      throw Exception(e);
    }
  }
}
