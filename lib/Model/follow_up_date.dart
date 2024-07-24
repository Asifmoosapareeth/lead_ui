class FollowUpDate {
  final int id;
  final String followUpDates;
  final int dateId;
  final String createdAt;
  final String updatedAt;

  FollowUpDate({
    required this.id,
    required this.followUpDates,
    required this.dateId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowUpDate.fromJson(Map<String, dynamic> json) {
    return FollowUpDate(
      id: json['id'],
      followUpDates: json['follow_up_dates'],
      dateId: json['date_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}