/// Builders for Spark code generation.
///
/// This library exports the builder factories used by build_runner
/// to process @Page and @Component annotations.
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/page_generator.dart';
import 'src/router_builder.dart';
import 'src/web_entry_builder.dart';
import 'src/endpoint_generator.dart';
import 'src/component_generator.dart';

export 'src/page_generator.dart';
export 'src/router_builder.dart';
export 'src/web_entry_builder.dart';
export 'src/endpoint_generator.dart';
export 'src/component_generator.dart';

/// Creates a builder that processes @Page annotations.
///
/// This builder generates handler functions for each annotated page class.
Builder sparkPagesBuilder(BuilderOptions options) => SharedPartBuilder([
  PageGenerator(),
  EndpointGenerator(),
], 'spark');

/// Creates a builder that processes @Component annotations.
///
/// This builder generates reactive implementation classes for components.
/// Expects source files ending with _base.dart and generates _impl.dart files.
Builder sparkComponentsBuilder(BuilderOptions options) =>
    LibraryBuilder(
      ComponentGenerator(),
      generatedExtension: '.impl.dart',
    );

/// Creates a builder that aggregates all page routes.
///
/// This builder collects all generated page handlers and creates
/// the `createSparkRouter()` and `createSparkServer()` functions.
Builder sparkRouterBuilder(BuilderOptions options) => RouterBuilder();

/// Creates a builder that generates web entry points.
Builder sparkWebEntryBuilder(BuilderOptions options) => WebEntryBuilder();
