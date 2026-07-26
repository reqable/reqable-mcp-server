# Build And Run

## Requirements

- Dart SDK v3.0+

## Install Dependencies

```bash
dart pub get
```

## Run Locally

```bash
dart run bin/main.dart
```

To connect to a specific Reqable API endpoint, pass the startup arguments explicitly:

```bash
dart run bin/main.dart --host 127.0.0.1 --port 9000
```

## Compile An Executable

```bash
dart compile exe bin/main.dart -o build/reqable-mcp-server
```

Run the compiled binary:

```bash
./build/reqable-mcp-server
```
