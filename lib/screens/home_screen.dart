import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/ad_service.dart';
import '../l10n/generated/app_localizations.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _filter = 'all'; // all, withAudio, favorites
  String _sortBy = 'dateModified'; // dateCreated, dateModified, titleAZ

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notesProvider = Provider.of<NotesProvider>(context);

    List<NoteModel> notes = _getFilteredNotes(notesProvider.notes);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip(l10n.all, 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip(l10n.withAudio, 'withAudio'),
                      const SizedBox(width: 8),
                      _buildFilterChip(l10n.favorites, 'favorites'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Notes List
                Expanded(
                  child: notes.isEmpty
                      ? _buildEmptyState(l10n)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _toggleFavorite(note),
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.white,
                                    icon: note.isFavorite ? Icons.star : Icons.star_border,
                                  ),
                                  SlidableAction(
                                    onPressed: (_) => _deleteNote(note, l10n),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: NoteCard(
                                note: note,
                                onTap: () => _editNote(note),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(l10n.noNotes, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.addFirstNote, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    var filtered = notes.where((note) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!note.title.toLowerCase().contains(query) &&
            !note.content.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      switch (_filter) {
        case 'withAudio':
          return note.audioPath != null;
        case 'favorites':
          return note.isFavorite;
        default:
          return true;
      }
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'dateCreated':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'titleAZ':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      default: // dateModified
        filtered.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }

    return filtered;
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sortBy),
        content: RadioGroup<String>(
          groupValue: _sortBy,
          onChanged: (v) {
            setState(() => _sortBy = v!);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.dateModified),
                leading: Radio<String>(value: 'dateModified'),
                onTap: () {
                  setState(() => _sortBy = 'dateModified');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.dateCreated),
                leading: Radio<String>(value: 'dateCreated'),
                onTap: () {
                  setState(() => _sortBy = 'dateCreated');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.titleAZ),
                leading: Radio<String>(value: 'titleAZ'),
                onTap: () {
                  setState(() => _sortBy = 'titleAZ');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewNote() {
    AdService().incrementActionCount();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
  }

  void _editNote(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  void _toggleFavorite(NoteModel note) {
    Provider.of<NotesProvider>(context, listen: false).toggleFavorite(note);
  }

  void _deleteNote(NoteModel note, AppLocalizations l10n) {
    Provider.of<NotesProvider>(context, listen: false).deleteNote(note);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.noteDeleted),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            Provider.of<NotesProvider>(context, listen: false).undoDelete();
          },
        ),
      ),
    );
  }
}
