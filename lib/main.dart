
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown_fade/text_element.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:simple_html_css/simple_html_css.dart';

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
  String? currentFragment;
  final inlineSpans = <InlineSpan>[];
  final newFragments = <InlineSpan>[];

  void _addMarkdown(BuildContext context) {
    _currentMarkdown ??= '';
    setState(() {
      currentFragment = markdownCunks[_markdownIndex];

      final htmlCode = md.markdownToHtml(currentFragment!);

      final listNodes =HTML.toTextSpan(context, htmlCode);

      newFragments.addAll([listNodes, TextSpan(text: ' ')]);

      _markdownIndex++;
    });
  }

  Future<void> updateMarkdown() async {
    if (currentFragment == null) {
      return;
    }
    setState(() {
      if (_currentMarkdown == null) {
        _currentMarkdown = currentFragment!;
      } else {
        _currentMarkdown = _currentMarkdown! + currentFragment!;
      }
      inlineSpans.addAll(newFragments);
      currentFragment = null;
      newFragments.clear();
    });
  }

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
              // MarkdownBody(data: markdownCunks.join('')),
              Text.rich(
                TextSpan(
                  children: [
                    ...inlineSpans.map((e) => e),
                    if (newFragments.isNotEmpty)
                      ...newFragments.map((e) => WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: TextElement(
                            key: Key(_markdownIndex.toString()),
                            textToShow: "hi",
                            inlineSpans: e,
                            onEnd: updateMarkdown,
                          ))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: ()=>_addMarkdown(context),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        }
      ),
    );
  }
}

List<InlineSpan> convertMarkdownToInlineSpans(String text,
    {bool preserveSoftLineBreaks = false}) {
  final List<md.Node> nodes = md.Document().parse(text);
  return _parseNodes(nodes, preserveSoftLineBreaks);
}

List<InlineSpan> _parseNodes(List<md.Node> nodes, bool preserveSoftLineBreaks) {
  final List<InlineSpan> spans = [];

  for (final node in nodes) {
    if (node is md.Text) {
      spans.addAll(_handleTextNode(node, preserveSoftLineBreaks));
    } else if (node is md.Element) {
      spans.addAll(_parseElement(node, preserveSoftLineBreaks));
    }
  }

  return spans;
}

List<InlineSpan> _handleTextNode(md.Text node, bool preserveSoftLineBreaks) {
  if (preserveSoftLineBreaks) {
    return [TextSpan(text: node.text)];
  } else {
    // Remove soft line breaks (spaces at end of lines and leading spaces)
    final String trimmedText = node.text.replaceAll(RegExp(r' ?\n *'), ' ');
    return [TextSpan(text: trimmedText)];
  }
}

List<InlineSpan> _parseElement(
    md.Element element, bool preserveSoftLineBreaks) {
  final List<InlineSpan> spans = [];

  switch (element.tag) {
    case 'strong':
      spans.add(TextSpan(
        children: _parseNodes(element.children!, preserveSoftLineBreaks),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      break;
    case 'em':
      spans.add(TextSpan(
        children: _parseNodes(element.children!, preserveSoftLineBreaks),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
      break;
    case 'a':
      spans.add(TextSpan(
        children: _parseNodes(element.children!, preserveSoftLineBreaks),
        style: const TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Handle link tap
            print('Link tapped: ${element.attributes['href']}');
          },
      ));
      break;
    case 'br':
      spans.add(const TextSpan(text: '\n'));
      break;
    case 'p':
    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
    case 'li':
      // For block-level elements, add a newline after parsing their children
      spans.addAll(_parseNodes(element.children!, preserveSoftLineBreaks));
      spans.add(const TextSpan(text: '\n'));
      break;
    default:
      // For other elements, just parse their children
      spans.addAll(_parseNodes(element.children!, preserveSoftLineBreaks));
  }

  return spans;
}

List<InlineSpan> markdownToTextSpans(String markdownText) {
  final List<InlineSpan> spans = [];
  final List<md.Node> nodes = md.Document().parse(markdownText);

  for (final node in nodes) {
    if (node is md.Text) {
      final List<String> lines = node.text.split('\n');
      for (int i = 0; i < lines.length; i++) {
        spans.add(TextSpan(text: lines[i]));
        if (i < lines.length - 1) {
          spans.add(WidgetSpan(child: const SizedBox(height: 12.0))); // Line break
        }
      }
    } else if (node is md.Element) {
      switch (node.tag) {
        case 'p':
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          final List<String> lines = node.textContent.split('\n');
          for (int i = 0; i < lines.length; i++) {
            spans.add(TextSpan(text: lines[i]));
            if (i < lines.length - 1) {
              spans.add(WidgetSpan(child: const SizedBox(height: 12.0))); // Line break
            }
          }
          spans.add(WidgetSpan(child: const SizedBox(height: 12.0))); // Extra line break after block elements
          break;
        case 'br':
          spans.add(WidgetSpan(child: const SizedBox(height: 12.0))); // Line break
          break;
        default:
          spans.add(TextSpan(text: node.textContent));
          break;
      }
    }
  }

  return spans;
}