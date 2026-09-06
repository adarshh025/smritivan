// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';
import 'user_provider.dart';
import '../../home/application/elder_home_provider.dart';
import '../../caregiver/application/caregiver_dashboard_provider.dart';
import '../../../shared/widgets/app_button.dart';

class EditPatientProfileView extends ConsumerStatefulWidget {
  const EditPatientProfileView({Key? key}) : super(key: key);

  @override
  ConsumerState<EditPatientProfileView> createState() => _EditPatientProfileViewState();
}

class _EditPatientProfileViewState extends ConsumerState<EditPatientProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  String _preferredTime = 'Morning';
  String _selectedState = 'Assam';

  @override
  void initState() {
    super.initState();
    final user = ref.read(activeUserProvider).value;
    _nameController = TextEditingController(text: user?.name ?? 'Bhaben Bora');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '68');
    _phoneController = TextEditingController(text: user?.phone ?? '+91 98765 43210');
    _preferredTime = user?.preferredActivityTime ?? 'Morning';
    _selectedState = user?.state ?? 'Assam';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = ref.read(activeUserProvider).value;
        final targetUser = user ?? const UserModel(
          id: 'patient_ner_001',
          name: 'Bhaben Bora (ভবেন বৰা)',
          nativeLanguage: 'as',
          state: 'Assam',
          dementiaStage: 'Early-Stage (Mild Cognitive Impairment)',
          soundEffectsEnabled: true,
          voiceGuidanceEnabled: true,
          hapticFeedbackEnabled: true,
          notificationsEnabled: true,
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          hlcTimestamp: '',
        );
        final updated = targetUser.copyWith(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          phone: _phoneController.text.trim(),
          state: _selectedState,
          preferredActivityTime: _preferredTime,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await ref.read(activeUserProvider.notifier).updateUser(updated);
        ref.read(elderHomeProvider.notifier).loadData();
        ref.read(caregiverDashboardProvider.notifier).loadData();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profile saved successfully!'),
              backgroundColor: Color(0xFF2A9D8F),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save profile: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Basic Information",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                style: const TextStyle(fontSize: 20),
                validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: const InputDecoration(
                  labelText: "North Eastern State",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                items: [
                  'Assam',
                  'Arunachal Pradesh',
                  'Manipur',
                  'Meghalaya',
                  'Mizoram',
                  'Nagaland',
                  'Sikkim',
                  'Tripura',
                ].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedState = val);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "Preferences",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _preferredTime,
                decoration: const InputDecoration(
                  labelText: "Preferred Activity Time",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                style: const TextStyle(fontSize: 20, color: Colors.black87),
                items: ['Morning', 'Afternoon', 'Evening'].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _preferredTime = val);
                },
              ),
              const SizedBox(height: 48),
              AppButton.primary(
                text: "Save Profile",
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
