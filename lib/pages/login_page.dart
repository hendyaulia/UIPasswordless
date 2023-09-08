import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_register_nodejs/pages/pem_file_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import '../services/api_service.dart';
import '../config.dart';
import '../models/login_request_model.dart';
import 'otp_verify_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isApiCallProcess = false;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  String? userName;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _checkFileExists() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/certs.pem');
    final fileExists = await file.exists();

    if (!fileExists) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PemFilePage()),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor("#283B71"),
        body: ProgressHUD(
          child: Form(
            key: globalFormKey,
            child: _loginUI(context),
          ),
          inAsyncCall: isApiCallProcess,
          opacity: 0.3,
          key: UniqueKey(),
        ),
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 5.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
                bottomLeft: Radius.circular(100),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/123.png",
                    fit: BoxFit.contain,
                    width: 250,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 30, top: 50),
            child: Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FormHelper.inputFieldWidget(
              context,
              "Username",
              "Masukkan Username",
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Username HARUS diisi';
                } else if (onValidateVal.contains(' ')) {
                  return 'Username tidak boleh mengandung spasi';
                }

                return null;
              },
              (onSavedVal) => {
                userName = onSavedVal,
              },
              initialValue: "",
              obscureText: false,
              borderFocusColor: Colors.white,
              prefixIconColor: Colors.white,
              borderColor: Colors.white,
              textColor: Colors.white,
              hintColor: Colors.white.withOpacity(0.7),
              borderRadius: 10,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: FormHelper.submitButton(
              "Login",
              () async {
                var certava = await _checkFileExists();
                if (certava && validateAndSave()) {
                  setState(() {
                    isApiCallProcess = true;
                  });

                  LoginRequestModel model = LoginRequestModel(
                    username: userName,
                  );

                  APIService.login(model).then(
                    (response) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      if (response.data != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => OtpVerifyPage(
                                  email: response.data?.email,
                                  otpCode: response.data?.otpCode,
                                  otpHash: response.data?.otpHash)),
                        );
                      } else {
                        print("No data returned from API");
                        FormHelper.showSimpleAlertDialog(
                          context,
                          Config.appName,
                          "Username tidak terdaftar",
                          "OK",
                          () {
                            Navigator.of(context).pop();
                          },
                        );
                      }
                    },
                  );
                }
              },
              btnColor: HexColor("283B71"),
              borderColor: Colors.white,
              txtColor: Colors.white,
              borderRadius: 10,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "OR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 25,
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white, fontSize: 14.0),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Belum punya akun? ',
                    ),
                    TextSpan(
                      text: 'Daftar sekarang',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(
                            context,
                            '/register',
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
