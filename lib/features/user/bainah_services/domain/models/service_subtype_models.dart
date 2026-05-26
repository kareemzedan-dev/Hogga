import 'package:hogga/core/utils/app_strings.dart';

class ServiceSubType {
  final String id;
  final String title;
  final String description;

  const ServiceSubType({
    required this.id,
    required this.title,
    required this.description,
  });
}

class ServiceSubTypesData {
  /// Returns the sub-types for a given service ID.
  static List<ServiceSubType> forService(String serviceId) {
    return _data[serviceId] ?? [];
  }

  static final Map<String, List<ServiceSubType>> _data = {
    'legal_writings': [
      const ServiceSubType(
        id: 'lawsuit',
        title: AppStrings.subtypeLawsuit,
        description: AppStrings.subtypeLawsuitDesc,
      ),
      const ServiceSubType(
        id: 'reply_memo',
        title: AppStrings.subtypeReplyMemo,
        description: AppStrings.subtypeReplyMemoDesc,
      ),
      const ServiceSubType(
        id: 'reply_joinder',
        title: AppStrings.subtypeReplyJoinder,
        description: AppStrings.subtypeReplyJoinderDesc,
      ),
      const ServiceSubType(
        id: 'objection',
        title: AppStrings.subtypeObjection,
        description: AppStrings.subtypeObjectionDesc,
      ),
      const ServiceSubType(
        id: 'cassation',
        title: AppStrings.subtypeCassation,
        description: AppStrings.subtypeCassationDesc,
      ),
    ],
  };
}
