/// Anything the API returns as { id, name, ... } (accounts, categories).
class NamedItem {
  const NamedItem({required this.id, required this.name});

  final String id;
  final String name;

  factory NamedItem.fromJson(Map<String, dynamic> json) =>
      NamedItem(id: json['id'] as String, name: json['name'] as String);
}
