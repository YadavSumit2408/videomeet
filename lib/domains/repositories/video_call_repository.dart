import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';

abstract class VideoCallRepository {
  Future<Either<Failure, RtcEngine>> setupEngine();
  Future<Either<Failure, void>> joinCall(RtcEngine engine, String channelName);
  Future<Either<Failure, void>> leaveCall(RtcEngine engine);
  Future<Either<Failure, void>> toggleMute(RtcEngine engine, bool isMuted);
  Future<Either<Failure, void>> toggleVideo(RtcEngine engine, bool isEnabled);
  Future<Either<Failure, void>> startScreenShare(RtcEngine engine);
  Future<Either<Failure, void>> stopScreenShare(RtcEngine engine);
  Future<Either<Failure, void>> destroyEngine(RtcEngine engine);
  Future<Either<Failure, void>> requestPermissions();
  Future<Either<Failure, void>> switchCamera(RtcEngine engine);
}