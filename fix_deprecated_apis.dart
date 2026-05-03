import 'dart:io';

void main() {
  print('🔧 Fixing deprecated API calls in Let\'s Crease app...\n');
  
  final projectDir = Directory.current;
  final libDir = Directory('${projectDir.path}/lib');
  
  if (!libDir.existsSync()) {
    print('❌ lib directory not found. Make sure you\'re running this from the project root.');
    return;
  }
  
  int totalFiles = 0;
  int modifiedFiles = 0;
  
  // Find all Dart files
  final dartFiles = libDir
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  for (final file in dartFiles) {
    totalFiles++;
    String content = file.readAsStringSync();
    String originalContent = content;
    
    // Fix withOpacity() calls
    content = content.replaceAllMapped(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      (match) => '.withValues(alpha: ${match.group(1)})',
    );
    
    // Fix print statements (but preserve developer.log)
    if (!content.contains('import \'dart:developer\' as developer;') && 
        content.contains('print(')) {
      // Add developer import if not present and print statements exist
      final importIndex = content.indexOf('import ');
      if (importIndex != -1) {
        final lines = content.split('\n');
        final importLines = <String>[];
        final otherLines = <String>[];
        bool inImports = false;
        
        for (final line in lines) {
          if (line.trim().startsWith('import ')) {
            inImports = true;
            importLines.add(line);
          } else if (inImports && line.trim().isEmpty) {
            importLines.add(line);
          } else {
            if (inImports && !importLines.contains('import \'dart:developer\' as developer;')) {
              importLines.add('import \'dart:developer\' as developer;');
              inImports = false;
            }
            otherLines.add(line);
          }
        }
        
        if (inImports && !importLines.contains('import \'dart:developer\' as developer;')) {
          importLines.add('import \'dart:developer\' as developer;');
        }
        
        content = [...importLines, ...otherLines].join('\n');
      }
    }
    
    // Replace print statements with developer.log
    content = content.replaceAllMapped(
      RegExp(r'print\(([^)]+)\);'),
      (match) => 'developer.log(${match.group(1)});',
    );
    
    // Fix dialogBackgroundColor
    content = content.replaceAll(
      'Theme.of(context).dialogBackgroundColor',
      'Theme.of(context).dialogTheme.backgroundColor',
    );
    
    if (content != originalContent) {
      file.writeAsStringSync(content);
      modifiedFiles++;
      print('✅ Fixed: ${file.path.split('/').last}');
    }
  }
  
  print('\n🎉 Completed!');
  print('📊 Files processed: $totalFiles');
  print('🔧 Files modified: $modifiedFiles');
  print('\n🚀 Run "flutter analyze" to check remaining issues.');
}
