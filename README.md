# imageprox

Image processing app with smart face detection and document scanning.

# Preview

https://github.com/user-attachments/assets/6c6b8201-d434-402c-90ae-c3b91d56065f


**Key features**
- Live camera scan window with adjustable size
- Face flow: grayscale only detected faces
- Document flow: text detection, crop/enhance, PDF generation (text-first with image fallback)
- History backed by Hive

## Build & Run

**Prereqs**
- Flutter SDK (matching repo constraints)
- Android Studio / Xcode for device builds

**Install deps**
```bash
flutter pub get
```

**Run**
```bash
flutter run
```

**Build**
```bash
flutter build apk
flutter build ios
```

**Tests**
```bash
flutter test
```

## Architecture

Clean-architecture leaning split:

- **Domain**
  - Entities: `HistoryEntry`, `ProcessedResult`
  - Use cases: `HistoryUseCase`, `ProcessImageUseCase`
  - Interfaces: `HistoryRepository`, `ImageProcessingService`, `PdfService`, `StorageService`
  - Failures: `Failure`, `ProcessingFailure`, `StorageFailure`, `OcrFailure`

- **Data**
  - Models: `HistoryItem`, `ProcessingResult`, `ContentType`
  - Mappers: `HistoryMapper`, `ProcessingResultMapper`
  - Repositories: `HistoryRepositoryImpl` (Hive)
  - Services (impl): `ImageProcessingServiceImpl`, `PdfServiceImpl`, `StorageServiceImpl`, `ProcessingWorkflowService`, `VisionService`, `ImagePreprocessor`

- **Presentation (GetX)**
  - Controllers: `HomeController`, `ProcessingController`, `CameraScanController`
  - Views: `HomeView`, `ResultFaceView`, `ResultDocumentView`, `CameraScanView`
  - Sheets: `ProcessingSheet`, `DialogSelectSourceSheet`

Navigation is handled in UI (processing sheet), while use cases return domain entities.

## Project Structure

```
lib/
  app/
    bindings/
    core/
    data/
      local/
      mappers/
      models/
      repository/
      services/
    domain/
      entities/
      failures/
      repositories/
      services/
      usecases/
    modules/
      camera_scan/
      home/
      processing/
      result_document/
      result_face/
      dialog_select_source/
    routes/
  l10n/
assets/
  fonts/
test/
  data/
  domain/
```

## Notes

- ML Kit is used for face detection and text recognition.
- PDF text uses embedded Noto Sans (`assets/fonts/NotoSans-Regular.ttf`).
- History stored in Hive box `history_items`.
