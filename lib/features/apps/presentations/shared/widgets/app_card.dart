import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap, onClose, onRemove;
  final double? width, height;
  final bool isSelected;
  const AppCard(
    this.label, {
    this.width,
    this.height = 60,
    this.onTap,
    this.onClose,
    this.onRemove,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.teal : null,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  label,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete),
                  ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
