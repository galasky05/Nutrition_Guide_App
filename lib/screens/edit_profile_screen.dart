import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _gender; 
  String? _activityLevel;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;

      _nameController.text = data['name'];
      _ageController.text = data['age'].toString();
      _heightController.text = data['height'].toString();
      _weightController.text = data['weight'].toString();
      _gender = data['gender']; 
      _activityLevel = data['activityLevel'];
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text.trim(),
      'age': int.parse(_ageController.text),
      'height': int.parse(_heightController.text),
      'weight': int.parse(_weightController.text),
      'gender': _gender,
      'activityLevel': _activityLevel,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // NAMA
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // UMUR
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Umur",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Umur tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // GENDER
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: "Jenis Kelamin"),
                items: const [
                  DropdownMenuItem(value: "L", child: Text("Laki-laki")),
                  DropdownMenuItem(value: "P", child: Text("Perempuan")),
                ],
                onChanged: (val) => setState(() => _gender = val),
                validator: (v) =>
                    v == null ? "Pilih jenis kelamin" : null,
              ),
              const SizedBox(height: 16),

              // TINGGI
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Tinggi Badan (cm)",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Tinggi tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // BERAT
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Berat Badan (kg)",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Berat tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // ACTIVITY LEVEL
              DropdownButtonFormField<String>(
                value: _activityLevel,
                decoration: const InputDecoration(
                    labelText: "Activity Level"),
                items: const [
                  DropdownMenuItem(value: "Sedentary", child: Text("Tidak Aktif")),
                  DropdownMenuItem(value: "Light", child: Text("Ringan")),
                  DropdownMenuItem(value: "Moderate", child: Text("Sedang")),
                  DropdownMenuItem(value: "Active", child: Text("Tinggi")),
                  DropdownMenuItem(value: "Very Active", child: Text("Sangat Aktif")),
                ],
                onChanged: (val) => setState(() => _activityLevel = val),
                validator: (v) =>
                    v == null ? "Pilih activity level" : null,
              ),
              const SizedBox(height: 24),

              // BUTTON SAVE
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
