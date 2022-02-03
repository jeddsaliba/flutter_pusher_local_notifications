// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:pusher_channels/pusher_channels.dart';
import 'package:flutter_pusher_local_notifications/api/notification_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final pusher = Pusher(key: 'c2e71194e50d91c91f03', cluster: 'ap1');

  bool isConnected = false;
  bool isBinded = false;

  @override
  void initState() {
    super.initState();
    initPusher();
    NotificationApi.init();
    listenNotifications();
  }
  void listenNotifications() {
    NotificationApi.onNotifications.stream.listen(onClickedNotification);
  }
  void onClickedNotification(String? payload) {
    /* DO SOMETHING WHEN YOU CLICK ON THE NOTIFICATION */
  }
  Future<void> initPusher() async { /* INITIALIZE PUSHER CONNECTION */
    /* pusher = Pusher(key: 'c2e71194e50d91c91f03', cluster: 'ap1'); */
    //pusher.connect().whenComplete(() => ).onError((error, stackTrace) => null).catchError(onError)
    //await pusher.connect();
    /* LISTEN TO MESSAGES : START */
    /* final messageChannel = pusher.subscribe('message');
    messageChannel.bind('message', (dynamic data) {
      var payload = data['message'];
      var sender = payload['user']['first_name'] + ' ' + payload['user']['last_name'];
      var message = payload['message'];
      print(payload);
      NotificationApi.showNotification(title: sender, body: message, payload: payload.toString());
    }); */
    /* LISTEN TO MESSAGES : END */
  }
  Future<void> _pusherConnect() async {
    await pusher.connect().whenComplete(() {
      print("connected");
      setState(() {
        isConnected = true;
      });
    }).onError((error, stackTrace) {
      print(error);
      setState(() {
        isConnected = false;
      });
    }).catchError((onError) {
      print(onError);
      setState(() {
        isConnected = false;
      });
    });
  }
  Future<void> _pusherDisconnect() async {
    pusher.unbindGlobal();
    pusher.disconnect();
    print("disconnected");
    setState(() {
      isConnected = false;
    });
  }
  Future<void> _connectToMessageLogs() async {
    final messageChannel = pusher.subscribe('message');
    setState(() {
      isBinded = true;
    });
    messageChannel.bind('message', (dynamic data) {
      var payload = data['message'];
      var sender = payload['user']['first_name'] + ' ' + payload['user']['last_name'];
      var message = payload['message'];
      print(payload);
      NotificationApi.showNotification(title: sender, body: message, payload: payload.toString());
    });
  }
  Future<void> _disconnectToMessageLogs() async {
    pusher.unsubscribe('message');
    setState(() {
      isBinded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () => !isConnected ? _pusherConnect() : _pusherDisconnect(),
              child: !isConnected ? const Text('Connect to Pusher') : const Text('Disconnect Pusher'),
              color: !isConnected ? Colors.green : Colors.red
            ),
            isConnected == true ? FlatButton(onPressed: () => !isBinded ? _connectToMessageLogs() : _disconnectToMessageLogs(), child: !isBinded ? const Text('Connect to Project Logs') : const Text('Disconnect to Project Logs'), color: !isBinded ? Colors.blue : Colors.red) : const SizedBox.shrink()
          ],
        ),
      )
    );
  }
}
