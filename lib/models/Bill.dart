class Bill{
  final String bill_id;
  final String bill_slug;
  final String title;
  final String short_title;
  String? sponsor_id;
  String? sponsor_name;
  String? sponsor_state;
  String? sponsor_party;
  String? sponsor_uri;
  String? introduced_date;
  String? committees;
  String? latest_major_action;

  Bill(
      this.bill_id,
      this.bill_slug,
      this.title,
      this.short_title,
      [
        this.sponsor_id,
        this.sponsor_name,
        this.sponsor_state,
        this.sponsor_party,
        this.sponsor_uri,
        this.introduced_date,
        this.committees,
        this.latest_major_action
      ]
  );

  factory Bill.fromJson(Map<String, dynamic> json) {
    Bill val = Bill(json['bill_id'],json['bill_slug'],json['title'],json['short_title']);
    try{
      val = Bill(
          json['bill_id'],
          json['bill_slug'],
          json['title'],
          json['short_title'],
          json['sponsor_id'] ?? '',
          json['sponsor_name'] ?? '',
          json['sponsor_state'] ?? '',
          json['sponsor_party'] ?? '',
          json['sponsor_uri'] ?? '',
          json['introduced_date'] ?? '',
          json['committees'] ?? '',
          json['latest_major_action'] ?? ''
      );
    }catch(e){
      print("e");
      print(e);
    }
    return val;

  }

}