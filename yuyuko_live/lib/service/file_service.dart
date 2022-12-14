import 'dart:io';

import 'package:logging/logging.dart';

/// Read tempArenaInfo.json from the give path.
class FileService {
  final _logger = Logger('FileService');
  final String? path;
  FileService({required this.path});

  String? _json;
  String? get json => _json;

  DateTime? _lastModified;

  Future<bool?> load({
    required Duration cycle,
  }) async {
    if (path == null) return false;
    final jsonPath = '$path\\tempArenaInfo.json';
    try {
      final file = File(jsonPath);

      // only load again if the file is modified
      final fileStat = await file.stat();
      final lastModified = fileStat.modified;
      // only check this starting from the second cycle
      if (_lastModified == null) {
        _lastModified = lastModified;
      } else {
        final now = DateTime.now();
        final diff = now.difference(lastModified);
        if (diff.inSeconds > cycle.inSeconds) {
          _logger.info('File is not modified');
          return false;
        }
      }

      final json = await file.readAsString();
      _logger.fine('Loaded json successfully');
      _json = json;

      return true;
    } on FileSystemException {
      _logger.info('File does not exist');
      return false;
    } on Exception catch (e) {
      _logger.severe('EXCEPTION: $e');
      return null;
    }
  }
}
