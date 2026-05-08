import 'dart:async';
import 'package:campus_ai/features/home_feature/presentation/widgets/custom_home_app_bar.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/decoration_backgroung_stack_home_screen.dart';
import 'package:campus_ai/core/helper/search_text_field.dart';
import 'package:campus_ai/features/home_feature/presentation/widgets/welcome_section_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WelcomeAndSearchSection extends StatefulWidget {
  final Animation<double> blinkAnim;

  const WelcomeAndSearchSection({super.key, required this.blinkAnim});

  @override
  State<WelcomeAndSearchSection> createState() => _WelcomeAndSearchSectionState();
}

class _WelcomeAndSearchSectionState extends State<WelcomeAndSearchSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  List<Map<String, dynamic>> allServices = [];

  Future<void> fetchServices() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('services').get();

    allServices = snapshot.docs.map((doc) => doc.data()).toList();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        setState(() => results = []);
        return;
      }

      final lowerQuery = query.toLowerCase();

      final filtered = allServices.where((item) {
        final title = (item['title'] ?? '').toLowerCase();
        final subTitle = (item['subTitle'] ?? '').toLowerCase();

        return title.contains(lowerQuery) ||
            subTitle.contains(lowerQuery);
      }).toList();

      setState(() {
        results = filtered;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchServices();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
          colors: [Color(0xFF1B4FCC), Color(0xFF1338A8), Color(0xFF0D2680)],
        ),
      ),
      child: Stack(
        children: [
          const DecorationBackgroungStackHomeScreen(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHomeAppBar(blinkAnim: widget.blinkAnim),
                  const SizedBox(height: 20),
                  const WelcomeSectionHomeScreen(
                    tileName: 'Campus Guide',
                    subTitle: 'Sciences',
                    description:
                    'University of Ain Shams — Everything you need in one place',
                  ),
                  const SizedBox(height: 18),

                  SearchTextField(
                    controller: _searchController,
                    fillColor: Colors.transparent,
                    hintText: 'Search for places, services...',
                  ),

                  const SizedBox(height: 10),

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),

                  if (!isLoading && results.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final item = results[index];

                          return GestureDetector(
                            child: ListTile(
                              title: Text(
                                item['title'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
