import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/screen/push_stream_screen.dart';

class ApplyLiveScreen extends StatefulWidget {
  const ApplyLiveScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApplyLiveState();
}

class _ApplyLiveState extends State<ApplyLiveScreen> {
  final TextEditingController nameEditController = TextEditingController();
  final TextEditingController idEditController = TextEditingController();

  final FocusNode nameEditNode = FocusNode();
  final FocusNode idEditNode = FocusNode();

  bool buttonEnable = false;
  bool applySuccess = false;
  int liveId = -1;

  @override
  void initState() {
    super.initState();
    nameEditController.addListener(editChange);
    idEditController.addListener(editChange);
  }

  void editChange() {
    if (nameEditController.text.isNotEmpty &&
        idEditController.text.isNotEmpty) {
      setState(() => buttonEnable = true);
    } else {
      setState(() => buttonEnable = false);
    }
  }

  @override
  void dispose() {
    nameEditController.removeListener(editChange);
    idEditController.removeListener(editChange);
    nameEditController.dispose();
    idEditController.dispose();
    nameEditNode.dispose();
    idEditNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return applySuccess ? PushStreamScreen(liveId: liveId) : buildContent();
  }

  Widget buildContent() {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.white.withOpacity(0.8),
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(
            color: Colors.black.withOpacity(0.8),
          ),
          title: Text(
            '实名认证',
            style: GoogleFonts.roboto(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const C(20),
              Text(
                '根据法律法规要求，开播前请先完成身份认证：',
                style: GoogleFonts.roboto(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const C(12),
              Text(
                '认证信息将用于开直播，与账号唯一绑定，我们会对信息进行严格保密',
                style: GoogleFonts.roboto(
                  color: Colors.black.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const C(40),
              buildTextField(
                nameEditNode,
                nameEditController,
                '真实姓名',
                '输入您的真实姓名',
              ),
              buildTextField(
                idEditNode,
                idEditController,
                '身份证号',
                '请输入身份证号',
              ),
              const C(16),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(FocusNode node, TextEditingController controller,
      String title, String hint) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
        const C(10),
        Expanded(
          child: TextField(
            focusNode: node,
            controller: controller,
            maxLines: 1,
            maxLength: 18,
            style: GoogleFonts.roboto(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            textInputAction: TextInputAction.send,
            cursorColor: ColorName.fc6767.withOpacity(0.8),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.roboto(
                color: Colors.black.withOpacity(0.2),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorName.fc6767.withOpacity(0.8),
                  width: 2,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton() {
    return InkWell(
      onTap: buttonEnable ? submitInformation : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorName.fc6767.withOpacity(buttonEnable ? 1 : 0.4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '点击认证',
          style: GoogleFonts.roboto(
            color: Colors.white.withOpacity(buttonEnable ? 1 : 0.8),
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Future<void> submitInformation() async {
    // TODO 提交认证信息到后端记录，后端生成直播间号返回
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      applySuccess = true;
      liveId = 1234567;
      if (nameEditNode.hasFocus) {
        nameEditNode.unfocus();
      }
      if (idEditNode.hasFocus) {
        idEditNode.unfocus();
      }
    });
  }
}
