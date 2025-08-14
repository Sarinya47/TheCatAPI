import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';

class Dog {
  final String breedName;
  final String temperament;
  final List<String> images;
  final String coat;
  final String care;

  Dog({
    required this.breedName,
    required this.temperament,
    required this.images,
    required this.coat,
    required this.care,
  });
}

class DogService {
  static const Map<String, String> breedTemperament = {
    'Hound': 'ขี้เล่น ฉลาด กระตือรือร้น',
    'Bulldog': 'ขี้เล่น สุภาพ อดทน',
    'Retriever': 'ฉลาด รักสังคม ซื่อสัตย์',
    'Poodle': 'ฉลาด กระตือรือร้น ขี้เล่น',
    'Terrier': 'ขี้เล่น กล้าหาญ กระตือรือร้น',
    'Sheepdog': 'ซื่อสัตย์ อดทน ใจดี',
    'Spaniel': 'ขี้เล่น รักสังคม อ่อนโยน',
    'Boxer': 'ขี้เล่น พลังเยอะ ซื่อสัตย์',
    'Chihuahua': 'ฉลาด ขี้เล่น รักเจ้าของ',
    'Dachshund': 'ฉลาด ร่าเริง กล้าหาญ',
  };

  static const Map<String, Map<String, String>> breedDetails = {
    'Hound': {'coat': 'ขนสั้น-ยาว', 'care': 'แปรงขนสัปดาห์ละ 2-3 ครั้ง'},
    'Bulldog': {'coat': 'ขนสั้น', 'care': 'เช็ดตัวบ่อย ๆ เพื่อหลีกเลี่ยงเชื้อรา'},
    'Retriever': {'coat': 'ขนยาวปานกลาง', 'care': 'แปรงขนสัปดาห์ละ 3 ครั้ง'},
    'Poodle': {'coat': 'ขนหยิก', 'care': 'ตัดขนทุก 6-8 สัปดาห์'},
    'Terrier': {'coat': 'ขนสั้น-หยาบ', 'care': 'แปรงขนสัปดาห์ละ 1-2 ครั้ง'},
    'Sheepdog': {'coat': 'ขนยาวหนา', 'care': 'แปรงขนทุกวัน'},
    'Spaniel': {'coat': 'ขนกลาง', 'care': 'แปรงขน 2-3 ครั้ง/สัปดาห์'},
    'Boxer': {'coat': 'ขนสั้น', 'care': 'อาบน้ำตามความเหมาะสม'},
    'Chihuahua': {'coat': 'ขนสั้น/ยาว', 'care': 'แปรงขนสัปดาห์ละ 2 ครั้ง'},
    'Dachshund': {'coat': 'ขนสั้น/ยาว/หยิก', 'care': 'แปรงขนสัปดาห์ละ 2-3 ครั้ง'},
  };

  static String getTemperament(String breedName) {
    return breedTemperament[breedName] ?? 'ขี้เล่น ซื่อสัตย์ กระตือรือร้น';
  }

  static String normalizeBreed(String raw) {
    raw = raw.toLowerCase();
    if (raw.contains('hound')) return 'Hound';
    if (raw.contains('bulldog')) return 'Bulldog';
    if (raw.contains('retriever')) return 'Retriever';
    if (raw.contains('poodle')) return 'Poodle';
    if (raw.contains('terrier')) return 'Terrier';
    if (raw.contains('sheepdog')) return 'Sheepdog';
    if (raw.contains('spaniel')) return 'Spaniel';
    if (raw.contains('boxer')) return 'Boxer';
    if (raw.contains('chihuahua')) return 'Chihuahua';
    if (raw.contains('dachshund')) return 'Dachshund';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  static Future<List<Dog>> fetchDogs() async {
    final url = Uri.parse('https://dog.ceo/api/breeds/image/random/50');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List images = data['message'];

      Map<String, List<String>> breedImages = {};
      for (var imgUrl in images) {
        final parts = imgUrl.split('/');
        if (parts.length <= 4) continue;
        String breedName = normalizeBreed(parts[4]);
        breedImages.putIfAbsent(breedName, () => []);
        breedImages[breedName]!.add(imgUrl);
      }

      return breedImages.entries.map((e) {
        final coat = breedDetails[e.key]?['coat'] ?? 'ไม่ระบุ';
        final care = breedDetails[e.key]?['care'] ?? 'ไม่ระบุ';
        return Dog(
          breedName: e.key,
          temperament: getTemperament(e.key),
          images: e.value,
          coat: coat,
          care: care,
        );
      }).toList();
    } else {
      throw Exception('Failed to load dogs');
    }
  }
}

