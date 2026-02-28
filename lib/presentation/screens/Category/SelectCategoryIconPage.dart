import 'package:flutter/material.dart';

class SelectCategoryIconPage extends StatelessWidget {
  final int? selectedIconId;

  const SelectCategoryIconPage({
    super.key,
    this.selectedIconId,
  });

  String _iconPath(int id) => 'lib/assets/category_icon/$id.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn biểu tượng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 55,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final iconId = index + 1;
          final isSelected = selectedIconId == iconId;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context, iconId),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                _iconPath(iconId),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
