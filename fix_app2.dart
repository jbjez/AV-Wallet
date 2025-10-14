import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  final files = await libDir.list(recursive: true).where((f) => f.path.endsWith('.dart')).toList();
  
  for (final file in files) {
    final content = await File(file.path).readAsString();
    
    // Remplacer toutes les utilisations de loc.xxx par "Texte"
    var newContent = content.replaceAllMapped(
      RegExp(r'loc\.[a-zA-Z_]+'),
      (match) => '"Texte"'
    );
    
    await File(file.path).writeAsString(newContent);
  }
  
  print('Fini !');
}
