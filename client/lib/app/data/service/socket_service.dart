import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final io.Socket socket = io.io(
    'http://127.0.0.1:5000',
    <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    },
  );
}
