enum Environment { testing, production }

/// A class to hold the configuration for a specific environment.
class EnvConfig {
  final String baseUrl;

  EnvConfig({required this.baseUrl});

  /// A factory to create a configuration for a given environment.
  factory EnvConfig.fromEnvironment(Environment env) {
    switch (env) {
      case Environment.production:
        // TODO: Replace with your actual production URL
        return EnvConfig(baseUrl: 'https://172.20.10.2/');
      case Environment.testing:
        // TODO: Replace with your actual IPv4 address for local testi
        // Example: 'http://192.168.1.100:8000/api'
        // Example: 'http://192.168.1.180/api' College IP
        // Example: 'http://192.168.31.140/' Mandir IP
        // return EnvConfig(baseUrl: 'http://192.168.31.140/');
        return EnvConfig(baseUrl: 'http://172.20.10.2/');
    }
  }
}