Color temperamentColor(String temperament) {
  if (temperament.contains('ขี้เล่น')) return Colors.yellow.shade100;
  if (temperament.contains('ซื่อสัตย์')) return Colors.blue.shade100;
  if (temperament.contains('ฉลาด')) return Colors.green.shade100;
  return Colors.grey.shade100;
}

void main() {
  runApp(const DogScreen());
}

class DogScreen extends StatefulWidget {
  const DogScreen({super.key});

  @override
  State<DogScreen> createState() => _DogScreenState();
}

class _DogScreenState extends State<DogScreen> {
  List<Dog> allDogs = [];
  List<Dog> filteredDogs = [];
  Set<String> favorites = {};
  bool isLoading = true;
  bool isDarkMode = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadDogs();
    loadFavorites();
  }

  Future<void> loadDogs() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final dogs = await DogService.fetchDogs();
      setState(() {
        allDogs = dogs;
        filteredDogs = dogs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = 'ไม่สามารถโหลดข้อมูลได้';
      });
    }
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> toggleFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(breedName)) {
        favorites.remove(breedName);
      } else {
        favorites.add(breedName);
      }
      prefs.setStringList('favorites', favorites.toList());
    });
  }

  void filterDogs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredDogs = allDogs.where((dog) {
        return dog.breedName.toLowerCase().contains(lowerQuery) ||
            dog.temperament.toLowerCase().contains(lowerQuery) ||
            dog.coat.toLowerCase().contains(lowerQuery) ||
            dog.care.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('สายพันธุ์สุนัข'),
          centerTitle: true,
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: () {
                setState(() => isDarkMode = !isDarkMode);
              },
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg != null
                ? Center(child: Text(errorMsg!))
                : RefreshIndicator(
                    onRefresh: loadDogs,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'ค้นหาสายพันธุ์...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: filterDogs,
                          ),
                        ),
                        Expanded(
                          child: filteredDogs.isEmpty
                              ? const Center(child: Text('ไม่พบสายพันธุ์'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: filteredDogs.length,
                                  itemBuilder: (context, index) {
                                    final dog = filteredDogs[index];
                                    final isFav = favorites.contains(dog.breedName);
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DogDetailScreen(
                                              dog: dog,
                                              isFavorite: isFav,
                                              onFavoriteToggle: () => toggleFavorite(dog.breedName),
                                            ),
                                          ),
                                        );
                                      },
                                      child: DogCard(
                                        dog: dog,
                                        isFavorite: isFav,
                                        onFavoriteToggle: () => toggleFavorite(dog.breedName),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class DogCard extends StatelessWidget {
  final Dog dog;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const DogCard({super.key, required this.dog, required this.isFavorite, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    final temperamentList = dog.temperament.split(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [temperamentColor(dog.temperament), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: dog.images.first,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/loading.gif',
                  image: dog.images.first,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.grey[300]),
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.pets, size: 20, color: Colors.teal),
                            const SizedBox(width: 6),
                            Text(dog.breedName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: temperamentList
                              .map((t) => Chip(
                                    label: Text(t, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: Colors.teal.shade100,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 6),
                        Text('ลักษณะขน: ${dog.coat}'),
                        Text('การดูแล: ${dog.care}'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DogDetailScreen extends StatefulWidget {
  final Dog dog;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const DogDetailScreen({super.key, required this.dog, required this.isFavorite, required this.onFavoriteToggle});

  @override
  State<DogDetailScreen> createState() => _DogDetailScreenState();
}

class _DogDetailScreenState extends State<DogDetailScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final temperamentList = widget.dog.temperament.split(' ');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dog.breedName),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: widget.onFavoriteToggle,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.dog.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: widget.dog.images[index],
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/loading.gif',
                        image: widget.dog.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.grey[300]),
                            ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.dog.images.length,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 8,
                      activeDotColor: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.dog.breedName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  alignment: WrapAlignment.center,
                  children: temperamentList
                      .map((t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 14)),
                            backgroundColor: Colors.teal.shade100,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text('ลักษณะขน: ${widget.dog.coat}'),
                Text('การดูแล: ${widget.dog.care}'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
