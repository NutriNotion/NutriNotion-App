# Firestore Collection Structure for Mess Menu

## Collection: `mess`

The mess collection should contain documents named after each day of the week (lowercase). Each document represents the menu for that specific day.

### Real-time Updates

The mess service now supports **real-time updates** through Firestore streams. This means:

- Menu changes in Firestore are automatically reflected in the app
- No need to manually refresh to see updates
- Instant synchronization across all users
- Automatic error handling and retry logic

### Document Structure

Each day document (e.g., `monday`, `tuesday`, etc.) should have this simple structure with only food item names:

```json
{
  "breakfast": [
    "Idli Sambar",
    "Poha", 
    "Upma",
    "Aloo Paratha"
  ],
  "lunch": [
    "Dal Rice",
    "Chicken Curry",
    "Vegetable Biryani",
    "Rajma Chawal"
  ],
  "snacks": [
    "Samosa",
    "Bhel Puri", 
    "Pakora",
    "Masala Chai"
  ],
  "dinner": [
    "Roti Sabzi",
    "Fish Curry",
    "Mixed Dal",
    "Paneer Butter Masala"
  ],
  "lastUpdated": "2025-07-23T10:00:00Z",
  "updatedBy": "admin"
}
```

### How the Service Processes Item Names

The `MessService` automatically converts each food item name into a rich data object with:

- **Unique ID**: Generated from the item name (e.g., "Idli Sambar" → "idli_sambar")
- **Description**: Smart descriptions for 30+ common Indian dishes
- **Calories**: Estimated calories based on typical serving sizes
- **Vegetarian Status**: Automatically detects non-vegetarian items
- **Category**: Classifies into South Indian, North Indian, Street Food, etc.
- **Allergens**: Identifies common allergens like Gluten, Dairy, Nuts
      "price": 45.0,
      "image": "https://example.com/images/dal_rice.jpg",
      "isAvailable": true
    },
    {
      "id": "lunch_chicken_curry",
      "name": "Chicken Curry",
      "description": "Spiced chicken curry served with rice",
      "calories": 450,
      "ingredients": ["Chicken", "Onions", "Tomatoes", "Spices", "Oil"],
      "allergens": [],
      "isVegetarian": false,
      "category": "Non-Vegetarian",
      "price": 80.0,
      "image": "https://example.com/images/chicken_curry.jpg",
      "isAvailable": true
    }
  ],
  "snacks": [
    {
      "id": "snacks_samosa",
      "name": "Samosa",
      "description": "Deep fried pastry with spiced potato filling",
      "calories": 150,
      "ingredients": ["Flour", "Potatoes", "Oil", "Spices"],
      "allergens": ["Gluten"],
      "isVegetarian": true,
      "category": "Street Food",
      "price": 15.0,
      "image": "https://example.com/images/samosa.jpg",
      "isAvailable": true
    },
    {
      "id": "snacks_chai",
      "name": "Masala Chai",
      "description": "Spiced milk tea with cardamom and ginger",
      "calories": 80,
      "ingredients": ["Tea", "Milk", "Sugar", "Cardamom", "Ginger"],
      "allergens": ["Dairy"],
      "isVegetarian": true,
      "category": "Beverages",
      "price": 10.0,
      "image": "https://example.com/images/chai.jpg",
      "isAvailable": true
    }
  ],
  "dinner": [
    {
      "id": "dinner_roti_sabzi",
      "name": "Roti with Mixed Vegetables",
      "description": "Wheat flatbread served with seasonal vegetable curry",
      "calories": 280,
      "ingredients": ["Wheat Flour", "Mixed Vegetables", "Oil", "Spices"],
      "allergens": ["Gluten"],
      "isVegetarian": true,
      "category": "North Indian",
      "price": 35.0,
      "image": "https://example.com/images/roti_sabzi.jpg",
      "isAvailable": true
    },
    {
      "id": "dinner_paneer_butter_masala",
      "name": "Paneer Butter Masala",
      "description": "Cottage cheese in rich tomato and butter gravy",
      "calories": 380,
      "ingredients": ["Paneer", "Tomatoes", "Butter", "Cream", "Spices"],
      "allergens": ["Dairy"],
      "isVegetarian": true,
      "category": "North Indian",
      "price": 70.0,
      "image": "https://example.com/images/paneer_butter_masala.jpg",
      "isAvailable": true
    }
  ],
  "lastUpdated": "2025-07-23T10:00:00Z",
  "updatedBy": "admin"
}
```

### Field Descriptions

- **id**: Unique identifier for each menu item
- **name**: Display name of the food item
- **description**: Brief description of the dish
- **calories**: Calorie count per serving
- **ingredients**: Array of main ingredients
- **allergens**: Array of common allergens (e.g., "Gluten", "Dairy", "Nuts")
- **isVegetarian**: Boolean indicating if the item is vegetarian
- **category**: Food category/cuisine type
- **price**: Price in local currency (optional)
- **image**: URL to food item image (optional)
- **isAvailable**: Boolean indicating if item is currently available
- **lastUpdated**: Timestamp of last update
- **updatedBy**: ID of the user who last updated the menu

### Document Names (Days of Week)

- `monday`
- `tuesday` 
- `wednesday`
- `thursday`
- `friday`
- `saturday`
- `sunday`

### Usage Examples

1. **Get today's menu with real-time updates**: 
   ```dart
   // Start listening to today's menu stream
   messProvider.startTodayMessMenuStream();
   
   // The UI will automatically update when data changes
   Consumer<MessProvider>(
     builder: (context, messProvider, child) {
       if (messProvider.isLoading) {
         return CircularProgressIndicator();
       }
       
       final breakfastItems = messProvider.getMealItems('breakfast');
       return ListView.builder(...);
     },
   )
   ```

2. **Get specific day menu**: 
   ```dart
   messProvider.startMessMenuStreamForDay('monday');
   ```

3. **Manual refresh**: 
   ```dart
   messProvider.refreshTodayMenu(); // Restarts the stream
   ```

4. **Stream cleanup**: The provider automatically cancels streams when disposed, but you can also manually manage them.

### Sample Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to mess menu for authenticated users
    match /mess/{day} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

This structure allows for:
- Easy day-wise menu management  
- Rich food item metadata
- Dietary preference filtering
- Real-time menu updates
- Extensible for future features like ratings, reviews, etc.
