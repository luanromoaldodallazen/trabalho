import 'package:consulta_cep/Endereco.dart';
import 'package:flutter/material.dart';
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
  String cep = "";
  Endereco? endereco;
  String? erro;
  bool carregando = false;

  String _mascaraCep(String valor) {
    valor = valor.replaceAll(RegExp(r'[^0-9]'), '');

    if (valor.length > 8) {
      valor = valor.substring(0, 8);
    }

    if (valor.length > 5) {
      valor = '${valor.substring(0, 5)}-${valor.substring(5)}';
    }

    return valor;
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
            tffCep(),
            const SizedBox(height: 16),
            btnConsultarCep(),
            const SizedBox(height: 24),
            resultadoWidget(),
          ],
        ),
      ),
    );
  }

  TextFormField tffCep() {
    return TextFormField(
      initialValue: cep,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        return null;
      },
      onChanged: (value) {
        final novoCep = _mascaraCep(value);

        if (novoCep != value) {
          setState(() {
            cep = novoCep;
          });
          return;
        }

        setState(() {
          cep = novoCep;
        });
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        label: Text("CEP:"),
        hintText: "00000-000",
      ),
    );
  }
    ElevatedButton btnConsultarCep() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
      ),
      onPressed: () async {
        setState(() {
          carregando = true;
          endereco = null;
          erro = null;
        });

        try {
          // Remove o traço antes de enviar para a API
          String cepConsulta = cep.replaceAll('-', '');

          Endereco data = await ConsultaCep.fetchCep(cepConsulta);

          setState(() {
            endereco = data;
            carregando = false;
          });
        } catch (e) {
          setState(() {
            erro = 'CEP não encontrado. Verifique e tente novamente.';
            carregando = false;
          });
        }
      },
      child: const Text(
        "Consultar",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget resultadoWidget() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (erro != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                erro!,
                style: TextStyle(
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (endereco != null) {
      final e = endereco!;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          border: Border.all(color: Colors.purple.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.purple.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Endereço encontrado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            _linhaInfo('CEP', e.cep),
            _linhaInfo('Logradouro', e.logradouro),
            _linhaInfo('Bairro', e.bairro),
            _linhaInfo('Cidade', e.localidade),
            _linhaInfo('Estado', e.uf),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
    Widget _linhaInfo(String label, String? valor) {
    if (valor == null || valor.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }
}
