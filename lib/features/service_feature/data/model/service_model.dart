class ServiceModel {
  final String title;
  final String subTitle;
  final String borderColor;
  final String accentColor;
  final String icon;
  final String route;

  ServiceModel({
    required this.title,
    required this.subTitle,
    required this.borderColor,
    required this.accentColor,
    required this.icon,
    required this.route,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      title: json['title'],
      subTitle: json['subTitle'],
      borderColor: json['borderColor'],
      accentColor: json['accentColor'],
      icon: json['icon'],
      route: json['route'],
    );
  }
}
