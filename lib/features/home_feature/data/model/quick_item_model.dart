class QuickItem {
  final String id;
  final String label;
  final String icon;
  final String route;
  final int bgColor;
  final int borderColor;

  QuickItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    required this.bgColor,
    required this.borderColor,
  });

  factory QuickItem.fromJson(Map<String, dynamic> json, String id) {
    return QuickItem(
      id: id,
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      route: json['route'] ?? '',
      bgColor: int.parse(json['bgcolor']),
      borderColor: int.parse(json['bordercolor']),
    );
  }
}
