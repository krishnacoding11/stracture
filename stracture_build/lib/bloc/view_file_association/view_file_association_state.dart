part of 'view_file_association_cubit.dart';

abstract class FileAssociationState extends Equatable {}

class PaginationListInitial extends FileAssociationState {
  @override
  List<Object?> get props => [];
}

class ViewFullScreenFileAssociation extends FileAssociationState {
  final bool isShow;
  ViewFullScreenFileAssociation(this.isShow);
  @override
  List<Object?> get props => [isShow];
}
