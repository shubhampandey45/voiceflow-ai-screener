import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/api_endpoints.dart';

class VoiceScreenerRepository {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> checkPermissions() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      return false;
    }
  }

  Future<void> startRecording(String path) async {
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  Future<String> getTempPath() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/candidate_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<Map<String, dynamic>> uploadAudio(File file) async {
    final uri = Uri.parse(ApiEndpoints.processVoice);
    final request = http.MultipartRequest("POST", uri);
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        file.path,
        filename: 'voice_recording.m4a',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      String detail = 'Unknown server error';
      try {
        final decoded = json.decode(response.body);
        detail = decoded['detail'] ?? detail;
      } catch (_) {}
      throw HttpException("Server Error (${response.statusCode}): $detail");
    }
  }

  Future<List<Map<String, dynamic>>> fetchProfiles() async {
    final uri = Uri.parse(ApiEndpoints.profiles);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw HttpException("Failed to load candidate profiles: ${response.statusCode}");
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}
