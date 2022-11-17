import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor implements InterceptorContract {
  Logger logger = Logger();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    logger.v(
        "RequestTo: ${data.baseUrl}\nHeader: ${data.headers}\nBody: ${data.body}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode ~/ 100 == 2) {
      logger.i(
          "ResponseFrom: ${data.url}\nStatusCode: ${data.statusCode}\nHeader: ${data.headers}\nBody: ${data.body}");
    } else {
      logger.e(
          "ResponseFrom: ${data.url}\nStatusCode: ${data.statusCode}\nHeader: ${data.headers}\nBody: ${data.body}");
    }

    return data;
  }
}
