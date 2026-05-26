class AppConfig {
  final String latestVersion;
  final String minimumVersion;
  final bool forceUpdate;
  final bool isMaintenance;
  final String? maintenanceMessage;
  final String? updateMessage;
  final String storeUrl;

  AppConfig({
    required this.latestVersion,
    required this.minimumVersion,
    required this.forceUpdate,
    required this.isMaintenance,
    this.maintenanceMessage,
    this.updateMessage,
    required this.storeUrl,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      latestVersion: json['latest_version'] ?? '1.0.0',
      minimumVersion: json['minimum_version'] ?? '1.0.0',
      forceUpdate: json['force_update'] ?? false,
      isMaintenance: json['is_maintenance'] ?? false,
      maintenanceMessage: json['maintenance_message'],
      updateMessage: json['update_message'],
      storeUrl: json['store_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'minimum_version': minimumVersion,
      'force_update': forceUpdate,
      'is_maintenance': isMaintenance,
      'maintenance_message': maintenanceMessage,
      'update_message': updateMessage,
      'store_url': storeUrl,
    };
  }
}
