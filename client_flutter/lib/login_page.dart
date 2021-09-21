import 'package:betalk/data_service.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _loginFormKey = GlobalKey<FormState>();

  final _ipTextController = TextEditingController();
  final _nicknameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 10,
              child: Column(
                children: [buildForm(context)],
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) => Padding(
        padding: const EdgeInsets.all(50.0),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _ipTextController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                decoration: const InputDecoration(
                  labelText: "Ip adress",
                  hintText: "Your server ip adress",
                ),
                validator: (currentValue) {
                  if (currentValue == null || currentValue.isEmpty) {
                    return "Invalid adress";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nicknameTextController,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: "Nickname",
                  hintText: "Your nickname",
                ),
                validator: (currentValue) {
                  if ((currentValue?.length ?? 0) < 3) {
                    return "Nickname is too short";
                  } else {
                    return null;
                  }
                },
                onEditingComplete: () {
                  _login(context);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _login(context);
                      },
                      child: const Text("Login"),
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                          const Size(
                            double.nan,
                            55,
                          ),
                        ),
                        backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _login(BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      await DataProvider.of(context).init(
        _ipTextController.text,
        _nicknameTextController.text,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }
}
