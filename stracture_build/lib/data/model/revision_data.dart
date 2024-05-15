class RevisionId {
  int revisionId;
  String status;

  RevisionId({
    required this.revisionId,
    required this.status,
  });

  factory RevisionId.fromJson(Map<String, dynamic> json) => RevisionId(
        revisionId: json["revisionId"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "revisionId": revisionId,
        "status": status,
      };
}
