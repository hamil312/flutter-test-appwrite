import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:application_medicines/auth_controller.dart';
import 'package:application_medicines/medication.dart';
import 'package:application_medicines/medication_controller.dart';
import 'package:application_medicines/notification_service.dart';

class AddMedicationScreen extends StatelessWidget {
  final MedicationController medicationController =
      Get.find<MedicationController>();
  final NotificationService notificationService =
      Get.find<NotificationService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  final _formKey = GlobalKey<FormState>();

  AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Medicamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Medicamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dosageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Solo se permiten números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () => ListTile(
                  title: const Text('Hora de la Medicación'),
                  subtitle: Text(
                    '${selectedTime.value.hour}:${selectedTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime.value,
                    );
                    if (time != null) {
                      selectedTime.value = time;
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final now = DateTime.now();
                    final medicationTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime.value.hour,
                      selectedTime.value.minute,
                    );
                    print(medicationTime);

                    final userId =
                        (await Get.find<AuthController>().account.get()).$id;

                    final medication = Medication(
                      id: '',
                      name: nameController.text,
                      dosage: dosageController.text,
                      time: medicationTime,
                      userId: userId,
                    );

                    await medicationController.addMedication(medication);
                    await notificationService.scheduleMedicationNotification(
                      'Es hora de tu medicamento',
                      'Toma ${medication.name} - ${medication.dosage}',
                      medicationTime,
                    );

                    Get.back();
                  }
                },
                child: const Text('Guardar Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}