import 'package:hogga/features/user/hogga_services/domain/models/service_required_input.dart';

class BookingFlowArgs {
  final int itemCategoryId;
  final int childCategoryId;
  final int? subCategoryId;
  final double price;
  final String sectionName;
  final String subCategoryName;
  final String childCategoryName;
  final String itemName;
  final String? serviceType;
  final String? parentServiceType;
  final String? consultationType;
  final bool isConsultation;
  final double? publishingFee;
  final int? duration;
  final bool isCallType;
  final List<ServiceRequiredInput> requiredInputs;

  BookingFlowArgs({
    required this.itemCategoryId,
    required this.childCategoryId,
    this.subCategoryId,
    required this.price,
    required this.sectionName,
    required this.subCategoryName,
    required this.childCategoryName,
    required this.itemName,
    this.serviceType,
    this.parentServiceType,
    this.consultationType,
    this.isConsultation = false,
    this.publishingFee,
    this.duration,
    this.isCallType = false,
    this.requiredInputs = const [],
  });
}
