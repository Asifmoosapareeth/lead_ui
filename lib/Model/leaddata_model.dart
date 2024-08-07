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
  final String latitude;
  final String longitude;
  final String followUp;
  final String? followup_date;
  final String leadPriority;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String stateName;
  final String districtName;
  final String cityName;
  final String? image_path;

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
    required this.latitude,
    required this.longitude,
    required this.followUp,
    this.followup_date,
    required this.leadPriority,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.stateName,
    required this.districtName,
    required this.cityName,
    this.image_path,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if 'name' is null
      contactNumber: json['contact_number'] ?? 'Unknown', // Default to 'Unknown' if 'contact_number' is null
      isWhatsapp: json['is_whatsapp'] == 1,
      email: json['email'] as String?, // Cast to String? to handle null values
      address: json['address'] ?? '', // Default to empty string if 'address' is null
      state: json['state'] ?? '', // Default to empty string if 'state' is null
      district: json['district'] ?? '', // Default to empty string if 'district' is null
      city: json['city'] ?? '', // Default to empty string if 'city' is null
      locationCoordinates: json['location_coordinates'] ?? '', // Default to empty string if 'location_coordinates' is null
      latitude: json['latitude'] ?? '', // Default to empty string if 'latitude' is null
      longitude: json['longitude'] ?? '', // Default to empty string if 'longitude' is null
      followUp: json['follow_up'] ?? '', // Default to empty string if 'follow_up' is null
      followup_date: json['follow_up_date'] , // Safely parse the date
      leadPriority: json['lead_priority'] ?? '', // Default to empty string if 'lead_priority' is null
      remarks: json['remarks'] as String?, // Cast to String? to handle null values
      createdAt: DateTime.tryParse(json['created_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(), // Parse date or default to now
      updatedAt: DateTime.tryParse(json['updated_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(), // Parse date or default to now
      stateName: json['state_name'] ?? '', // Default to empty string if 'state_name' is null
      districtName: json['district_name'] ?? '', // Default to empty string if 'district_name' is null
      cityName: json['city_name'] ?? '', // Default to empty string if 'city_name' is null
      image_path: json['image_path'] as String?, // Cast to String? to handle null values
    );
  }
}
