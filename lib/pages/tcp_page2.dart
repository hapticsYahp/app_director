import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wifi_app/providers/tcp/tcp_client.dart';
import 'package:wifi_app/providers/tcp/tcp_client_socket.dart';

import '../providers/poma/poma_client.dart';
import '../providers/poma/poma_socket_impl.dart';

class TcpPage2 extends StatefulWidget {
  const TcpPage2({super.key, required this.title});

  final String title;

  @override
  State<TcpPage2> createState() => _TcpPageState2();
}

class _TcpPageState2 extends State<TcpPage2> {
  String tcpServerHost = "172.24.149.223";
  int tcpServerPort = 3333;
  bool tcpDebug = true;

  TcpClient tcpClient = TcpClientSocket();
  late PomaClient pomaClient = PomaClient(PomaSocketImpl());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _tcpServerHostController = TextEditingController();
  final _tcpServerPortController = TextEditingController();

  @override
  void dispose() {
    _tcpServerHostController.dispose();
    _tcpServerPortController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tcpServerHostController.text = tcpServerHost;
    _tcpServerPortController.text = tcpServerPort.toString();
    pomaClient.onDebug.listen(messageReceived);
    // TODO: implement initState
    super.initState();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        tcpServerHost = _tcpServerHostController.text;
        tcpServerPort = int.tryParse(_tcpServerPortController.text)!;
      });
      debugPrint("TCP Server: $tcpServerHost:$tcpServerPort.");
    }
  }

  final List<String> messages = [];

  void messageReceived(String msg) {
    setState(() {
      messages.add(msg);
    });
  }

  void _startConnection() async {
    try {
      debugPrint("Intentando conectar a $tcpServerHost:$tcpServerPort.");
      await pomaClient.connect(tcpServerHost, tcpServerPort);
      debugPrint("Conectado");
    } catch (e) {
      debugPrint('Error de conexión: $e');
    }
  }

  void _endConnection() async {
    await pomaClient.disconnect();
  }

  String? selectedTopic;
  List<String> topics = [];

  void _listTopics() async {
    topics = await pomaClient.getTopics();
  }

  void _getTopic(String topic) async {
    String? value = await pomaClient.getTopicValue(topic);
    _showAlert("Get '$topic' result:", (value != null) ? value : 'N/A');
  }

  void _setTopic(String topic, String value) async {
    bool success = await pomaClient.setTopicValue(topic, value);
    _showAlert("Set '$topic' result:", success ? 'Success' : 'Fail');
  }

  void _clearMessages() {
    setState(() {
      messages.clear();
    });
  }

  void _showAlert(String title, String value) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(value),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _prompt(String title, String hint) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              // Cancela la entrada
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              // Retorna el texto
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PoMA Server"),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tcpServerHostController,
                          decoration: InputDecoration(
                            labelText: "Host",
                            hintText: "Ej: example.com, 127.0.0.1",
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Host inválido.';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _tcpServerPortController,
                          decoration: InputDecoration(
                            labelText: "Puerto",
                            hintText: "Ej: 3333",
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Puerto inválido.';
                            }
                            final port = int.tryParse(value);
                            if (port == null || port < 1 || port > 65535) {
                              return 'Puerto inválido (1-65535).';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveForm,
                    child: Text("Guardar"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(thickness: 2),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _startConnection,
                  child: Text("Iniciar Cliente PoMA"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _endConnection,
                  child: Text("Detener Cliente PoMA"),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(thickness: 2),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _listTopics,
                  child: Text("List"),
                ),
                SizedBox(width: 10),
                Text("Topic:"),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedTopic,
                  hint: Text("Select Topic"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTopic = newValue;
                    });
                  },
                  items: topics.map<DropdownMenuItem<String>>((String topic) {
                    return DropdownMenuItem<String>(
                      value: topic,
                      child: Text(topic),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: selectedTopic == null
                      ? null
                      : () => _getTopic(selectedTopic!),
                  child: Text("Get"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: selectedTopic == null
                      ? null
                      : () {
                          var random = Random();
                          _setTopic(
                              selectedTopic!, random.nextInt(100).toString());
                        },
                  child: Text("Set Random"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: selectedTopic == null
                      ? null
                      : () async {
                          String? value = await _prompt("Value?", "any value");
                          if (value != null) {
                            _setTopic(selectedTopic!, value);
                          }
                        },
                  child: Text("Ask Prompt"),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => Text(messages[index]),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
              ),
            ),
            ElevatedButton(
              onPressed: _clearMessages,
              child: Text("Clear"),
            ),
          ],
        ),
      ),
    );
  }
}
