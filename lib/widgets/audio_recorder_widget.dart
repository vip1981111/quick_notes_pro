import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/generated/app_localizations.dart';

class AudioRecorderWidget extends StatefulWidget {
  final String? audioPath;
  final Function(String) onRecordingComplete;
  final VoidCallback onDelete;

  const AudioRecorderWidget({
    super.key,
    this.audioPath,
    required this.onRecordingComplete,
    required this.onDelete,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.audioPath;
    _player.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (_currentPath != null) ...[
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  iconSize: 48,
                  color: Colors.blue,
                  onPressed: _togglePlayback,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 32,
                  color: Colors.red,
                  onPressed: () {
                    setState(() => _currentPath = null);
                    widget.onDelete();
                  },
                ),
              ],
            ),
            Text(
              _isPlaying ? l10n.playRecording : l10n.tapToRecord,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ] else ...[
            // Recording controls
            GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording ? l10n.recording : l10n.tapToRecord,
              style: TextStyle(
                color: _isRecording ? Colors.red : Colors.grey[600],
                fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _currentPath = path;
        });
        widget.onRecordingComplete(path);
      }
    } else {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      if (_currentPath != null) {
        await _player.play(DeviceFileSource(_currentPath!));
        setState(() => _isPlaying = true);
      }
    }
  }
}
