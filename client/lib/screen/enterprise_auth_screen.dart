import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:image_picker/image_picker.dart';

class EnterpriseAuthScreen extends StatefulWidget {
  const EnterpriseAuthScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EnterpriseAuthState();
}

class _EnterpriseAuthState extends State<EnterpriseAuthScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController codeEditController = TextEditingController();
  final FocusNode codeEditNode = FocusNode();

  late Size screenSize;

  bool buttonEnable = false;
  String? licenseUrl;
  String licenseKey = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    codeEditController.addListener(editChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  void editChange() {
    if (codeEditController.text.isNotEmpty && licenseUrl != null) {
      setState(() => buttonEnable = true);
    } else {
      setState(() => buttonEnable = false);
    }
  }

  @override
  void dispose() {
    codeEditController.removeListener(editChange);
    codeEditController.dispose();
    codeEditNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(
          color: Colors.black.withOpacity(0.8),
        ),
        title: Text(
          '商家认证',
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
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const C(20),
              Text(
                '根据法律法规要求，进行商家认证需要填写上传以下信息：',
                style: GoogleFonts.roboto(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const C(12),
              Text(
                '信息将用于认证商家信息，我们会对信息进行严格保密',
                style: GoogleFonts.roboto(
                  color: Colors.black.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const C(40),
              buildTextField(
                codeEditNode,
                codeEditController,
                '统一社会信用代码',
                '输入企业的统一社会信用代码',
                validator: (input) {
                  if (input is String && input.isNotEmpty) {
                    if (input.length != 18) {
                      return '统一社会信用代码为18位代码';
                    }
                    return null;
                  }
                  return null;
                },
              ),
              const C(20),
              buildUploadLicense(),
              const C(40),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(FocusNode node, TextEditingController controller,
      String title, String hint,
      {FormFieldValidator? validator}) {
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
          child: TextFormField(
            focusNode: node,
            controller: controller,
            validator: validator,
            maxLines: 1,
            style: GoogleFonts.roboto(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            textInputAction: TextInputAction.send,
            cursorColor: ColorName.redFC6767.withOpacity(0.8),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.roboto(
                color: Colors.black.withOpacity(0.2),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorName.redFC6767.withOpacity(0.8),
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

  Widget buildUploadLicense() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '上传企业营业执照',
          style: GoogleFonts.roboto(
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        const C(10),
        InkWell(
          onTap: uploadLicense,
          child: SizedBox(
            width: screenSize.width - 40,
            height: (screenSize.width - 40) * 460 / 650,
            child: licenseUrl == null
                ? Container(
                    alignment: Alignment.center,
                    color: ColorName.grayBFBFBF,
                    child: const Icon(Icons.add, color: Colors.white, size: 64),
                  )
                : CachedNetworkImage(
                    imageUrl:
                        'http://${Api.host}:${Api.port}${Api.downloadLicense}?fileName=$licenseUrl',
                    cacheKey: licenseKey,
                    width: screenSize.width - 40,
                    height: (screenSize.width - 40) * 460 / 650,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildButton() {
    return InkWell(
      onTap: buttonEnable ? submit : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorName.redFC6767.withOpacity(buttonEnable ? 1 : 0.4),
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

  Future<void> uploadLicense() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    String? imagePath = image?.path;
    if (imagePath != null) {
      DioClient.post(Api.uploadLicense, {
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.substring(
            imagePath.lastIndexOf('/') + 1,
          ),
        ),
      }).then((response) async {
        if (response.statusCode == 200 && response.data != null) {
          if (response.data['code'] == 200) {
            Fluttertoast.showToast(msg: '上传成功');
            licenseKey = UniqueKey().toString();
            if (mounted) {
              setState(() => licenseUrl = response.data['data']);
            }
          } else {
            Fluttertoast.showToast(msg: response.data['msg']);
          }
        }
      });
    }
  }

  Future<void> submit() async {
    if (formKey.currentState?.validate() ?? true) {
      Response response = await DioClient.post(Api.authentication, {
        'code': codeEditController.text,
        'license': licenseUrl,
      });
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          exit(true);
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    }
  }

  void exit([bool? result]) => Navigator.pop(context, result);
}
