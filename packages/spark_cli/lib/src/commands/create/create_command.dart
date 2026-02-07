import 'package:args/command_runner.dart';

import 'create_page_command.dart';
import 'create_endpoint_command.dart';
import 'create_component_command.dart';

class CreateCommand extends Command<void> {
  CreateCommand() {
    addSubcommand(CreatePageCommand());
    addSubcommand(CreateEndpointCommand());
    addSubcommand(CreateComponentCommand());
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new page, endpoint, or component.';
}
