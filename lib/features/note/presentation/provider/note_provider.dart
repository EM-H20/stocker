// FILE: lib/features/note/presentation/provider/note_provider.dart

import 'package:flutter/material.dart';
import '../../domain/model/note.dart';
import '../../domain/repository/note_repository.dart';
import '../../data/dto/note_update_request.dart';

class NoteProvider with ChangeNotifier {
  final NoteRepository _repository;
  NoteProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  Future<void> fetchAllNotes() async {
    _setLoading(true);
    try {
      _notes = await _repository.getAllNotes();
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _errorMessage = '노트를 불러오는 데 실패했습니다: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<Note?> createNote(NoteUpdateRequest request) async {
    _setLoading(true);
    try {
      final newNote = await _repository.createNote(request);
      await fetchAllNotes();
      return newNote;
    } catch (e) {
      _errorMessage = '노트 생성에 실패했습니다: ${e.toString()}';
      _setLoading(false);
      return null;
    }
  }

  Future<bool> updateNote(int noteId, NoteUpdateRequest request) async {
    _setLoading(true);
    try {
      await _repository.updateNote(noteId, request);
      await fetchAllNotes();
      return true;
    } catch (e) {
      _errorMessage = '노트 수정에 실패했습니다: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteNote(int noteId) async {
    _setLoading(true);
    try {
      await _repository.deleteNote(noteId);
      await fetchAllNotes();
      return true;
    } catch (e) {
      _errorMessage = '노트 삭제에 실패했습니다: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
