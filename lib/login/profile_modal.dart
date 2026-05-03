import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../recipe/filters/filter_cubit.dart';
import 'authentication_cubit.dart';

void showProfilePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final state = context.read<AuthenticationCubit>().state as AuthenticationLoggedIn;
      return AlertDialog(
        title: Icon(Icons.person_rounded, size: 48),
        content: Text(state.username, textAlign: TextAlign.center),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     // Navigate to profile page
          //     Navigator.pop(context);
          //   },
          //   child: Text('Voir le profil'),
          // ),
          TextButton(
            onPressed: () {
              context.read<AuthenticationCubit>().logOut();
              context.read<FilterCubit>().update();
              Navigator.pop(context);
            },
            child: Text('Se déconnecter'),
          ),
        ],
      );
    },
  );
}
