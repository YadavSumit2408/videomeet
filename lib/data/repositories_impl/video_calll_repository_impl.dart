import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:either_dart/either.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../domains/repositories/video_call_repository.dart';

const String _agoraAppId = "c75f65b1a6254592a715abb6a2a94e1a";

class VideoCallRepositoryImpl implements VideoCallRepository {
  
  @override
  Future<Either<Failure, void>> requestPermissions() async {
    try {
      await [Permission.microphone, Permission.camera].request();
      final micStatus = await Permission.microphone.status;
      final camStatus = await Permission.camera.status;

      if (micStatus.isGranted && camStatus.isGranted) {
        return const Right(null);
      }
      return const Left(PermissionFailure('Microphone and Camera permissions are required.'));
    } catch (e) {
      return Left(PermissionFailure('Failed to request permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, RtcEngine>> setupEngine() async {
    if (_agoraAppId.isEmpty) {
      return const Left(ServerFailure('Agora App ID is not set.'));
    }

    try {
      final engine = createAgoraRtcEngine();
      await engine.initialize(const RtcEngineContext(appId: _agoraAppId));
      
      await engine.enableVideo();
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.startPreview();
      
      return Right(engine);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize Agora: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> joinCall(RtcEngine engine, String channelName) async {
    try {
      await engine.joinChannel(
        token: "",
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          publishScreenTrack: false, // Initially false
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to join channel: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveCall(RtcEngine engine) async {
    try {
      await engine.leaveChannel();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to leave channel: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> destroyEngine(RtcEngine engine) async {
    try {
      await engine.release();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to destroy engine: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMute(RtcEngine engine, bool isMuted) async {
    try {
      await engine.muteLocalAudioStream(isMuted);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to toggle mute: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> toggleVideo(RtcEngine engine, bool isEnabled) async {
    try {
      await engine.enableLocalVideo(isEnabled);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to toggle video: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> startScreenShare(RtcEngine engine) async {
    try {
      debugPrint('🔴 Starting screen share...');
      
      // Start screen capture with proper parameters
      await engine.startScreenCapture(
        const ScreenCaptureParameters2(
          captureAudio: true,  // Capture system audio if needed
          audioParams: ScreenAudioParameters(
            sampleRate: 16000,
            channels: 2,
            captureSignalVolume: 100,
          ),
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: 1920, height: 1080),
            frameRate: 15,
            bitrate: 0, // 0 means automatic
          ),
        ),
      );
      
      // CRITICAL: Update channel to publish screen and stop camera
      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishScreenCaptureVideo: true,  // Changed from publishScreenTrack
          publishScreenCaptureAudio: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: true, // Keep mic on
        ),
      );
      
      debugPrint('✅ Screen share started successfully');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ Screen share failed: $e');
      return Left(ServerFailure('Failed to start screen share: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> stopScreenShare(RtcEngine engine) async {
    try {
      debugPrint('🔴 Stopping screen share...');
      
      await engine.stopScreenCapture();
      
      // CRITICAL: Re-enable camera and disable screen
      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishScreenCaptureVideo: false,  // Changed from publishScreenTrack
          publishScreenCaptureAudio: false,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );
      
      debugPrint('✅ Screen share stopped successfully');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ Stop screen share failed: $e');
      return Left(ServerFailure('Failed to stop screen share: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> switchCamera(RtcEngine engine) async {
    try {
      await engine.switchCamera();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to switch camera: ${e.toString()}'));
    }
  }
}