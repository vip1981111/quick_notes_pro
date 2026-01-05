import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class DatabaseService {
  static const String _notesBoxName = 'notes';
  late Box<NoteModel> _notesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteModelAdapter());
    _notesBox = await Hive.openBox<NoteModel>(_notesBoxName);
  }

  Box<NoteModel> get notesBox => _notesBox;

  List<NoteModel> getAllNotes() {
    return _notesBox.values.toList();
  }

  Future<void> addNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> updateNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<void> clearAllNotes() async {
    await _notesBox.clear();
  }
}
