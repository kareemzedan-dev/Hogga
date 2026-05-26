import 'package:hogga/core/utils/app_strings.dart';

class LawyerModel {
  final String id;
  final String name;
  final String city;
  final String region;
  final double rating;
  final bool isVerified;
  final bool isAvailableNow;
  final String bio;
  final String experienceRange; // e.g. "3-5"
  final int requestCount;
  final String? avatarUrl;
  final bool isMale;

  const LawyerModel({
    required this.id,
    required this.name,
    required this.city,
    required this.region,
    required this.rating,
    this.isVerified = true,
    this.isAvailableNow = false,
    required this.bio,
    required this.experienceRange,
    required this.requestCount,
    this.avatarUrl,
    this.isMale = true,
  });
}

const List<String> omanCities = [
  AppStrings.muscat,
  AppStrings.salalah,
  AppStrings.sohar,
  AppStrings.nizwa,
  AppStrings.sur,
  AppStrings.rustaq,
  AppStrings.buraimi,
  AppStrings.ibra,
  AppStrings.haima,
  AppStrings.khasab,
  AppStrings.seeb,
  AppStrings.bawshar,
  AppStrings.mutrah,
  AppStrings.amerat,
  AppStrings.barka,
  AppStrings.ibri,
  AppStrings.musannah,
  AppStrings.bahla,
  AppStrings.suwaiq,
];
