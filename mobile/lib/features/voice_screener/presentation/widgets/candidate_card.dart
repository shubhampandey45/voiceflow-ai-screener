import 'package:flutter/material.dart';

class CandidateCard extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final bool isLatest;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.isLatest,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = candidate['candidate_name'] ?? 'Candidate Name (Unparsed)';
    final rawTranscript = candidate['raw_transcript'] ?? '';
    final experience = candidate['experience_years'] ?? 0;
    final priority = candidate['priority_score'] ?? 'Medium';
    
    List<String> skills = [];
    if (candidate['skills'] != null) {
      if (candidate['skills'] is List) {
        skills = List<String>.from((candidate['skills'] as List).map((s) => s.toString()));
      }
    }

    final priorityColor = _getPriorityColor(priority);

    return Container(
      decoration: BoxDecoration(
        color: isLatest ? const Color(0xFF1E293B) : const Color(0xFF1E293B).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: isLatest ? Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35), width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: isLatest ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: priorityColor.withValues(alpha: 0.8), width: 1),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "$experience Year${experience == 1 ? '' : 's'} of Experience",
              style: TextStyle(
                color: Colors.white70,
                fontSize: isLatest ? 14 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (rawTranscript.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 10),
              const Text(
                "RAW TRANSCRIPT",
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rawTranscript,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
