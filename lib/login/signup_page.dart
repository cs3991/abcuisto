import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets.dart';
import 'authentication_cubit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationLoggedIn) {
          Navigator.pop(context);
        } else if (state is AuthenticationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("S'inscrire")),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 64),

                    const SizedBox(height: 64),
                    // TEXT
                    Text(
                      "Créez un compte pour pouvoir créer vos propres recettes et les partager avec qui vous voulez.",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 32),

                    // EMAIL
                    RoundedTextField(
                      controller: emailController,
                      hintText: "Adresse email",
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),

                    const SizedBox(height: 16),

                    // EMAIL
                    RoundedTextField(
                      controller: usernameController,
                      hintText: "Nom d'utilisateur",
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.newUsername],
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    RoundedTextField(
                      controller: passwordController,
                      hintText: "Mot de passe",
                      obscureText: obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    RoundedTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirmer le mot de passe",
                      obscureText: obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SIGN UP BUTTON
                    PrimaryButton(
                      label: "Créer un compte",
                      onPressed: () {
                        if (passwordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Les mots de passe ne correspondent pas")));
                          return;
                        }

                        context.read<AuthenticationCubit>().signUp(emailController.text, passwordController.text, usernameController.text);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Already an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Déjà un compte ? "),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              "Se connecter",
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
