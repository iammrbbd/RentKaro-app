enum Environment {
  development,
  staging,
  production,
}

abstract final class EnvironmentConfig {
  static const Environment current = Environment.development;

  static bool get isProduction =>
      current == Environment.production;
}
