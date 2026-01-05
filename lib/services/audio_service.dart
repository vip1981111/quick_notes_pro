import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioService {
  Future<String> getAudioDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  Future<String> generateAudioPath() async {
    final dir = await getAudioDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$dir/note_audio_$timestamp.m4a';
  }

  Future<void> deleteAudioFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> getAudioFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<List<String>> getAllAudioFiles() async {
    final dir = await getAudioDirectory();
    final audioDir = Directory(dir);
    if (!await audioDir.exists()) return [];

    final files = await audioDir.list().toList();
    return files
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.m4a'))
        .toList();
  }

  Future<void> cleanupOrphanedAudioFiles(List<String> usedPaths) async {
    final allFiles = await getAllAudioFiles();
    for (final file in allFiles) {
      if (!usedPaths.contains(file)) {
        await deleteAudioFile(file);
      }
    }
  }
}
