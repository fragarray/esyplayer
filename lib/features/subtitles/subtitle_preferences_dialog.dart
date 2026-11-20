// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../core/settings/settings.dart';

/// Dialog per le preferenze dei sottotitoli.
///
/// Restituisce (via Navigator.pop) la mappa aggiornata con le stesse chiavi
/// mpv ricevute in [initialValues], oppure null se l'utente annulla.
class SubtitlePreferencesDialog extends StatefulWidget {
  const SubtitlePreferencesDialog({required this.initialValues, super.key});

  final Map<String, String> initialValues;

  @override
  State<SubtitlePreferencesDialog> createState() =>
      _SubtitlePreferencesDialogState();
}

class _SubtitlePreferencesDialogState extends State<SubtitlePreferencesDialog> {
  late final Map<String, String> _values;
  final Map<String, TextEditingController> _controllers = {};
  int _tab = 0;

  static const _colorPresets = <String>[
    '#FFFFFF',
    '#FFEB3B',
    '#00E5FF',
    '#69F0AE',
    '#FF5252',
    '#000000',
    '#80000000',
  ];

  @override
  void initState() {
    super.initState();
    _values = Map<String, String>.of(widget.initialValues);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- helpers

  void _setValue(String key, String value) {
    setState(() {
      _values[key] = value;
      if (key == 'sub-border-style') {
        _values['sub-ass-override'] = 'force';
      }
      final controller = _controllers[key];
      if (controller != null && controller.text != value) {
        controller.text = value;
      }
    });
  }

  void _resetToDefaults() {
    setState(() {
      _values
        ..clear()
        ..addAll(AppSettings.subtitlePreferenceDefaults);
      for (final entry in _controllers.entries) {
        entry.value.text = _values[entry.key] ?? '';
      }
    });
  }

  TextEditingController _controller(String key) => _controllers.putIfAbsent(
    key,
    () => TextEditingController(text: _values[key] ?? ''),
  );

  double _num(String key, double fallback) =>
      double.tryParse(_values[key] ?? '') ?? fallback;

  bool _bool(String key) => _values[key] == 'yes';

  Color? _parseColor(String? raw) {
    if (raw == null) return null;
    final hex = raw.trim().replaceFirst('#', '');
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    if (hex.length == 6) return Color(0xFF000000 | parsed);
    if (hex.length == 8) return Color(parsed);
    return null;
  }

  // ---------------------------------------------------------------- widgets

  Widget _section(String title, IconData icon, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _text(
    String key,
    String label, {
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: _controller(key),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
      onChanged: (v) => setState(() => _values[key] = v),
    );
  }

  Widget _slider(
    String key,
    String label, {
    required double min,
    required double max,
    required int divisions,
    int decimals = 0,
    String suffix = '',
  }) {
    final scheme = Theme.of(context).colorScheme;
    final value = _num(key, min).clamp(min, max).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${value.toStringAsFixed(decimals)}$suffix',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSecondaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value,
            onChanged: (next) => _setValue(key, next.toStringAsFixed(decimals)),
          ),
        ),
      ],
    );
  }

  Widget _switch(String key, String label, {String? subtitle}) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(label),
        subtitle: subtitle == null ? null : Text(subtitle),
        value: _bool(key),
        onChanged: (v) => _setValue(key, v ? 'yes' : 'no'),
      ),
    );
  }

  /// [options] mappa valore mpv -> etichetta mostrata.
  Widget _dropdown(String key, String label, Map<String, String> options) {
    final current = options.containsKey(_values[key]) ? _values[key] : null;
    return DropdownButtonFormField<String>(
      key: ValueKey('$key-$current'),
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: [
        for (final e in options.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: (v) {
        if (v != null) _setValue(key, v);
      },
    );
  }

  Widget _colorField(String key, String label) {
    final scheme = Theme.of(context).colorScheme;
    final color = _parseColor(_values[key]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller(key),
          decoration: InputDecoration(
            labelText: label,
            hintText: '#RRGGBB o #AARRGGBB',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: (_values[key] ?? '').isNotEmpty && color == null
                ? 'Formato non valido'
                : null,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: _Swatch(color: color, size: 24),
            ),
          ),
          onChanged: (v) => setState(() => _values[key] = v),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 6,
          runSpacing: 5,
          children: [
            for (final preset in _colorPresets)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _setValue(key, preset),
                child: _Swatch(
                  color: _parseColor(preset),
                  size: 22,
                  selected: (_values[key] ?? '').toUpperCase() == preset,
                  accent: scheme.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- preview

  Widget _previewLine(
    String text, {
    required double fontSize,
    required double ax,
    required double ay,
    required double marginX,
    required double marginY,
    required bool secondary,
  }) {
    final v = _values;
    final fill = _parseColor(v['sub-color']) ?? Colors.white;
    final outlineColor = _parseColor(v['sub-outline-color']) ?? Colors.black;
    final backColor =
        _parseColor(v['sub-back-color']) ?? const Color(0x99000000);
    final outline = _num('sub-outline-size', 2);
    final shadow = _num('sub-shadow-offset', 1);
    final blur = _num('sub-blur', 0);
    final borderStyle = v['sub-border-style'] ?? 'outline-and-shadow';
    final boxed = borderStyle != 'outline-and-shadow';

    final base = TextStyle(
      fontFamily: (v['sub-font'] ?? '').isEmpty ? null : v['sub-font'],
      fontSize: fontSize,
      fontWeight: _bool('sub-bold') ? FontWeight.w800 : FontWeight.w500,
      fontStyle: _bool('sub-italic') ? FontStyle.italic : FontStyle.normal,
      letterSpacing: _num('sub-spacing', 0),
      height: 1.15,
    );

    Widget label = Stack(
      children: [
        if (!boxed && outline > 0)
          Text(
            text,
            textAlign: TextAlign.center,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeJoin = StrokeJoin.round
                ..strokeWidth = outline * 1.6
                ..color = outlineColor,
            ),
          ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(
            color: fill,
            shadows: boxed || shadow <= 0
                ? null
                : [
                    Shadow(
                      color: backColor,
                      offset: Offset(shadow, shadow),
                      blurRadius: blur,
                    ),
                  ],
          ),
        ),
      ],
    );

    if (boxed) {
      label = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: label,
      );
    }

    return Align(
      alignment: Alignment(ax, ay),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: marginX, vertical: marginY),
        child: label,
      ),
    );
  }

  Widget _preview() {
    final v = _values;
    final ax = switch (v['sub-align-x']) {
      'left' => -1.0,
      'right' => 1.0,
      _ => 0.0,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(
          builder: (context, c) {
            final k = c.maxHeight / 720;
            final marginX = _num('sub-margin-x', 25) * k;
            final marginY = _num('sub-margin-y', 22) * k;
            final primaryPos = _num('sub-pos', 100).clamp(0, 100) / 100;
            final secondaryPos =
                _num('secondary-sub-pos', 0).clamp(0, 100) / 100;
            return Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF263238), Color(0xFF0B1115)],
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    size: c.maxHeight * .3,
                    color: Colors.white12,
                  ),
                ),
                if (_bool('sub-visibility'))
                  _previewLine(
                    'Sottotitolo primario',
                    fontSize:
                        (_num('sub-font-size', 40) * _num('sub-scale', 1) * k)
                            .clamp(8, 80),
                    ax: ax,
                    ay: primaryPos * 2 - 1,
                    marginX: marginX,
                    marginY: marginY,
                    secondary: false,
                  ),
                if (_bool('secondary-sub-visibility'))
                  _previewLine(
                    'Seconda traccia',
                    fontSize:
                        (_num('sub-font-size', 40) *
                                _num('secondary-sub-scale', 1) *
                                k)
                            .clamp(8, 80),
                    ax: ax,
                    ay: secondaryPos * 2 - 1,
                    marginX: marginX,
                    marginY: marginY,
                    secondary: true,
                  ),
                Positioned(
                  left: 10,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Anteprima',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------------------- sections

  static const _alignX = {
    'left': 'Sinistra',
    'center': 'Centro',
    'right': 'Destra',
  };
  static const _alignY = {'top': 'Alto', 'center': 'Centro', 'bottom': 'Basso'};
  static const _borderStyles = {
    'outline-and-shadow': 'Bordo e ombra',
    'opaque-box': 'Riquadro opaco',
    'background-box': 'Riquadro di sfondo',
  };
  static const _hinting = {
    'none': 'Nessuno',
    'light': 'Leggero',
    'normal': 'Normale',
    'native': 'Nativo',
  };
  static const _assOverride = {
    'no': 'No (rispetta lo stile ASS)',
    'yes': 'Sì (applica le preferenze)',
    'scale': 'Solo scala',
    'force': 'Forza tutto',
    'strip': 'Rimuovi stili',
  };

  List<Widget> _primarySections() => [
    _section('Generale', Icons.tune_rounded, [
      _switch('sub-visibility', 'Mostra sottotitoli primari'),
      _text(
        'sub-delay',
        'Ritardo (secondi)',
        icon: Icons.timer_outlined,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
      ),
      _text('sub-codepage', 'Codifica sottotitoli', icon: Icons.translate),
    ]),
    _section('Testo', Icons.text_fields_rounded, [
      _text('sub-font', 'Carattere', icon: Icons.font_download_outlined),
      _slider(
        'sub-font-size',
        'Dimensione carattere',
        min: 12,
        max: 100,
        divisions: 88,
      ),
      _slider(
        'sub-scale',
        'Scala',
        min: 0.5,
        max: 2,
        divisions: 30,
        decimals: 2,
        suffix: '×',
      ),
      _slider(
        'sub-spacing',
        'Spaziatura lettere',
        min: -5,
        max: 20,
        divisions: 50,
        decimals: 1,
      ),
      Row(
        children: [
          Expanded(child: _switch('sub-bold', 'Grassetto')),
          const SizedBox(width: 12),
          Expanded(child: _switch('sub-italic', 'Corsivo')),
        ],
      ),
    ]),
    _section('Colori e bordo', Icons.palette_outlined, [
      _colorField('sub-color', 'Colore testo'),
      _colorField('sub-outline-color', 'Colore bordo'),
      _slider(
        'sub-outline-size',
        'Spessore bordo',
        min: 0,
        max: 10,
        divisions: 40,
        decimals: 2,
      ),
      _dropdown('sub-border-style', 'Stile bordo', _borderStyles),
      _colorField('sub-back-color', 'Colore ombra/sfondo'),
      _slider(
        'sub-shadow-offset',
        'Offset ombra',
        min: 0,
        max: 20,
        divisions: 40,
        decimals: 1,
      ),
      _slider(
        'sub-blur',
        'Sfocatura',
        min: 0,
        max: 20,
        divisions: 50,
        decimals: 1,
      ),
    ]),
    _section('Posizione', Icons.open_with_rounded, [
      _slider(
        'sub-pos',
        'Posizione verticale (100 = basso)',
        min: 0,
        max: 150,
        divisions: 150,
      ),
      Row(
        children: [
          Expanded(child: _dropdown('sub-align-x', 'Orizzontale', _alignX)),
          const SizedBox(width: 12),
          Expanded(child: _dropdown('sub-align-y', 'Verticale', _alignY)),
        ],
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
      _switch('sub-use-margins', 'Usa i margini video'),
      _switch('sub-ass-force-margins', 'Forza i margini per ASS/SSA'),
    ]),
    _section('Avanzate (ASS/SSA)', Icons.settings_suggest_outlined, [
      _dropdown('sub-ass-override', 'Override stile ASS/SSA', _assOverride),
      _slider(
        'sub-line-spacing',
        'Spaziatura righe',
        min: -10,
        max: 20,
        divisions: 60,
        decimals: 1,
      ),
      _dropdown('sub-hinting', 'Hinting carattere', _hinting),
    ]),
  ];

  List<Widget> _secondarySections() {
    final scheme = Theme.of(context).colorScheme;
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'mpv non permette font, colori e bordi indipendenti per la '
                'seconda traccia: seguono lo stile del sottotitolo primario. '
                'Posizione, scala, ritardo e visibilità sono separati.',
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
      _section('Generale', Icons.tune_rounded, [
        _switch('secondary-sub-visibility', 'Mostra seconda traccia'),
        _text(
          'secondary-sub-delay',
          'Ritardo (secondi)',
          icon: Icons.timer_outlined,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
        ),
      ]),
      _section('Posizione e scala', Icons.open_with_rounded, [
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
          decimals: 2,
          suffix: '×',
        ),
      ]),
      _section('Avanzate (ASS/SSA)', Icons.settings_suggest_outlined, [
        _dropdown(
          'secondary-sub-ass-override',
          'Override stile ASS/SSA',
          _assOverride,
        ),
      ]),
    ];
  }

  Widget _tabSelector() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: 0,
            icon: Icon(Icons.subtitles_rounded),
            label: Text('Primario'),
          ),
          ButtonSegment(
            value: 1,
            icon: Icon(Icons.subtitles_outlined),
            label: Text('Secondario'),
          ),
        ],
        selected: {_tab},
        onSelectionChanged: (s) => setState(() => _tab = s.first),
      ),
    );
  }

  Widget _settingsList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
      children: _tab == 0 ? _primarySections() : _secondarySections(),
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 820;

    final body = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 292,
                child: Column(
                  children: [
                    _preview(),
                    const SizedBox(height: 8),
                    _tabSelector(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _settingsList()),
            ],
          )
        : Column(
            children: [
              _preview(),
              const SizedBox(height: 8),
              _tabSelector(),
              const SizedBox(height: 4),
              Expanded(child: _settingsList()),
            ],
          );

    return Dialog(
      insetPadding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 960,
          maxHeight: (size.height - 28).clamp(400, 760),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.closed_caption_rounded, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Preferenze sottotitoli',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chiudi',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                child: body,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _resetToDefaults,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Ripristina predefinite'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, _values),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Salva'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pallino colorato con scacchiera per mostrare la trasparenza.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.size,
    this.selected = false,
    this.accent,
  });

  final Color? color;
  final double size;
  final bool selected;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade400,
        border: Border.all(
          color: selected ? (accent ?? outline) : outline,
          width: selected ? 2.5 : 1,
        ),
      ),
      child: ClipOval(
        child: color == null
            ? const Icon(Icons.block, size: 14, color: Colors.white)
            : ColoredBox(color: color!),
      ),
    );
  }
}
