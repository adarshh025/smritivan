// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About SMRITIVAN"),
        backgroundColor: const Color(0xFF84A98C),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.psychology, size: 80, color: Color(0xFF52796F)),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "SMRITIVAN",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2F3E46)),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "A Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in the North Eastern Region (NER) of India.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              
              const Text(
                "SIH 2026 Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF52796F)),
              ),
              const SizedBox(height: 10),
              const Text("Problem Statement ID: 26003", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              const Text(
                "Developed By",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF52796F)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Team laccha paratha",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              _buildTeamMember("Adarsh A"),
              _buildTeamMember("Twinkle B"),
              _buildTeamMember("Kashish"),
              _buildTeamMember("Utkarsh"),
              _buildTeamMember("Pratibha"),
              _buildTeamMember("Akash"),
              
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  "© 2026 Team laccha paratha. All rights reserved.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.person, color: Color(0xFF84A98C)),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
