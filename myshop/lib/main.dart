import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';

void main() {
  runApp(const GameStoreApp());
}

class GameStoreApp extends StatelessWidget {
  const GameStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameStore',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: Color.fromARGB(255, 66, 66, 66),
          unselectedItemColor: Color.fromARGB(255, 66, 66, 66),
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Game> favoriteGames = [];
  List<CartItem> cartItems = [];

  final List<Game> games = [
    Game('Forza Horizon 4', 'assets/forza.jpg', 49.99, 'Гоночная игра в открытом мире.'),
    Game('Stardew Valley', 'assets/stardew_valley.jpg', 14.99, 'Симулятор фермы и ролевой игры.'),
    Game('GTA 5', 'assets/gta5.jpg', 29.99, 'Популярная криминальная экшен-игра.'),
    Game('Metro Exodus', 'assets/metro_exodus.jpg', 39.99, 'Шутер с элементами выживания в России.'),
  ];

  void toggleFavorite(Game game) {
    setState(() {
      favoriteGames.contains(game) ? favoriteGames.remove(game) : favoriteGames.add(game);
    });
  }

  void _addToCart(Game game) {
    setState(() {
      final existingItem = cartItems.firstWhere(
        (item) => item.game == game,
        orElse: () => CartItem(game, 0),
      );
      if (existingItem.quantity == 0) {
        cartItems.add(CartItem(game, 1));
      } else {
        existingItem.quantity++;
      }
    });
  }

  void _addNewGame(Game game) {
    setState(() {
      games.add(game);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      GameStoreScreen(
        games: games,
        toggleFavorite: toggleFavorite,
        favoriteGames: favoriteGames,
        onAddToCart: _addToCart,
        onAddGame: _addNewGame,
      ),
      FavoriteScreen(favoriteGames: favoriteGames, toggleFavorite: toggleFavorite),
      CartScreen(cartItems: cartItems),
      ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Games'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.favorite),
                if (favoriteGames.isNotEmpty)
                  Positioned(
                    right: 5.7,
                    child: Container(
                      padding: const EdgeInsets.all(3.3),
                      
                      child: Text(
                        '${favoriteGames.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 6.5,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        '${cartItems.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person), // Иконка профиля
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class GameStoreScreen extends StatelessWidget {
  final List<Game> games;
  final List<Game> favoriteGames;
  final Function(Game) toggleFavorite;
  final Function(Game) onAddToCart;
  final Function(Game) onAddGame;

  const GameStoreScreen({
    Key? key,
    required this.games,
    required this.toggleFavorite,
    required this.favoriteGames,
    required this.onAddToCart,
    required this.onAddGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameStore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGameScreen(
                    onAdd: (game) {
                      onAddGame(game);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailScreen(game: game),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: game.imageFilePath != null
                        ? Image.file(File(game.imageFilePath!), fit: BoxFit.cover)
                        : Image.asset(game.imagePath, fit: BoxFit.cover),
                  ),
                  ListTile(
                    title: Text(game.name),
                    subtitle: Text('${game.price} \$'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            favoriteGames.contains(game) ? Icons.favorite : Icons.favorite_border,
                          ),
                          onPressed: () => toggleFavorite(game),
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () => onAddToCart(game),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _removeItem(CartItem item) {
    setState(() {
      widget.cartItems.remove(item);
    });
  }

   void _incrementQuantity(CartItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decrementQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _removeItem(item);
      }
    });
  }

  double _calculateTotal() {
    return widget.cartItems.fold(0, (total, item) => total + item.game.price * item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('Корзина пуста'))
          : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Slidable(
                  key: ValueKey(item.game.name),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _removeItem(item);
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Удалить',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.asset(item.game.imagePath, width: 50, fit: BoxFit.cover),
                    title: Text(item.game.name),
                    subtitle: Text('${item.game.price} \$'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: () => _decrementQuantity(item)),
                        Text('${item.quantity}'),
                        IconButton(icon: const Icon(Icons.add), onPressed: () => _incrementQuantity(item)),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Text('Итог: ${_calculateTotal().toStringAsFixed(2)} \$', style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

class CartItem {
  final Game game;
  int quantity;

  CartItem(this.game, this.quantity);
}

class FavoriteScreen extends StatelessWidget {
  final List<Game> favoriteGames;
  final Function(Game) toggleFavorite;

  const FavoriteScreen({super.key, required this.favoriteGames, required this.toggleFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favoriteGames.isEmpty
          ? const Center(child: Text('Нет избранных игр'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
              itemCount: favoriteGames.length,
              itemBuilder: (context, index) {
                final game = favoriteGames[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GameDetailScreen(game: game)));
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Expanded(
                          child: game.imageFilePath != null
                              ? Image.file(File(game.imageFilePath!), fit: BoxFit.cover)
                              : Image.asset(game.imagePath, fit: BoxFit.cover),
                        ),
                        ListTile(
                          title: Text(game.name),
                          subtitle: Text('${game.price} \$'),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite),
                            onPressed: () => toggleFavorite(game),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController(text: 'Хидиров Карим');
  final groupController = TextEditingController(text: 'ЭФБО-03-22');
  final phoneController = TextEditingController(text: '+7 123 456 7890');
  final emailController = TextEditingController(text: 'khidirov@karim.com');

  void _saveProfile() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ФИО')),
            TextField(controller: groupController, decoration: const InputDecoration(labelText: 'Группа')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Телефон')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfile, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}

class AddGameScreen extends StatefulWidget {
  final Function(Game) onAdd;

  const AddGameScreen({super.key, required this.onAdd});

  @override
  _AddGameScreenState createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  String? imageFilePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFilePath = pickedFile.path;
      });
    }
  }

  void _addGame() {
    final name = nameController.text;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final description = descriptionController.text;

    if (name.isNotEmpty) {
      final newGame = Game(name, '', price, description, imageFilePath: imageFilePath);
      widget.onAdd(newGame);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить игру')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Цена')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Описание')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: const Text('Выбрать изображение')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _addGame, child: const Text('Добавить')),
          ],
        ),
      ),
    );
  }
}

class Game {
  final String name;
  final String imagePath;
  final double price;
  final String description;
  final String? imageFilePath;

  Game(this.name, this.imagePath, this.price, this.description, {this.imageFilePath});
}

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: Column(
        children: [
          Expanded(
            child: game.imageFilePath != null
                ? Image.file(File(game.imageFilePath!), fit: BoxFit.cover)
                : Image.asset(game.imagePath, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(game.description),
          ),
          Text('Цена: ${game.price} \$', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}


