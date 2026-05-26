import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/more/data/models/contact_us_model.dart';
import 'package:hogga/features/user/more/data/repositories/more_repository.dart';

abstract class ContactUsState {}

class ContactUsInitial extends ContactUsState {}

class ContactUsLoading extends ContactUsState {}

class ContactUsSuccess extends ContactUsState {
  final ContactData contactData;
  ContactUsSuccess(this.contactData);
}

class ContactUsError extends ContactUsState {
  final String message;
  ContactUsError(this.message);
}

class ContactUsCubit extends Cubit<ContactUsState> {
  final MoreRepository repository;

  ContactUsCubit(this.repository) : super(ContactUsInitial());

  Future<void> getContactInfo() async {
    emit(ContactUsLoading());
    final result = await repository.getContactInfo();
    result.fold(
      (failure) => emit(ContactUsError(failure.message)),
      (model) {
        if (model.data != null) {
          emit(ContactUsSuccess(model.data!));
        } else {
          emit(ContactUsError('No contact data available'));
        }
      },
    );
  }
}
