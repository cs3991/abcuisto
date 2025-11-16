import 'package:abcuisto/generated/pocketbase/users_record.dart';

class Comment {
  final double note;
  final String comment;
  final UsersRecord author;

  Comment({required this.note, required this.comment, required this.author});
}
