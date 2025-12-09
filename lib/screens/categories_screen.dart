import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'meals_screen.dart';
import 'meal_detail_screen.dart';
import 'favorites_screen.dart'; // import the favorites screen

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> _future;
  List<Category> _all = [];
  List<Category> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _future = ApiService.fetchCategories();
    _future.then((value) {
      setState(() {
        _all = value;
        _filtered = value;
        _loading = false;
      });
    }).catchError((e) {
      setState(() => _loading = false);
    });
  }

  void _search(String q) {
    final s = q.toLowerCase().trim();
    setState(() {
      _filtered = _all.where((c) => c.strCategory.toLowerCase().contains(s)).toList();
    });
  }

  void _openRandom() async {
    final meal = await ApiService.randomMeal();
    if (meal != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailScreen(mealDetail: meal)),
      );
    }
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
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                child: const Icon(
                  Icons.shuffle,
                  color: Color(0xFF27AE60),
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
                hintText: 'Search categories...',
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
              onRefresh: () async {
                final fresh = await ApiService.fetchCategories();
                setState(() {
                  _all = fresh;
                  _filtered = fresh;
                });
              },
              child: ListView.builder(
                itemCount: _filtered.length + 1, // +1 for Favorites
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Favorites card at top
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Card(
                        color: Colors.amber[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.favorite, color: Colors.red),
                          title: const Text(
                            "Favorites",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FavoritesScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  final cat = _filtered[index - 1]; // adjust for favorites
                  return CategoryCard(
                    category: cat,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealsScreen(category: cat.strCategory),
                        ),
                      );
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
