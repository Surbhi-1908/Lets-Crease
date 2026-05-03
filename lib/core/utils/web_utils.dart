import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;

class WebUtils {
  static bool get isWeb => kIsWeb;
  
  static bool get supportsWebGL {
    if (!kIsWeb) return false;
    
    try {
      final canvas = html.CanvasElement();
      final gl = canvas.getContext3d();
      return gl != null;
    } catch (e) {
      return false;
    }
  }
  
  static Future<Uint8List?> pickImageFromWeb() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        if (kIsWeb) {
          // Web: use bytes directly
          return file.bytes;
        } else if (Platform.isAndroid || Platform.isIOS) {
          // Mobile: read from file path
          if (file.path != null) {
            return await File(file.path!).readAsBytes();
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error picking image: $e');
      return null;
    }
  }

  static Future<Uint8List?> pickFileFromWeb() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        if (kIsWeb) {
          // Web: use bytes directly
          return file.bytes;
        } else if (Platform.isAndroid || Platform.isIOS) {
          // Mobile: read from file path
          if (file.path != null) {
            return await File(file.path!).readAsBytes();
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error picking file: $e');
      return null;
    }
  }

  static void downloadFile(Uint8List bytes, String filename) {
    if (!kIsWeb) return;
    
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      developer.log('Error downloading file: $e');
    }
  }

  static void updateMetaTag(String name, String content) {
    if (!kIsWeb) return;
    
    try {
      var meta = html.document.querySelector('meta[name="$name"]') as html.MetaElement?;
      if (meta == null) {
        meta = html.MetaElement()
          ..name = name
          ..content = content;
        html.document.head?.append(meta);
      } else {
        meta.content = content;
      }
    } catch (e) {
      print('Error updating meta tag: $e');
    }
  }

  static void optimizeForWeb() {
    if (!kIsWeb) return;
    
    try {
      // Add performance hints
      updateMetaTag('viewport', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
      
      // Preload critical resources
      final preloadLink = html.LinkElement()
        ..rel = 'preload'
        ..href = 'assets/fonts/MaterialIcons-Regular.otf'
        ..setAttribute('as', 'font')
        ..setAttribute('type', 'font/otf')
        ..setAttribute('crossorigin', 'anonymous');
      html.document.head?.append(preloadLink);
    } catch (e) {
      print('Error optimizing for web: $e');
    }
  }

  static void setPageTitle(String title) {
    if (!kIsWeb) return;
    html.document.title = title;
  }
  
  static void updateMetaDescription(String description) {
    if (!kIsWeb) return;
    
    final meta = html.document.querySelector('meta[name="description"]') as html.MetaElement?;
    meta?.content = description;
  }
}
