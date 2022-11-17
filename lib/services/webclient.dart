import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:simple_journal/services/http_interceptors.dart';

class WebClient {
  static const String url = "http://192.168.1.10:3000/";
  static http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
    requestTimeout: const Duration(seconds: 5),
  );
}
