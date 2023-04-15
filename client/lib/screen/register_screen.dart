import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/text_form_field_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameEditController = TextEditingController();
  final TextEditingController emailEditController = TextEditingController();
  final TextEditingController pwdEditController = TextEditingController();

  bool buttonEnable = false;

  @override
  void initState() {
    super.initState();
    nameEditController.addListener(editChange);
    emailEditController.addListener(editChange);
    pwdEditController.addListener(editChange);
  }

  @override
  void dispose() {
    nameEditController.removeListener(editChange);
    emailEditController.removeListener(editChange);
    pwdEditController.removeListener(editChange);
    nameEditController.dispose();
    emailEditController.dispose();
    pwdEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 22, top: toolbarHeight, right: 22),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const C(12),
              InkWell(
                onTap: exit,
                child: Assets.images.back.image(width: 41, height: 41),
              ),
              const C(28),
              Text(
                '你好！注册开始',
                style: GoogleFonts.roboto(
                  color: ColorName.black1E232C,
                  fontWeight: FontWeight.w700,
                  height: 39 / 18,
                  fontSize: 18,
                ),
              ),
              const C(32),
              TextFormFieldWidget(
                hintText: '用户名',
                controller: nameEditController,
                validator: (input) => null,
              ),
              const C(15),
              TextFormFieldWidget(
                hintText: '邮箱地址',
                controller: emailEditController,
                validator: (input) {
                  if (input is String && input.isNotEmpty) {
                    if (!verifyEmail(input)) {
                      if (!input.contains('qq')) {
                        return '目前仅支持注册qq邮箱，请输入qq邮箱';
                      }
                      return '请输入正确的邮箱地址';
                    }
                    return null;
                  }
                  return null;
                },
              ),
              const C(15),
              TextFormFieldWidget(
                hintText: '密码',
                controller: pwdEditController,
                validator: (input) => null,
              ),
              const C(30),
              InkWell(
                onTap: buttonEnable ? submit : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        ColorName.redEC008E.withOpacity(buttonEnable ? 1 : 0.4),
                        ColorName.redFC6767.withOpacity(buttonEnable ? 1 : 0.4),
                      ],
                    ),
                  ),
                  child: Text(
                    '注册',
                    style: GoogleFonts.urbanist(
                      color: Colors.white.withOpacity(buttonEnable ? 1 : 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '已经有账户了吗？',
                        style: GoogleFonts.urbanist(
                          color: ColorName.black1E232C,
                          fontWeight: FontWeight.w500,
                          height: 21 / 15,
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: exit,
                        child: Text(
                          '立即登录',
                          style: GoogleFonts.urbanist(
                            color: ColorName.green35C2C1,
                            fontWeight: FontWeight.w500,
                            height: 21 / 15,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void editChange() {
    if (nameEditController.text.isNotEmpty &&
        emailEditController.text.isNotEmpty &&
        pwdEditController.text.isNotEmpty) {
      setState(() => buttonEnable = true);
    } else {
      setState(() => buttonEnable = false);
    }
  }

  Future<void> submit() async {
    if (formKey.currentState?.validate() ?? true) {
      Response response = await DioClient.post(Api.register, {
        'name': nameEditController.text,
        'email': emailEditController.text,
        'pwd': pwdEditController.text,
      });
      if (response.statusCode == 200) {
        if (response.data['code'] == 200) {
          Fluttertoast.showToast(msg: '注册成功');
          exit();
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    }
  }

  void exit() => Navigator.pop(context);
}
