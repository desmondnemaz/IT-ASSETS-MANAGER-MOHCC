class Province {
  final int id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(id: json['id'], name: json['province_name']);
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['id'], name: json['district_name']);
  }
}

class Station {
  final int id;
  final String name;
  final String type;

  Station({required this.id, required this.name, required this.type});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['station_name'],
      type: json['station_type'],
    );
  }
}
