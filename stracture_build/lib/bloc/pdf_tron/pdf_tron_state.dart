part of 'pdf_tron_cubit.dart';

abstract class PdfTronState extends Equatable {}

class PaginationListInitial extends PdfTronState {
  @override
  List<Object?> get props => [];
}



class FilteredListState extends PdfTronState {
  FilteredListState();

  @override
  List<Object?> get props => [];
}

class EmptyFilteredListState extends PdfTronState {
  EmptyFilteredListState();

  @override
  List<Object?> get props => [];
}


class MenuOptionLoadedState extends PdfTronState {
  final bool isEditMenuVisible;
  final bool isMarkupMenuVisible;
  final bool isRulerMenuVisible;
  final bool isCuttingPlaneMenuVisible;
  final bool isShowPdfView;
  final bool isShowPdfViewFullScreen;
  final String pdfFileName;

  MenuOptionLoadedState(
      this.isEditMenuVisible,
      this.isMarkupMenuVisible,
      this.isRulerMenuVisible,
      this.isCuttingPlaneMenuVisible,
      this.isShowPdfView,
      this.isShowPdfViewFullScreen,
      this.pdfFileName);

  @override
  List<Object?> get props => [
        isEditMenuVisible,
        isMarkupMenuVisible,
        isRulerMenuVisible,
        isCuttingPlaneMenuVisible,
        isShowPdfView,
        isShowPdfViewFullScreen,
        pdfFileName
      ];
}

class FullPdfTronVIew extends PdfTronState {
  final bool isShowPdfViewFullScreen;

  FullPdfTronVIew(this.isShowPdfViewFullScreen);

  @override
  List<Object?> get props => [isShowPdfViewFullScreen];
}

class ErrorState extends PdfTronState {
  final AppException exception;
  ErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class PDFDownloading extends PdfTronState {
  PDFDownloading();

  @override
  List<Object?> get props => [];
}

class PDFDownloaded extends PdfTronState {
  PDFDownloaded();

  @override
  List<Object?> get props => [];
}
