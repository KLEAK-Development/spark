import 'package:spark_framework/spark.dart';

@Page(
  path: '/404',
) // Path is not strictly used when passed as notFoundPage but good for reference
class NotFoundPage extends SparkPage<void> {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null, statusCode: 404);
  }

  @override
  Node render(void data, PageRequest request) {
    return div(
      attributes: {'style': 'text-align: center; padding: 50px;'},
      [
        h1(['404 - Page Not Found']),
        p(['The page you are looking for does not exist.']),
        a(href: '/', ['Go Home']),
      ],
    );
  }

  @override
  String title(void data, PageRequest request) => 'Page Not Found';
}
