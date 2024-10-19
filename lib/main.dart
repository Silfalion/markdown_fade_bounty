import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_fade/text_element.dart';

const markdownCunks = [
  '''
### Problem

We’re building an LLM based tool for one of our FilledStacks clients. 
  ''',
  '''
As with ChatGPT, the response from the LLM is streamed back to us.
  ''',
  '''
The text comes back as it 
  ''',
  '''
is being completed. 
  ''',
  '''
Here’s an example of how
  ''',
  '''
paragraph would be returned:
  ''',
  '''
**The full paragraph**

“I need every new
  ''',
  '''
word being added to the text to animate i
  ''',
  '''
n using a fade functionality. This an
  ''',
  '''
example of this can be seen when using Gemini chat.”
  ''',
  '''
**How it’s returned**

“I need”
  ''',
  '''
“I need every new word”
  ''',
  '''
“I need every new word
  ''',
  '''
being added to”
  ''',
  '''
“I need every new word being
  ''',
  '''
added to the text”
  ''',
  '''
“I need every new word being added to the text to animate in”
  ''',
];

const defaultMessage = 'Tap FAB to add markdown';

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
  String? _currentMarkdown;
  int _markdownIndex = 0;
  List<String> currentTextFragments = [];
  String previousChunk = '';
  List<String> previousGFragments = [];
  String newAddedText = '';

  void _addMarkdown(BuildContext context) {
    if (_markdownIndex >= markdownCunks.length) {
      return;
    }
    _currentMarkdown ??= '';
    setState(() {
      if (currentTextFragments.isNotEmpty) {
        previousChunk = currentTextFragments.join('');
        previousGFragments = [...currentTextFragments];
      }
      currentTextFragments = markdownCunks.sublist(0, _markdownIndex);

      _markdownIndex++;
    });
  }

  List<String> get diffFragments {
    if(previousGFragments.isEmpty) {
      return [];
    }
    return currentTextFragments.sublist(
      previousGFragments.length - 1, currentTextFragments.length);
  }

  SomeKindOfController controller = SomeKindOfController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              MarkdownBody(
                data: markdownCunks.join(''),
              ),
              MarkdownBody(
                key: ValueKey(currentTextFragments.join('')),
                data: currentTextFragments.join(''),
                customMarkdownBuilderConfiguration:
                    CustomMarkdownBuilderConfiguration(
                  onElementParsed: (element, index) {
                    if (index == controller.index) {
                      controller.index++;
                    }
                  },
                  customBuilder: (element, child, index) {
                    if (previousChunk.lastIndexOf(diffFragments.join('')) !=
                        currentTextFragments
                            .join('')
                            .lastIndexOf(diffFragments.join(''))) {
                      return TextElement(
                        textToShow: 'hi',
                        onEnd: () {},
                        child: child,
                      );
                    }
                    return child;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () => _addMarkdown(context),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}

class SomeKindOfController {
  int index = 0;
}
