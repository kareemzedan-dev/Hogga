import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hogga/core/utils/app_colors.dart';
import '../theme/app_theme.dart';


class CustomTextField extends StatefulWidget {
  final String hintText; // النص الثابت داخل البوردر
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int? maxLines;
  final Color? fillColor;
  final bool? filled;
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final bool isDarkBackground;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.maxLines = 1,
    this.fillColor,
    this.filled,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.isDarkBackground = false,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool isFocused = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  void _onChanged(String value) {
    // كل ما المستخدم يكتب، نحذف رسالة الخطأ
    if (errorText != null) {
      setState(() {
        errorText = null;
      });
    }
    if (widget.onChanged != null) widget.onChanged!(value);
  }

  void _validate() {
    if (widget.validator != null) {
      final result = widget.validator!(widget.controller?.text);
      setState(() {
        errorText = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: _onChanged,
      validator: widget.validator,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
      onTap: widget.onTap,
      cursorColor: AppColors.golden,

      style: context.text.titleMedium?.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        helperStyle: context.text.labelSmall,
        hintStyle: context.text.labelMedium,
        prefixIcon: widget.prefixIcon != null 
            ? IconTheme(
                data: IconThemeData(color: isFocused ? AppColors.golden : context.textSecondary),
                child: widget.prefixIcon!,
              )
            : null,
        suffixIcon: widget.suffixIcon,
        fillColor: widget.fillColor ?? context.mc.inputFill,
        filled: widget.filled ?? true,
        contentPadding: widget.contentPadding,
      ),
      onEditingComplete: _validate,
    );
  }
}
