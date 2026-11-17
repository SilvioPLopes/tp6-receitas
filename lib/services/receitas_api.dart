// Integrante: Silvio Lopes, João Pedro.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/receita.dart';

class ReceitasApi {
  ReceitasApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Receita>> buscar(String termo) async {
    // Uri.https codifica corretamente espaços e caracteres da pesquisa.
    final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {
      's': termo.trim(),
    });
    final resposta = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (resposta.statusCode != 200) {
      throw http.ClientException('Erro HTTP ${resposta.statusCode}', uri);
    }
    final dynamic dados = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (dados is! Map<String, dynamic> || !dados.containsKey('meals')) {
      throw const FormatException('Resposta inválida da API.');
    }
    final dynamic itens = dados['meals'];
    // A API retorna meals: null quando não encontra receitas.
    if (itens == null) return [];
    if (itens is! List) {
      throw const FormatException('Lista de receitas inválida.');
    }
    return itens.map((dynamic item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Receita inválida.');
      }
      return Receita.fromJson(item);
    }).toList();
  }

  void dispose() => _client.close();
}
