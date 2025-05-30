class ContactModel {
    String? id;
    String?  name;
    String?  contact;
    String?  location;
    String?  enquireFor;
    String?  date;
    String?  remark;
    String?  priority;
    String?  status;

    ContactModel({
        this.id,
        this.name,
        this.contact,
        this.location,
        this.enquireFor,
        this.date,
        this.remark,
        this.priority,
        this.status,
    });

    factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        id: json["id"]  ??"",
        name: json["name"]  ??"",
        contact: json["contact"]  ??"",
        location: json["location"]  ??"",
        enquireFor: json["enquire_for"]  ??"",
        date: json["date"]  ??"",
        remark: json["remark"]  ??"",
        priority: json["priority"]  ??"",
        status: json["status"]  ??"",
    );
}