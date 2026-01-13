import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  final List<Color> _noteColors = const [
    Colors.white,
    Color(0xFFFFCDD2), // red.shade100
    Color(0xFFFFE0B2), // orange.shade100
    Color(0xFFFFF9C4), // yellow.shade100
    Color(0xFFC8E6C9), // green.shade100
    Color(0xFFBBDEFB), // blue.shade100
    Color(0xFFE1BEE7), // purple.shade100
    Color(0xFFF8BBD0), // pink.shade100
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = note.colorIndex != null
        ? _noteColors[note.colorIndex!]
        : (isDark ? Colors.grey[800] : Theme.of(context).cardColor);

    // لون الخط: أسود دائماً إذا كان هناك لون خلفية، أبيض في Dark Mode بدون لون
    final textColor = note.colorIndex != null
        ? Colors.black87
        : (isDark ? Colors.white : Colors.black87);

    final subtitleColor = note.colorIndex != null
        ? Colors.black54
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isFavorite)
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  if (note.audioPath != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.mic, color: Colors.blue, size: 20),
                    ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _formatDate(note.modifiedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
