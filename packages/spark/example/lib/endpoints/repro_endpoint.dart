import 'package:spark_framework/spark.dart';

class ReproDto {
  final Map<String, dynamic>? nextTier;
  ReproDto({this.nextTier});
}

@Endpoint(
  path: '/api/repro',
  method: 'GET',
  summary: 'Repro Endpoint',
  description: 'Reproduction for nullable Map serialization',
  statusCode: 200,
)
class ReproEndpoint extends SparkEndpoint {
  @override
  Future<ReproDto> handler(SparkRequest request) async {
    return ReproDto(nextTier: {'a': 1});
  }
}
