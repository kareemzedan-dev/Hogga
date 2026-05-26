
class UserModel {
  final int? id;
  final String email;
  final String name;
  final String phone;
  final String? password;
  final String? type;
  final String? accountType;
  final String? gender;
  final String role;
  final String? token;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final bool? isActive;
  final String? governorate;
  final String? state;
  final String? district;
  final String? street;
  final String? buildingNo;
  final String? apartmentNo;
  final String? details;
  final String? image;
  final List<dynamic>? shops;
  final bool isProvider;
  final String? providerTypeName;
  final List<String> specializations;

  const UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.password,
    this.type,
    this.accountType,
    this.gender,
    required this.role,
    this.token,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.isActive,
    this.governorate,
    this.state,
    this.district,
    this.street,
    this.buildingNo,
    this.apartmentNo,
    this.details,
    this.image,
    this.shops,
    this.isProvider = false,
    this.providerTypeName,
    this.specializations = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'],
      type: json['type'],
      accountType: json['account_type'],
      gender: json['gender'],
      role: json['role'] ?? json['type'] ?? 'user',
      token: json['token'],
      emailVerifiedAt: json['email_verified_at'],
      phoneVerifiedAt: json['phone_verified_at'],
      isActive: json['is_active'] is int ? json['is_active'] == 1 : json['is_active'],
      governorate: json['governorate'],
      state: json['state'],
      district: json['district'],
      street: json['street'],
      buildingNo: json['building_no'],
      apartmentNo: json['apartment_no'],
      details: json['details'],
      image: json['image'] ?? json['photo'],
      shops: json['shops'],
      isProvider: json['is_provider'] is int ? json['is_provider'] == 1 : json['is_provider'] == true,
      providerTypeName: json['provider_type_name'],
      specializations: (json['specializations'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'password': password,
      'type': type,
      'account_type': accountType,
      'gender': gender,
      'role': role,
      'token': token,
      'email_verified_at': emailVerifiedAt,
      'phone_verified_at': phoneVerifiedAt,
      'is_active': isActive,
      'governorate': governorate,
      'state': state,
      'district': district,
      'street': street,
      'building_no': buildingNo,
      'apartment_no': apartmentNo,
      'details': details,
      'image': image,
      'shops': shops,
      'is_provider': isProvider,
      'provider_type_name': providerTypeName,
      'specializations': specializations,
    };
  }
  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? password,
    String? type,
    String? accountType,
    String? gender,
    String? role,
    String? token,
    String? emailVerifiedAt,
    String? phoneVerifiedAt,
    bool? isActive,
    String? governorate,
    String? state,
    String? district,
    String? street,
    String? buildingNo,
    String? apartmentNo,
    String? details,
    String? image,
    List<dynamic>? shops,
    bool? isProvider,
    String? providerTypeName,
    List<String>? specializations,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      type: type ?? this.type,
      accountType: accountType ?? this.accountType,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      token: token ?? this.token,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      isActive: isActive ?? this.isActive,
      governorate: governorate ?? this.governorate,
      state: state ?? this.state,
      district: district ?? this.district,
      street: street ?? this.street,
      buildingNo: buildingNo ?? this.buildingNo,
      apartmentNo: apartmentNo ?? this.apartmentNo,
      details: details ?? this.details,
      image: image ?? this.image,
      shops: shops ?? this.shops,
      isProvider: isProvider ?? this.isProvider,
      providerTypeName: providerTypeName ?? this.providerTypeName,
      specializations: specializations ?? this.specializations,
    );
  }
}






