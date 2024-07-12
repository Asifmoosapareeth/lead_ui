class Lead {
  final int id;
  final String name;
  final String contactNumber;
  final bool isWhatsapp;
  final String? email;
  final String address;
  final String state;
  final String district;
  final String city;
  final String locationCoordinates;
  final String followUp;
  final String leadPriority;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String stateName;
  final String districtName;
  final String cityName;


  Lead({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.isWhatsapp,
    this.email,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.locationCoordinates,
    required this.followUp,
    required this.leadPriority,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.stateName,
    required this.districtName,
    required this.cityName,

  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      isWhatsapp: json['is_whatsapp'] == 1,
      email: json['email'],
      address: json['address'],
      state: json['state'],
      district: json['district'],
      city: json['city'],
      locationCoordinates: json['location_coordinates'],
      followUp: json['follow_up'],
      leadPriority: json['lead_priority'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      stateName: json['state_name'],
      districtName: json['district_name'],
      cityName: json['city_name'],

    );
  }
}