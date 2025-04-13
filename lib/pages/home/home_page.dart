// pages/home/home_page.dart
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
        title: const Text('Notas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: homeProvider.notas.length,
              itemBuilder: (context, index) {
                final nota = homeProvider.notas[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                Text('#'),
                                SizedBox(
                                  width: 4.0,
                                ),
                                Text(
                                  nota.id.toString(),
                                ),
                              ],
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 16.0,
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                Text(nota.dataBr),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('código:'),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text(nota.codigo),
                          ],
                        ),
                        Row(
                          children: [
                            Text('url:'),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text(nota.url),
                          ],
                        ),
                        Row(
                          children: [
                            Text('status'),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text('NFC-e'),
                          ],
                        ),
                        // ListTile(
                        //   title: Text(test.id.toString()),
                        //   subtitle: Text(test.toString()),
                        //   trailing: IconButton(
                        //     icon: const Icon(Icons.delete),
                        //     onPressed: () async {
                        //       await homeProvider.removeTest(
                        //         context: context,
                        //         index: index,
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // if (_textController.text.isNotEmpty) {
          //   homeProvider.addTest(_textController.text);
          //   _textController.clear();
          // }
          Navigator.pushReplacementNamed(context, '/camera');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
