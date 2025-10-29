import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_list_provider.dart';
import '../widgets/user_list/user_list_item.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users as soon as the screen loads
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserListProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Consumer<UserListProvider>(
        builder: (context, provider, child) {
          switch (provider.state) {
            case UserListState.loading:
            case UserListState.initial:
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            case UserListState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Failed to load users:\n${provider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            case UserListState.loaded:
              return RefreshIndicator(
                onRefresh: provider.fetchUsers,
                color: Colors.black,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    return UserListItem(user: user);
                  },
                ),
              );
          }
        },
      ),
    );
  }
}