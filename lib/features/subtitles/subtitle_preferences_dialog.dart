// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class SubtitlePreferencesDialog extends StatefulWidget {
  const SubtitlePreferencesDialog({required this.initialValues, super.key});

  final Map<String, String> initialValues;

  @override
  State<SubtitlePreferencesDialog> createState() =>
      _SubtitlePreferencesDialogState();
}

class _SubtitlePreferencesDialogState extends State<SubtitlePreferencesDialog> {
  late final Map<String, String> _values;

  @override
  void initState() {
    super.initState();
    _values = Map<String, String>.of(widget.initialValues);
  }

  void _setValue(String key, String value) {
    setState(() => _values[key] = value);
  }

  Widget _textField(String key, String label, {String? hint}) {
    return TextFormField(
      key: ValueKey(key),
      initialValue: _values[key] ?? '',
      decoration: InputDecoration(labelText: label, hintText: hint),
      onChanged: (value) => _values[key] = value,
    );
  }

  Widget _slider(
    String key,
    String label, {
    required double min,
    required double max,
    required int divisions,
    int decimalPlaces = 0,
  }) {
    final value = double.tryParse(_values[key] ?? '') ?? min;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(decimalPlaces)}'),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max),
          onChanged: (next) =>
              _setValue(key, next.toStringAsFixed(decimalPlaces)),
        ),
      ],
    );
  }

  Widget _switch(String key, String label) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: _values[key] == 'yes',
      onChanged: (value) => _setValue(key, value ? 'yes' : 'no'),
    );
  }

  Widget _dropdown(String key, String label, List<String> options) {
    return DropdownButtonFormField<String>(
      initialValue: _values[key],
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (value) {
        if (value != null) {
          _setValue(key, value);
        }
      },
    );
  }

  Widget _primaryPreferences() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _textField('sub-font', 'Carattere'),
        _slider(
          'sub-font-size',
          'Dimensione carattere',
          min: 12,
          max: 100,
          divisions: 88,
        ),
        _slider(
          'sub-pos',
          'Posizione verticale (100 = basso)',
          min: 0,
          max: 150,
          divisions: 150,
        ),
        _dropdown('sub-align-x', 'Allineamento orizzontale', [
          'left',
          'center',
          'right',
        ]),
        _dropdown('sub-align-y', 'Allineamento verticale', [
          'top',
          'center',
          'bottom',
        ]),
        _slider(
          'sub-scale',
          'Scala',
          min: 0.5,
          max: 2,
          divisions: 30,
          decimalPlaces: 2,
        ),
        _textField('sub-color', 'Colore testo', hint: '#RRGGBB o #AARRGGBB'),
        _textField(
          'sub-outline-color',
          'Colore bordo',
          hint: '#RRGGBB o #AARRGGBB',
        ),
        _slider(
          'sub-outline-size',
          'Spessore bordo',
          min: 0,
          max: 10,
          divisions: 40,
          decimalPlaces: 2,
        ),
        _dropdown('sub-border-style', 'Stile bordo', [
          'outline-and-shadow',
          'opaque-box',
          'background-box',
        ]),
        _textField(
          'sub-back-color',
          'Colore ombra/sfondo',
          hint: '#RRGGBB o #AARRGGBB',
        ),
        _slider(
          'sub-shadow-offset',
          'Offset ombra',
          min: 0,
          max: 20,
          divisions: 40,
          decimalPlaces: 1,
        ),
        _slider(
          'sub-margin-x',
          'Margine orizzontale',
          min: 0,
          max: 100,
          divisions: 100,
        ),
        _slider(
          'sub-margin-y',
          'Margine verticale',
          min: 0,
          max: 100,
          divisions: 100,
        ),
        _slider(
          'sub-spacing',
          'Spaziatura lettere',
          min: -5,
          max: 20,
          divisions: 50,
          decimalPlaces: 1,
        ),
        _slider(
          'sub-blur',
          'Sfocatura',
          min: 0,
          max: 20,
          divisions: 50,
          decimalPlaces: 1,
        ),
        _slider(
          'sub-line-spacing',
          'Spaziatura righe ASS/SSA',
          min: -10,
          max: 20,
          divisions: 60,
          decimalPlaces: 1,
        ),
        _dropdown('sub-hinting', 'Hinting carattere', [
          'none',
          'light',
          'normal',
          'native',
        ]),
        _dropdown('sub-ass-override', 'Override stile ASS/SSA', [
          'no',
          'yes',
          'scale',
          'force',
          'strip',
        ]),
        _textField('sub-codepage', 'Codifica sottotitoli'),
        _textField('sub-delay', 'Ritardo (secondi)'),
        _switch('sub-bold', 'Grassetto'),
        _switch('sub-italic', 'Corsivo'),
        _switch('sub-use-margins', 'Usa i margini video'),
        _switch('sub-ass-force-margins', 'Forza i margini per ASS/SSA'),
        _switch('sub-visibility', 'Mostra sottotitoli primari'),
      ],
    );
  }

  Widget _secondaryPreferences() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'mpv non offre font, colori e bordi indipendenti per la seconda '
            'traccia: questi seguono lo stile condiviso. Posizione, scala, '
            'ritardo e visibilita sono regolabili separatamente.',
          ),
        ),
        _slider(
          'secondary-sub-pos',
          'Posizione verticale (0 = alto)',
          min: 0,
          max: 150,
          divisions: 150,
        ),
        _slider(
          'secondary-sub-scale',
          'Scala',
          min: 0.5,
          max: 2,
          divisions: 30,
          decimalPlaces: 2,
        ),
        _textField('secondary-sub-delay', 'Ritardo (secondi)'),
        _dropdown('secondary-sub-ass-override', 'Override stile ASS/SSA', [
          'no',
          'yes',
          'scale',
          'force',
          'strip',
        ]),
        _switch('secondary-sub-visibility', 'Mostra seconda traccia'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preferenze sottotitoli'),
      content: SizedBox(
        width: 560,
        height: 560,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Primario'),
                  Tab(text: 'Secondario'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [_primaryPreferences(), _secondaryPreferences()],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _values),
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
