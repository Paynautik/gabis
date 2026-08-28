class AppContact {
  final String id;
  final String name;
  final String phone;
  final bool hasElumo;
  final String? avatarUrl;

  const AppContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.hasElumo,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
