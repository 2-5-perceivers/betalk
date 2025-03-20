import 'package:betalk/data_service.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _loginFormKey = GlobalKey<FormState>();

  final _ipTextController = TextEditingController();
  final _nicknameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BeTalk"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [buildForm(context)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Made by 2.5 Perveivers",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
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
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: "Url adress",
                  hintText: "Your server url/ip adress",
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
                    child: FilledButton.tonal(
                      onPressed: () {
                        _login(context);
                      },
                      child: Text("Login"),
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
      bool init = await DataProvider.of(context).init(
        _ipTextController.text,
        _nicknameTextController.text,
      );

      if (init && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    }
  }
}
