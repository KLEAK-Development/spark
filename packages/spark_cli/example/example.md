# Spark CLI Examples

This document provides practical examples of using the Spark CLI to create, develop, and deploy Spark applications.

## Creating a New Project

### Basic Project Creation

```bash
# Create a new project called "my_blog"
spark init my_blog
```

**Output:**
```
Creating project my_blog...
Project my_blog created successfully!
Run the following commands to get started:
  cd my_blog
  dart pub get
  spark dev
```

### Generated Project Structure

After running `spark init my_blog`, you'll have:

```
my_blog/
├── bin/
│   └── server.dart          # Server entry point
├── lib/
│   ├── components/
│   │   └── counter.dart     # Interactive component example
│   ├── endpoints/
│   │   └── endpoints.dart   # API endpoint example
│   └── pages/
│       └── home_page.dart   # Home page with SSR
├── analysis_options.yaml
├── pubspec.yaml
└── .gitignore
```

## Development Workflow

### Starting the Development Server

```bash
cd my_blog
dart pub get
spark dev
```

**Output:**
```
Starting development environment...
Cleaning build folder...
Build folder deleted.
Starting build_runner...
Waiting for first build to complete...
Build completed.
Starting server...
Live Reload server listening on port 35729
Server running at http://localhost:8080
Connected to VM Service for Hot Reload.
Watching for file changes...
```

### Making Changes with Hot Reload

When you edit a `.dart` file, the CLI automatically:

1. Detects the file change
2. Triggers a rebuild if needed
3. Performs hot reload on the server
4. Refreshes connected browsers

**Example output when editing a file:**
```
File changed: lib/pages/home_page.dart
Building...
Build completed.
Reloading...
Hot reload complete.
Triggering Browser Reload...
```

### Router Changes Trigger Full Restart

When you add new pages or endpoints, the router configuration changes:

```
File changed: lib/pages/about_page.dart
Building...
Build completed.
Router changed - restarting server...
Server running at http://localhost:8080
Connected to VM Service for Hot Reload.
Triggering Browser Reload...
```

## Production Build

### Standard Build

```bash
spark build
```

**Output:**
```
Building Spark project for production...

Cleaning build/...
Running code generation...
Code generation complete.
Compiling server...
Server compiled.
Compiling web assets...
  Compiling main.dart...
Web assets compiled (1 file).
Copying static assets...
Copied 3 assets.
Cleaning up development artifacts...

Build complete!

Output: build/
  bin/server (2.4 MB)
  web/main.dart.js (156.2 KB)
  web/styles.css (4.1 KB)
  web/favicon.ico (1.2 KB)

Completed in 45s
```

### Custom Output Directory

```bash
spark build -o dist
```

Outputs the production build to `dist/` instead of `build/`.

### Verbose Build

```bash
spark build -v
```

Shows detailed output from each build phase, useful for debugging build issues.

### Incremental Build (Skip Clean)

```bash
spark build --no-clean
```

Skips cleaning the build directory, useful for faster rebuilds during testing.

### Combined Options

```bash
spark build -o release -v --no-clean
```

## API Documentation Generation

### Generate OpenAPI Spec

```bash
spark openapi
```

**Output:**
```
Scanning for endpoints in lib/...
OpenAPI spec generated at openapi.json
```

### Custom Output Path

```bash
spark openapi -o docs/api-spec.json
```

### Example Generated OpenAPI Spec

Given an endpoint like:

```dart
@Endpoint(
  path: '/api/users/{id}',
  method: 'GET',
  summary: 'Get user by ID',
  tags: ['Users'],
)
class GetUserEndpoint extends SparkEndpoint {
  @override
  Future<User> handler(SparkRequest request) async {
    final id = request.params['id'];
    // ... fetch user
    return user;
  }
}
```

The generated `openapi.json` will include:

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Spark Application API",
    "version": "1.0.0"
  },
  "paths": {
    "/api/users/{id}": {
      "get": {
        "summary": "Get user by ID",
        "tags": ["Users"],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": { "type": "string" }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful operation",
            "content": {
              "application/json": {
                "schema": { "$ref": "#/components/schemas/User" }
              }
            }
          },
          "500": {
            "description": "Internal Server Error"
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "User": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "name": { "type": "string" },
          "email": { "type": "string", "format": "email" }
        }
      }
    }
  }
}
```

## Complete Workflow Example

Here's a complete workflow from project creation to production deployment:

```bash
# 1. Create a new project
spark init my_api
cd my_api

# 2. Install dependencies
dart pub get

# 3. Start development
spark dev

# 4. (In another terminal) Generate API documentation
spark openapi -o docs/openapi.json

# 5. Build for production
spark build -o dist

# 6. Run the production server
./dist/bin/server
```

## Helpful Tips

### Check CLI Version

```bash
spark --version
```

### Get Help

```bash
# General help
spark --help

# Command-specific help
spark init --help
spark build --help
spark openapi --help
```

### Environment Variables

The development server sets these environment variables for your application:

| Variable | Description |
|----------|-------------|
| `SPARK_DEV_RELOAD_PORT` | Port for the live reload WebSocket server |

### Production Deployment

The production build creates a self-contained bundle:

```
dist/
├── bin/
│   └── server        # Native executable (no Dart runtime needed)
├── lib/              # Native libraries (if any)
└── web/
    ├── *.dart.js     # Compiled JavaScript
    └── ...           # Static assets
```

To deploy, simply copy the `dist/` directory to your server and run:

```bash
./bin/server
```

Or use Docker:

```dockerfile
FROM scratch
COPY dist/ /app/
WORKDIR /app
EXPOSE 8080
CMD ["./bin/server"]
```
