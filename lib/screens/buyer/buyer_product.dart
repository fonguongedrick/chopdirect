import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chopdirect/screens/buyer/deliveryDetails.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math' as math;

// Main App
class ChopDirectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChopDirect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
      ),
      home: BuyerProductsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final List<String> specialties;
  final String farmerId;
  final String imageUrl;
  int quantity;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.farmerId,
    required this.imageUrl,
    this.quantity = 1,
    this.specialties = const [],
  });
}

// Cart Manager
class CartManager extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _currentFarmerId;
  
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get subtotal => totalPrice; // Define subtotal as an alias for totalPrice
  String? get currentFarmerId => _currentFarmerId;
  
  bool canAddItem(String farmerId) {
    return _currentFarmerId == null || _currentFarmerId == farmerId;
  }
  
  void addItem(Map<String, dynamic> product) {
    final farmerId = product['farmerId'] ?? '';
    
    if (!canAddItem(farmerId)) {
      throw Exception('Cannot add items from different farmers');
    }
    
    _currentFarmerId = farmerId;
    
    final existingIndex = _items.indexWhere((item) => item.id == product['id']);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: product['id'] ?? '',
        name: product['name'] ?? '',
        price: (product['price'] ?? 0).toDouble(),
        farmerId: farmerId,
        imageUrl: product['imageUrl'] ?? '',
      ));
    }
    
    notifyListeners();
  }
  
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    if (_items.isEmpty) {
      _currentFarmerId = null;
    }
    notifyListeners();
  }
  
  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(id);
      } else {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }
  
  void clearCart() {
    _items.clear();
    _currentFarmerId = null;
    notifyListeners();
  }
}

// Farmer Model
class Farmer {
  final String id;
  final String name;
  final String location;
  final String image;
  final List<String> specialties;
  final double rating;
  final String distance;
  
  Farmer({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.specialties,
    required this.rating,
    required this.distance,
  });

  static Farmer fromMap(Map<String, dynamic> data) {
    return Farmer(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      image: data['image'] ?? '',
      specialties: List<String>.from(data['productTypes'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      distance: data['distance'] ?? '',
    );
  }
}
 
// Product Stream
Stream<List<Map<String, dynamic>>> fetchProducts() {
  return FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList());
}
Stream<List<Farmer>> fetchFarmers() {
  return FirebaseFirestore.instance
      .collection('users_chopdirect')
      .where('role', isEqualTo: 'farmer')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Farmer.fromMap(data);
          }).toList());
}
Stream<List<Product>> _fetchFarmerProducts(String farmerId) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }


// 3. Add these model classes if you don't have them


class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String farmerId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.farmerId,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      farmerId: data['farmerId'] ?? '',
    );
  }
}
// Main Screen
class BuyerProductsScreen extends StatefulWidget {
  const BuyerProductsScreen({super.key});

  @override
  State<BuyerProductsScreen> createState() => _BuyerProductsScreenState();
}

