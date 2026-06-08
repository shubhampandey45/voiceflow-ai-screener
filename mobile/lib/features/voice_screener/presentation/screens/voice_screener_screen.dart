import 'package:flutter/material.dart';
import '../../providers/voice_screener_provider.dart';
import '../widgets/recording_card.dart';
import '../widgets/candidate_card.dart';

class VoiceScreenerScreen extends StatefulWidget {
  const VoiceScreenerScreen({super.key});

  @override
  State<VoiceScreenerScreen> createState() => _VoiceScreenerScreenState();
}

class _VoiceScreenerScreenState extends State<VoiceScreenerScreen> {
  late final VoiceScreenerProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = VoiceScreenerProvider();
    _provider.fetchProfiles();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _handleRecordPress() async {
    if (_provider.isRecording) {
      await _provider.stopRecording();
    } else {
      await _provider.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceFlow AI'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('refresh_button'),
            icon: const Icon(Icons.refresh),
            onPressed: () => _provider.fetchProfiles(),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => _provider.fetchProfiles(),
            color: const Color(0xFF6366F1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_provider.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Container(
                        key: const Key('error_box'),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _provider.errorMessage,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                              onPressed: () => _provider.clearError(),
                            )
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  RecordingControlCard(
                    isRecording: _provider.isRecording,
                    isProcessing: _provider.isProcessing,
                    onRecordPressed: _handleRecordPress,
                  ),
                  const SizedBox(height: 24),

                  if (_provider.isProcessing)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              key: Key('processing_indicator'),
                              color: Color(0xFF6366F1),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Analyzing voice recording...",
                              style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Transcribing & structuring candidate metadata via AI",
                              style: TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: _provider.profiles.isEmpty && _provider.lastExtractedProfile == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.record_voice_over, size: 48, color: Colors.white24),
                                  SizedBox(height: 16),
                                  Text(
                                    "No candidate profiles processed yet",
                                    style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tap and record a candidate summary voice command",
                                    style: TextStyle(color: Colors.white30, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              key: const Key('profile_list'),
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                if (_provider.lastExtractedProfile != null) ...[
                                  _buildSectionHeader("Latest Extraction"),
                                  CandidateCard(candidate: _provider.lastExtractedProfile!, isLatest: true),
                                  const SizedBox(height: 20),
                                ],
                                if (_provider.profiles.isNotEmpty) ...[
                                  _buildSectionHeader("Historic Records"),
                                  ..._provider.profiles
                                      .where((p) => p['id'] != _provider.lastExtractedProfile?['id'])
                                      .map((p) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: CandidateCard(candidate: p, isLatest: false),
                                          )),
                                ]
                              ],
                            ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
