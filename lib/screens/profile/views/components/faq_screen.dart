import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'How do I track my order?',
      answer:
          'You can track your order by going to the Orders section and tapping on "Track".',
    ),
    FAQItem(
      question: 'What is the return policy?',
      answer:
          'Returns are accepted within 7 days of delivery. Make sure the product is unused and in original packaging.',
    ),
    FAQItem(
      question: 'How can I contact customer service?',
      answer:
          'You can contact customer service through the Help Center or via chat support in the app.',
    ),
    FAQItem(
      question: 'How do I change my shipping address?',
      answer:
          'Go to your Profile > Addresses and edit your default shipping address before placing a new order.',
    ),
    // Add more FAQ items here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return FAQAccordion(item: faqItems[index]);
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  FAQItem({required this.question, required this.answer});
}

class FAQAccordion extends StatefulWidget {
  final FAQItem item;
  const FAQAccordion({super.key, required this.item});

  @override
  State<FAQAccordion> createState() => _FAQAccordionState();
}

class _FAQAccordionState extends State<FAQAccordion>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Optional: Animate expand/collapse arrow rotation
  late final AnimationController _controller;
  late final Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _arrowAnimation =
        Tween(begin: 0.0, end: 0.5).animate(_controller); // 0.5 = 180deg
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _arrowAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: Container(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.item.answer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 200),
              )
            ],
          ),
        ),
      ),
    );
  }
}
