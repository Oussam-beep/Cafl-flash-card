if (deckName.isNotEmpty) {
  print("Deck Name: $deckName");

  int a = int.tryParse(questionCountController.text) ?? 0;

  if (a > 0) {
    Future(() async {
      for (int i = 0; i < a; i++) {
        await generateCardsUsingAi(deckName);
        setState(() {}); // Refresh UI after each question is generated
      }
    });
  }

  Navigator.pop(context);
}