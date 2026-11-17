import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relato.dart';
import '../providers/relato_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/visuals.dart';

/// Formulário de cadastro e edição de relato.
/// Recebe um [Relato] para editar; sem argumento, cria um novo.
class RelatoFormScreen extends StatefulWidget {
  const RelatoFormScreen({super.key, this.relato});

  final Relato? relato;

  @override
  State<RelatoFormScreen> createState() => _RelatoFormScreenState();
}

class _RelatoFormScreenState extends State<RelatoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _bairroCtrl;

  CategoriaRelato? _categoria;
  StatusRelato _status = StatusRelato.aberto;
  bool _risco = false;
  bool _salvando = false;

  bool get _editando => widget.relato != null;

  @override
  void initState() {
    super.initState();
    final r = widget.relato;
    _tituloCtrl = TextEditingController(text: r?.titulo ?? '');
    _descricaoCtrl = TextEditingController(text: r?.descricao ?? '');
    _bairroCtrl = TextEditingController(text: r?.bairro ?? '');
    _categoria = r?.categoria;
    _status = r?.status ?? StatusRelato.aberto;
    _risco = r?.risco ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _bairroCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<RelatoProvider>();

    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Corrija os campos destacados.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    final base = widget.relato;
    final relato = Relato(
      id: base?.id,
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      categoria: _categoria!,
      bairro: _bairroCtrl.text.trim(),
      status: _status,
      apoios: base?.apoios ?? 0,
      apoiado: base?.apoiado ?? false,
      risco: _risco,
      dataCriacao: base?.dataCriacao ?? DateTime.now(),
    );

    final ok =
        _editando ? await provider.atualizar(relato) : await provider.adicionar(relato);

    if (!mounted) return;
    setState(() => _salvando = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (_editando
                  ? 'Relato atualizado com sucesso!'
                  : 'Relato publicado! Seus vizinhos já podem apoiar.')
              : 'Não foi possível salvar o relato. Tente novamente.',
        ),
      ),
    );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar relato' : 'Novo relato'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _tituloCtrl,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: campoDecoration(
                  'Título',
                  dica: 'Ex.: Buraco perigoso na Av. Principal',
                  icone: Icons.title,
                ),
                validator: Validators.titulo,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoriaRelato>(
                // ignore: deprecated_member_use
                value: _categoria,
                isExpanded: true,
                decoration: campoDecoration('Categoria', icone: Icons.category),
                items: [
                  for (final categoria in CategoriaRelato.values)
                    DropdownMenuItem(
                      value: categoria,
                      child: Row(
                        children: [
                          Icon(iconeDaCategoria(categoria), size: 20),
                          const SizedBox(width: 8),
                          Text(categoria.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (valor) => setState(() => _categoria = valor),
                validator: Validators.categoria,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bairroCtrl,
                maxLength: 40,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: campoDecoration(
                  'Bairro / local',
                  dica: 'Ex.: Jardim das Flores',
                  icone: Icons.place_outlined,
                ),
                validator: Validators.bairro,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoCtrl,
                maxLength: 300,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: campoDecoration(
                  'Descrição',
                  dica: 'Conte o que está acontecendo e onde exatamente',
                  icone: Icons.notes,
                ),
                validator: Validators.descricao,
              ),
              const SizedBox(height: 4),
              Card(
                elevation: 0,
                color: Colors.white,
                child: SwitchListTile(
                  title: const Text('Oferece risco para pessoas?'),
                  subtitle: const Text(
                    'Marque se o problema pode causar acidentes ou doenças.',
                  ),
                  secondary: const Icon(Icons.warning_amber_rounded),
                  value: _risco,
                  onChanged: (valor) => setState(() => _risco = valor),
                ),
              ),
              if (_editando) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<StatusRelato>(
                  // ignore: deprecated_member_use
                  value: _status,
                  isExpanded: true,
                  decoration: campoDecoration(
                    'Situação do relato',
                    icone: Icons.flag_outlined,
                  ),
                  items: [
                    for (final status in StatusRelato.values)
                      DropdownMenuItem(value: status, child: Text(status.label)),
                  ],
                  onChanged: (valor) {
                    if (valor != null) setState(() => _status = valor);
                  },
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _editando ? 'Salvar alterações' : 'Publicar relato',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _salvando ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
