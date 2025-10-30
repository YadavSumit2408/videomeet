
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_call_provider.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  const VideoCallScreen({super.key, required this.channelName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // --- NEW: This stores the position of your floating video ---
  Offset _floatingVideoPosition = const Offset(16, 40);

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoCallProvider>(
      builder: (context, provider, child) {
        return WillPopScope(
          onWillPop: () async {
            await provider.leaveCall();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: _buildBody(provider),
          ),
        );
      },
    );
  }

  Widget _buildBody(VideoCallProvider provider) {
    // 1. Handle Loading
    if (provider.isLoading) {
      return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Joining call...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    // 2. Handle Error
    if (provider.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${provider.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    // 3. Handle Success
    if (provider.isJoined) {
      return Stack(
        children: [
          _buildVideoGrid(provider),
          _buildControls(provider),
        ],
      );
    }

    // 4. Handle Fallback
    return const Center(
      child: Text('Something went wrong.', style: TextStyle(color: Colors.white)),
    );
  }

  // --- NEW: Helper widget to build the local video (or "Camera Off") view ---
  Widget _buildLocalVideoView(VideoCallProvider provider) {
    if (provider.isVideoDisabled) {
      // "Camera Off" UI
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                'Camera Off',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Local camera view
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: provider.engine!,
        canvas: const VideoCanvas(
          uid: 0, // 0 is always local
          sourceType: VideoSourceType.videoSourceCamera,
        ),
      ),
    );
  }

  // --- UPDATED: This logic is now much better ---
  Widget _buildVideoGrid(VideoCallProvider provider) {
    // 1. Screen Sharing (No change, this is good)
    if (provider.isScreenSharing) {
      return Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: provider.engine!,
                  canvas: const VideoCanvas(
                    uid: 0,
                    sourceType: VideoSourceType.videoSourceScreen,
                  ),
                ),
              ),
            ),
          ),
          if (provider.remoteUids.isNotEmpty)
            Expanded(
              flex: 1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.remoteUids.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.all(4),
                    child: AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: provider.engine!,
                        canvas: VideoCanvas(
                          uid: provider.remoteUids[index],
                          sourceType: VideoSourceType.videoSourceRemote,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    }

    final remoteUserUids = provider.remoteUids;

    // 2. Normal Call - Only local user
    if (remoteUserUids.isEmpty) {
      // Show local video fullscreen
      return _buildLocalVideoView(provider);
    }

    // 3. Normal Call - 1-on-1 or group (WhatsApp style)
    // Main view is the remote user
    // Floating view is the local user
    return Stack(
      children: [
        // Fullscreen Remote User (the first one)
        AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: provider.engine!,
            canvas: VideoCanvas(
              uid: remoteUserUids[0], // First remote user
              sourceType: VideoSourceType.videoSourceRemote,
            ),
          ),
        ),

        // Floating, Draggable Local Preview
        Positioned(
          left: _floatingVideoPosition.dx,
          top: _floatingVideoPosition.dy,
          child: Draggable(
            feedback: SizedBox( // This is the widget being dragged
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildLocalVideoView(provider),
              ),
            ),
            childWhenDragging: Container(), // Leave an empty space
            onDragEnd: (details) {
              // Update the position, but keep it on screen
              final size = MediaQuery.of(context).size;
              setState(() {
                double newDx = details.offset.dx;
                double newDy = details.offset.dy;

                // Clamp to screen boundaries
                if (newDx < 0) newDx = 0;
                if (newDx > size.width - 120) newDx = size.width - 120;
                if (newDy < 40) newDy = 40; // Respect status bar area
                if (newDy > size.height - 160) newDy = size.height - 160;

                _floatingVideoPosition = Offset(newDx, newDy);
              });
            },
            child: SafeArea( // This is the widget at rest
              child: SizedBox(
                width: 120,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildLocalVideoView(provider),
                ),
              ),
            ),
          ),
        ),
        
        // (Optional: Show other remote users as thumbnails at the bottom)
        if (remoteUserUids.length > 1)
          Positioned(
            bottom: 120, // Just above controls
            left: 0,
            right: 0,
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: remoteUserUids.length - 1,
              itemBuilder: (context, index) {
                final uid = remoteUserUids[index + 1]; // The *other* remote users
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 80,
                      height: 100,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: provider.engine!,
                          canvas: VideoCanvas(
                            uid: uid,
                            sourceType: VideoSourceType.videoSourceRemote,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildControls(VideoCallProvider provider) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildControlButton(
            icon: provider.isMuted ? Icons.mic_off : Icons.mic,
            onPressed: provider.toggleMute,
            backgroundColor: provider.isMuted ? Colors.red : Colors.white24,
          ),

          // End Call Button
          _buildControlButton(
            icon: Icons.call_end,
            onPressed: () {
              provider.leaveCall();
              Navigator.of(context).pop();
            },
            backgroundColor: Colors.red,
          ),

          // Video On/Off Button
          _buildControlButton(
            icon: provider.isVideoDisabled ? Icons.videocam_off : Icons.videocam,
            onPressed: provider.toggleVideo,
            backgroundColor: provider.isVideoDisabled ? Colors.red : Colors.white24,
          ),

          // Switch Camera Button (only when not screen sharing)
          if (!provider.isScreenSharing)
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              onPressed: provider.switchCamera,
              backgroundColor: Colors.white24,
            ),

          // Screen Share Button
          _buildControlButton(
            icon: provider.isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
            onPressed: provider.toggleScreenShare,
            backgroundColor: provider.isScreenSharing ? Colors.green : Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.white,
        iconSize: 28,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}