class MemberModel {
  String? age, name,phone,relation,uid;

  static MemberModel toObject(doc) {
    MemberModel model = MemberModel();

    model.age = doc['age'];
    model.name = doc['name'];
    model.phone = doc['phone'];
    model.relation = doc['relation'];
    model.uid = doc['uid'];

    return model;
  }

  Map<String, Object> getMap() {
    Map<String, Object> map = Map();

    map['age'] = age ?? "";
    map['phone'] = phone ?? "";
    map['name'] = name ?? "";
    map['relation'] = relation ?? "";
    map['uid'] = uid ?? "";
    return map;
  }
}
