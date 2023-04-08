import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/colors.gen.dart';

enum InputType { normal, password }

class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({
    Key? key,
    required this.hintText,
    required this.controller,
    this.type = InputType.normal,
    this.validator,
  }) : super(key: key);

  final String hintText;
  final TextEditingController controller;
  final InputType type;
  final FormFieldValidator? validator;

  @override
  State<StatefulWidget> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends State<TextFormFieldWidget> {
  String get hintText => widget.hintText;

  TextEditingController get controller => widget.controller;

  InputType get type => widget.type;

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
        border: Border.all(color: ColorName.redF14336),
      ),
      child: TextFormField(
        focusNode: node,
        controller: controller,
        validator: validator,
        obscureText: isObscure,
        maxLines: 1,
        style: GoogleFonts.roboto(
          color: Colors.black.withOpacity(0.8),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        textInputAction: TextInputAction.next,
        cursorColor: ColorName.redF14336.withOpacity(0.8),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: GoogleFonts.roboto(
            color: Colors.black.withOpacity(0.2),
            fontWeight: FontWeight.w400,
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
