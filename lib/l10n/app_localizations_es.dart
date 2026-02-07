// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ImageProx';

  @override
  String get homeTitle => 'ImageProx';

  @override
  String get homeEmpty =>
      'Aún no hay historial. Captura una imagen para comenzar.';

  @override
  String get captureTitle => 'Capturar imagen';

  @override
  String get captureSourceLabel => 'Selecciona una fuente de imagen';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get processingTitle => 'Procesando';

  @override
  String get processingDetecting => 'Detectando contenido...';

  @override
  String get processingFace => 'Procesando rostro...';

  @override
  String get processingDocument => 'Procesando documento...';

  @override
  String get processingPreparing => 'Preparando resultado...';

  @override
  String get noImageSelected =>
      'No se seleccionó ninguna imagen para procesar.';

  @override
  String get processingTimeout =>
      'La detección excedió el tiempo. Inténtalo de nuevo.';

  @override
  String get processingFailed => 'El procesamiento falló.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get resultTitle => 'Resultado';

  @override
  String get beforeAfter => 'Antes / Después';

  @override
  String get original => 'Original';

  @override
  String get processed => 'Procesado';

  @override
  String get done => 'Listo';

  @override
  String get pdfCreatedTitle => 'PDF creado';

  @override
  String get documentTitle => 'Título del documento';

  @override
  String get openPdf => 'Abrir PDF';

  @override
  String get pdfUnavailable => 'El PDF aún no está disponible.';

  @override
  String get faceProcessed => 'Rostro procesado';

  @override
  String get documentScan => 'Escaneo de documento';

  @override
  String get historyDetailTitle => 'Detalle del historial';

  @override
  String get cameraPermissionDenied => 'Permiso de cámara denegado.';

  @override
  String get galleryPermissionDenied => 'Permiso de galería denegado.';
}
