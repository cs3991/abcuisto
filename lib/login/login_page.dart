import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication_cubit.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Se connecter")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AutofillGroup(
          child: Column(
            children: [
              TextField(
                autofocus: true,
                controller: emailController,
                decoration: InputDecoration(hintText: "Email"),
                autofillHints: [AutofillHints.email, AutofillHints.username],
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                autofocus: true,
                controller: passwordController,
                decoration: InputDecoration(hintText: "Mot de passe"),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: [AutofillHints.password],
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthenticationCubit>().logIn(emailController.text, passwordController.text);
                },
                child: Text("Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
