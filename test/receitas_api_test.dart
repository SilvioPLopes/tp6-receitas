import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tp6_receitas/services/receitas_api.dart';

void main() {
  test('envia o texto digitado como parâmetro e interpreta o JSON', () async {
    final api = ReceitasApi(
      client: MockClient((request) async {
        expect(request.url.host, 'www.themealdb.com');
        expect(request.url.path, '/api/json/v1/1/search.php');
        expect(request.url.queryParameters['s'], 'chicken & rice');
        return http.Response(
          jsonEncode({
            'meals': [
              {
                'strMeal': 'Chicken & rice',
                'strMealThumb': 'https://example.com/a.jpg',
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(api.dispose);
    final receitas = await api.buscar('  chicken & rice  ');
    expect(receitas, hasLength(1));
    expect(receitas.first.nome, 'Chicken & rice');
    expect(receitas.first.imagem, 'https://example.com/a.jpg');
  });

  test('meals nulo corresponde a nenhum resultado', () async {
    final api = ReceitasApi(
      client: MockClient((_) async {
        return http.Response('{"meals":null}', 200);
      }),
    );
    addTearDown(api.dispose);
    expect(await api.buscar('inexistente'), isEmpty);
  });

  test('status HTTP de falha gera erro', () async {
    final api = ReceitasApi(
      client: MockClient((_) async {
        return http.Response('Serviço indisponível', 503);
      }),
    );
    addTearDown(api.dispose);
    await expectLater(
      api.buscar('chicken'),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('JSON inválido gera FormatException', () async {
    final api = ReceitasApi(
      client: MockClient((_) async {
        return http.Response('<html>Erro</html>', 200);
      }),
    );
    addTearDown(api.dispose);
    await expectLater(api.buscar('chicken'), throwsFormatException);
  });

  test('formato inesperado não é confundido com lista vazia', () async {
    final api = ReceitasApi(
      client: MockClient((_) async {
        return http.Response('{"erro":"resposta inesperada"}', 200);
      }),
    );
    addTearDown(api.dispose);
    await expectLater(api.buscar('chicken'), throwsFormatException);
  });
}
