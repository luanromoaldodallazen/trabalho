
import 'package:flutter/material.dart';
import 'package:consulta_cep/Endereco.dart';
import 'ConsultaCep.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta CEP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(title: 'Consultando CEPs'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  final TextEditingController _cepController = TextEditingController();

  Endereco? endereco;
  String? erro;
  bool carregando = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  void _aplicarMascara(String value) {
    String numeros = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numeros.length > 8) {
      numeros = numeros.substring(0, 8);
    }

    String texto = numeros;
    if (numeros.length > 5) {
      texto = '${numeros.substring(0, 5)}-${numeros.substring(5)}';
    }

    if (texto != _cepController.text) {
      _cepController.value = TextEditingValue(
        text: texto,
        selection: TextSelection.collapsed(offset: texto.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            TextFormField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              onChanged: _aplicarMascara,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'CEP:',
                hintText: '00000-000',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                setState(() {
                  carregando = true;
                  endereco = null;
                  erro = null;
                });

                try {
                  String cep = _cepController.text.replaceAll('-', '');
                  if (cep.length != 8) {
                  setState(() {
                  erro = 'Digite um CEP válido.';
                  carregando = false;
                    });
                  return;
                  }
                  final data = await ConsultaCep.fetchCep(cep);

                  setState(() {
                    endereco = data;
                    carregando = false;
                  });
                } catch (_) {
                  setState(() {
                    erro = 'CEP não encontrado. Verifique e tente novamente.';
                    carregando = false;
                  });
                }
              },
              child: const Text(
                'Consultar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (carregando)
              const Center(child: CircularProgressIndicator())
            else if (erro != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(erro!),
              )
            else if (endereco != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _linhaInfo('CEP', endereco!.cep),
                    _linhaInfo('Logradouro', endereco!.logradouro),
                    _linhaInfo('Bairro', endereco!.bairro),
                    _linhaInfo('Cidade', endereco!.localidade),
                    _linhaInfo('Estado', endereco!.uf),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _linhaInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
