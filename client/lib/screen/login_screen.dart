import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/sp_manager.dart';
import 'package:graduationdesign/user_context.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: spInitSuccess
          ? buildContent()
          : FutureBuilder<bool>(
              future: SpManager.init().then((result) => spInitSuccess = result),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return buildContent();
                } else {
                  return const C(0);
                }
              },
            ),
    );
  }

  Widget buildContent() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 22, top: toolbarHeight, right: 22),
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
                color: ColorName.black1E232C,
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
                  onTap: () => Navigator.pushNamed(context, 'retrievePwd'),
                  child: Text(
                    '忘记了密码？',
                    style: GoogleFonts.roboto(
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
                      ColorName.redEC008E.withOpacity(buttonEnable ? 1 : 0.4),
                      ColorName.redFC6767.withOpacity(buttonEnable ? 1 : 0.4),
                    ],
                  ),
                ),
                child: Text(
                  '登录',
                  style: GoogleFonts.roboto(
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
                      style: GoogleFonts.roboto(
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
                        style: GoogleFonts.roboto(
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
    if (formKey.currentState?.validate() ?? true) {
      Response response = await DioClient.post(Api.login, {
        'email': emailEditController.text,
        'pwd': pwdEditController.text,
      });
      if (response.statusCode == 200) {
        if (response.data['code'] == 200) {
          UserContext.onUserLogin(response.data['data']);
          Fluttertoast.showToast(msg: '登录成功');
          exit(true);
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    }
  }

  void exit<T extends Object?>([T? result]) => Navigator.pop(context, result);
}
