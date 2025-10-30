import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videomeet/presentation/screens/user_list_screen.dart';
import 'package:videomeet/presentation/screens/video_call_screen.dart';

import '../providers/video_call_provider.dart';


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),    
    UserListScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ), // Use IndexedStack to keep state of each tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // Or your app's theme color
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _channelNameController = TextEditingController();

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  Future<void> _joinCall(String channelName) async {
    final videoProvider = context.read<VideoCallProvider>();

    // Show a loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.black)),
    );

    // Call the provider to set up and join the call
    final bool success = await videoProvider.joinCall(channelName);

    // Hide the loading spinner
    Navigator.of(context).pop();

    if (success) {
      // If successful, navigate to the call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(channelName: channelName),
        ),
      );
    } else {
      // If failed, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join call: ${videoProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showJoinCallDialog() {
    _channelNameController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Join a Call"),
          content: TextField(
            controller: _channelNameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Enter Meeting ID",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Join"),
              onPressed: () {
                final channelName = _channelNameController.text;
                if (channelName.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  _joinCall(channelName);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Meet Home'),
        backgroundColor: Colors.black,
      centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_call_rounded,
              size: 100,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: _showJoinCallDialog,
              child: const Text('Join a Call'),
            ),
          ],
        ),
      ),
    );
  }
}