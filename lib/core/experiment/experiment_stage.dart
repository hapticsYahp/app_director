import 'package:flutter/material.dart';
import '../../providers/poma/poma_client.dart';

abstract class ExperimentStage<T_Result> {
  final String id;
  final String title;
  final String description;
  final Map<String, String> pomaCommands;
  PomaClient? pomaClient;

  ExperimentStage({
    required this.id,
    required this.title,
    required this.description,
    this.pomaCommands = const {},
  });

  void setPomaClient(PomaClient pomaClient) {
    this.pomaClient = pomaClient;
  }

  void _pomaCallback(String eventKey) {
    if (pomaCommands.containsKey(eventKey)) {
      String pomaCommand = pomaCommands[eventKey]!;
      if ((pomaClient != null) && pomaClient!.isConnected()) {
        pomaClient!.send(pomaCommand);
      } else {
        debugPrint("Sending PoMA command: '$pomaCommand'."); // TODO: quitar.
      }
    }
  }

  void onEnter() {
    _pomaCallback("ENTER");
  }

  void onExit() {
    _pomaCallback("EXIT");
  }

  void onTick(int seconds) {
    _pomaCallback("TICK_$seconds");
  }

  Widget buildWidget(
    BuildContext context,
    void Function(T_Result result) onResult,
  );
}
