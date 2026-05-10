class FaqItem {
  final String question;
  final String answer;
  bool isOpen;
  FaqItem({required this.question, required this.answer, this.isOpen = false});
}