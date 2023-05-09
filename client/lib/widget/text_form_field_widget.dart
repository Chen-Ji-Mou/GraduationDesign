import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/colors.gen.dart';

enum InputType { normal, password }

class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({
    Key? key,
    required this.controller,
    required this.hintText,
    this.type = InputType.normal,
    this.borderColor = ColorName.redF14336,
    this.cursorColor = ColorName.redF14336,
    this.maxLines = 1,
    this.validator,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final InputType type;
  final Color borderColor;
  final Color cursorColor;
  final int maxLines;
  final FormFieldValidator? validator;

  @override
  State<StatefulWidget> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends State<TextFormFieldWidget> {
  String get hintText => widget.hintText;

  TextEditingController get controller => widget.controller;

  InputType get type => widget.type;

  Color get borderColor => widget.borderColor;

  Color get cursorColor => widget.cursorColor;

  int get maxLines => widget.maxLines;

  FormFieldValidator? get validator => widget.validator;

  final FocusNode node = FocusNode();

  bool isObscure = false;

  @override
  void initState() {
    super.initState();
    if (type == InputType.password) {
      isObscure = true;
    }
  }

  @override
  void dispose() {
    if (node.hasFocus) {
      node.unfocus();
    }
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: TextFormField(
        focusNode: node,
        controller: controller,
        validator: validator,
        obscureText: isObscure,
        maxLines: maxLines,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.normal,
          color: Colors.black,
          fontSize: 14,
        ),
        textInputAction: TextInputAction.next,
        cursorColor: cursorColor,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: GoogleFonts.roboto(
            color: Colors.black.withOpacity(0.4),
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          suffixIcon: type == InputType.password
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility : Icons.visibility_off,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
