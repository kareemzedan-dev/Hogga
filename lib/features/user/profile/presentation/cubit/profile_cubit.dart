import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../config/shared_preference/shared_preference.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import 'package:hogga/core/utils/image_helper.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final AuthCubit authCubit;
  final ImagePicker _picker = ImagePicker();

  ProfileCubit({required this.repository, required this.authCubit}) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await repository.getProfile();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> updatePersonalData({
    required String name,
    required String email,
    String? gender,
    String? accountType,
  }) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(ProfileUpdating(user: currentState.user));

    final result = await repository.updateProfile(
      name: name,
      email: email,
      gender: gender,
      accountType: accountType,
    );

    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
        emit(currentState);
      },
      (updatedUser) {
        authCubit.updateUser(updatedUser);
        emit(ProfileUpdateSuccess(user: updatedUser));
        emit(ProfileLoaded(user: updatedUser));
      },
    );
  }

  Future<void> updateAvatar() async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    emit(ProfileAvatarUpdating(user: currentState.user));

    final compressedFile = await ImageHelper.compressImage(File(image.path));
    final result = await repository.updateAvatar(compressedFile);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
        emit(currentState);
      },
      (photoUrl) async {
        // Evict old cached image so the new one loads immediately everywhere
        try {
          final oldUrl = currentState.user.image;
          if (oldUrl != null && oldUrl.isNotEmpty) {
            await CachedNetworkImage.evictFromCache(oldUrl);
          }
          // Also evict the new URL in case it was cached before
          await CachedNetworkImage.evictFromCache(photoUrl);
        } catch (_) {}

        final updatedUser = currentState.user.copyWith(image: photoUrl);
        authCubit.updateUser(updatedUser); // This triggers Header & MoreScreen rebuild
        emit(ProfileAvatarUpdateSuccess(user: updatedUser));
        emit(ProfileLoaded(user: updatedUser));
      },
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      emit(const ProfileError(AppStrings.pleaseCompleteAllFields));
      emit(currentState);
      return;
    }

    if (newPassword != confirmPassword) {
      emit(const ProfileError(AppStrings.passwordMismatch));
      emit(currentState);
      return;
    }

    emit(ProfilePasswordUpdating(user: currentState.user));

    final result = await repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
        emit(currentState);
      },
      (message) {
        emit(ProfilePasswordUpdateSuccess(message: message));
        emit(currentState);
      },
    );
  }
}
