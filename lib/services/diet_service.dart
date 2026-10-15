import '../models/diet_plan.dart';
import '../models/user.dart';

class DietService {
  static IndianDietPlan generateDietPlan(User user, {String? preferenceOverride}) {
    final pref = preferenceOverride ?? user.dietaryPreference;
    final calories = user.targetCalories;
    final protein = user.proteinGrams;
    final carbs = user.carbsGrams;
    final fats = user.fatsGrams;
    final water = user.waterTargetLiters;
    final goal = user.goal;

    final weeklyDays = switch (pref) {
      'Vegan' => _buildVegan7Days(calories, protein, carbs, fats),
      'Non-Vegetarian' => _buildNonVeg7Days(calories, protein, carbs, fats),
      _ => _buildVegetarian7Days(calories, protein, carbs, fats),
    };

    final swaps = [
      const DietSwap(
        unhealthyItem: 'Refined Maida Naan / Paratha',
        healthySwap: 'Multigrain Phulka (Wheat + Ragi + Oats)',
        benefit: 'Provides complex low-glycemic fiber and prevents post-meal insulin spikes.',
        impact: '-120 kcal, +5g Fiber',
      ),
      const DietSwap(
        unhealthyItem: 'Deep-Fried Samosa / Pakoras',
        healthySwap: 'Roasted Makhana (Foxnuts) / Air-Fried Chilla',
        benefit: 'Rich in magnesium and plant protein without inflammatory trans-fats.',
        impact: '-210 kcal, +4g Protein',
      ),
      const DietSwap(
        unhealthyItem: 'Heavy Cream / Butter Gravies',
        healthySwap: 'Low-Fat Dahi & Tomato Puree Gravy with Jeera Tadka',
        benefit: 'Delivers full authentic aroma and probiotics while cutting saturated fats.',
        impact: '-180 kcal, -18g Saturated Fat',
      ),
      const DietSwap(
        unhealthyItem: 'High-Sugar Masala Chai (3-4 cups/day)',
        healthySwap: 'Cardamom Green Tea / Elaichi Black Tea with Jaggery',
        benefit: 'Antioxidant catechin boost to accelerate resting metabolic rate.',
        impact: '-150 kcal, -25g Sugar',
      ),
      const DietSwap(
        unhealthyItem: 'White Polished Basmati Rice',
        healthySwap: 'Hand-Pounded Brown Rice / Foxtail Millet Pulav',
        benefit: 'Sustained energy release with a low glycemic index, keeping you full longer.',
        impact: 'Zero blood glucose crash, +3g Protein',
      ),
    ];

    final highlights = [
      'Authentic Indian spices (Turmeric, Jeera, Ajwain) provide natural anti-inflammatory curcumin to speed up muscular recovery.',
      'Targeting ${user.proteinGrams}g daily protein using bioavailable Indian staples to support muscle synthesis.',
      'Minimum hydration guideline: Drink ${water.toStringAsFixed(1)} Litres of clean water daily, supplemented with tender coconut water.',
      'Pre-workout timing: Consume complex carbs & hydration 45-60 minutes before initiating your AI camera session.',
    ];

    return IndianDietPlan(
      preference: pref,
      goal: goal,
      dailyCalories: calories,
      targetProtein: protein,
      targetCarbs: carbs,
      targetFats: fats,
      targetFiber: 35,
      waterLiters: water,
      weeklyDays: weeklyDays,
      smartSwaps: swaps,
      nutritionHighlights: highlights,
    );
  }

  // =========================================================================
  // 1. VEGETARIAN: 7-DAY MEAL SCHEDULE (High Protein Lacto-Veg)
  // =========================================================================
  static List<DailyDietPlan> _buildVegetarian7Days(int cals, int prot, int carb, int fat) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final themes = [
      'Protein Kickstart • Moong Chilla & Paneer',
      'Metabolic Balance • Chana Masala & Missi Roti',
      'High-Density Fuel • Soya Bhurji & Dal Makhani',
      'Millet & Fiber Power • Rajma & Brown Rice',
      'Clean Recovery • Moong Idlis & Dal Tadka',
      'Weekend Strength • Paneer Paratha & Millet Pulav',
      'Probiotic Reset • Multi-Dal Adai & Veg Biryani',
    ];

