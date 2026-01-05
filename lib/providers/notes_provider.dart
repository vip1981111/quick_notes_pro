import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';

class NotesProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final AudioService _audioService = AudioService();

  List<NoteModel> _notes = [];
  NoteModel? _lastDeletedNote;

  NotesProvider(this._databaseService) {
    _loadNotes();
  }

  List<NoteModel> get notes => _notes;

  void _loadNotes() {
    _notes = _databaseService.getAllNotes();
    notifyListeners();
  }

  Future<void> addNote(NoteModel note) async {
    await _databaseService.addNote(note);
    _notes.add(note);
    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    await _databaseService.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  Future<void> deleteNote(NoteModel note) async {
    _lastDeletedNote = note;

    // Delete audio file if exists
    if (note.audioPath != null) {
      await _audioService.deleteAudioFile(note.audioPath!);
    }

    await _databaseService.deleteNote(note.id);
    _notes.removeWhere((n) => n.id == note.id);
    notifyListeners();
  }

  Future<void> undoDelete() async {
    if (_lastDeletedNote != null) {
      await addNote(_lastDeletedNote!);
      _lastDeletedNote = null;
    }
  }

  void toggleFavorite(NoteModel note) {
    note.isFavorite = !note.isFavorite;
    note.modifiedAt = DateTime.now();
    updateNote(note);
  }

  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    final lowerQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<NoteModel> getNotesWithAudio() {
    return _notes.where((note) => note.audioPath != null).toList();
  }

  List<NoteModel> getFavoriteNotes() {
    return _notes.where((note) => note.isFavorite).toList();
  }

  int get totalNotesCount => _notes.length;
  int get notesWithAudioCount => getNotesWithAudio().length;
  int get favoriteNotesCount => getFavoriteNotes().length;
}
