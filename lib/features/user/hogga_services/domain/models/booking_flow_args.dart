class BookingFlowArgs {
  final int itemCategoryId;
  final int childCategoryId;
  final double price;
  final String sectionName;
  final String subCategoryName;
  final String childCategoryName;
  final String itemName;
  final int? duration;
  final bool isCallType;

  BookingFlowArgs({
    required this.itemCategoryId,
    required this.childCategoryId,
    required this.price,
    required this.sectionName,
    required this.subCategoryName,
    required this.childCategoryName,
    required this.itemName,
    this.duration,
    this.isCallType = false,
  });
}