    return List.generate(7, (i) {
      final List<IndianMeal> meals = switch (i) {
        // Monday
        0 => [
            _meal('breakfast', 'Morning Fuel • Moong Dal Chilla & Paneer', '7:30 AM', (cals * 0.24).round(), (prot * 0.26).round(), [
              _dish('Moong Dal & Besan Chilla with Paneer', '2 large chillas (160g)', 320, 22, 34, 10, 'Yellow moong, 50g paneer, onions, coriander.'),
              _dish('Fresh Mint Chutney', '2 tbsp (30g)', 35, 1, 4, 1, 'Mint, coriander, ginger, rock salt, lemon.'),
              _dish('Tender Coconut Water', '1 glass (250ml)', 45, 1, 9, 0, 'Natural electrolytes.'),
            ], 'Cook on cast-iron skillet with 1/2 tsp cold pressed oil.'),
            _meal('snack1', 'Mid-Morning • Foxnut Crunch', '11:00 AM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Roasted Makhana with Rock Salt', '1 bowl (35g)', 125, 4, 22, 2, 'Foxnuts, pink salt, black pepper, turmeric.'),
              _dish('Soaked Almonds & Walnuts', '6 almonds + 2 walnuts', 95, 3, 3, 8, 'Peeled almonds, raw walnuts.'),
            ], 'Peeling soaked almonds removes phytic acid for 3x better zinc absorption.'),
            _meal('lunch', 'Power Lunch • Paneer Bhurji & Dal Tadka', '1:00 PM', (cals * 0.32).round(), (prot * 0.32).round(), [
              _dish('Multigrain Phulkas', '2 phulkas (80g)', 180, 6, 36, 2, 'Stone-ground wheat & jowar.'),
              _dish('Homestyle Paneer Bhurji', '1 bowl (150g)', 220, 18, 8, 14, '100g low-fat paneer, tomato-onion tadka.'),
              _dish('Thick Dal Tadka', '1 katori (150g)', 140, 9, 22, 3, 'Toor & moong lentils, hing, jeera.'),
              _dish('Cucumber Sprouted Moong Salad', '1 bowl (120g)', 60, 4, 10, 0, 'Sprouted moong, lemon, chaat masala.'),
              _dish('Set Curd (Dahi)', '1 katori (100g)', 65, 4, 5, 3, 'Fresh probiotic dahi.'),
            ], 'Eat your salad first to prime insulin sensitivity.'),
            _meal('snack2', 'Pre-Workout • Sattu Cooler', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Bihari Sattu Buttermilk Drink', '1 tall glass (300ml)', 140, 10, 18, 3, '30g roasted gram flour, chaas, rock salt.'),
              _dish('Robust Banana', '1 medium (100g)', 90, 1, 23, 0, 'Clean fast glycogen fuel.'),
            ], 'Sattu delivers sustained non-spiking athletic endurance.'),
            _meal('dinner', 'Dinner • Palak Paneer & Golden Milk', '7:45 PM', (cals * 0.20).round(), (prot * 0.18).round(), [
              _dish('Palak Paneer (Light Gravy)', '1 bowl (180g)', 210, 16, 8, 13, 'Blanched spinach, 80g paneer, garlic.'),
              _dish('Foxtail Millet Khichdi', '1 bowl (120g)', 130, 4, 24, 2, 'Millet, yellow moong, ginger.'),
              _dish('Warm Haldi Doodh', '1 cup (150ml)', 85, 5, 7, 3, 'Low-fat milk, wild turmeric, black pepper.'),
            ], 'Curcumin with black pepper accelerates deep muscular recovery.'),
          ],
        // Tuesday
        1 => [
            _meal('breakfast', 'Morning Fuel • Methi Missi Roti & Dahi', '7:30 AM', (cals * 0.24).round(), (prot * 0.24).round(), [
              _dish('Besan Methi Missi Rotis', '2 rotis (120g)', 280, 14, 38, 7, 'Gram flour, whole wheat, fresh fenugreek leaves.'),
              _dish('Fresh Mint Curd Dip', '1 katori (100g)', 70, 5, 5, 3, 'Low-fat curd, mint paste, roasted jeera.'),
              _dish('Ginger Lemon Green Tea', '1 mug (250ml)', 10, 0, 2, 0, 'Steeped green tea, crushed fresh ginger.'),
            ], 'Fenugreek (methi) is clinically proven to improve glucose clearance.'),
            _meal('snack1', 'Mid-Morning • Sprouted Moong Chaat', '11:00 AM', (cals * 0.12).round(), (prot * 0.14).round(), [
              _dish('Sprouted Moong & Kala Chana Chaat', '1 bowl (120g)', 140, 9, 22, 1, 'Sprouts, chopped tomatoes, onions, lemon.'),
              _dish('Handful of Soaked Walnuts', '3 walnut halves (15g)', 95, 2, 2, 9, 'Rich in alpha-linolenic acid (Omega-3).'),
            ], 'Sprouting increases protein bioavailability and vitamins by 400%.'),
            _meal('lunch', 'Power Lunch • Chana Masala & Brown Rice', '1:00 PM', (cals * 0.32).round(), (prot * 0.30).round(), [
              _dish('Punjabi Chana Masala', '1 large bowl (180g)', 240, 14, 32, 6, 'Kabuli chana, onion-tomato gravy, anardana.'),
              _dish('Steamed Hand-Pounded Brown Rice', '1 cup (130g)', 160, 4, 34, 1, 'Hand-pounded low-GI rice.'),
              _dish('Stir-Fried Bhindi with Ajwain', '1 bowl (100g)', 85, 2, 10, 4, 'Okra sautéed with carom seeds, turmeric.'),
              _dish('Cucumber & Beetroot Salad', '1 bowl (100g)', 45, 1, 9, 0, 'Nitrate-rich beets to boost blood flow.'),
            ], 'Chickpeas plus brown rice forms a 100% complete essential amino acid profile.'),
            _meal('snack2', 'Pre-Workout • Roasted Gud-Chana', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Roasted Chana with Jaggery', '40g portion', 150, 7, 26, 2, 'Traditional Indian endurance snack.'),
              _dish('Black Coffee with Cinnamon', '1 cup (200ml)', 5, 0, 1, 0, 'Caffeine enhances central nervous system motor drive.'),
            ], 'Take caffeine 40 mins before camera workout for peak rep counts.'),
            _meal('dinner', 'Dinner • Matar Paneer & Lauki Broth', '7:45 PM', (cals * 0.20).round(), (prot * 0.20).round(), [
              _dish('Matar Paneer with Light Gravy', '1 bowl (160g)', 210, 15, 14, 11, '80g paneer, tender green peas, tomato base.'),
              _dish('1 Jowar Phulka', '1 roti (50g)', 95, 3, 20, 1, 'Gluten-free sorghum flour.'),
              _dish('Lauki & Moong Dal Clear Soup', '1 large bowl (200ml)', 80, 5, 12, 1, 'Bottle gourd, yellow lentils, cumin.'),
            ], 'Bottle gourd alkalizes the stomach and eases nighttime digestion.'),
          ],
        // Wednesday
        2 => [
            _meal('breakfast', 'Morning Fuel • High-Protein Paneer Upma', '7:30 AM', (cals * 0.24).round(), (prot * 0.26).round(), [
              _dish('Oats & Paneer Veg Upma', '1 large bowl (200g)', 310, 20, 32, 11, 'Roasted oats, 60g crumbled paneer, mustard seeds, curry leaves.'),
              _dish('Chilled Masala Chaas', '1 tall glass (250ml)', 60, 4, 4, 2, 'Curd, ginger, mint, rock salt.'),
            ], 'Curry leaves contain carbazole alkaloids that support gut integrity.'),
            _meal('snack1', 'Mid-Morning • Pumpkin & Chia Seed Fuel', '11:00 AM', (cals * 0.12).round(), (prot * 0.10).round(), [
              _dish('Roasted Pumpkin & Watermelon Seeds', '2 tbsp (20g)', 110, 6, 3, 9, 'High zinc for cellular repair.'),
              _dish('1 Seasonal Orange / Sweet Lime', '1 fruit (130g)', 65, 1, 15, 0, 'Vitamin C to boost collagen synthesis.'),
            ], 'Zinc and Vitamin C accelerate micro-tear healing in tendon fibers.'),
            _meal('lunch', 'Power Lunch • Soya Bhurji & Dal Makhani', '1:00 PM', (cals * 0.32).round(), (prot * 0.34).round(), [
              _dish('High-Protein Soya Chunks Bhurji', '1 bowl (150g)', 220, 22, 12, 6, 'Minced soya granules, capsicum, tomatoes.'),
              _dish('Healthy Dal Makhani (No Butter/Cream)', '1 katori (150g)', 170, 10, 24, 3, 'Black urad dal simmered with low-fat curd.'),
              _dish('Whole Wheat Phulkas', '2 phulkas (80g)', 180, 6, 36, 2, 'Stone-ground wheat.'),
              _dish('Fresh Onion, Tomato & Lemon Kachumber', '1 bowl (100g)', 45, 1, 9, 0, 'Raw onions supply antioxidant quercetin.'),
            ], 'Soya granules pack 52g protein per 100g dry weight.'),
            _meal('snack2', 'Pre-Workout • Sattu Lemon Shaker', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Chana Sattu Sherbet with Mint', '1 tumbler (300ml)', 150, 10, 21, 3, 'Roasted gram powder, water, lemon, kala namak.'),
              _dish('4 Soaked Almonds', '4 almonds', 30, 1, 1, 3, 'Nutrient dense bite.'),
            ], 'Sattu replenishes glycogen without heaviness in the stomach.'),
            _meal('dinner', 'Dinner • Skewered Paneer Tikka & Soup', '7:45 PM', (cals * 0.20).round(), (prot * 0.18).round(), [
              _dish('Tawa Grilled Paneer Tikka', '150g portion', 220, 18, 6, 14, '100g paneer cubes, capsicum, onions, hung curd marinade.'),
              _dish('Green Moong Dal Soup with Ginger', '1 bowl (200ml)', 90, 6, 14, 1, 'Split green moong dal, ginger, black pepper.'),
              _dish('1 Small Phulka', '1 roti (40g)', 85, 3, 17, 1, 'Light evening carbohydrate.'),
            ], 'High-protein, low-carb dinner stimulates overnight growth hormone.'),
          ],
        // Thursday
        3 => [
            _meal('breakfast', 'Morning Fuel • Ragi Dosa & Sambar', '7:30 AM', (cals * 0.24).round(), (prot * 0.22).round(), [
              _dish('Crispy Ragi & Urad Dal Dosas', '2 dosas (150g)', 290, 12, 44, 7, 'Finger millet, urad dal batter.'),
              _dish('Mixed Vegetable Toor Dal Sambar', '1 large bowl (200g)', 120, 7, 18, 2, 'Lentils, drumstick, pumpkin, shallots.'),
              _dish('Coconut Coriander Chutney', '2 tbsp (30g)', 50, 1, 2, 5, 'Fresh grated coconut, green chillies.'),
            ], 'Ragi is loaded with natural calcium for high-stress bone density.'),
            _meal('snack1', 'Mid-Morning • Roasted Makhana & Fig', '11:00 AM', (cals * 0.12).round(), (prot * 0.10).round(), [
              _dish('Dry Roasted Makhana', '1 bowl (30g)', 110, 3, 20, 1, 'Low calorie, high polyphenol foxnuts.'),
              _dish('Soaked Anjeer (Dried Fig) & Walnuts', '1 fig + 2 walnuts', 85, 2, 12, 4, 'Natural iron and insoluble fiber.'),
            ], 'Anjeer provides iron for superior hemoglobin oxygen transport.'),
            _meal('lunch', 'Power Lunch • Rajma & Hand-Pounded Rice', '1:00 PM', (cals * 0.32).round(), (prot * 0.32).round(), [
              _dish('Slow-Cooked Punjabi Rajma Masala', '1 large bowl (200g)', 240, 15, 34, 4, 'Red kidney beans, tomato-ginger gravy.'),
              _dish('Steamed Hand-Pounded Brown Rice', '1 cup (130g)', 160, 4, 34, 1, 'Hand-ground unpolished brown rice.'),
              _dish('French Beans & Carrot Poriyal', '1 bowl (100g)', 75, 2, 10, 3, 'Steamed beans, carrots, mustard seed tadka.'),
              _dish('Fresh Dahi with Roasted Jeera', '1 katori (100g)', 65, 4, 5, 3, 'Probiotic boost.'),
            ], 'Rajma delivers soluble fiber that stabilizes blood glucose.'),
            _meal('snack2', 'Pre-Workout • Tender Coconut & Chana', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Fresh Tender Coconut Water', '1 glass (250ml)', 45, 1, 9, 0, 'Natural bioavailable potassium and sodium.'),
              _dish('Roasted Chana with Rock Salt', '35g portion', 130, 7, 20, 2, 'Crunchy endurance legumes.'),
            ], 'Coconut water prevents electrolyte-induced workout cramping.'),
            _meal('dinner', 'Dinner • Methi Paneer & Lauki Broth', '7:45 PM', (cals * 0.20).round(), (prot * 0.24).round(), [
              _dish('Methi Paneer (Fresh Fenugreek)', '1 bowl (160g)', 210, 16, 7, 13, '80g paneer, tender methi leaves, garlic, jeera.'),
              _dish('1 Multigrain Roti', '1 roti (45g)', 95, 3, 19, 1, 'Whole wheat, oats, ragi.'),
              _dish('Warm Bottle Gourd Dal Soup', '1 bowl (200ml)', 80, 5, 12, 1, 'Gentle on gut.'),
            ], 'Garlic in the tadka lowers resting blood pressure and arterial stiffness.'),
          ],
        // Friday
        4 => [
            _meal('breakfast', 'Morning Fuel • Moong Dal Steamed Idlis', '7:30 AM', (cals * 0.24).round(), (prot * 0.26).round(), [
              _dish('Steamed Moong Dal & Spinach Idlis', '3 idlis (150g)', 260, 16, 38, 4, 'Yellow moong dal, puréed palak, eno/mustard.'),
              _dish('Mixed Vegetable Toor Sambar', '1 bowl (180g)', 110, 6, 17, 2, 'Lentils, tomatoes, drumstick.'),
              _dish('Tomato Garlic Chutney', '2 tbsp (30g)', 35, 1, 5, 1, 'Roasted country tomatoes, garlic, curry leaves.'),
            ], 'Steamed moong idlis are ultra-gentle on the gut while delivering 16g protein.'),
            _meal('snack1', 'Mid-Morning • Papaya & Almonds', '11:00 AM', (cals * 0.12).round(), (prot * 0.10).round(), [
              _dish('Fresh Papaya Cubes', '1 medium bowl (150g)', 65, 1, 15, 0, 'Contains papain enzyme to speed up protein breakdown.'),
              _dish('Soaked Almonds & Pumpkin Seeds', '6 almonds + 1 tbsp seeds', 110, 4, 3, 9, 'Rich in Vitamin E and magnesium.'),
            ], 'Papain enzyme significantly speeds up digestion of dietary amino acids.'),
            _meal('lunch', 'Power Lunch • Kala Chana & Jowar Roti', '1:00 PM', (cals * 0.32).round(), (prot * 0.32).round(), [
              _dish('Kala Chana (Black Chickpea) Curry', '1 large bowl (180g)', 220, 14, 28, 5, 'Traditional desi chana, tomato gravy, amchur.'),
              _dish('Jowar (Sorghum) Rotis', '2 rotis (90g)', 180, 5, 38, 2, 'Gluten-free, fiber rich grain.'),
              _dish('Shahi Paneer Bhurji with Bell Peppers', '1 bowl (100g)', 160, 12, 5, 10, '60g paneer, capsicum, mild spices.'),
              _dish('Sprouted Moong Salad', '1 bowl (80g)', 50, 4, 8, 0, 'Fresh lemon juice, pink salt.'),
            ], 'Black chickpeas are the powerhouse staple of traditional Indian wrestlers.'),
            _meal('snack2', 'Pre-Workout • Sattu Lemonade', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Desi Sattu Sherbet', '1 large glass (300ml)', 150, 11, 20, 3, 'Chana sattu, mint, black salt, lemon.'),
              _dish('1 Banana', '1 fruit', 90, 1, 23, 0, 'Fast-acting pre-session carbs.'),
            ], 'Drink 45 mins before your AI camera workout session.'),
            _meal('dinner', 'Dinner • Paneer Tikka Masala & Phulka', '7:45 PM', (cals * 0.20).round(), (prot * 0.20).round(), [
              _dish('Paneer Tikka Masala (Dahi Gravy)', '1 bowl (160g)', 220, 17, 8, 14, '90g paneer, roasted capsicum, onion-curd gravy.'),
              _dish('1 Whole Wheat Phulka', '1 roti (40g)', 85, 3, 17, 1, 'Light, non-bloating carbohydrate.'),
              _dish('Warm Turmeric Milk with Cinnamon', '1 cup (150ml)', 80, 5, 6, 3, 'Promotes deep restful sleep.'),
            ], 'Cinnamon helps regulate nighttime fasting blood glucose levels.'),
          ],
        // Saturday
        5 => [
            _meal('breakfast', 'Morning Fuel • Stuffed Paneer Paratha', '8:00 AM', (cals * 0.26).round(), (prot * 0.26).round(), [
              _dish('Tawa Roasted Paneer Paratha', '1 large paratha (140g)', 320, 18, 36, 12, 'Whole wheat dough, 70g low-fat spiced paneer, roasted on dry tawa with 1 tsp ghee.'),
              _dish('Fresh Mint Curd Dip', '1 katori (100g)', 70, 5, 5, 3, 'Probiotic companion.'),
            ], 'Roasting with measured ghee provides healthy fat-soluble vitamin absorption.'),
            _meal('snack1', 'Mid-Morning • Foxnut & Dry Fruit Trail', '11:15 AM', (cals * 0.12).round(), (prot * 0.10).round(), [
              _dish('Roasted Makhana with Pepper', '1 bowl (30g)', 110, 3, 20, 1, 'Crunchy snack.'),
              _dish('Soaked Walnuts & Dried Cranberries', '2 walnuts + 10g berries', 95, 2, 8, 7, 'Antioxidant punch.'),
            ], 'Foxnuts have zero trans fats and low sodium for cardiovascular health.'),
            _meal('lunch', 'Power Lunch • Soya Matar Pulav & Toor Dal', '1:30 PM', (cals * 0.32).round(), (prot * 0.34).round(), [
              _dish('Foxtail Millet Pulav with Soya Chunks', '1 large bowl (200g)', 260, 20, 36, 4, 'Millet grains, 40g soya chunks, green peas, carrots, whole spices.'),
              _dish('Yellow Toor Dal Tadka', '1 katori (150g)', 130, 8, 20, 2, 'Pigeon pea dal, garlic, cumin.'),
              _dish('Cucumber & Tomato Raita', '1 katori (120g)', 75, 4, 7, 3, 'Cooling curd accompaniment.'),
            ], 'Millets release glucose 40% slower than refined white rice.'),
            _meal('snack2', 'Pre-Workout • Black Coffee & Dark Chocolate', '5:00 PM', (cals * 0.10).round(), (prot * 0.08).round(), [
              _dish('Double Espresso / Black Coffee', '1 cup', 5, 0, 1, 0, 'Peak alertness for camera tracking session.'),
              _dish('Dark Chocolate (70%+) & Soaked Almonds', '1 square (15g) + 4 almonds', 110, 2, 8, 8, 'Polyphenols to expand blood vessels.'),
            ], 'Dark chocolate flavanols enhance nitric oxide production and blood flow.'),
            _meal('dinner', 'Dinner • Mushroom & Paneer Sauté', '8:00 PM', (cals * 0.20).round(), (prot * 0.22).round(), [
              _dish('Sautéed Mushroom & Paneer with Peppers', '1 bowl (180g)', 220, 18, 9, 13, '80g paneer, 80g button mushrooms, oregano, black pepper.'),
              _dish('1 Jowar Phulka', '1 roti (45g)', 90, 3, 19, 1, 'Ancient grain bread.'),
              _dish('Clear Vegetable Dal Broth', '1 bowl (180ml)', 70, 5, 11, 1, 'Hydrating evening soup.'),
            ], 'Mushrooms provide ergothioneine, an exclusive antioxidant that protects mitochondria.'),
          ],
        // Sunday
        6 => [
            _meal('breakfast', 'Sunday Fuel • Multi-Dal Adai Dosa', '8:30 AM', (cals * 0.26).round(), (prot * 0.26).round(), [
              _dish('Mixed Lentil Adai Dosa', '2 dosas (160g)', 320, 19, 42, 8, 'Chana dal, toor dal, moong dal, ginger, curry leaves.'),
              _dish('Fresh Tomato Coriander Chutney', '2 tbsp (30g)', 35, 1, 5, 1, 'Zesty traditional dip.'),
              _dish('Tender Coconut Water', '1 glass', 45, 1, 9, 0, 'Weekend hydration.'),
            ], 'Adai dosa uses 4 distinct lentils for exceptional protein variety.'),
            _meal('snack1', 'Mid-Morning • Royal Dry Fruit Nibble', '11:30 AM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Almonds, Walnuts & Pistachios Mix', '25g portion', 145, 5, 5, 12, 'Heart-healthy monounsaturated fats.'),
              _dish('Fresh Sweet Lime / Orange', '1 fruit (120g)', 60, 1, 14, 0, 'Clean citrus refresh.'),
            ], 'Pistachios contain high levels of lutein and zeaxanthin for optical health.'),
            _meal('lunch', 'Sunday Feast • Healthy Hyderabadi Paneer Biryani', '1:30 PM', (cals * 0.32).round(), (prot * 0.32).round(), [
              _dish('Layered Paneer Vegetable Biryani (Brown Rice)', '1 large bowl (220g)', 330, 21, 44, 9, '100g paneer, hand-pounded brown basmati, saffron, mint, green cardamom.'),
              _dish('Cooling Boondi & Cucumber Raita', '1 bowl (120g)', 85, 4, 8, 4, 'Probiotics to soothe digestion.'),
              _dish('Fresh Garden Salad', '1 plate (100g)', 40, 1, 8, 0, 'Crunchy greens, lemon.'),
            ], 'Biryani made with brown basmati and grilled paneer is high in protein and low in refined fats.'),
            _meal('snack2', 'Evening Refresh • Jeera Chaas', '5:00 PM', (cals * 0.10).round(), (prot * 0.08).round(), [
              _dish('Masala Chaas with Roasted Cumin & Mint', '1 tall tumbler (300ml)', 70, 5, 5, 3, 'Aids post-meal gut motility.'),
              _dish('Roasted Chana', '25g portion', 90, 5, 14, 1, 'Guilt-free crunch.'),
            ], 'Roasted cumin (jeera) stimulates pancreatic enzymes for peak digestion.'),
            _meal('dinner', 'Dinner • Restorative Moong Khichdi & Haldi Milk', '8:00 PM', (cals * 0.20).round(), (prot * 0.22).round(), [
              _dish('Comforting Moong Dal Khichdi with Steamed Veggies', '1 large bowl (200g)', 240, 12, 38, 4, 'Split yellow lentils, rice, carrots, peas, hing tadka.'),
              _dish('Golden Turmeric Milk', '1 cup (150ml)', 85, 5, 7, 3, 'Warm bedtime recovery ritual.'),
            ], 'Khichdi is the ultimate Ayurvedic restorative meal before a new training week.'),
          ],
        _ => <IndianMeal>[],
      };

      final totalCals = meals.fold<int>(0, (s, m) => s + m.calories);
      final totalProt = meals.fold<int>(0, (s, m) => s + m.protein);

      return DailyDietPlan(
        dayIndex: i,
        dayName: dayNames[i],
        theme: themes[i],
        totalCalories: totalCals,
        totalProtein: totalProt,
        meals: meals,
      );
    });
  }

  // =========================================================================
  // 2. VEGAN: 7-DAY MEAL SCHEDULE (100% Plant-Based Indian)
  // =========================================================================
  static List<DailyDietPlan> _buildVegan7Days(int cals, int prot, int carb, int fat) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final themes = [
      'Plant Protein Kickstart • Tofu Chilla & Soya Curries',
      'Legume Ignition • Rajma & Sprouted Moong',
      'Calcium & Fiber • Ragi Dosa & White Chana',
      'Desi Power • Kala Chana & Hand-Pounded Rice',
      'Clean Steamed Greens • Palak Tofu & Soya Pulav',
      'Grain Diversity • Bajra Phulka & Black Eyed Peas',
      'Ayurvedic Vegan Reset • Mixed Dal Khichdi & Tofu Stir Fry',
    ];

    return List.generate(7, (i) {
      final List<IndianMeal> meals = switch (i) {
        0 => [
            _meal('breakfast', 'Morning Fuel • Besan Oats Chilla & Tofu', '7:30 AM', (cals * 0.24).round(), (prot * 0.26).round(), [
              _dish('Besan Oats Chilla with Crumbled Tofu', '2 chillas (180g)', 330, 21, 36, 11, 'Gram flour, oats, 60g organic tofu, coriander.'),
              _dish('Fresh Tomato Chutney', '2 tbsp', 30, 1, 5, 1, 'Tomatoes, shallots, curry leaves.'),
              _dish('Turmeric Almond Milk Latte', '1 cup', 50, 2, 3, 3, 'Unsweetened almond milk, turmeric.'),
            ], 'Organic firm tofu delivers all 9 essential amino acids with zero cholesterol.'),
            _meal('snack1', 'Mid-Morning • Roasted Kala Chana', '11:00 AM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Roasted Black Chickpeas', '1 bowl (40g)', 145, 8, 22, 3, 'Crunchy whole black chana, pink salt.'),
              _dish('Pumpkin & Chia Seeds', '1 tbsp', 75, 3, 2, 6, 'Plant zinc & magnesium.'),
            ], 'Black chana is one of the highest protein-to-cost staples in traditional fitness.'),
            _meal('lunch', 'Power Lunch • Soya Chunks & Rajma Curry', '1:00 PM', (cals * 0.32).round(), (prot * 0.32).round(), [
              _dish('Soya Chunks & Green Pea Curry', '1 large bowl (180g)', 230, 24, 16, 6, '50g dry soya chunks, tomato gravy, jeera.'),
              _dish('Punjabi Rajma Curry', '1 katori (150g)', 160, 9, 26, 2, 'Red kidney beans, onion-tomato masala.'),
              _dish('Hand-Pounded Brown Rice', '1 cup (120g)', 160, 4, 34, 1, 'Low glycemic index rice.'),
              _dish('Lemon Sprout Salad', '1 bowl (100g)', 70, 4, 12, 0, 'Sprouted moong, cucumber, fresh lime.'),
            ], 'Soya chunks feature 52% protein by weight — highest in the plant kingdom.'),
            _meal('snack2', 'Pre-Workout • Sattu Elixir', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Desi Sattu Sherbet with Lemon', '1 tall tumbler (300ml)', 150, 11, 20, 3, 'Roasted gram flour, rock salt, mint.'),
              _dish('Roasted Peanuts with Jaggery', '20g portion', 90, 3, 9, 5, 'Iron & good monounsaturated fats.'),
            ], 'Sattu sherbet provides sustained pre-workout muscular stamina.'),
            _meal('dinner', 'Dinner • Tofu Bhurji & Lauki Soup', '7:45 PM', (cals * 0.20).round(), (prot * 0.18).round(), [
              _dish('Tofu Bhurji with Bell Peppers', '1 bowl (160g)', 200, 17, 7, 11, '120g firm tofu, capsicum, peas, turmeric.'),
              _dish('Lauki & Moong Dal Light Soup', '1 bowl (200ml)', 95, 6, 14, 1, 'Bottle gourd, yellow moong, ginger.'),
              _dish('1 Multigrain Phulka', '1 roti (40g)', 85, 3, 17, 1, 'Whole wheat & ragi.'),
            ], 'Bottle gourd calms the gastrointestinal tract overnight.'),
          ],
        _ => [
            _meal('breakfast', 'Morning Fuel • Sprouted Vegan Chilla & Tofu', '7:30 AM', (cals * 0.24).round(), (prot * 0.24).round(), [
              _dish('Sprouted Moong Chilla with Tofu Scramble', '2 chillas (170g)', 310, 20, 34, 10, 'Green moong, 60g tofu, ginger, spices.'),
              _dish('Mint Coriander Dip', '2 tbsp', 30, 1, 4, 1, 'Fresh greens, rock salt, lemon.'),
            ], 'Clean plant-based morning nutrition.'),
            _meal('snack1', 'Mid-Morning • High-Zinc Seeds & Makhana', '11:00 AM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Roasted Foxnuts with Chaat Masala', '1 bowl (35g)', 120, 4, 22, 2, 'Foxnuts, spices.'),
              _dish('Soaked Walnuts & Pumpkin Seeds', '20g portion', 100, 4, 3, 8, 'Plant Omega-3s.'),
            ], 'Omega-3 fatty acids lubricate synovial joint capsules.'),
            _meal('lunch', 'Power Lunch • Chole Masala & Brown Rice', '1:00 PM', (cals * 0.32).round(), (prot * 0.32).round(), [
              _dish('White Chickpea Chole Masala', '1 large bowl (180g)', 240, 14, 32, 6, 'Kabuli chana, anardana, ginger.'),
              _dish('Steamed Hand-Pounded Brown Rice', '1 cup (130g)', 160, 4, 34, 1, 'Complex carbs.'),
              _dish('Steamed French Beans & Carrots', '1 bowl (100g)', 75, 2, 10, 3, 'Rich in carotenoids.'),
              _dish('Cucumber Kachumber', '1 bowl (80g)', 40, 1, 8, 0, 'Cooling salad.'),
            ], 'Legumes and whole grains provide complete amino acids.'),
            _meal('snack2', 'Pre-Workout • Sattu Cooler & Banana', '4:45 PM', (cals * 0.12).round(), (prot * 0.12).round(), [
              _dish('Sattu Drink with Mint', '1 tumbler (300ml)', 140, 10, 19, 3, 'Gram flour, lemon, mint.'),
              _dish('1 Banana', '1 fruit', 90, 1, 23, 0, 'Clean muscular fuel.'),
            ], 'Fast energy release.'),
            _meal('dinner', 'Dinner • Palak Tofu & Moong Soup', '7:45 PM', (cals * 0.20).round(), (prot * 0.20).round(), [
              _dish('Palak Tofu (Spinach Tofu Gravy)', '1 bowl (180g)', 210, 17, 8, 12, 'Blanched spinach, 90g tofu, garlic.'),
              _dish('1 Jowar Phulka', '1 roti (45g)', 90, 3, 19, 1, 'Sorghum bread.'),
              _dish('Yellow Moong Broth', '1 bowl (180ml)', 80, 5, 12, 1, 'Restorative soup.'),
            ], 'Iron-rich spinach and protein-dense tofu for recovery.'),
          ],
      };

      final totalCals = meals.fold<int>(0, (s, m) => s + m.calories);
      final totalProt = meals.fold<int>(0, (s, m) => s + m.protein);

      return DailyDietPlan(
        dayIndex: i,
        dayName: dayNames[i],
        theme: themes[i],
        totalCalories: totalCals,
        totalProtein: totalProt,
        meals: meals,
      );
    });
  }

  // =========================================================================
  // 3. NON-VEGETARIAN: 7-DAY MEAL SCHEDULE (Indian Non-Veg Protein)
  // =========================================================================
  static List<DailyDietPlan> _buildNonVeg7Days(int cals, int prot, int carb, int fat) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final themes = [
      'High Albumin Kickstart • Egg Bhurji & Tandoori Chicken',
      'Omega-3 Fish Fuel • Masala Omelette & Rohu Fish Curry',
      'Lean Minced Power • Egg Whites & Chicken Keema Matar',
      'Poultry & Greens • Chicken Saag & Yellow Moong',
      'High-Tension Friday • Tandoori Chicken Breast & Rice',
      'Weekend Protein Feast • Fish Tikka & Chicken Biryani',
      'Sunday Akuri & Homestyle Curry Reset',
    ];

    return List.generate(7, (i) {
      final List<IndianMeal> meals = switch (i) {
        0 => [
            _meal('breakfast', 'Morning Fuel • Desi Egg White Bhurji & Phulka', '7:30 AM', (cals * 0.24).round(), (prot * 0.28).round(), [
              _dish('Spicy Egg Bhurji (3 Whites + 1 Whole)', '1 plate (150g)', 210, 21, 4, 11, '4 eggs, onions, tomatoes, chillies, coriander.'),
              _dish('Whole Wheat Phulkas', '2 phulkas (70g)', 160, 5, 32, 1, 'Stone ground flour.'),
              _dish('Ginger Cardamom Green Tea', '1 mug', 10, 0, 2, 0, 'Thermogenic spices.'),
            ], 'Whole egg yolk supplies lutein, choline, and fat-soluble vitamins.'),
            _meal('snack1', 'Mid-Morning • Boiled Egg Whites & Papaya', '11:00 AM', (cals * 0.12).round(), (prot * 0.14).round(), [
              _dish('Boiled Egg Whites with Chaat Masala', '2 whites (66g)', 34, 7, 0, 0, 'Pure albumin protein.'),
              _dish('Fresh Papaya / Guava Cubes', '1 bowl (150g)', 80, 1, 19, 0, 'Digestive enzymes.'),
              _dish('Soaked Almonds & Walnuts', '6 almonds + 2 walnuts', 90, 3, 3, 8, 'Cellular health fats.'),
            ], 'Guava has 4x more vitamin C than an orange and 4g protein per cup.'),
            _meal('lunch', 'Power Lunch • Grilled Tandoori Chicken & Dal', '1:00 PM', (cals * 0.32).round(), (prot * 0.34).round(), [
              _dish('Grilled Tandoori Chicken Breast', '150g cooked', 240, 34, 4, 8, 'Skinless breast, dahi marinade, spices, lemon.'),
              _dish('Yellow Moong Dal', '1 katori (140g)', 120, 8, 19, 2, 'Lentils, tomato, hing tadka.'),
              _dish('Steamed Brown Rice / 2 Phulkas', '1 serving (120g)', 160, 4, 34, 1, 'Glycogen replenishment.'),
              _dish('Kachumber Salad & Curd', '1 bowl', 90, 6, 9, 3, 'Fresh veggies & probiotic dahi.'),
            ], 'Chicken breast contains 31g protein per 100g with minimal saturated fat.'),
            _meal('snack2', 'Pre-Workout • Sattu Cooler & Banana', '4:45 PM', (cals * 0.12).round(), (prot * 0.10).round(), [
              _dish('Chana Sattu Cooler / Black Coffee', '1 serving', 140, 6, 26, 2, 'Sattu or double espresso with banana.'),
              _dish('Roasted Makhana', '1 bowl (30g)', 110, 4, 18, 2, 'Low glycemic index carb.'),
            ], 'Caffeine 40 minutes before workout boosts muscular motor unit firing.'),
            _meal('dinner', 'Dinner • Dry Roasted Chicken Tikka', '7:45 PM', (cals * 0.20).round(), (prot * 0.24).round(), [
              _dish('Dry Roasted Chicken Tikka', '130g portion', 200, 28, 3, 7, 'Chicken breast cubes, hung curd, degi mirch, lemon.'),
              _dish('Sautéed Indian Green Beans & Carrots', '1 bowl (150g)', 90, 3, 12, 3, 'Mustard oil, jeera, turmeric.'),
              _dish('1 Multigrain Phulka / Clear Broth', '1 serving', 85, 4, 16, 1, 'Light evening carbohydrate.'),
            ], 'Low-carb dinner promotes overnight fat oxidation and growth hormone release.'),
          ],
        _ => [
            _meal('breakfast', 'Morning Fuel • Masala Omelette & Toast', '7:30 AM', (cals * 0.24).round(), (prot * 0.28).round(), [
              _dish('Masala Omelette (3 Whites + 1 Whole)', '1 plate', 210, 21, 4, 11, 'Eggs, onions, tomatoes, green chillies.'),
              _dish('Whole Wheat Multigrain Toast', '2 slices (60g)', 150, 5, 28, 2, 'Fiber-rich complex carbs.'),
              _dish('Ginger Lemon Green Tea', '1 mug', 10, 0, 2, 0, 'Metabolism booster.'),
            ], 'High-protein breakfast stops mid-morning hunger pangs.'),
            _meal('snack1', 'Mid-Morning • Boiled Eggs & Fruit', '11:00 AM', (cals * 0.12).round(), (prot * 0.14).round(), [
              _dish('Boiled Egg Whites', '2 whites', 34, 7, 0, 0, 'Clean protein.'),
              _dish('Fresh Apple / Seasonal Orange', '1 fruit', 75, 1, 18, 0, 'Fiber & antioxidants.'),
              _dish('Soaked Almonds', '6 almonds', 45, 2, 2, 4, 'Healthy fats.'),
            ], 'Clean morning snack to keep nitrogen balance positive.'),
            _meal('lunch', 'Power Lunch • Fresh Fish Curry / Chicken & Rice', '1:00 PM', (cals * 0.32).round(), (prot * 0.34).round(), [
              _dish('Freshwater Rohu Fish Curry / Chicken', '160g portion', 230, 32, 4, 8, 'Fresh fish, mustard & tomato gravy, turmeric.'),
              _dish('Yellow Moong Dal', '1 katori', 120, 8, 19, 2, 'Lentils & cumin.'),
              _dish('Steamed Hand-Pounded Rice', '1 cup', 160, 4, 34, 1, 'Sustained energy.'),
              _dish('Green Salad & Fresh Curd', '1 bowl', 85, 5, 8, 3, 'Probiotic accompaniment.'),
            ], 'Fresh fish provides marine Omega-3 fatty acids for joint health.'),
            _meal('snack2', 'Pre-Workout • Sattu Drink & Banana', '4:45 PM', (cals * 0.12).round(), (prot * 0.10).round(), [
              _dish('Sattu Buttermilk Cooler', '1 glass', 130, 8, 18, 2, 'Sustained stamina.'),
              _dish('1 Banana', '1 fruit', 90, 1, 23, 0, 'Fast energy fuel.'),
            ], 'Pre-workout carb timing prevents in-session fatigue.'),
            _meal('dinner', 'Dinner • Chicken Tikka & Steamed Veggies', '7:45 PM', (cals * 0.20).round(), (prot * 0.24).round(), [
              _dish('Tandoori Chicken Tikka', '140g portion', 210, 30, 3, 7, 'Chicken breast, lemon, spices.'),
              _dish('Sautéed Seasonal Vegetables', '1 bowl', 80, 2, 11, 2, 'Vitamins and minerals.'),
              _dish('1 Phulka', '1 roti', 85, 3, 17, 1, 'Light dinner carb.'),
            ], 'High protein dinner accelerates muscle fiber remodeling while you sleep.'),
          ],
      };

      final totalCals = meals.fold<int>(0, (s, m) => s + m.calories);
      final totalProt = meals.fold<int>(0, (s, m) => s + m.protein);

      return DailyDietPlan(
        dayIndex: i,
        dayName: dayNames[i],
        theme: themes[i],
        totalCalories: totalCals,
        totalProtein: totalProt,
        meals: meals,
      );
    });
  }

  // --- Helper Builders ---
  static IndianMeal _meal(String id, String title, String time, int cals, int prot, List<IndianDish> dishes, String tip) {
    return IndianMeal(
      mealId: id,
      title: title,
      timeSlot: time,
      calories: cals,
      protein: prot,
      carbs: (cals * 0.45 / 4).round(),
      fats: (cals * 0.25 / 9).round(),
      dishes: dishes,
      chefTip: tip,
    );
  }

  static IndianDish _dish(String name, String portion, int cals, int prot, int carb, int fat, String ingredients) {
    return IndianDish(
      name: name,
      portion: portion,
      calories: cals,
      protein: prot,
      carbs: carb,
      fats: fat,
      ingredients: ingredients,
    );
  }
}
