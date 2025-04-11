import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Testes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do teste',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      homeProvider.addTest(_textController.text);
                      _textController.clear(); // Limpa o campo de texto
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: homeProvider.tests.length,
              itemBuilder: (context, index) {
                final test = homeProvider.tests[index];
                return ListTile(
                  title: Text(test.url), // Exibe o campo relevante do modelo
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      homeProvider.removeTest(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
