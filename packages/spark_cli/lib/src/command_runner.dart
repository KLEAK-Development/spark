import 'package:args/command_runner.dart';
import 'commands/init_command.dart';
import 'commands/dev_command.dart';
import 'commands/build_command.dart';
import 'commands/openapi_command.dart';

class SparkCommandRunner extends CommandRunner<void> {
  SparkCommandRunner() : super('spark', 'A CLI tool for the Spark Framework.') {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current version.',
    );

    addCommand(InitCommand());
    addCommand(DevCommand());
    addCommand(BuildCommand());
    addCommand(OpenApiCommand());
  }

  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }
}
