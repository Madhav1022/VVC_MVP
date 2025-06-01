import 'package:cloud_firestore/cloud_firestore.dart';

const String tableContact = 'tbl_contact';
const String tblContactColId = 'id';
const String tblContactColFirebaseId = 'firebaseId';
const String tblContactColName = 'name';
const String tblContactColMobile = 'mobile';
const String tblContactColEmail = 'email';
const String tblContactColAddress = 'address';
const String tblContactColCompany = 'company';
const String tblContactColDesignation = 'designation';
const String tblContactColWebsite = 'website';
const String tblContactColImageLocal = 'imageLocal';
const String tblContactColImageUrl = 'imageUrl';
const String tblContactColFavorite = 'favorite';
const String tblContactColCreatedAt = 'createdAt';

class ContactModel {
  int id;
  String? firebaseId;
  String name;
  String mobile;
  String email;
  String address;
  String company;
  String designation;
  String website;
  String imageLocal;
  String imageUrl;
  bool favorite;
  DateTime? createdAt;

  ContactModel({
    this.id = -1,
    this.firebaseId,
    required this.name,
    required this.mobile,
    this.email = '',
    this.address = '',
    this.company = '',
    this.designation = '',
    this.website = '',
    this.imageLocal = '',
    this.imageUrl = '',
    this.favorite = false,
    this.createdAt,
  });

  /// Local SQLite map
  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      tblContactColName: name,
      tblContactColMobile: mobile,
      tblContactColEmail: email,
      tblContactColAddress: address,
      tblContactColCompany: company,
      tblContactColDesignation: designation,
      tblContactColWebsite: website,
      tblContactColImageLocal: imageLocal,
      tblContactColImageUrl: imageUrl,
      tblContactColFavorite: favorite ? 1 : 0,
      // store timestamp as integer millis if present
      if (createdAt != null) tblContactColCreatedAt: createdAt!.millisecondsSinceEpoch,
      if (firebaseId != null) tblContactColFirebaseId: firebaseId,
    };
    if (id > 0) m[tblContactColId] = id;
    return m;
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) => ContactModel(
    id: map[tblContactColId] as int,
    firebaseId: map[tblContactColFirebaseId] as String?,
    name: map[tblContactColName] as String,
    mobile: map[tblContactColMobile] as String,
    email: map[tblContactColEmail] as String,
    address: map[tblContactColAddress] as String,
    company: map[tblContactColCompany] as String,
    designation: map[tblContactColDesignation] as String,
    website: map[tblContactColWebsite] as String,
    imageLocal: map[tblContactColImageLocal] as String,
    imageUrl: map[tblContactColImageUrl] as String,
    favorite: (map[tblContactColFavorite] as int) == 1,
    createdAt: map.containsKey(tblContactColCreatedAt)
        ? DateTime.fromMillisecondsSinceEpoch(map[tblContactColCreatedAt] as int)
        : null,
  );

  /// Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': address,
      'company': company,
      'designation': designation,
      'website': website,
      'favorite': favorite,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Construct from Firestore DocumentSnapshot
  factory ContactModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ContactModel(
      firebaseId: doc.id,
      name: data['name'] as String? ?? '',
      mobile: data['mobile'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      company: data['company'] as String? ?? '',
      designation: data['designation'] as String? ?? '',
      website: data['website'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      imageLocal: '', // local filename not stored in Firestore
      favorite: data['favorite'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  String toString() {
    return 'ContactModel{id: $id, firebaseId: $firebaseId, name: $name, mobile: $mobile, email: $email, address: $address, company: $company, designation: $designation, website: $website, imageLocal: $imageLocal, imageUrl: $imageUrl, favorite: $favorite, createdAt: $createdAt}';
  }
}
