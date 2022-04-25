class Representative {
  final String id;
  final String name;
  String? role;
  String? gender;
  String? party;
  String? twitter_id;
  String? facebook_account;
  String? youtube_id;
  String? next_election;
  String? api_uri;
  String? date_of_birth;
  String? website;
  String? current_party;
  String? most_recent_vote;
  String? twitter_account;
  String? youtube_account;

  Representative(this.id, this.name,
      [this.role,
      this.gender,
      this.party,
      this.twitter_id,
      this.facebook_account,
      this.youtube_id,
      this.next_election,
      this.api_uri,
      this.date_of_birth,
      this.website,
      this.current_party,
        this.most_recent_vote,
        this.twitter_account,
        this.youtube_account
      ]);

  factory Representative.fromJson(Map<String, dynamic> json) {
    Representative val = Representative('id', 'name');
    try {
      val = Representative(
          json['id'],
          json['first_name'] + ' ' + json['last_name'],
          json['role'] ?? '',
          json['gender'] ?? '',
          json['party'] ?? '',
          json['twitter_id'] ?? '',
          json['facebook_account'] ?? '',
          json['youtube_id'] ?? '',
          json['next_election'] ?? '',
          json['api_uri'] ?? '',
          json['date_of_birth'] ?? '',
          json['url'] ?? '',
          json['current_party'] ?? '',
      json['most_recent_vote'] ?? '',
      json['twitter_account'] ?? '',
      json['youtube_account']??'');
    } catch (e) {
      print("rep e");
      print(e);
    }

    return val;
  }
}
