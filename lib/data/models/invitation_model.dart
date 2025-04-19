class InvitationModel {
  final String id;
  final String title;
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String location;
  final String backgroundImage;
  final String template;

  InvitationModel({
    required this.id,
    required this.title,
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    required this.location,
    required this.backgroundImage,
    required this.template,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      title: json['title'],
      groomName: json['groom_name'],
      brideName: json['bride_name'],
      weddingDate: DateTime.parse(json['wedding_date']),
      location: json['location'],
      backgroundImage: json['background_image'],
      template: json['template'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'groom_name': groomName,
      'bride_name': brideName,
      'wedding_date': weddingDate.toIso8601String(),
      'location': location,
      'background_image': backgroundImage,
      'template': template,
    };
  }
}
