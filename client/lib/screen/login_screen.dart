import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/text_form_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailEditController = TextEditingController();
  final TextEditingController pwdEditController = TextEditingController();

  bool buttonEnable = false;

  @override
  void initState() {
    super.initState();
    emailEditController.addListener(editChange);
    pwdEditController.addListener(editChange);
  }

  @override
  void dispose() {
    emailEditController.removeListener(editChange);
    pwdEditController.removeListener(editChange);
    emailEditController.dispose();
    pwdEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 1,
          backgroundColor: Colors.black.withOpacity(0.8),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const C(12),
                InkWell(
                  onTap: () => exit(),
                  child: Assets.images.back.image(width: 41, height: 41),
                ),
                const C(28),
                Text(
                  '欢迎回来！很高兴再次见到你！',
                  style: GoogleFonts.roboto(
                    color: ColorName.redF14336,
                    fontWeight: FontWeight.w700,
                    height: 39 / 18,
                    fontSize: 18,
                  ),
                ),
                const C(32),
                TextFormFieldWidget(
                  hintText: '输入你的邮箱地址',
                  controller: emailEditController,
                  validator: (input) {
                    if (input is String && input.isNotEmpty) {
                      if (!verifyEmail(input)) {
                        if (!input.contains('qq')) {
                          return '请输入qq邮箱地址';
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
                  hintText: '输入你的密码',
                  controller: pwdEditController,
                  type: InputType.password,
                  validator: (input) => null,
                ),
                const C(11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: Text(
                        '忘记了密码？',
                        style: GoogleFonts.urbanist(
                          color: ColorName.gray6A707C,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
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
                          ColorName.redEC008E
                              .withOpacity(buttonEnable ? 1 : 0.4),
                          ColorName.redFC6767
                              .withOpacity(buttonEnable ? 1 : 0.4),
                        ],
                      ),
                    ),
                    child: Text(
                      '登录',
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
                          '没有帐户？',
                          style: GoogleFonts.urbanist(
                            color: ColorName.black1E232C,
                            fontWeight: FontWeight.w500,
                            height: 21 / 15,
                            fontSize: 15,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, 'register'),
                          child: Text(
                            '立即注册',
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
      ),
    );
  }

  void editChange() {
    if (emailEditController.text.isNotEmpty &&
        pwdEditController.text.isNotEmpty) {
      setState(() => buttonEnable = true);
    } else {
      setState(() => buttonEnable = false);
    }
  }

  Future<void> submit() async {
    if (formKey.currentState?.validate() ?? false) {
      // TODO 提交登录信息到后端
      await Future.delayed(const Duration(milliseconds: 500));
      Fluttertoast.showToast(msg: '登录成功');
      exit(true);
    }
  }

  void exit<T extends Object?>([T? result]) => Navigator.pop(context, result);
}
