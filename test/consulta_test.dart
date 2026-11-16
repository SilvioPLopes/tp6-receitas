import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tp6_receitas/main.dart';
import 'package:tp6_receitas/services/receitas_api.dart';

void main() {
  testWidgets('pesquisa vazia mostra orientação sem consultar a API', (
    tester,
  ) async {
    var chamadas = 0;
    final api = ReceitasApi(
      client: MockClient((_) async {
        chamadas++;
        return http.Response('{"meals":null}', 200);
      }),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: ReceitasPage(api: api)));
    expect(find.text('Silvio Lopes'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(
      find.text('Digite o nome ou parte do nome de uma receita.'),
      findsOneWidget,
    );
    expect(chamadas, 0);
  });

  testWidgets('mostra carregamento e depois informa ausência de resultados', (
    tester,
  ) async {
    final resposta = Completer<http.Response>();
    final api = ReceitasApi(client: MockClient((_) => resposta.future));
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: ReceitasPage(api: api)));
    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Buscando receitas...'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    resposta.complete(http.Response('{"meals":null}', 200));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma receita encontrada'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('falha HTTP mostra mensagem e permite nova tentativa', (
    tester,
  ) async {
    var chamadas = 0;
    final api = ReceitasApi(
      client: MockClient((_) async {
        chamadas++;
        return http.Response(
          chamadas == 1 ? 'Erro' : '{"meals":null}',
          chamadas == 1 ? 500 : 200,
        );
      }),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: ReceitasPage(api: api)));
    await tester.enterText(find.byType(TextField), 'chicken');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Verifique sua conexão'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(chamadas, 2);
    expect(find.text('Nenhuma receita encontrada'), findsOneWidget);
  });

  testWidgets('exibe nome e imagem em ListView', (tester) async {
    final api = ReceitasApi(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode({
            'meals': [
              {
                'strMeal': 'Chicken soup',
                'strMealThumb': 'https://example.com/soup.jpg',
              },
            ],
          }),
          200,
        );
      }),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(MaterialApp(home: ReceitasPage(api: api)));
    await tester.enterText(find.byType(TextField), 'chicken');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Chicken soup'), findsOneWidget);
    final imagem = tester.widget<Image>(find.byType(Image));
    expect(imagem.image, isA<NetworkImage>());
    expect((imagem.image as NetworkImage).url, 'https://example.com/soup.jpg');
  });
}
