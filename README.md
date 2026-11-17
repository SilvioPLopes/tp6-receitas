# TP6 — App de Consulta de Receitas

Aplicativo Flutter/Dart para pesquisar receitas pelo nome ou parte dele usando a API REST pública TheMealDB.

**Integrante:** Silvio Lopes. Confira se este é o nome completo exigido pela atividade. Se necessário, atualize a AppBar, os comentários no início dos arquivos em `lib/`, este README e a expectativa de nome no teste `test/consulta_test.dart`. Para uma dupla, inclua os dois nomes.

## Executar

Instale o Flutter SDK estável (3.29 ou superior, com Dart 3.7 ou superior) e configure um dispositivo Android ou o Chrome. Para Android, use JDK 17 e o SDK Android configurado. Dentro desta pasta, execute:

```bash
flutter pub get
flutter run
```

Para executar especificamente no navegador:

```bash
flutter run -d chrome
```

É necessária conexão com a internet. O projeto inclui as plataformas Android e Web. Não inclui APK compilado.

## Usar

1. Digite o nome ou parte do nome de uma receita, preferencialmente em inglês: `chicken`, `pasta`, `cake`.
2. Toque em **Buscar receitas** ou use a tecla de pesquisa do teclado.
3. Veja o nome e a foto de cada receita na lista.

Uma busca em branco mostra uma orientação sem enviar requisições. Durante a consulta, aparece um indicador de carregamento. Também há mensagens para ausência de resultados, demora excessiva, dados inválidos e erro de conexão. Imagens indisponíveis apresentam um ícone substituto.

## API utilizada

Documentação oficial: https://www.themealdb.com/api.php

Endpoint de pesquisa:

```text
https://www.themealdb.com/api/json/v1/1/search.php?s=chicken
```

O parâmetro `s` recebe o texto digitado pelo usuário. A URL é construída com `Uri.https`, que codifica espaços e caracteres especiais. A chave de teste `1` é disponibilizada pela TheMealDB para desenvolvimento e uso educacional.

O serviço faz uma chamada HTTP GET, verifica o status e interpreta o JSON com `jsonDecode`. Quando `meals` é `null`, devolve uma lista vazia. Os campos `strMeal` e `strMealThumb` fornecem o nome e a imagem. A consulta tem limite de 15 segundos.

O endpoint de detalhes por ID existe, mas não é necessário ao fluxo solicitado e não é usado por este aplicativo.

## Requisitos atendidos

| Requisito | Implementação |
| --- | --- |
| Flutter/Dart | Projeto com `pubspec.yaml`, Android e Web |
| API REST pública e JSON | `http.Client`, GET e `jsonDecode` em `receitas_api.dart` |
| Campo de pesquisa | `TextField` com `TextEditingController` |
| Botão de consulta | `ElevatedButton.icon` |
| Texto digitado na URL | Parâmetro `s` construído com `Uri.https` |
| Lista de receitas | `ListView.builder` |
| Nome e imagem | `Text` e `Image.network` |
| Atualização da interface | `StatefulWidget` e `setState` |
| Carregamento, vazio e erro | Estados explícitos na tela |
| Integrante na AppBar e comentário inicial | Silvio Lopes |
| Sem armazenamento local | Nenhum banco, arquivo ou preferência persistente implementado |

Os resultados ficam apenas em memória enquanto a tela está aberta. Os widgets de imagem usam o comportamento padrão do Flutter; o aplicativo não implementa cache persistente.

## Estrutura do código

```text
lib/
  main.dart                 Tela, pesquisa e gerenciamento de estado
  models/receita.dart        Conversão dos campos de cada receita
  services/receitas_api.dart Consulta HTTP e interpretação do JSON
test/
  receitas_api_test.dart     Parâmetros, JSON, ausência e falhas HTTP
  consulta_test.dart         Estados e componentes da interface
```

## Verificar

```bash
flutter analyze
flutter test
flutter build web
```

Os testes usam respostas HTTP simuladas para não depender da disponibilidade da API nem da internet. Para conferir a integração real, execute o app e pesquise `chicken`.

### Validação desta entrega

- A consulta real ao endpoint com `chicken` retornou HTTP 200 e 25 receitas durante a preparação.
- Os cinco arquivos Dart foram processados pelo formatador, sem alterações pendentes.
- Os arquivos YAML, XML e JSON foram verificados; a permissão de internet e os arquivos do Gradle Wrapper estão presentes.
- Os nove testes foram escritos, mas **não foram executados** neste ambiente. A inicialização do Flutter foi bloqueada pela revisão automática de segurança após uma tentativa da ferramenta de acessar metadados internos do ambiente. A análise com `flutter analyze` e as compilações também não foram executadas. Rode os três comandos acima no seu computador antes de entregar.
- As dependências serão baixadas por `flutter pub get`; o `pubspec.lock` será gerado nesse momento.

Checklist manual:

- Pesquisar `chicken`: nomes e imagens na lista.
- Pesquisar parte de um nome, como `chick`: resultados correspondentes.
- Pesquisar `zzzzzzzzzz`: mensagem de nenhum resultado.
- Pesquisar só espaços: orientação de preenchimento.
- Desconectar a internet e pesquisar: mensagem de falha ou tempo excedido.
- Fazer outra pesquisa após uma falha: recuperação normal.
- Conferir nome completo na AppBar e nos comentários.

## Repositório e entrega

Repositório: https://github.com/SilvioPLopes/tp6-receitas

Projeto completo: https://github.com/SilvioPLopes/tp6-receitas/tree/tp6-receitas

O projeto está na branch `tp6-receitas`. Foram separados três commits de desenvolvimento: configuração Android/Web, consulta HTTP/modelo e interface/testes/documentação.

Para baixar e executar:

```bash
git clone --branch tp6-receitas https://github.com/SilvioPLopes/tp6-receitas.git
cd tp6-receitas
flutter pub get
flutter run
```

Não envie `build/`, `.dart_tool/` ou `android/local.properties`. O `.gitignore` já exclui esses arquivos. Após executar `flutter pub get`, inclua o `pubspec.lock` gerado no repositório.

O enunciado informa entrega em **14/11 às 23h59**. Os commits usam a data real de sua criação. O envio do link à plataforma da professora fica a cargo do integrante.
