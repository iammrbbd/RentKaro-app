import 'package:dio/dio.dart';
import '../models/vehicle.dart';

class VehicleService {
  VehicleService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://rentkaro.up.railway.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  final Dio _dio;

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _dio.get(
        '/api/vehicles',
        queryParameters: {
          'refresh': DateTime.now().millisecondsSinceEpoch,
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid vehicle response. Expected Map but got ${data.runtimeType}',
        );
      }

      final vehiclesData = data['vehicles'];

      if (vehiclesData is! List) {
        throw Exception(
          'Invalid vehicles data. Expected List but got ${vehiclesData.runtimeType}',
        );
      }

      return vehiclesData
          .whereType<Map>()
          .map(
            (item) => Vehicle.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (responseData is Map && responseData['detail'] != null) {
        throw Exception(
          responseData['detail'].toString(),
        );
      }

      if (statusCode == 404) {
        throw Exception(
          'Vehicle API endpoint not found.',
        );
      }

      if (statusCode != null) {
        throw Exception(
          'Unable to load vehicles. Server returned $statusCode.',
        );
      }

      throw Exception(
        'Unable to connect to the vehicle server.',
      );
    } catch (error) {
      throw Exception(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }
}