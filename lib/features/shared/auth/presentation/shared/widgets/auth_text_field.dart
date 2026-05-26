import 'package:flutter/material.dart';
import 'package:hogga/core/widgets/custom_text_field.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;

  const AuthTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hint,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      textAlign: TextAlign.start,
    );
  }
}
