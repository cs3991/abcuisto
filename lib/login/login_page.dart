import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication_cubit.dart';


class LoginPage extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Se connecter")),
      body: Column(
        children: [
          TextField(
            autofocus: true,
            controller: usernameController,
            decoration: InputDecoration(hintText: "Nom d'utilisateur"),
          ),
          TextField(
            autofocus: true,
            controller: passwordController,
            decoration: InputDecoration(hintText: "Mot de passe"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthenticationCubit>().logIn(
                    usernameController.text,
                    passwordController.text,
                  );
            },
            child: Text("Se connecter"),
          ),
        ],
      ),
    );
  }
}
