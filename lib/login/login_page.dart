import 'package:abcuisto/login/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../recipe/filters/filter_cubit.dart';
import '../widgets.dart';
import 'authentication_cubit.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  var obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthenticationCubit, bool>((cubit) => cubit.state is AuthenticationLoading);
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationLoggedIn) {
          Navigator.pop(context);
        } else if (state is AuthenticationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Se connecter")),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AutofillGroup(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    SizedBox(height: 64),
                    // Text and logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image(image: const AssetImage("assets/logo.png"), width: 100, height: 100, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),

                    Text(
                      "Vous connecter à un compte ABCuisto vous permet de sauvegarder "
                      "vos recettes préférées, d'ajouter vos propres recettes, et de les "
                      "partager avec qui vous voulez !",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    // EMAIL FIELD
                    // EMAIL FIELD
                    RoundedTextField(
                      controller: emailController,
                      hintText: "Adresse email",
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email, AutofillHints.username],
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD FIELD
                    RoundedTextField(
                      controller: passwordController,
                      hintText: "Mot de passe",
                      obscureText: obscureText,
                      autofillHints: const [AutofillHints.password],
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton(
                          icon: Icon(
                            obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // FORGOT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                          },
                          child: const Text("Mot de passe oublié ?"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // LOGIN BUTTON
                    PrimaryButton(
                      label: "Connexion",
                      isLoading: isLoading,
                      onPressed: () async {
                        final loggedIn = await context.read<AuthenticationCubit>().logIn(emailController.text, passwordController.text);
                        if (loggedIn && context.mounted) {
                          context.read<FilterCubit>().update();
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // SIGN UP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Vous êtes nouveau ici ? "),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                            },
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
