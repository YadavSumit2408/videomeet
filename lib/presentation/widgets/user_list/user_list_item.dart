import 'package:flutter/material.dart';
import 'package:videomeet/domains/entities/user_entity.dart';


class UserListItem extends StatelessWidget {
  final UserEntity user;
  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // We use a Container to mimic the style of our theme's text fields
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatar != null
              ? NetworkImage(user.avatar!)
              : null,
          child: user.avatar == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // TODO: In the future, this could start a video call
        },
      ),
    );
  }
}