import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo_core/otogapo_core.dart';

///
class OpstechFormField extends StatefulWidget {
  ///
  const OpstechFormField({
    required this.focusNode,
    this.onpressed,
    this.controller,
    this.label,
    this.txtficon,
    this.isEnabled,
    this.onchaged,
    this.hideKeyboard,
    this.compareToValidValue,
    this.errorTextWrongInput,
    this.suffix,
    this.keyboardType,
    super.key,
    this.textCapitalization,
  });

  ///
  final Future<void> Function()? onpressed;

  ///
  final Null Function(dynamic val)? onchaged;

  ///
  final TextEditingController? controller;

  ///
  final String? label;

  ///
  final Icon? txtficon;

  ///
  final bool? isEnabled;

  ///
  final bool? hideKeyboard;

  ///
  final FocusNode? focusNode;

  ///
  final List<String>? compareToValidValue;

  ///
  final String? errorTextWrongInput;

  ///
  final Widget? suffix;

  ///
  final TextInputType? keyboardType;

  ///
  final TextCapitalization? textCapitalization;

  @override
  State<OpstechFormField> createState() => _OpstechFormFieldState();
}

class _OpstechFormFieldState extends State<OpstechFormField> {
  //
  String? errorText = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label == null)
            const SizedBox.shrink()
          else
            Text(
              widget.label ?? '',
              style: OpstechTextTheme.heading5.copyWith(
                color: (widget.isEnabled ?? true) ? OpstechColors.grey600 : Colors.grey.shade300,
                fontSize: 30.sp,
              ),
            ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            keyboardType: widget.keyboardType,
            focusNode: widget.focusNode,
            textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
            autovalidateMode: AutovalidateMode.always,
            validator: (String? input) {
              if (input?.isEmpty ?? true) return 'Please insert data';
              if (widget.compareToValidValue?.isNotEmpty ?? false) {
                if (!widget.compareToValidValue!.contains(input)) {
                  return widget.errorTextWrongInput;
                }
              }
              return null;
            },
            controller: widget.controller,
            enabled: widget.isEnabled,
            onChanged: widget.onchaged,
            style: (widget.isEnabled ?? true)
                ? OpstechTextTheme.heading5
                : OpstechTextTheme.heading5.copyWith(color: Colors.grey.shade400),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 20),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: OpstechColors.grey300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: OpstechColors.grey600,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade100,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: OpstechColors.amber,
                  width: 8,
                ),
              ),
              suffixIcon: widget.suffix,
            ),
          ),
        ],
      ),
    );
  }
}
