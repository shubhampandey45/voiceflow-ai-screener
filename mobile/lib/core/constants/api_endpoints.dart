import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Pointing directly to your live Hugging Face cloud backend
  static String get baseUrl {
    return "https://shubhampandey45-voiceflowai.hf.space";
  }

  static String get processVoice => "$baseUrl/api/v1/process-voice";
  static String get profiles => "$baseUrl/api/v1/profiles";
}