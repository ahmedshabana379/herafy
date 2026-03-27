
class GovernorateModel {
  int? id;
  String? name;
  List<RegionModel>? regions; 

  GovernorateModel({this.id, this.name, this.regions});

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: json['id'],
      name: json['name'],
      regions: json['regions'] != null
          ? (json['regions'] as List).map((i) => RegionModel.fromJson(i)).toList()
          : null,
    );
  }
}


class RegionModel {
  int? id;
  String? name;

  RegionModel({this.id, this.name});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'],
      name: json['name'],
    );
  }
}