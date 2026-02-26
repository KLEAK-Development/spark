# Stage 1: Install Dart, Spark CLI, and build the project
FROM dart:stable as builder

# Install Spark CLI
RUN dart pub global activate spark_cli
ENV PATH="$PATH:/root/.pub-cache/bin"

# Copy the entire workspace (from the root) into /workspace
WORKDIR /workspace
COPY . .

# Resolve dependencies at the workspace root
RUN dart pub get

# Navigate to the example project and build
WORKDIR /workspace/packages/spark/example
RUN dart pub get
RUN spark build

# Stage 2: Create a minimal runtime image
FROM debian:stable-slim
WORKDIR /app

# Copy the compiled output from the builder
# Replace "build" with the actual output directory from `spark build`
COPY --from=builder /workspace/packages/spark/example/build /app

# Install required glibc libraries
RUN apt-get update && apt-get install -y libc6 && rm -rf /var/lib/apt/lists/*

# Expose the port your server uses
EXPOSE 8080

# Run the compiled binary (replace with the actual binary name)
CMD ["/app/bin/server"]
