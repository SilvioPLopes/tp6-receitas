// Integrante: Silvio Lope, João Pedro.
class Receita {
  const Receita({required this.nome, required this.imagem});

  final String nome;
  final String imagem;

  factory Receita.fromJson(Map<String, dynamic> json) {
    if (json['strMeal'] is! String || json['strMealThumb'] is! String) {
      throw const FormatException('Receita com campos inválidos.');
    }
    return Receita(
      nome: json['strMeal'] as String,
      imagem: json['strMealThumb'] as String,
    );
  }
}
