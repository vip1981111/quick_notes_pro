import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../widgets/audio_recorder_widget.dart';
import '../l10n/generated/app_localizations.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _audioPath;
  int? _colorIndex;
  bool _isEditing = false;

  final List<Color> _noteColors = [
    Colors.white,
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _audioPath = widget.note?.audioPath;
    _colorIndex = widget.note?.colorIndex;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backgroundColor = _colorIndex != null ? _noteColors[_colorIndex!] : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(_isEditing ? l10n.editNote : l10n.newNote),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: l10n.title,
                border: InputBorder.none,
              ),
              maxLines: 1,
            ),
            const Divider(),

            // Content Field
            TextField(
              controller: _contentController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.content,
                border: InputBorder.none,
              ),
              maxLines: null,
              minLines: 10,
            ),
            const SizedBox(height: 24),

            // Audio Recorder
            AudioRecorderWidget(
              audioPath: _audioPath,
              onRecordingComplete: (path) {
                setState(() => _audioPath = path);
              },
              onDelete: () {
                setState(() => _audioPath = null);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_noteColors.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _colorIndex = index == 0 ? null : index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _noteColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colorIndex == index ? Colors.blue : Colors.grey,
                        width: _colorIndex == index ? 3 : 1,
                      ),
                    ),
                    child: index == 0
                        ? const Icon(Icons.format_color_reset, color: Colors.grey)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (_isEditing) {
      final updatedNote = widget.note!
        ..title = _titleController.text
        ..content = _contentController.text
        ..modifiedAt = DateTime.now()
        ..audioPath = _audioPath
        ..colorIndex = _colorIndex;
      notesProvider.updateNote(updatedNote);
    } else {
      final newNote = NoteModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        audioPath: _audioPath,
        colorIndex: _colorIndex,
      );
      notesProvider.addNote(newNote);
    }

    Navigator.pop(context);
  }
}
