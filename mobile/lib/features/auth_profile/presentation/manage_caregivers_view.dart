// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/relationship_model.dart';
import 'user_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class ManageCaregiversView extends ConsumerStatefulWidget {
  const ManageCaregiversView({Key? key}) : super(key: key);

  @override
  ConsumerState<ManageCaregiversView> createState() => _ManageCaregiversViewState();
}

class _ManageCaregiversViewState extends ConsumerState<ManageCaregiversView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showAddCaregiverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Caregiver"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the caregiver's connection code.", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "ABCD-1234",
              ),
              style: const TextStyle(fontSize: 24, letterSpacing: 2),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              // MVP logic: In a real app we'd validate the code against the backend
              // and pull the caregiver's name and prompt for confirmation.
              // Here, we just pop for simulation.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Caregiver connection requested. Pending approval.")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A9D8F), foregroundColor: Colors.white),
            child: const Text("Connect", style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }

  void _revokeAccess(CaregiverRelationshipModel rel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Caregiver?"),
        content: const Text(
          "Are you sure you want to remove this caregiver's access to your activity and history?",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(activeUserProvider.notifier).revokeCaregiverAccess(rel.relId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Caregiver access revoked.")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Remove", style: TextStyle(fontSize: 18)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Access"),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Who Can Access My Information?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF264653)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Connected caregivers can view your game history, activity insights, and well-being check-ins.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                if (state.relationships.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text("No caregivers connected yet.", style: TextStyle(fontSize: 18, color: Colors.black54)),
                    ),
                  )
                else
                  ...state.relationships.map((rel) => _buildCaregiverCard(rel)).toList(),
                const SizedBox(height: 32),
                AppButton.primary(
                  text: "Connect a Caregiver",
                  icon: Icons.add,
                  onPressed: _showAddCaregiverDialog,
                )
              ],
            ),
    );
  }

  Widget _buildCaregiverCard(CaregiverRelationshipModel rel) {
    bool isActive = rel.status == RelationshipStatus.active;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF2A9D8F),
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Caregiver ID: ${rel.caregiverId.substring(0, 8)}...", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Relationship: ${rel.relationshipType}", style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(isActive ? Icons.check_circle : Icons.pending, size: 16, color: isActive ? Colors.green.shade800 : Colors.orange.shade800),
                      const SizedBox(width: 4),
                      Text(
                        isActive ? "Active" : "Pending",
                        style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade800 : Colors.orange.shade800),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text("Access: Activity, Reminders, Game History, Well-being", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _revokeAccess(rel),
                icon: const Icon(Icons.block, color: Colors.red),
                label: const Text("Manage Access", style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
