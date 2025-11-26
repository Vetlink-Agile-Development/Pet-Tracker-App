import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SaveChangesModal extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const SaveChangesModal({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Guardar Cambios?'),
      content: const Text('¿Quieres guardar los cambios?'),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
            context.pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            onSave();
            context.go('/settings');
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
