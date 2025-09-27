import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlantPage extends StatefulWidget {
  const PlantPage({super.key});

  @override
  State<PlantPage> createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  static const Color cream = Color(0xFFD8CBC2);
  static const Color navy = Color(0xFF112250);
  static const Color cardBg = Color(0xFFF7F5F2);

  static const double co2PerTreeKg = 25.0;

  int _sessionCount = 1;

  double get _sessionCo2 => _sessionCount * co2PerTreeKg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(
          const AssetImage('assets/images/arkaplansilinmisagac.png'),
          context,
        );
      } catch (_) {
        /* ignore */
      }
    });
  }

  void _onDonationConfirmed(int count) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Thanks! +$count trees donated 🌳')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: cream,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Plant Trees',
          style: text.titleMedium?.copyWith(
            color: navy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: ListView(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + bottomSafe),
              children: [
                SizedBox(
                  height: 170,
                  child: Center(
                    child: Image.asset(
                      'assets/images/arkaplansilinmisagac.png',
                      height: 130,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.park,
                        size: 110,
                        color: navy.withValues(alpha: .9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Column(
                  children: [
                    Text(
                      'Plant Trees',
                      textAlign: TextAlign.center,
                      style: text.titleLarge?.copyWith(
                        color: navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Offset your water footprint by\nplanting trees',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _BeigeCard(
                  child: _DonationCard(
                    initialCount: _sessionCount,
                    onCountChanged: (v) => setState(() => _sessionCount = v),
                    onConfirmed: _onDonationConfirmed,
                    usePaymentSheet: true,
                  ),
                ),
                const SizedBox(height: 16),
                _BeigeCard(
                  child: Column(
                    children: [
                      Text(
                        'This Donation',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_sessionCount tree${_sessionCount > 1 ? 's' : ''}',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '≈ ${(_sessionCo2).toStringAsFixed(0)} kg CO₂ saved',
                        style: text.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Note: 1 tree ≈ 25 kg CO₂/year on average. Actual savings vary by species, climate and location.',
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonationCard extends StatefulWidget {
  const _DonationCard({
    required this.initialCount,
    required this.onCountChanged,
    required this.onConfirmed,
    this.usePaymentSheet = true,
  });

  final int initialCount;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<int> onConfirmed;
  final bool usePaymentSheet;

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _setCount(int v) {
    _count = v.clamp(1, 999).toInt();
    widget.onCountChanged(_count);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Number of Trees',
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundBtn(
              icon: Icons.remove,
              onTap: () {
                HapticFeedback.selectionClick();
                _setCount(_count - 1);
              },
            ),
            const SizedBox(width: 18),
            Container(
              width: 72,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                '$_count',
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 18),
            _RoundBtn(
              icon: Icons.add,
              onTap: () {
                HapticFeedback.selectionClick();
                _setCount(_count + 1);
              },
            ),
          ],
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _PlantPageState.navy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              if (!widget.usePaymentSheet) {
                widget.onConfirmed(_count);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Donation completed 🌳')),
                );
                return;
              }

              final ok = await _openPaymentSheet(context, _count);
              if (!mounted) return;

              if (ok == true) {
                widget.onConfirmed(_count);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Donation completed 🌳')),
                );
              }
            },
            child: const Text('Donate'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Payments for your tree donations will be transferred to TEMA Foundation.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Future<bool?> _openPaymentSheet(BuildContext context, int trees) {
    final amountText = '$trees tree${trees > 1 ? 's' : ''}';
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _PaymentSheet(amountText: amountText, navy: _PlantPageState.navy),
    );
  }
}

class _BeigeCard extends StatelessWidget {
  const _BeigeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _PlantPageState.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.amountText, required this.navy});

  final String amountText;
  final Color navy;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final List<String> _savedCards = ['Visa •••• 1234', 'Mastercard •••• 5678'];
  String? _selectedSaved;

  final _ctrlName = TextEditingController();
  final _ctrlNum = TextEditingController();
  final _ctrlExp = TextEditingController();
  final _ctrlCvc = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saveThisCard = false;

  @override
  void dispose() {
    _ctrlName.dispose();
    _ctrlNum.dispose();
    _ctrlExp.dispose();
    _ctrlCvc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (ctx, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: widget.navy,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: ListView(
            controller: scroll,
            children: [
              Row(
                children: [
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Donate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'You are donating for ${widget.amountText}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),

              // ---------- Saved cards ----------
              if (_savedCards.isNotEmpty) ...[
                const Text(
                  'Saved cards',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                for (final card in _savedCards)
                  RadioListTile<String>(
                    value: card,
                    groupValue: _selectedSaved,
                    onChanged: (v) {
                      setState(() {
                        _selectedSaved = v;
                        _ctrlName.clear();
                        _ctrlNum.clear();
                        _ctrlExp.clear();
                        _ctrlCvc.clear();
                        _saveThisCard = false;
                      });
                    },
                    activeColor: Colors.white,
                    title: Text(
                      card,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Use this card',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                const Divider(color: Colors.white24),
              ],

              const SizedBox(height: 6),
              const Text(
                'Or enter a new card',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _whiteField(
                      controller: _ctrlName,
                      label: 'Card holder',
                      enabled: _selectedSaved == null,
                      validator: (v) {
                        if (_selectedSaved != null)
                          return null; // saved seçiliyse valide etme
                        if (v == null || v.trim().length < 3)
                          return 'Enter a name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _whiteField(
                      controller: _ctrlNum,
                      label: 'Card number',
                      enabled: _selectedSaved == null,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      validator: (v) {
                        if (_selectedSaved != null) return null;
                        final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 12) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _whiteField(
                            controller: _ctrlExp,
                            label: 'MM/YY',
                            enabled: _selectedSaved == null,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _CardExpFormatter(),
                            ],
                            validator: (v) {
                              if (_selectedSaved != null) return null;
                              if (v == null || !v.contains('/')) return 'MM/YY';
                              final p = v.split('/');
                              final mm = int.tryParse(p[0]);
                              final yy = int.tryParse(p[1]);
                              if (mm == null || yy == null) return 'MM/YY';
                              if (mm < 1 || mm > 12) return 'MM/YY';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _whiteField(
                            controller: _ctrlCvc,
                            label: 'CVC',
                            enabled: _selectedSaved == null,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (_selectedSaved != null) return null;
                              if (v == null || v.length < 3) return 'CVC';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _saveThisCard,
                          onChanged: _selectedSaved == null
                              ? (v) =>
                                    setState(() => _saveThisCard = v ?? false)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Save this card for demo',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: widget.navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          if (_selectedSaved != null) {
                            Navigator.pop(context, true);
                            return;
                          }
                          if (_formKey.currentState?.validate() != true) return;

                          if (_saveThisCard) {
                            final digits = _ctrlNum.text.replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            final last4 = digits.length >= 4
                                ? digits.substring(digits.length - 4)
                                : digits;
                            setState(() {
                              final masked = 'Card •••• $last4';
                              _savedCards.add(masked);
                              _selectedSaved = masked;
                            });
                          }

                          Navigator.pop(context, true);
                        },
                        child: const Text(
                          'Pay',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                'Payments are simulated for demo. No real charges are made.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _whiteField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: enabled ? Colors.white10 : Colors.white10.withOpacity(.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final t = buf.toString();
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

class _CardExpFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 4) d = d.substring(0, 4);
    String f;
    if (d.length >= 3) {
      f = '${d.substring(0, 2)}/${d.substring(2)}';
    } else {
      f = d;
    }
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final _SavedCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.white : Colors.white24),
        ),
        child: Row(
          children: [
            _RadioCircle(selected: selected),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card.brand} ${card.masked}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.holder,
                    style: const TextStyle(color: Colors.white70),
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

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String message;

  const _EmptyBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _SavedCard {
  final String masked;
  final String holder;
  final String brand;

  _SavedCard({required this.masked, required this.holder, required this.brand});
}
