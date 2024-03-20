import 'package:athena/features/apps/presentations/shared/widgets/section_title.dart';
import 'package:flutter/widgets.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        Wrap(
          runSpacing: 10,
          spacing: 10,
          children: children,
        ),
      ],
    );
  }
}
