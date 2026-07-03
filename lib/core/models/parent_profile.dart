class ParentProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String? avatarUrl;

  ParentProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.avatarUrl,
  });
}
