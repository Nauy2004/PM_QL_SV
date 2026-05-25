class Meal {
  final String name;
  final String calories;
  final String image;
  final String category;

  Meal({
    required this.name,
    required this.calories,
    required this.image,
    required this.category,
  });
}

List<Meal> dummyMeals = [
  Meal(name: 'Oatmeal with Fruits', calories: '350 kcal', image: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf', category: 'Breakfast'),
  Meal(name: 'Grilled Chicken Salad', calories: '450 kcal', image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c', category: 'Lunch'),
  Meal(name: 'Salmon with Veggies', calories: '500 kcal', image: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288', category: 'Dinner'),
];
