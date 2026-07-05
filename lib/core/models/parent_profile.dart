class ParentProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String nationalId;
  final String? avatarUrl;

  ParentProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.nationalId,
    this.avatarUrl,
  });
}
