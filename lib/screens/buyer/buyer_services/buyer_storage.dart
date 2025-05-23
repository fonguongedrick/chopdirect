import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

 class StorageServices with ChangeNotifier{
  final firebaseStorage = FirebaseStorage.instance;

  List<String> _imageUrl = [];
  bool _isLoading = false;
  bool _isUploading = false;

  List<String> get imageUrl => _imageUrl;
  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;


  Future<void> fetchImages() async {
   _isLoading = true;
   final ListResult result = await firebaseStorage.ref("uploaded_images").listAll();
   final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
   _imageUrl = urls;
   _isLoading = false;
   notifyListeners();
  }

  Future<void> deleteImages(String imageUrl) async {
   try{
    _imageUrl.remove(imageUrl);
    final String path = extractPathFromUrl(imageUrl);
    await firebaseStorage.ref(path).delete();

   }catch(e){
    print("Error deleting image: $e");
   }
   notifyListeners();
  }

  Future<void> uploadImage() async {
   _isUploading = true;
   notifyListeners();
   final ImagePicker picker = ImagePicker();
   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
   if(image == null) return;
   File file = File(image.path);
   try{
    final String path = "uploaded_images/${DateTime.now().millisecondsSinceEpoch}.png";
    final UploadTask uploadTask = firebaseStorage.ref(path).putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    _imageUrl.add(downloadUrl);
    _isUploading = false;
    notifyListeners();
   }catch(e){
    print("Error uploading image: $e");
    _isUploading = false;
    notifyListeners();
   }
  }


  String extractPathFromUrl(String url) {
   Uri uri = Uri.parse(url);
   String encodedPath = uri.pathSegments.last;
   return Uri.decodeComponent(encodedPath);
  }

 }