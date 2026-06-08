import 'dart:io';
import 'package:flutter/material.dart';
import '../data/voice_screener_repository.dart';

class VoiceScreenerProvider extends ChangeNotifier {
  final VoiceScreenerRepository _repository = VoiceScreenerRepository();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  
  List<Map<String, dynamic>> _profiles = [];
  Map<String, dynamic>? _lastExtractedProfile;
  String _errorMessage = '';

  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  List<Map<String, dynamic>> get profiles => _profiles;
  Map<String, dynamic>? get lastExtractedProfile => _lastExtractedProfile;
  String get errorMessage => _errorMessage;

  Future<void> startRecording() async {
    try {
      _errorMessage = '';
      final hasPermission = await _repository.checkPermissions();
      if (!hasPermission) {
        _errorMessage = "Microphone permission is required to record voice notes.";
        notifyListeners();
        return;
      }

      final path = await _repository.getTempPath();
      await _repository.startRecording(path);
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to start recording: $e";
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!_isRecording) return;
      final path = await _repository.stopRecording();
      _isRecording = false;
      
      if (path != null) {
        notifyListeners();
        await uploadAudio(File(path));
      } else {
        _errorMessage = "Failed to finalize audio capture.";
        notifyListeners();
      }
    } catch (e) {
      _isRecording = false;
      _errorMessage = "Failed to stop recording: $e";
      notifyListeners();
    }
  }

  Future<void> uploadAudio(File audioFile) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _lastExtractedProfile = await _repository.uploadAudio(audioFile);
      await fetchProfiles();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "").replaceAll("HttpException: ", "");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfiles() async {
    try {
      _profiles = await _repository.fetchProfiles();
      _errorMessage = '';
    } catch (e) {
      if (_errorMessage.isEmpty) {
        _errorMessage = e.toString().replaceAll("Exception: ", "").replaceAll("HttpException: ", "");
      }
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
