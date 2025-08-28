import 'package:flutter/material.dart';

class LanguageDropdownMenu extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final List<String> languages;
  final String label;

  const LanguageDropdownMenu({
    super.key,
    required this.value,
    required this.onChanged,
    this.languages = const [
      'en-US',
      'en-GB',
      'fr-FR',
      'de-DE',
      'es-ES',
      'it-IT',
      'pt-PT',
    ],
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down),
            items:
                languages.map<DropdownMenuItem<String>>((String lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
