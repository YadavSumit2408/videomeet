import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:videomeet/domains/repositories/video_call_repository.dart';

class VideoCallProvider extends ChangeNotifier {
  final VideoCallRepository _repository;

  VideoCallProvider({required VideoCallRepository videoCallRepository})
      : _repository = videoCallRepository;

  // State
  RtcEngine? _engine;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoDisabled = false;
  bool _isScreenSharing = false;
  int _localUid = 0; 
  final List<int> _remoteUids = [];

  // Getters
  RtcEngine? get engine => _engine;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoDisabled => _isVideoDisabled;
  bool get isScreenSharing => _isScreenSharing;
  int get localUid => _localUid;
  List<int> get remoteUids => _remoteUids;

  void _resetState() {
    _engine = null;
    _isLoading = false;
    _errorMessage = '';
    _isJoined = false;
    _isMuted = false;
    _isVideoDisabled = false;
    _isScreenSharing = false;
    _localUid = 0;
    _remoteUids.clear();
  }

  Future<bool> joinCall(String channelName) async {
    _isLoading = true; // --- SET TO TRUE ---
    _errorMessage = '';
    _remoteUids.clear();
    _localUid = 0;
    notifyListeners();

    // 1. Request Permissions
    final permResult = await _repository.requestPermissions();
    if (permResult.isLeft) {
      _errorMessage = permResult.left.message;
      _isLoading = false; // --- SET TO FALSE ON FAILURE ---
      notifyListeners();
      return false;
    }

    // 2. Setup Engine
    final engineResult = await _repository.setupEngine();
    if (engineResult.isLeft) {
      _errorMessage = engineResult.left.message;
      _isLoading = false; // --- SET TO FALSE ON FAILURE ---
      notifyListeners();
      return false;
    }
    _engine = engineResult.right;

    // 3. Register Event Handlers
    _registerEventHandlers();

    // 4. Join Channel
    final joinResult = await _repository.joinCall(_engine!, channelName);
    if (joinResult.isLeft) {
      _errorMessage = joinResult.left.message;
      _isLoading = false; // --- SET TO FALSE ON FAILURE ---
      notifyListeners();
      return false;
    }

    // We no longer set isLoading = false here. We wait for the event.
    notifyListeners();
    return true;
  }

  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user ${connection.localUid} joined');
          _localUid = connection.localUid ?? 0;
          _isJoined = true;
          _isLoading = false; // --- FIX: SET TO FALSE ON SUCCESS ---
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('Remote user $remoteUid joined');
          _remoteUids.add(remoteUid);
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('Remote user $remoteUid left');
          _remoteUids.remove(remoteUid);
          notifyListeners();
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora Error: [$err] $msg');
          _errorMessage = msg;
          _isLoading = false; // --- FIX: SET TO FALSE ON ERROR ---
          _isJoined = false;
          notifyListeners();
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('Left channel');
          _remoteUids.clear();
          _isJoined = false;
          notifyListeners();
        },
      ),
    );
  }

  Future<void> leaveCall() async {
    if (_engine != null) {
      if (_isScreenSharing) {
        await toggleScreenShare();
      }
      await _repository.leaveCall(_engine!);
      await _repository.destroyEngine(_engine!);
    }
    _resetState();
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (_engine == null) return;
    _isMuted = !_isMuted;
    final result = await _repository.toggleMute(_engine!, _isMuted);
    if (result.isLeft) {
      _errorMessage = result.left.message;
      _isMuted = !_isMuted;
    }
    notifyListeners();
  }

  Future<void> toggleVideo() async {
    if (_engine == null) return;
    _isVideoDisabled = !_isVideoDisabled;
    final result = await _repository.toggleVideo(_engine!, !_isVideoDisabled);
    if (result.isLeft) {
      _errorMessage = result.left.message;
      _isVideoDisabled = !_isVideoDisabled;
    }
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    final result = await _repository.switchCamera(_engine!);
    if (result.isLeft) {
      _errorMessage = result.left.message;
    }
    notifyListeners();
  }

  Future<void> toggleScreenShare() async {
    if (_engine == null) return;
    _isScreenSharing = !_isScreenSharing;
    final result = _isScreenSharing
        ? await _repository.startScreenShare(_engine!)
        : await _repository.stopScreenShare(_engine!);

    if (result.isLeft) {
      _errorMessage = result.left.message;
      _isScreenSharing = !_isScreenSharing;
    }
    notifyListeners();
  }
}