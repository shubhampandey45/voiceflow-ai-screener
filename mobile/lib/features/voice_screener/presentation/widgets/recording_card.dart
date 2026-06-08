import 'package:flutter/material.dart';

class RecordingControlCard extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onRecordPressed;

  const RecordingControlCard({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    required this.onRecordPressed,
  });

  @override
  State<RecordingControlCard> createState() => _RecordingControlCardState();
}

class _RecordingControlCardState extends State<RecordingControlCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant RecordingControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRec = widget.isRecording;
    final isProc = widget.isProcessing;

    return Card(
      key: const Key('record_card'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isRec
                  ? "Recording... Tap button again to analyze"
                  : isProc
                      ? "Processing transaction pipeline..."
                      : "Tap to record candidate details",
              style: TextStyle(
                fontSize: 14,
                color: isRec ? Colors.redAccent : Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: isProc ? null : widget.onRecordPressed,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    double scale = 1.0 + (_pulseController.value * 0.12);
                    return Transform.scale(
                      scale: isRec ? scale : 1.0,
                      child: Container(
                        key: const Key('mic_button'),
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRec ? const Color(0xFFEF4444) : const Color(0xFF6366F1),
                          boxShadow: [
                            BoxShadow(
                              color: (isRec ? const Color(0xFFEF4444) : const Color(0xFF6366F1))
                                  .withValues(alpha: 0.35),
                              blurRadius: isRec ? 18 * _pulseController.value + 6 : 8,
                              spreadRadius: isRec ? 4 * _pulseController.value + 1 : 1,
                            )
                          ],
                        ),
                        child: Icon(
                          isRec ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
