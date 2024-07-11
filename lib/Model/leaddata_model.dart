class Lead {
  final String name;
  final String? email;
  final String contactNumber;
  final String? address;
  final String stateId;
  final String stateName;
  final String districtName;
  final String cityName;

  Lead({
    required this.name,
    this.email,
    required this.contactNumber,
    this.address,
    required this.stateId,
    required this.stateName,
    required this.districtName,
    required this.cityName,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json['name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      address: json['address'],
      stateId: json['state'].toString(),
      stateName: json['state_name'],
      districtName: json['district_name'],
      cityName: json['city_name'],
    );
  }
}
