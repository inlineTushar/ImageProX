// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ImageProx';

  @override
  String get homeTitle => 'ImageProx';

  @override
  String get homeEmpty => 'No history yet. Capture an image to get started.';

  @override
  String get captureTitle => 'Capture Image';

  @override
  String get captureSourceLabel => 'Select an image source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get processingTitle => 'Processing';

  @override
  String get processingDetecting => 'Detecting content...';

  @override
  String get processingFace => 'Processing face image...';

  @override
  String get processingDocument => 'Processing document image...';

  @override
  String get processingPreparing => 'Preparing result...';

  @override
  String get noImageSelected => 'No image selected for processing.';

  @override
  String get processingTimeout => 'Detection timed out. Please try again.';

  @override
  String get processingFailed => 'Processing failed.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get resultTitle => 'Result';

  @override
  String get beforeAfter => 'Before / After';

  @override
  String get original => 'Original';

  @override
  String get processed => 'Processed';

  @override
  String get done => 'Done';

  @override
  String get pdfCreatedTitle => 'PDF Created';

  @override
  String get documentTitle => 'Document Title';

  @override
  String get openPdf => 'Open PDF';

  @override
  String get pdfUnavailable => 'PDF is not available yet.';

  @override
  String get faceProcessed => 'Face Processed';

  @override
  String get documentScan => 'Document Scan';

  @override
  String get historyDetailTitle => 'History Detail';

  @override
  String get cameraPermissionDenied => 'Camera permission denied.';

  @override
  String get galleryPermissionDenied => 'Gallery permission denied.';
}
