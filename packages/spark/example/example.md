# Spark Example

This directory contains a complete example application built with the Spark framework.

## Features Demonstrated

- **Server Setup**: Basic server configuration with logging and middleware (`bin/server.dart`).
- **Endpoint Definition**: Creating endpoints using the `@Endpoint` annotation (`lib/endpoints/endpoints.dart`).
- **Request Handling**:
  - Typed request bodies (`EchoUserEndpoint`)
  - Map/dynamic request bodies (`EchoDetailsEndpoint`)
  - Path parameters (`GetUserEndpoint`)
- **Middleware**: Applying middleware to specific endpoints (`CheckMwEndpoint`).
- **OpenAPI**: Automatic OpenApi specification generation.

## Running the Example

1.  **Get dependencies:**

    ```bash
    dart pub get
    ```

2.  **Start the server:**

    First, install the `spark_cli` (if not already installed):

    ```bash
    dart pub global activate spark_cli
    ```

    Then run the development server:

    ```bash
    spark dev
    ```

    You should see output indicating the server is running, e.g., `Server running at http://localhost:9003`.

3.  **Test Endpoints:**
    - **Hello World**:

      ```
      GET http://localhost:9003/api/hello
      ```

    - **Echo User (POST)**:
      ```
      POST http://localhost:9003/api/echo
      Body: { "name": "Alice123456" }
      ```

4.  **View OpenAPI Spec:**
    To generate the OpenAPI specification, run:

    ```bash
    spark openapi
    ```

    The `openapi.json` file is generated in the root of the example directory.

5.  **Build for Production:**
    To build the project for production, run:
    ```bash
    spark build
    ```

## Directory Structure

- `bin/`: Contains the server entry point.
- `lib/endpoints/`: Defines the API endpoints and DTOs.
- `lib/pages/`: Contains the application pages (for server-side rendering).
- `lib/components/`: Example UI components (if applicable).
