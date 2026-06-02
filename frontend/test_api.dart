import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
  ));
  
  try {
    print('Testing /incidents/...');
    final res = await dio.get('/incidents/');
    print('Status: ' + res.statusCode.toString());
    print('Data: ' + res.data.toString());
  } on DioException catch (e) {
    print('Dio Error: ' + e.response?.statusCode.toString() + ' ' + e.message.toString());
    print('Response: ' + e.response?.data.toString());
  } catch (e) {
    print('Error: ' + e.toString());
  }

  try {
    print('Testing /dispatcher/users/...');
    final res = await dio.get('/dispatcher/users/');
    print('Status: ' + res.statusCode.toString());
    print('Data: ' + res.data.toString());
  } on DioException catch (e) {
    print('Dio Error: ' + (e.response?.statusCode.toString() ?? 'null') + ' ' + e.message.toString());
    print('Response: ' + (e.response?.data.toString() ?? 'null'));
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
