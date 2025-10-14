import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'action_button.dart';

class CommentButton extends StatefulWidget {
  final String commentKey; // Clé unique pour identifier le commentaire
  final String dialogTitle; // Titre du dialog
  final String tabName; // Nom de l'onglet pour l'affichage
  final Function(String)? onCommentChanged; // Callback quand le commentaire change
  final bool showCommentFrame; // Afficher le cadre de commentaire
  final double? commentFrameSpacing; // Espacement avant le cadre de commentaire

  const CommentButton({
    super.key,
    required this.commentKey,
    required this.dialogTitle,
    required this.tabName,
    this.onCommentChanged,
    this.showCommentFrame = true,
    this.commentFrameSpacing,
  });

  @override
  State<CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<CommentButton> {
  Map<String, String> _comments = {};
  String _currentComment = '';

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void didUpdateWidget(CommentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentKey != widget.commentKey) {
      _loadComments();
    }
  }

  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('app_comments');
      if (commentsJson != null) {
        setState(() {
          _comments = Map<String, String>.from(json.decode(commentsJson));
          _currentComment = _comments[widget.commentKey] ?? '';
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_comments', json.encode(_comments));
      // Nettoyer les anciens commentaires (garder seulement les 50 plus récents)
      _cleanupOldComments();
    } catch (e) {
      print('Error saving comments: $e');
    }
  }

  void _cleanupOldComments() {
    if (_comments.length > 50) {
      // Garder seulement les 50 commentaires les plus récents
      final sortedEntries = _comments.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      _comments.clear();
      for (int i = 0; i < 50 && i < sortedEntries.length; i++) {
        _comments[sortedEntries[i].key] = sortedEntries[i].value;
      }
    }
  }

  Future<void> _showCommentDialog() async {
    final TextEditingController commentController = TextEditingController(
      text: _currentComment,
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1128)
              : Colors.white,
          content: SizedBox(
            width: 300, // Largeur fixe pour éviter le resserrement
            child: TextField(
              controller: commentController,
              maxLines: 3,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire pour ${widget.tabName}...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                setState(() {
                  if (comment.isEmpty) {
                    _comments.remove(widget.commentKey);
                    _currentComment = '';
                  } else {
                    _comments[widget.commentKey] = comment;
                    _currentComment = comment;
                  }
                });
                await _saveComments();
                if (widget.onCommentChanged != null) {
                  widget.onCommentChanged!(_currentComment);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton commentaire
        ActionButton.comment(
          onPressed: _showCommentDialog,
        ),
        
        // Cadre de commentaire (si activé et commentaire présent)
        if (widget.showCommentFrame && _currentComment.isNotEmpty) ...[
          SizedBox(height: widget.commentFrameSpacing ?? 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[900]?.withOpacity(0.3)
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.lightBlue[300]!
                    : Colors.blue[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.lightBlue[300]
                      : Colors.blue[700],
                ),
                const SizedBox(height: 6),
                Text(
                  _currentComment,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
