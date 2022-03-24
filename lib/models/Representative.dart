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

   Representative(
    this.id,
    this.name,
    [this.role,
    this.gender,
    this.party,
    this.twitter_id,
    this.facebook_account,
    this.youtube_id,
     this.next_election,
     this.api_uri]
  );

  factory Representative.fromJson(Map<String, dynamic> json) {
    print(json);
    Representative val = Representative('id','name');
    try{
      val = Representative(
          json['id'],
          json['name'],
          json['role'] ?? '',
         json['gender'] ?? '',
          json['party'] ?? '',
          json['twitter_id'] ?? '',
          json['facebook_account'] ?? '',
          json['youtube_id'] ?? '',
          json['next_election'] ?? '',
          json['api_uri'] ?? ''
      );
    }catch(e){
      print(e);
    }

    print(val);
    return val;
  }
}