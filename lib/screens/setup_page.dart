import 'package:flutter/material.dart';

import '../main.dart';
import '../models/business.dart';
import 'home_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final type = TextEditingController();
  final owner = TextEditingController();
  final count = TextEditingController(text: '20');
  String currency = 'MXN';
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    type.dispose();
    owner.dispose();
    count.dispose();
    super.dispose();
  }

  Future<void> save({bool demo = false}) async {
    if (!demo && !formKey.currentState!.validate()) return;
    setState(() => saving = true);
    final value = demo
        ? DemoBusiness.value
        : Business(
            name: name.text.trim(),
            type: type.text.trim(),
            owner: owner.text.trim(),
            currency: currency,
            productCount: int.tryParse(count.text) ?? 0,
          );
    await AppScope.of(context).setup(value, demo: demo);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SetupBrand(),
                    const SizedBox(height: 34),
                    Text(
                      'Configuremos tu negocio',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estos datos se guardan solo en este dispositivo.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 28),
                    field(
                      name,
                      'Nombre del negocio',
                      Icons.storefront_outlined,
                    ),
                    const SizedBox(height: 14),
                    field(type, 'Tipo de negocio', Icons.category_outlined),
                    const SizedBox(height: 14),
                    field(
                      owner,
                      'Nombre del propietario',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: field(
                            count,
                            'Productos aprox.',
                            Icons.inventory_2_outlined,
                            number: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: currency,
                            decoration: const InputDecoration(
                              labelText: 'Moneda',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'MXN',
                                child: Text('MXN (4)'),
                              ),
                              DropdownMenuItem(
                                value: 'USD',
                                child: Text('USD (4)'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => currency = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: saving ? null : save,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Crear mi negocio'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: saving ? null : () => save(demo: true),
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('Explorar con datos demo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Este campo es obligatorio'
          : null,
    );
  }
}

class SetupBrand extends StatelessWidget {
  const SetupBrand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'img/logo.jpg',
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          semanticLabel: 'Logo de LossTrack',
        ),
      ),
      SizedBox(width: 8),
      Flexible(
        child: Text(
          'LossTrack',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class DemoBusiness {
  static const value = Business(
    name: 'Mi Tienda',
    type: 'Abarrotes',
    owner: 'Propietario',
    currency: 'MXN',
    productCount: 6,
  );
}
