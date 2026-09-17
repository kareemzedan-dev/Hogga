class ServiceRequiredInput {
  final String label;
  final String slug;
  final String type;
  final bool isRequired;
  final List<String> options;

  const ServiceRequiredInput({
    required this.label,
    required this.slug,
    required this.type,
    required this.isRequired,
    this.options = const [],
  });

  factory ServiceRequiredInput.fromJson(Map<String, dynamic> json) {
    return ServiceRequiredInput(
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? json['key']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase().trim() ?? 'text',
      isRequired:
          json['required'] == true ||
          json['is_required'] == true ||
          json['required'] == 1 ||
          json['is_required'] == 1,
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
    );
  }

  bool get isUsable => slug.trim().isNotEmpty && label.trim().isNotEmpty;

  bool get isDate => type == 'date';

  bool get isNumber => type == 'number' || type == 'numeric' || type == 'int';

  bool get isLongText =>
      type == 'textarea' || type == 'long_text' || type == 'text_area';
}
