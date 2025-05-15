import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:application_medicines/auth_controller.dart';
import 'package:application_medicines/medication_controller.dart';
import 'package:application_medicines/medication.dart';
import 'package:application_medicines/notification_service.dart';

class EditMedicationScreen extends StatelessWidget {
  final MedicationController medicationController =
      Get.find<MedicationController>();
  final NotificationService notificationService =
      Get.find<NotificationService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final String medicationId;

  EditMedicationScreen({super.key})
      : medicationId = Get.parameters['id'] ?? '' {
    final medication = medicationController.medications
        .firstWhere((med) => med.id == medicationId);

    nameController.text = medication.name;
    dosageController.text = medication.dosage;
    selectedTime.value = TimeOfDay.fromDateTime(medication.time);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este medicamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cerrar modal
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await medicationController.deleteMedication(medicationId);
              Navigator.of(context).pop(); // Cerrar modal
              Get.back(); // Salir de la pantalla de edición
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Medicamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Medicamento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosis',
                border: OutlineInputBorder(),
              ),
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
                final now = DateTime.now();
                final medicationTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime.value.hour,
                  selectedTime.value.minute,
                );

                final medication = Medication(
                  id: medicationId,
                  name: nameController.text,
                  dosage: dosageController.text,
                  time: medicationTime,
                  userId: (await Get.find<AuthController>().account.get()).$id,
                );

                await medicationController.updateMedication(medication);
                await notificationService.scheduleMedicationNotification(
                  'Es hora de tu medicamento',
                  'Toma ${medication.name} - ${medication.dosage}',
                  medicationTime,
                );

                Get.back();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}