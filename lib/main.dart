import 'dart:convert'; // For decoding the file content
import 'package:flutter/material.dart'; // For Flutter UI components
import 'package:flutter/services.dart'; // For rootBundle to load assets

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Frequency Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Solution(),
    );
  }
}

class Solution extends StatefulWidget {
  @override
  _SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  List<String> output = [];
  bool isProcessing = false;

  // Step 1: Load the file content from assets
  void loadFileFromAssets() async {
    setState(() {
      isProcessing = true; // Show a loading state
    });
    try {
      // Load the file content from the assets
      String fileContent = await rootBundle.loadString('assets/file.txt');

      // Analyze the file content
      analyzeFile(fileContent);
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      print("Error loading the file from assets: $e");
    }
  }

  // Step 2: Analyze each line to find highest frequency words
  void analyzeFile(String fileContent) {
    final lines = LineSplitter.split(fileContent);
    List<List<String>> highestWordsPerLine = [];
    List<int> wordFrequencyPerLine = [];

    // Loop through each line to analyze word frequencies
    for (var line in lines) {
      final words = line.toLowerCase().split(RegExp(r'\s+'));
      final wordCount = <String, int>{};

      // Count the occurrences of each word
      for (var word in words) {
        if (word.isEmpty) continue;
        wordCount[word] = (wordCount[word] ?? 0) + 1;
      }

      // Find the maximum frequency in this line
      final maxFreq =
          wordCount.values.isEmpty
              ? 0
              : wordCount.values.reduce((a, b) => a > b ? a : b);
      final mostFrequentWords =
          wordCount.entries
              .where((entry) => entry.value == maxFreq)
              .map((entry) => entry.key)
              .toList();

      // Store results for the line
      highestWordsPerLine.add(mostFrequentWords);
      wordFrequencyPerLine.add(maxFreq);
    }

    // Calculate the line with the highest frequency across all lines
    calculateLineWithHighestFrequency(wordFrequencyPerLine);
    // Print the results
    printHighestWordFrequencyAcrossLines(
      highestWordsPerLine,
      wordFrequencyPerLine,
    );
  }

  // Step 3: Find the maximum frequency across all lines
  void calculateLineWithHighestFrequency(List<int> wordFrequencyPerLine) {
    if (wordFrequencyPerLine.isEmpty) return;

    int maxFrequency = wordFrequencyPerLine.reduce((a, b) => a > b ? a : b);
    print("Maximum frequency across all lines: $maxFrequency");
  }

  // Step 4: Print lines with highest-frequency word(s)
  void printHighestWordFrequencyAcrossLines(
    List<List<String>> highestWordsPerLine,
    List<int> wordFrequencyPerLine,
  ) {
    List<String> result = [];
    for (int i = 0; i < wordFrequencyPerLine.length; i++) {
      result.add('${highestWordsPerLine[i]} (appears in line ${i + 1})');
    }

    // Update the UI with the result
    setState(() {
      isProcessing = false; // Hide loading state
      output = result; // Update the output list to display
    });
  }

  @override
  void initState() {
    super.initState();
    loadFileFromAssets(); // Automatically load file on app startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Word Frequency Analyzer')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:
            isProcessing
                ? Center(
                  child: CircularProgressIndicator(),
                ) // Show loading indicator
                : ListView.builder(
                  itemCount: output.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(output[index]));
                  },
                ),
      ),
    );
  }
}
