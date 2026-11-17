// Integrante: Silvio Lopes.
// TP6 — App de Consulta de Receitas. Sem armazenamento local.
import 'dart:async';

import 'package:flutter/material.dart';

import 'models/receita.dart';
import 'services/receitas_api.dart';

void main() => runApp(const ReceitasApp());

class ReceitasApp extends StatelessWidget {
  const ReceitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de Receitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF26734D)),
        scaffoldBackgroundColor: const Color(0xFFFAF9F5),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const ReceitasPage(),
    );
  }
}

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key, this.api});

  final ReceitasApi? api;

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  final _pesquisaController = TextEditingController();
  late final ReceitasApi _api;
  List<Receita> _receitas = [];
  bool _carregando = false;
  bool _pesquisou = false;
  String? _erro;
  String _ultimoTermo = '';

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? ReceitasApi();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    // O proprietário de uma API injetada é responsável por fechá-la.
    if (widget.api == null) _api.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (_carregando) return;
    final termo = _pesquisaController.text.trim();
    FocusScope.of(context).unfocus();
    if (termo.isEmpty) {
      setState(() {
        _erro = 'Digite o nome ou parte do nome de uma receita.';
        _receitas = [];
        _pesquisou = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      _receitas = [];
      _pesquisou = true;
      _ultimoTermo = termo;
    });
    try {
      final receitas = await _api.buscar(termo);
      // A tela pode ter sido fechada enquanto a consulta estava em andamento.
      if (!mounted) return;
      setState(() => _receitas = receitas);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _erro = 'A consulta demorou demais. Tente novamente.');
    } on FormatException {
      if (!mounted) return;
      setState(
        () => _erro = 'O serviço retornou dados inválidos. Tente novamente.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro =
            'Não foi possível consultar as receitas. '
            'Verifique sua conexão e tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Widget _mensagem(IconData icone, String titulo, String texto) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando receitas...'),
          ],
        ),
      );
    }
    if (_erro != null) {
      return _mensagem(Icons.info_outline, 'Confira sua pesquisa', _erro!);
    }
    if (!_pesquisou) {
      return _mensagem(
        Icons.restaurant_menu,
        'O que vamos preparar?',
        'Pesquise uma receita pelo nome. Experimente chicken, pasta ou cake.',
      );
    }
    if (_receitas.isEmpty) {
      return _mensagem(
        Icons.search_off,
        'Nenhuma receita encontrada',
        'Não encontramos receitas para “$_ultimoTermo”. Tente outro nome em inglês.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '${_receitas.length} receita(s) para “$_ultimoTermo”',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _receitas.length,
            itemBuilder: (context, index) {
              final receita = _receitas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Image.network(
                      receita.imagem,
                      width: 104,
                      height: 104,
                      fit: BoxFit.cover,
                      semanticLabel: 'Foto de ${receita.nome}',
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 104,
                          height: 104,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 104,
                          height: 104,
                          child: Icon(
                            Icons.broken_image_outlined,
                            semanticLabel: 'Imagem indisponível',
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          receita.nome,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consulta de Receitas'),
            Text('Silvio Lopes', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _pesquisaController,
                        enabled: !_carregando,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _buscar(),
                        decoration: const InputDecoration(
                          labelText: 'Nome da receita',
                          hintText: 'Ex.: chicken',
                          prefixIcon: Icon(Icons.search),
                          helperText: 'A TheMealDB utiliza nomes em inglês.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _carregando ? null : _buscar,
                        icon: const Icon(Icons.search),
                        label: Text(
                          _carregando ? 'Buscando...' : 'Buscar receitas',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _conteudo()),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Receitas fornecidas por TheMealDB',
                    style: TextStyle(fontSize: 12),
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
