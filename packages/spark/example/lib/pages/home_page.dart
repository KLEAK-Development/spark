/// Example home page demonstrating Spark Framework page pattern.
///
/// This page shows how to:
/// - Use the @Page annotation for route registration
/// - Implement loader() for data fetching
/// - Implement render() for HTML generation
/// - Use components (islands) within pages
library;

import 'package:spark_framework/spark.dart';

import '../components/counter.dart';
import '../components/counter_final/counter_final.dart';

/// Home page data model.
///
/// This demonstrates how pages can have typed data.
class HomePageData {
  final String title;
  final String description;
  final int counterStart;

  const HomePageData({
    required this.title,
    required this.description,
    required this.counterStart,
  });
}

/// The home page of the application.
///
/// With build_runner, this annotation automatically registers the route:
/// ```dart
/// @Page(path: '/')
/// class HomePage extends SparkPage<HomePageData> { ... }
/// ```
///
/// The generated code will create a handler that:
/// 1. Calls loader() to fetch data
/// 2. Calls render() with the typed data
/// 3. Wraps the content in a full HTML page
@Page(path: '/')
class HomePage extends SparkPage<HomePageData> {
  @override
  Future<PageResponse<HomePageData>> loader(PageRequest request) async {
    // In a real app, you might fetch data from a database or API here
    // For example:
    // final response = await http.get(Uri.parse('$apiUrl/settings'));
    // final settings = Settings.fromJson(jsonDecode(response.body));

    // For this example, we return static data
    return PageData(
      HomePageData(
        title: 'Spark Framework Demo',
        description:
            'This counter was rendered on the server and hydrated on the client.',
        counterStart: 100,
      ),
    );
  }

  @override
  Element render(HomePageData data, PageRequest request) {
    return div([
      h1(data.title),
      p(data.description),

      Counter(value: data.counterStart, label: 'Clicks').render(),
      CounterFinal(value: data.counterStart).render(),

      p([
        strong(['Try it:']),
        ' The counter works immediately (declarative shadow DOM) and becomes interactive after hydration.',
      ]),
    ]);
  }

  @override
  String title(HomePageData data, PageRequest request) => data.title;

  @override
  List<ComponentInfo> get components => [
    ComponentInfo(Counter.tag, Counter.new),
    // ComponentInfo(CounterV2.tag, CounterV2.new),
    ComponentInfo(CounterFinal.tag, CounterFinal.new),
  ];

  @override
  Stylesheet? get inlineStyles => css({
    'body': Style(
      fontFamily:
          'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      maxWidth: '800px',
      margin: '0 auto',
      padding: '40px 20px',
      lineHeight: '1.6',
      color: '#333',
    ),
    'h1': Style(color: '#2196f3'),
    'p': Style(color: '#666'),
  });
}
