// notification_setup_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controller/notification_controller.dart';
import '../../../../models/warranty_model.dart';
import '../../warranty/add-warranty/steps/success_warranty_page.dart';

class NotificationSetupPage extends StatefulWidget {
  final WarrantyModel warranty;

  const NotificationSetupPage({Key? key, required this.warranty}) : super(key: key);

  @override
  State<NotificationSetupPage> createState() => _NotificationSetupPageState();
}

class _NotificationSetupPageState extends State<NotificationSetupPage> {
  final NotificationController _controller = Get.put(NotificationController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _reminderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.resetState();
    });
  }

  @override
  void dispose() {
    _reminderNameController.dispose();
    super.dispose();
  }

  void _saveNotification() async {
    _controller.isLoading.value = true;
    _controller.errorMessage.value = '';

    try {
      if (!_controller.isDefaultNotificationEnabled.value) {
        if (!_formKey.currentState!.validate() || _controller.selectedDateTime.value == null) {
          Get.snackbar(
            'Erreur',
            'Veuillez remplir tous les champs du rappel personnalisé.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          _controller.isLoading.value = false;
          return;
        }
      }
      
      // Appellez la méthode du contrôleur pour tout gérer.
      if (_controller.isDefaultNotificationEnabled.value) {
        await _controller.saveNotification(
          warranty: widget.warranty,
          reminderName: null,
        );
      } else {
        await _controller.saveNotification(
          warranty: widget.warranty,
          reminderName: _reminderNameController.text,
        );
      }
      
      // La navigation se fait à l'intérieur du contrôleur en cas de succès.
    } catch (e) {
      _controller.errorMessage.value = 'Erreur lors de la sauvegarde: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        _controller.errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF333333)),
          onPressed: () {
            Get.off(() => SuccessWarrantyPage(newWarranty: widget.warranty));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurer les Notifications',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choisissez entre la configuration par défaut établie par nos experts du domaine ou personnalisez vos propres préférences.',
                style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notification par Défaut',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 52, 51, 51)),
                  ),
                  Obx(() => Switch(
                        value: _controller.isDefaultNotificationEnabled.value,
                        onChanged: _controller.toggleDefaultNotification,
                        activeColor: const Color.fromARGB(255, 15, 188, 61),
                      )),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (_controller.isDefaultNotificationEnabled.value) {
                  return DefaultNotificationSection(warranty: widget.warranty);
                } else {
                  return CustomNotificationSection(
                    controller: _controller,
                    reminderNameController: _reminderNameController,
                    showNotificationTypePicker: _showNotificationTypePicker,
                    showDateTimePicker: _showDateTimePicker,
                  );
                }
              }),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _saveNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: _controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Confirmer',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type de notification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 16),
              ..._controller.notificationTypes.map((type) => Obx(() => ListTile(
                    title: Text(type, style: const TextStyle(color: Color(0xFF333333))),
                    trailing: _controller.notificationType.value == type
                        ? const Icon(Icons.check, color: Color(0xFFE91E63))
                        : null,
                    onTap: () {
                      _controller.notificationType.value = type;
                      Get.back();
                    },
                  ))).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDateTime.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE91E63),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_controller.selectedDateTime.value ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFE91E63),
                onPrimary: Colors.white,
                onSurface: Color(0xFF333333),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE91E63),
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        _controller.selectedDateTime.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }
}

class DefaultNotificationSection extends StatelessWidget {
  final WarrantyModel warranty;

  const DefaultNotificationSection({Key? key, required this.warranty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final endDate = warranty.endDate;

    if (endDate == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Erreur: Date de fin de garantie manquante.",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final oneMonthBefore = endDate.subtract(const Duration(days: 30));
    final twoWeeksBefore = endDate.subtract(const Duration(days: 14));

    final List<Widget> reminderCards = [];

    if (oneMonthBefore.isAfter(today) || (oneMonthBefore.year == today.year && oneMonthBefore.month == today.month && oneMonthBefore.day == today.day)) {
      reminderCards.add(_buildDefaultReminderCard(
        'Rappel de Préexpiration 1',
        DateFormat('dd-MM-yyyy').format(oneMonthBefore),
        '(Un mois avant la fin de la garantie)',
      ));
    }

    if (twoWeeksBefore.isAfter(today) || (twoWeeksBefore.year == today.year && twoWeeksBefore.month == today.month && twoWeeksBefore.day == today.day)) {
      if (reminderCards.isNotEmpty) {
        reminderCards.add(const SizedBox(height: 16));
      }
      reminderCards.add(_buildDefaultReminderCard(
        'Rappel de Préexpiration 2',
        DateFormat('dd-MM-yyyy').format(twoWeeksBefore),
        '(Deux semaines avant la fin de la garantie)',
      ));
    }

    if (reminderCards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "La garantie est déjà expirée ou expire dans moins de deux semaines. Les notifications par défaut ne peuvent pas être configurées.",
          style: TextStyle(color: Color(0xFFE91E63), fontSize: 16),
        ),
      );
    }

    return Column(
      children: reminderCards,
    );
  }

  Widget _buildDefaultReminderCard(String title, String date, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333))),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 14, color: Color(0xFFE91E63))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
        ],
      ),
    );
  }
}

class CustomNotificationSection extends StatelessWidget {
  final NotificationController controller;
  final TextEditingController reminderNameController;
  final Function(BuildContext) showNotificationTypePicker;
  final Function(BuildContext) showDateTimePicker;

  const CustomNotificationSection({
    Key? key,
    required this.controller,
    required this.reminderNameController,
    required this.showNotificationTypePicker,
    required this.showDateTimePicker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nom du rappel', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 8),
        TextFormField(
          controller: reminderNameController,
          decoration: InputDecoration(
            hintText: 'Nommer ce rappel (ex: un mois avant)',
            hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez nommer ce rappel';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        const Text('Type de notification', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Obx(() => _buildDropdownField(
              value: controller.notificationType.value,
              onTap: () => showNotificationTypePicker(context),
            )),
        const SizedBox(height: 24),
        const Text('Date/Heure du rappel', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 8),
        Obx(() => _buildDropdownField(
              value: controller.selectedDateTime.value == null
                  ? 'Sélectionner'
                  : DateFormat('dd-MM-yyyy à HH:mm').format(controller.selectedDateTime.value!),
              onTap: () => showDateTimePicker(context),
            )),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                color: value == 'Sélectionner' ? const Color(0xFFBBBBBB) : const Color(0xFF333333),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}