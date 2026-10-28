class GroupMember {
  final String id;
  final String userName;

  const GroupMember({required this.id, required this.userName});

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    id: json['id'] as String,
    userName: json['userName'] as String,
  );
}
