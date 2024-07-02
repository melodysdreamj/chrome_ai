import 'package:chrome_ai/chrome_ai.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller =
      TextEditingController(text: "why sky is blue?");
  String _displayText = "This space is filled with text.";
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter some text',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final availability = await ChromeAI.canCreateTextSession();
                    if (availability == AIModelAvailability.no) {
                      // can not create text session
                    } else if (availability ==
                        AIModelAvailability.afterDownload) {
                      // need to download model
                    } else if (availability == AIModelAvailability.readily) {
                      // model is ready
                    }
                    setState(() {
                      _displayText = availability.toString();
                    });
                  },
                  child: const Text('can create text session?'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final session = await ChromeAI.createTextSession();
                    var result = await session.prompt(_controller.text);

                    setState(() {
                      _displayText = result;
                    });
                  },
                  child: const Text('generateText'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final session = await ChromeAI.createTextSession();
                    final stream = session.promptStreaming(_controller.text);

                    stream.listen((result) {
                      setState(() {
                        _displayText = result;
                      });
                    }).onError((e, stackTrace) {
                      setState(() {
                        _error = e.toString();
                      });
                    });
                  },
                  child: const Text('streamText'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _displayText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
