# Spark Framework Example

A complete example application demonstrating the Spark Framework with code generation, server-side rendering, and API endpoints.

## 🚀 Quick Start

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) (version 3.10.7 or higher)
- [Spark CLI](https://sparkframework.dev) (installed via `dart pub global activate spark_cli`)

### 1. Running Locally

```bash
# Navigate to the example directory
cd packages/spark/example

# Install dependencies
dart pub get

# Install Spark CLI (if not already installed)
dart pub global activate spark_cli

# Start the development server
spark dev
```

The server will start at `http://localhost:9003` (or another available port).

### 2. Testing Endpoints

Try these endpoints:

- **GET** `http://localhost:9003/api/hello` - Simple hello world
- **POST** `http://localhost:9003/api/echo` - Echo back user data
  ```json
  { "name": "Alice" }
  ```

### 3. Building for Production

```bash
spark build
```

This generates optimized production-ready code in the `build/` directory.

## 🐳 Docker Deployment

### Build the Docker image

```bash
docker build -t spark/example -f packages/spark/example/Dockerfile .
```

### Run the container

```bash
docker run -d --name spark_example -p 127.0.0.1:8081:8080 spark/example:latest
```

The application will be available at `http://localhost:8081`.

## 🐋 Podman Deployment

### Build the Podman image

```bash
podman build -t spark/example -f packages/spark/example/Dockerfile .
```

### Run the container

```bash
podman run -d --name spark_example -p 127.0.0.1:8081:8080 localhost/spark/example:latest
```

The application will be available at `http://localhost:8081`.

## 📁 Project Structure

```
bin/          # Server entry point
lib/          # Application code
  components/ # UI components
  pages/      # Server-rendered pages
web/          # Web entry points
Dockerfile    # Container configuration
openapi.json  # OpenAPI specification
```

## 🔧 Additional Commands

- **Generate OpenAPI spec**: `spark openapi`
- **Run tests**: `dart test`

## 📚 Features Demonstrated

- Server-side rendering with Spark
- API endpoint generation
- Component-based UI architecture
- OpenAPI specification generation
- Production build optimization
