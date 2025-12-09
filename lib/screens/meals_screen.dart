import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<MealSummary> _items = [];
  List<MealSummary> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final meals = await ApiService.fetchMealsByCategory(widget.category);
      setState(() {
        _items = meals;
        _filtered = meals;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openRandom() async {
    if (_items.isEmpty) return;

    _items.shuffle();
    final randomMeal = _items.first;

    final detail = await ApiService.lookupMeal(randomMeal.idMeal);

    if (detail != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealDetail: detail),
        ),
      );
    }
  }

  void _search(String q) {
    final s = q.toLowerCase().trim();
    setState(() {
      _filtered = _items.where((m) => m.strMeal.toLowerCase().contains(s)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final green1 = const Color(0xFF2ECC71);
    final green2 = const Color(0xFF27AE60);

    return Scaffold(
      backgroundColor: const Color(0xFFF3FFF5),

      appBar: AppBar(
        backgroundColor: green2,
        elevation: 2,
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _openRandom,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: green1.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(
                  Icons.shuffle,
                  color: green2,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              cursorColor: green2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search meals in the category...',
                prefixIcon: const Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: green1, width: 1.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: green2, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _search,
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: green2,
              backgroundColor: Colors.white,
              onRefresh: _load,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final meal = _filtered[index];
                  return MealCard(
                    meal: meal,
                    onTap: () async {
                      final detail = await ApiService.lookupMeal(meal.idMeal);
                      if (detail != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(mealDetail: detail),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
