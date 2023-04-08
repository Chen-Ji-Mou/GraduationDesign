import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/text_form_field_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum _CurrentState { getCode, verifyCode, newPwd, backLogin }

class RetrievePwdScreen extends StatefulWidget {
  const RetrievePwdScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RetrievePwdState();
}

class _RetrievePwdState extends State<RetrievePwdScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController editController = TextEditingController();

  bool buttonEnable = false;
  _CurrentState curState = _CurrentState.getCode;
  String? email;
  String? verificationCode;

  @override
  void initState() {
    super.initState();
    editController.addListener(editChange);
  }

  @override
  void dispose() {
    editController.removeListener(editChange);
    editController.dispose();
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
        body: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Form(
        key: formKey,
        child: curState == _CurrentState.backLogin
            ? Column(
                children: [
                  const C(204),
                  Assets.images.successMark.image(width: 100, height: 100),
                  const C(35),
                  Text(
                    getTitle(),
                    style: GoogleFonts.roboto(
                      color: ColorName.black1E232C,
                      fontWeight: FontWeight.w700,
                      height: 39 / 18,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    getSubtitle(),
                    style: GoogleFonts.roboto(
                      color: ColorName.gray8391A1,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const C(40),
                  InkWell(
                    onTap: submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [
                            ColorName.redEC008E,
                            ColorName.redFC6767,
                          ],
                        ),
                      ),
                      child: Text(
                        getButtonText(),
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const C(12),
                  InkWell(
                    onTap: () => exit(),
                    child: Assets.images.back.image(width: 41, height: 41),
                  ),
                  const C(28),
                  Text(
                    getTitle(),
                    style: GoogleFonts.roboto(
                      color: ColorName.black1E232C,
                      fontWeight: FontWeight.w700,
                      height: 39 / 18,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    getSubtitle(),
                    style: GoogleFonts.roboto(
                      color: ColorName.gray8391A1,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const C(32),
                  if (curState == _CurrentState.verifyCode)
                    SizedBox(
                      height: 60,
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                        onChanged: (value) =>
                            setState(() => buttonEnable = value.isNotEmpty),
                        onCompleted: (value) => verificationCode = value,
                        cursorColor: Colors.blueAccent,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          fieldWidth: 66,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    )
                  else
                    TextFormFieldWidget(
                      hintText: getHintText(),
                      controller: editController,
                      validator: (input) => getValidator(input),
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
                        getButtonText(),
                        style: GoogleFonts.urbanist(
                          color:
                              Colors.white.withOpacity(buttonEnable ? 1 : 0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if ([
                    _CurrentState.getCode,
                    _CurrentState.verifyCode,
                  ].contains(curState))
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getBottomText(),
                              style: GoogleFonts.urbanist(
                                color: ColorName.black1E232C,
                                fontWeight: FontWeight.w500,
                                height: 21 / 15,
                                fontSize: 15,
                              ),
                            ),
                            InkWell(
                              onTap: bottomClick,
                              child: Text(
                                getBottomClickText(),
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
    );
  }

  String getTitle() {
    String title;
    switch (curState) {
      case _CurrentState.getCode:
        title = '忘记密码？';
        break;
      case _CurrentState.verifyCode:
        title = 'OTP验证';
        break;
      case _CurrentState.newPwd:
        title = '创建新密码';
        break;
      case _CurrentState.backLogin:
        title = '密码已更改！';
        break;
    }
    return title;
  }

  String getSubtitle() {
    String subtitle;
    switch (curState) {
      case _CurrentState.getCode:
        subtitle = '别担心！它发生了。请输入与您的帐户链接的电子邮件地址。';
        break;
      case _CurrentState.verifyCode:
        subtitle = '输入我们刚刚在您的电子邮件地址上发送的验证码';
        break;
      case _CurrentState.newPwd:
        subtitle = '您的新密码必须与以前使用的密码不同。';
        break;
      case _CurrentState.backLogin:
        subtitle = '您的密码已成功更改。';
        break;
    }
    return subtitle;
  }

  String getHintText() {
    String hint;
    switch (curState) {
      case _CurrentState.getCode:
        hint = '输入您的邮箱地址';
        break;
      case _CurrentState.verifyCode:
        hint = '';
        break;
      case _CurrentState.newPwd:
        hint = '新的密码';
        break;
      case _CurrentState.backLogin:
        hint = '';
        break;
    }
    return hint;
  }

  String? getValidator(String input) {
    switch (curState) {
      case _CurrentState.getCode:
        return emailValidator(input);
      case _CurrentState.verifyCode:
        return null;
      case _CurrentState.newPwd:
        return pwdValidator(input);
      case _CurrentState.backLogin:
        return null;
    }
  }

  String? emailValidator(String input) {
    if (input.isNotEmpty) {
      if (!verifyEmail(input)) {
        if (!input.contains('qq')) {
          return '请输入qq邮箱地址';
        }
        return '请输入正确的邮箱地址';
      }
      return null;
    }
    return null;
  }

  String? pwdValidator(String input) {
    if (input.isNotEmpty) {
      // TODO 验证输入是否与旧密码一致
      return null;
    }
    return null;
  }

  String getButtonText() {
    String buttonText;
    switch (curState) {
      case _CurrentState.getCode:
        buttonText = '发送验证码';
        break;
      case _CurrentState.verifyCode:
        buttonText = '验证';
        break;
      case _CurrentState.newPwd:
        buttonText = '重置密码';
        break;
      case _CurrentState.backLogin:
        buttonText = '返回登录';
        break;
    }
    return buttonText;
  }

  String getBottomText() {
    String bottomText;
    switch (curState) {
      case _CurrentState.getCode:
        bottomText = '想起密码了？';
        break;
      case _CurrentState.verifyCode:
        bottomText = '没有收到验证码？';
        break;
      case _CurrentState.newPwd:
        bottomText = '';
        break;
      case _CurrentState.backLogin:
        bottomText = '';
        break;
    }
    return bottomText;
  }

  String getBottomClickText() {
    String text;
    switch (curState) {
      case _CurrentState.getCode:
        text = '登录';
        break;
      case _CurrentState.verifyCode:
        text = '重新发送';
        break;
      case _CurrentState.newPwd:
        text = '';
        break;
      case _CurrentState.backLogin:
        text = '';
        break;
    }
    return text;
  }

  void bottomClick() {
    switch (curState) {
      case _CurrentState.getCode:
        exit();
        break;
      case _CurrentState.verifyCode:
        // TODO 请求后端重新发送邮箱验证码
        break;
      case _CurrentState.newPwd:
      case _CurrentState.backLogin:
        break;
    }
  }

  void editChange() {
    if (editController.text.isNotEmpty) {
      setState(() => buttonEnable = true);
    } else {
      setState(() => buttonEnable = false);
    }
  }

  Future<void> submit() async {
    if (formKey.currentState?.validate() ?? true) {
      switch (curState) {
        case _CurrentState.getCode:
          email = editController.text;
          Response response =
              await DioClient.get(Api.sendEmailVerificationCode, {
            'email': email,
          });
          if (response.statusCode == 200) {
            if (response.data['code'] == 200) {
              setState(() {
                Fluttertoast.showToast(msg: '验证码已发送至对应邮箱，请查收');
                curState = _CurrentState.verifyCode;
                reset();
              });
            } else {
              Fluttertoast.showToast(msg: response.data['msg']);
            }
          }
          break;
        case _CurrentState.verifyCode:
          Response response =
              await DioClient.post(Api.verifyEmailVerificationCode, {
            'email': email,
            'code': verificationCode,
          });
          if (response.statusCode == 200) {
            if (response.data['code'] == 200) {
              setState(() {
                Fluttertoast.showToast(msg: '验证成功');
                curState = _CurrentState.newPwd;
                reset();
              });
            } else {
              Fluttertoast.showToast(msg: response.data['msg']);
            }
          }
          break;
        case _CurrentState.newPwd:
          Response response = await DioClient.post(Api.changePwd, {
            'email': email,
            'pwd': editController.text,
          });
          if (response.statusCode == 200) {
            if (response.data['code'] == 200) {
              setState(() {
                curState = _CurrentState.backLogin;
                reset();
              });
            } else {
              Fluttertoast.showToast(msg: response.data['msg']);
            }
          }
          break;
        case _CurrentState.backLogin:
          exit();
          break;
      }
    }
  }

  void reset() {
    editController.clear();
    buttonEnable = false;
  }

  void exit() => Navigator.pop(context);
}
