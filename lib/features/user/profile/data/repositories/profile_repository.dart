import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../shared/auth/data/models/user_model.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../../../../config/shared_preference/shared_preference.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getProfile();
  Future<Either<Failure, UserModel>> updateProfile({
    required String name,
    required String email,
    String? gender,
    String? accountType,
  });
  Future<Either<Failure, String>> updateAvatar(File image);
  Future<Either<Failure, String>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required String name,
    required String email,
    String? gender,
    String? accountType,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        name: name,
        email: email,
        gender: gender,
        accountType: accountType,
      );
      
      // Update local storage
      final prefs = AppPreferences();
      await prefs.saveName(user.name);
      await prefs.saveEmail(user.email);
      if (user.accountType != null) {
        await prefs.saveAccountType(user.accountType!);
      }
      
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar(File image) async {
    try {
      final photoUrl = await remoteDataSource.updateAvatar(image);
      
      // Update local storage
      await AppPreferences().saveImage(photoUrl);
      
      return Right(photoUrl);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final message = await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
