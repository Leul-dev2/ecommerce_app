import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';

class SizeGuideScreen extends StatelessWidget {
  const SizeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Size Guide",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey.shade300),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                children: [
                  _buildHeaderRow(),
                  _buildRow("S", "34-36", "28-30"),
                  _buildRow("M", "38-40", "32-34"),
                  _buildRow("L", "42-44", "36-38"),
                  _buildRow("XL", "46-48", "40-42"),
                  _buildRow("XXL", "50-52", "44-46"),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("Close", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
      children: [
        _buildCell("Size", isHeader: true),
        _buildCell("Chest (in)", isHeader: true),
        _buildCell("Waist (in)", isHeader: true),
      ],
    );
  }

  TableRow _buildRow(String size, String chest, String waist) {
    return TableRow(
      children: [
        _buildCell(size),
        _buildCell(chest),
        _buildCell(waist),
      ],
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}