class _BuyerProductsScreenState extends State<BuyerProductsScreen>
    with TickerProviderStateMixin {
  final CartManager _cartManager = CartManager();
  final TextEditingController _searchController = TextEditingController();
  final PageController _featuredPageController = PageController();
  
  String _searchQuery = "";
  
  bool _isSearchExpanded = false;
  bool _showRewardPopup = false;
  int _userLevel = 3;
  double _experiencePoints = 85.0;
  int _streakDays = 7;
  int _totalPurchases = 24;
  
  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _cartBounceController;
  late AnimationController _floatingParticlesController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  
  // Animations
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _searchScaleAnimation;
  late Animation<double> _cartBounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample farmers data
  final List<Farmer> _farmers = [
    Farmer(
      id: 'farmer1',
      name: 'Njoh Farm',
      location: 'Bafoussam West',
      image: '🌾',
      specialties: ['Tomatoes', 'Peppers', 'Onions'],
      rating: 4.8,
      distance: '2.5 km',
    ),
    Farmer(
      id: 'farmer2',
      name: 'Mbu Organic Farm',
      location: 'Bafoussam Center',
      image: '🍌',
      specialties: ['Bananas', 'Plantains', 'Avocados'],
      rating: 4.9,
      distance: '3.1 km',
    ),
    Farmer(
      id: 'farmer3',
      name: 'Ndi Fresh Farm',
      location: 'Bafoussam East',
      image: '🌽',
      specialties: ['Beans', 'Maize', 'Carrots'],
      rating: 4.7,
      distance: '5.2 km',
    ),
    Farmer(
      id: 'farmer4',
      name: 'Green Valley Farm',
      location: 'Bafoussam North',
      image: '🥬',
      specialties: ['Lettuce', 'Cabbage', 'Spinach'],
      rating: 4.6,
      distance: '4.8 km',
    ),
  ];
   String _userName = "Guest";
bool _isLoadingUser = true;

// Add this method to fetch user data
Future<void> _fetchUserName() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  debugPrint("Current User: ${currentUser?.uid ?? 'No user logged in'}");
  if (currentUser == null) {
    setState(() {
      _userName = "Guest";
      _isLoadingUser = false;
    });
    return;
  }

  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users_chopdirect')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _userName = userDoc['role'] ?? "Farmer Friend";
        _isLoadingUser = false;
      });
    } else {
      setState(() {
        _userName = "Farmer Friend";
        _isLoadingUser = false;
      });
    }
  } catch (e) {
    setState(() {
      _userName = "Farmer Friend";
      _isLoadingUser = false;
    });
    print("Error fetching user data: $e");
  }
}

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _cartManager.addListener(_onCartChanged);
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerSlideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.elasticOut),
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _searchAnimationController, curve: Curves.elasticOut),
    );

    _cartBounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cartBounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _cartBounceController, curve: Curves.elasticOut),
    );

    _floatingParticlesController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(1, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _headerAnimationController.forward();
    _searchAnimationController.forward();
  }

  void _loadUserData() async {
    // Simulate loading user data
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _userName = currentUser.displayName ?? currentUser.email?.split('@')[0] ?? "Farmer Friend";
      });
    }
  }

  void _onCartChanged() {
    setState(() {});
    _cartBounceController.forward().then((_) {
      _cartBounceController.reverse();
    });
    HapticFeedback.lightImpact();
    
    if (_cartManager.itemCount > 0 && _cartManager.itemCount % 3 == 0) {
      _showRewardAnimation();
    }
  }

  void _showRewardAnimation() {
    setState(() {
      _showRewardPopup = true;
      _experiencePoints += 10;
      if (_experiencePoints >= 100) {
        _experiencePoints = 0;
        _userLevel++;
      }
    });
    
    HapticFeedback.heavyImpact();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showRewardPopup = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> _filterProducts(
      List<Map<String, dynamic>> products, String query) {
    if (query.isEmpty) return products;
    return products.where((product) {
      final prodName = (product["name"] ?? "").toString().toLowerCase();
      final farmerName = (product["farmerId"] ?? "").toString().toLowerCase();
      return prodName.contains(query.toLowerCase()) || 
             farmerName.contains(query.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    _cartBounceController.dispose();
    _floatingParticlesController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    ();
   _fetchUserName();
   fetchFarmers();
  
    _cartManager.dispose();
    _featuredPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          SafeArea(
            child: Column(
              children: [
                _buildGamefiedAppBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
          if (_showRewardPopup) _buildRewardPopup(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingParticlesController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF4CAF50), const Color(0xFF8BC34A),
                    _floatingParticlesController.value)!,
                Color.lerp(const Color(0xFF4CAF50), const Color(0xFF8BC34A),
                    _floatingParticlesController.value)!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingParticlesController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final offset = _floatingParticlesController.value * 2 * math.pi;
            final x = 30 + index * 50 + 40 * math.sin(offset + index);
            final y = 80 + index * 100 + 30 * math.cos(offset + index * 0.7);
            
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 6 + (index % 4) * 3,
                height: 6 + (index % 4) * 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildGamefiedAppBar() {
    return AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.green.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeaderRow(),
                const SizedBox(height: 20),
                _buildUserProgressBar(),
                const SizedBox(height: 20),
                _buildAnimatedSearchBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, $_userName! 👋",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                      ).createShader(bounds),
                      child: const Text(
                        "CHOPDIRECT",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                "Fresh • Fast • Direct 🌱",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildGamefiedCart(),
      ],
    );
  }

  Widget _buildGamefiedCart() {
    return AnimatedBuilder(
      animation: _cartBounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cartBounceAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showCartBottomSheet();
            },
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  if (_cartManager.itemCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _cartManager.itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProgressBar() {
  return GestureDetector(
    onTap: () {
      // Add interaction feedback
      HapticFeedback.lightImpact();
      // You could add a dialog showing level details here
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
      decoration: BoxDecoration(
        // 
        color: Colors.white.withOpacity(0.9), // Slightly more opaque
        borderRadius: BorderRadius.circular(20), // Slightly smaller radius
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.4), // More visible border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level Badge with pulse animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LV $_userLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Slightly smaller font
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: 16,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Progress section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_experiencePoints.toInt()} / 100 XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_streakDays day streak',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.orange,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Animated progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutQuint,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: _experiencePoints / 100,
                      backgroundColor: Colors.green[100],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                
                // Progress percentage (optional)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(_experiencePoints / 100 * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAnimatedSearchBar() {
  return AnimatedBuilder(
    animation: _searchScaleAnimation,
    builder: (context, child) {
      return Transform.scale(
        scale: _searchScaleAnimation.value,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
            });
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced padding
            height: 48, // Fixed height
            decoration: BoxDecoration(
              color: _isSearchExpanded ? Colors.white : Colors.grey[50],
              borderRadius: BorderRadius.circular(24), // Slightly smaller radius
              border: Border.all(
                color: _isSearchExpanded 
                    ? const Color(0xFF4CAF50) 
                    : Colors.transparent,
                width: 1.5, // Slightly thinner border
              ),
              boxShadow: _isSearchExpanded ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ] : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  color: _isSearchExpanded 
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[600],
                  size: 20, // Smaller icon
                ),
                const SizedBox(width: 10), // Reduced spacing
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      isDense: true, // Reduces the internal padding
                      hintText: 'Search products...', // Shorter hint
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13, // Smaller font
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8), // Adjusted padding
                    ),
                    style: const TextStyle(
                      fontSize: 13, // Smaller font
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isSearchExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.tune_rounded,
                    color: _isSearchExpanded 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey[600],
                    size: 18, // Smaller icon
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 25),
            _buildSectionHeader('🌟 Featured Products', Icons.star_rounded, Colors.orange),
            _buildFeaturedProductsSlider(),
            const SizedBox(height: 35),
            _buildSectionHeader('🚜 Our Farmers', Icons.agriculture_rounded, const Color(0xFF4CAF50)),
            _buildFarmersSection(),
            const SizedBox(height: 35),
            _buildSectionHeader('🛒 All Products', Icons.grid_view_rounded, Colors.blue),
            _buildAllProducts(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'View All',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildFeaturedProductsSlider() {
  return StreamBuilder<List<Map<String, dynamic>>>(
    stream: fetchProducts(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox(
          height: 280,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4CAF50),
            ),
          ),
        );
      }
     
      List<Map<String, dynamic>> products = snapshot.data!;
      products = _filterProducts(products, _searchQuery);
      
      if (products.isEmpty) {
        return const SizedBox(
          height: 280,
          child: Center(
            child: Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }
      
      return Column(
        children: [
          SizedBox(
            height: 280,
            child: CarouselSlider.builder(
              itemCount: products.length,
              options: CarouselOptions(
                height: 280,
                aspectRatio: 16/9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.2,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  // Optional: Handle page change
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return _buildProductCard(products[index], index);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: products.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.green).withOpacity(
                          _currentCarouselIndex == entry.key ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}

// Add this to your state class
int _currentCarouselIndex = 0;
final CarouselController _carouselController = CarouselController();

// Update your _buildProductCard to maintain all existing functionality
Widget _buildProductCard(Map<String, dynamic> product, int index) {
  final canAddToCart = _cartManager.canAddItem(product['farmerId'] ?? '');
  final farmerId = product['farmerId'] ?? '';
  
  return AnimatedContainer(
    duration: Duration(milliseconds: 300 + (index * 100)),
    margin: const EdgeInsets.symmetric(horizontal: 5),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image - Keep your existing image implementation
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.3),
                  const Color(0xFF8BC34A).withOpacity(0.3),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.network(
                    product['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 140,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          (product['ratings']?.toDouble() ?? 4.5)
                              .toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Product Info - Keep your existing info implementation
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Fresh Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  ' ${product['description'] ?? 'Local Farmer'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product['price'] ?? 0} XAF',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (canAddToCart) {
                          try {
                            _cartManager.addItem(product);
                            HapticFeedback.lightImpact();
                          } catch (e) {
                            _showFarmerRestrictionDialog();
                          }
                        } else {
                          _showFarmerRestrictionDialog();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: canAddToCart 
                              ? const Color(0xFF4CAF50) 
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: canAddToCart ? [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : [],
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildFarmersSection() {
  return SizedBox(
    height: 200, // Fixed height for the section
    child: StreamBuilder<List<Farmer>>(
      stream: fetchFarmers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.green));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading farmers'));
        }

        final farmers = snapshot.data ?? [];

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: farmers.length,
          itemBuilder: (context, index) {
            final farmer = farmers[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              margin: const EdgeInsets.only(right: 16),
              child: _buildFarmerCard(farmer),
            );
          },
        );
      },
    ),
  );
}

// 4. Build each farmer card (matches your example exactly)
Widget _buildFarmerCard(Farmer farmer) {
   return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarmerProfileScreen(farmer: farmer),
        ),
      );
    },
    child: Container(
    width: 160,
    height: 180, // Fixed height as in your example
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Farmer Image/Emoji
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(
            child: Text(
              farmer.image,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            children: [
              Text(
                farmer.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                farmer.location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    farmer.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    farmer.distance,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: farmer.specialties
                    .take(2) // Only show first 2 specialties
                    .map((specialty) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            specialty,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    ),
  ));
}
  
  Widget _buildAllProducts() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }
        
        List<Map<String, dynamic>> products = snapshot.data!;
        products = _filterProducts(products, _searchQuery);
        
        if (products.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔍', style: TextStyle(fontSize: 50)),
                  SizedBox(height: 10),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              child: _buildGridProductCard(products[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildGridProductCard(Map<String, dynamic> product) {
    final canAddToCart = _cartManager.canAddItem(product['farmerId'] ?? '');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.2),
                    const Color(0xFF8BC34A).withOpacity(0.2),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.network(product['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                    // Text(
                    //   product['imageUrl']?.isNotEmpty == true ? '📦' : '🥬',
                    //   style: const TextStyle(fontSize: 40),
                    // ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            (product['ratings']?.toDouble() ?? 4.5).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Fresh Product',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${product['farmerId'] ?? 'Local Farmer'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '${product['price'] ?? 0} XAF',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (canAddToCart) {
                            try {
                              _cartManager.addItem(product);
                              HapticFeedback.lightImpact();
                            } catch (e) {
                              _showFarmerRestrictionDialog();
                            }
                          } else {
                            _showFarmerRestrictionDialog();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: canAddToCart 
                                ? const Color(0xFF4CAF50) 
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: canAddToCart ? [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ] : [],
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPopup() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            padding: const EdgeInsets.all(35),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fantastic!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '+10 XP Earned!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep shopping for more rewards! 🌟',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFarmerRestrictionDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Oops! 🚜',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You can only add items from one farmer at a time to support direct farm-to-table purchases!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              'Current farmer: ${_cartManager.currentFarmerId ?? 'None'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
          ElevatedButton(
            onPressed: () {
              _cartManager.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Clear Cart',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(cartManager: _cartManager),
    );
  }
}

// Cart Bottom Sheet Widget


class CartBottomSheet extends StatefulWidget {
  final CartManager cartManager;
  
  const CartBottomSheet({Key? key, required this.cartManager}) : super(key: key);
  
  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: widget.cartManager,
        builder: (context, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(),
                _buildCartContent(),
                if (widget.cartManager.items.isNotEmpty) _buildBottomSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shopping Cart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${widget.cartManager.itemCount} ${widget.cartManager.itemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (widget.cartManager.items.isNotEmpty)
            TextButton.icon(
              onPressed: _showClearCartDialog,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.red[400],
              ),
              label: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Expanded(
      child: widget.cartManager.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartItems(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some fresh products to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: widget.cartManager.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = widget.cartManager.items[index];
        return _buildCartItem(item, index);
      },
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        widget.cartManager.removeItem(item.id);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from cart'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Implement undo functionality if needed
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildProductImage(),
            const SizedBox(width: 16),
            _buildProductInfo(item),
            const SizedBox(width: 12),
            _buildQuantityControls(item),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF8BC34A).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Center(
        child: Text('🥬', style: TextStyle(fontSize: 32)),
      ),
    );
  }

  Widget _buildProductInfo(CartItem item) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users_chopdirect') 
      .doc(item.farmerId) // Directly access the document without using 'where'
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text(
        'Loading...',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      );
    }
    
    
    
    final farmerData = snapshot.data!.data() as Map<String, dynamic>;
    final farmerName = farmerData['farmName'] ?? 'Unknown Farmer';
    
    return Text(
      farmerName,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  },
)
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${item.price.toInt()} XAF',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'each',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${(item.price * item.quantity).toInt()} XAF',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildQuantityButton(
            icon: Icons.add_rounded,
            onTap: () {
              widget.cartManager.updateQuantity(item.id, item.quantity + 1);
              HapticFeedback.lightImpact();
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (item.quantity > 1) {
                widget.cartManager.updateQuantity(item.id, item.quantity - 1);
                HapticFeedback.lightImpact();
              }
            },
            enabled: item.quantity > 1,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF4CAF50) : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final subtotal = widget.cartManager.subtotal;
    final deliveryFee = 500.0; // Fixed delivery fee
    final total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPricingRow('Subtotal', '${subtotal.toInt()} XAF'),
          const SizedBox(height: 8),
          _buildPricingRow('Delivery Fee', '${deliveryFee.toInt()} XAF'),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          _buildPricingRow(
            'Total',
            '${total.toInt()} XAF',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPricingRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF1A1A1A) : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: isTotal ? const Color(0xFF4CAF50) : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  void _proceedToCheckout() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsScreen(
          cartManager: widget.cartManager,
        ),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.cartManager.clearCart();
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ],
        );
      },
    );
  }

}
class FarmerProfileScreen extends StatelessWidget {
  final Farmer farmer;

  const FarmerProfileScreen({Key? key, required this.farmer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(farmer.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Header Section
            _buildFarmerHeader(),
            const SizedBox(height: 24),
            
            // About Section
            _buildAboutSection(),
            const SizedBox(height: 24),
            
            // Location Section
            _buildLocationSection(),
            const SizedBox(height: 24),
            
            // Products Section
            _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[50],
            ),
            child: Center(
              child: Text(
                farmer.image,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            farmer.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                farmer.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, color: Colors.green, size: 20),
              const SizedBox(width: 4),
              Text(
                farmer.distance,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Specializes in: ${farmer.specialties.join(', ')}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.location_on, color: Colors.green),
          title: const Text('Farm Address'),
          subtitle: Text(farmer.location),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: const Center(
            child: Icon(Icons.map, size: 50, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Product>>(
          stream: _fetchFarmerProducts(farmer.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Error loading products'));
            }
            
            final products = snapshot.data!;
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: product.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl == null
                  ? const Center(child: Icon(Icons.shopping_bag, size: 40))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price} XAF',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  