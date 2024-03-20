import 'package:athena/features/luna_api/presentaion/bloc/luna_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LunaApiRoute {
  static Widget get route => BlocProvider(
        create: (context) => LunaBloc(),
        child: BlocListener<LunaBloc, LunaState>(
          listener: (context, state) {
            if (ModalRoute.of(context)?.isCurrent == false) {
              Navigator.pop(context);
            }
            state.whenOrNull(
              loading: () {
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text('Loading'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: const LunaApiPage(),
        ),
      );
}

class LunaApiPage extends StatefulWidget {
  const LunaApiPage({super.key});

  @override
  State<LunaApiPage> createState() => _LunaApiPageState();
}

class _LunaApiPageState extends State<LunaApiPage>
    with AutomaticKeepAliveClientMixin {
  final textFieldDecoration = const InputDecoration(
    border: OutlineInputBorder(),
    isDense: true,
    contentPadding: EdgeInsets.all(12),
  );

  late final bloc = context.read<LunaBloc>();
  final endPointController = TextEditingController();
  final paramsController = TextEditingController();

  @override
  void dispose() {
    endPointController.dispose();
    paramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: endPointController,
                      decoration: textFieldDecoration.copyWith(
                        labelText: 'Luna endpoint',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: paramsController,
                      decoration: textFieldDecoration.copyWith(
                        labelText: 'Params',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  bloc.add(
                    LunaEvent.callApi(
                      endpoint: endPointController.text.replaceAll(' ', ''),
                      params: paramsController.text.isNotEmpty
                          ? paramsController.text.trim()
                          : null,
                    ),
                  );
                },
                icon: const Icon(Icons.send),
              )
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: BlocBuilder<LunaBloc, LunaState>(
              buildWhen: (_, current) => current.maybeWhen(
                success: (_) => true,
                orElse: () => false,
              ),
              builder: (context, state) {
                return Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: state.maybeWhen(
                          success: (result) => Stack(
                            children: [
                              SelectableText(result),
                            ],
                          ),
                          orElse: () => const SizedBox(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: state.maybeWhen(
                        success: (result) => Visibility(
                          visible: result.isNotEmpty,
                          child: IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: result),
                              );
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ),
                        orElse: () => const SizedBox(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
