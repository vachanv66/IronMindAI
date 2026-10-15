import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'goal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String level = 'Beginner';
  String gender = 'Male';
  String dietaryPreference = 'Vegetarian';

  final nameController = TextEditingController(text: 'Athlete');
  final heightController = TextEditingController(text: '175');
  final weightController = TextEditingController(text: '70');
  final ageController = TextEditingController(text: '25');

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Athlete Biometric Intake')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell your AI coach about you',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'We use your biometrics to calibrate joint angles, weekly exercise volume, and custom Indian nutrition.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: nameController,
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: heightController,
                    label: 'Height (cm)',
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: weightController,
                    label: 'Weight (kg)',
                    prefixIcon: Icons.monitor_weight_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: ageController,
                    label: 'Age (years)',
                    prefixIcon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                        .toList(),
                    onChanged: (v) => setState(() => gender = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: dietaryPreference,
              decoration: const InputDecoration(labelText: 'Indian Diet Preference'),
              items: ['Vegetarian', 'Vegan', 'Non-Vegetarian']
                  .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                  .toList(),
              onChanged: (v) => setState(() => dietaryPreference = v!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: level,
              decoration: const InputDecoration(labelText: 'Fitness Experience'),
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                  .toList(),
              onChanged: (v) => setState(() => level = v!),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Next: Select Goal',
              onPressed: () {
                final heightVal = double.tryParse(heightController.text.trim()) ?? 175.0;
                final weightVal = double.tryParse(weightController.text.trim()) ?? 70.0;
                final ageVal = int.tryParse(ageController.text.trim()) ?? 25;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GoalScreen(
                      level: level,
                      name: nameController.text.trim().isEmpty ? 'Athlete' : nameController.text.trim(),
                      height: heightVal,
                      weight: weightVal,
                      age: ageVal,
                      gender: gender,
                      dietaryPreference: dietaryPreference,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
