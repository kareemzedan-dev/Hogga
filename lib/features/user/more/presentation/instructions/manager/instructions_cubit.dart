import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/more/data/models/instructions_model.dart';
import 'package:hogga/features/user/more/data/repositories/more_repository.dart';

abstract class InstructionsState {}

class InstructionsInitial extends InstructionsState {}

class InstructionsLoading extends InstructionsState {}

class InstructionsSuccess extends InstructionsState {
  final List<InstructionData> instructions;
  InstructionsSuccess(this.instructions);
}

class InstructionsError extends InstructionsState {
  final String message;
  InstructionsError(this.message);
}

class InstructionsCubit extends Cubit<InstructionsState> {
  final MoreRepository repository;

  InstructionsCubit(this.repository) : super(InstructionsInitial());

  Future<void> getInstructions() async {
    emit(InstructionsLoading());
    final result = await repository.getInstructions();
    result.fold(
      (failure) => emit(InstructionsError(failure.message)),
      (model) => emit(InstructionsSuccess(model.data)),
    );
  }
}
