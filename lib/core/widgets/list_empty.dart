import 'package:material_ui/material_ui.dart';

/// Centered empty-state illustration with a short message.
class ListEmpty extends StatelessWidget {
  /// Creates an empty list placeholder.
  const ListEmpty({super.key, required this.img, required this.text});

  /// Asset path for the illustration.
  final String img;

  /// Already-translated message shown under the image.
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [_buildImage(img), _buildText(context, text)],
    ),
  );

  Widget _buildImage(String img) => Image.asset(img, scale: 5);

  Widget _buildText(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
