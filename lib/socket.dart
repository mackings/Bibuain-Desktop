import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class Socket extends StatefulWidget {
  const Socket({super.key});

  @override
  State<Socket> createState() => _SocketState();
}

class _SocketState extends State<Socket> {
  late IO.Socket socket;
  List<String> messages = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  Future<void> connectSocket() async {

    try {
      const connectionPoint = 'https://b-backend-xe8q.onrender.com';

      // socket = IO.io('https://b-backend-xe8q.onrender.com:1000', <String, dynamic>{
      //   'transports': ['websocket'],
      //   'autoConnect': true,
      //   'timeout': 20000,
      // });


      socket = IO.io(
          connectionPoint,
          OptionBuilder().setTransports(['websocket'])
              .build());

      print("Socket: ${socket.io.options}");

      socket.onConnect((_) {
        print("Socket Connected");
        setState(() {
          errorMessage = '';
        });
        socket.emit('msg', 'Hello from Flutter');
      });

      socket.onConnectError((error) {
        setState(() {
          errorMessage = 'Connect Error: $error';
        });
      });

      socket.onError((error) {
        print("Socket Error: $error");
        setState(() {
          errorMessage = 'Socket Error: $error';
        });
      });

      socket.onDisconnect((_) {
        print("Socket Disconnected");
        setState(() {
          errorMessage = 'Socket Disconnected';
        });
      });

      socket.on('trade.started', (data) {
        print("Trade started: $data");
        final decodedData = jsonDecode(data);
        setState(() {
          messages.add("Trade started: $decodedData");
        });
      });

      socket.on('trade.chat_message_received', (data) {
        print("Chat message received: $data");
        final decodedData = jsonDecode(data);
        setState(() {
          messages.add("Chat message received: $decodedData");
        });
      });

      socket.on('trade.paid', (data) {
        print("Trade paid: $data");
        final decodedData = jsonDecode(data);
        setState(() {
          messages.add("Trade paid: $decodedData");
        });
      });

      socket.connect();
    } catch (e) {
      print("Error connecting: $e");
      setState(() {
        errorMessage = 'Error connecting: $e';
      });
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebSocket Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
