// ==================== Food Carbon Footprint Calculator Formulas ====================
//
// 基本公式: Annual CO2e = Frequency × Portion Weight (kg) × Weeks/Days × Emission Factor
//
// 1. 红肉 (Red Meat - Beef, Lamb, Mutton)
//    - 输入: 每周食用次数 (0-10+)
//    - 默认份量: 0.15 kg (150g cooked meat)
//    - 年度消耗: frequency/week × portionWeight × 52 weeks = kg/year
//    - 排放因子: (beef_EF + lamb_EF) / 2 = (99.48 + 39.72) / 2 = 69.6 kg CO2e/kg
//    - 年度排放: kg/year × 69.6 = total CO2e
//    - 例子: 3次/周 × 0.15kg × 52周 × 69.6 = 1,628.64 kg CO2e/year
//
// 2. 家禽 (Poultry - Chicken)
//    - 输入: 每周食用次数 (0-10+)
//    - 默认份量: 0.15 kg (150g cooked poultry)
//    - 年度消耗: frequency/week × portionWeight × 52 weeks = kg/year
//    - 排放因子: chicken_EF = 9.87 kg CO2e/kg
//    - 年度排放: kg/year × 9.87 = total CO2e
//    - 例子: 5次/周 × 0.15kg × 52周 × 9.87 = 384.65 kg CO2e/year
//
// 3. 海鲜 (Seafood - Fish & Prawns)
//    - 输入: 每周食用次数 (0-10+)
//    - 默认份量: 0.15 kg (150g cooked seafood)
//    - 年度消耗: frequency/week × portionWeight × 52 weeks = kg/year
//    - 排放因子: (fish_EF + prawns_EF) / 2 = (13.63 + 26.87) / 2 = 20.25 kg CO2e/kg
//    - 年度排放: kg/year × 20.25 = total CO2e
//    - 例子: 2次/周 × 0.15kg × 52周 × 20.25 = 316.22 kg CO2e/year
//
// 4. 乳制品与蛋类 (Dairy & Eggs - Milk, Cheese, Eggs)
//    - 输入: 每天食用次数 (0-5+)
//    - 默认份量: 0.1 kg (100g per serving)
//    - 年度消耗: frequency/day × portionWeight × 365 days = kg/year
//    - 排放因子: (milk_EF + cheese_EF + eggs_EF) / 3 = (3.15 + 23.88 + 4.67) / 3 = 10.57 kg CO2e/kg
//    - 年度排放: kg/year × 10.57 = total CO2e
//    - 例子: 2次/天 × 0.1kg × 365天 × 10.57 = 771.61 kg CO2e/year
//
// 5. 谷物主食 (Grains - Rice & Wheat)
//    - 输入: 每天食用次数 (0-5+)
//    - 默认份量: 0.15 kg (150g cooked rice/noodles)
//    - 年度消耗: frequency/day × portionWeight × 365 days = kg/year
//    - 排放因子: (rice_EF + wheat_EF) / 2 = (4.45 + 1.57) / 2 = 3.01 kg CO2e/kg
//    - 年度排放: kg/year × 3.01 = total CO2e
//    - 例子: 3次/天 × 0.15kg × 365天 × 3.01 = 494.49 kg CO2e/year
//
// 6. 植物性食物 (Plant-Based - Vegetables, Fruits, Pulses, Nuts)
//    - 输入: 每天食用次数 (0-5+)
//    - 默认份量: 0.1 kg (100g per serving)
//    - 年度消耗: frequency/day × portionWeight × 365 days = kg/year
//    - 排放因子: (veg_EF + fruit_EF + pulses_EF + nuts_EF) / 4
//                = (0.53 + 1.05 + 1.79 + 0.43) / 4 = 0.95 kg CO2e/kg
//    - 年度排放: kg/year × 0.95 = total CO2e
//    - 例子: 5次/天 × 0.1kg × 365天 × 0.95 = 173.44 kg CO2e/year
//
// 注: 所有默认份量可在设置页面调整
// ==================================================================================

class FoodEmissionConfig {
  FoodEmissionConfig._();

  // ==================== Food Emission Factors ====================
  // Unit: kg CO2e per kg of edible food
  // Source: Poore & Nemecek (2018) via Our World in Data (year column = 2010)

  static const Map<String, Map<String, dynamic>> foodEmissionFactors = {
    // ---- Meats commonly eaten in Malaysia (NO PORK) ----
    'beef': {
      'ef_per_kg': 99.48, // Beef (beef herd)
      'metadata': {
        'source': 'Poore & Nemecek (2018), Beef (beef herd)',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 99.48 kg CO2e/kg (2010).',
      },
    },
    'lamb_mutton': {
      'ef_per_kg': 39.72, // Lamb & Mutton
      'metadata': {
        'source': 'Poore & Nemecek (2018), Lamb & Mutton',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 39.72 kg CO2e/kg (2010).',
      },
    },
    'chicken': {
      'ef_per_kg': 9.87, // Poultry Meat
      'metadata': {
        'source': 'Poore & Nemecek (2018), Poultry Meat',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 9.87 kg CO2e/kg (2010). Includes all poultry types.',
      },
    },
    'fish_farmed': {
      'ef_per_kg': 13.63, // Fish (farmed)
      'metadata': {
        'source': 'Poore & Nemecek (2018), Fish (farmed)',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 13.63 kg CO2e/kg (2010).',
      },
    },
    'prawns_farmed': {
      'ef_per_kg': 26.87, // Prawns (farmed)
      'metadata': {
        'source': 'Poore & Nemecek (2018), Prawns (farmed)',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 26.87 kg CO2e/kg (2010).',
      },
    },

    // ---- Eggs & dairy ----
    'eggs': {
      'ef_per_kg': 4.67,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Eggs',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 4.67 kg CO2e/kg (2010).',
      },
    },
    'milk': {
      'ef_per_kg': 3.15,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Milk',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 3.15 kg CO2e/kg (2010).',
      },
    },
    'cheese': {
      'ef_per_kg': 23.88,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Cheese',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 23.88 kg CO2e/kg (2010).',
      },
    },
    'soy_milk': {
      'ef_per_kg': 0.98,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Soy milk',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 0.98 kg CO2e/kg (2010).',
      },
    },
    'tofu': {
      'ef_per_kg': 3.16,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Tofu',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 3.16 kg CO2e/kg (2010).',
      },
    },

    // ---- Staples commonly eaten in Malaysia ----
    'rice': {
      'ef_per_kg': 4.45,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Rice',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 4.45 kg CO2e/kg (2010).',
      },
    },
    'wheat_products': {
      'ef_per_kg': 1.57, // Wheat & Rye
      'metadata': {
        'source': 'Poore & Nemecek (2018), Wheat & Rye',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 1.57 kg CO2e/kg (2010).',
      },
    },
    'potatoes': {
      'ef_per_kg': 0.46,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Potatoes',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 0.46 kg CO2e/kg (2010).',
      },
    },
    'oatmeal': {
      'ef_per_kg': 2.48,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Oatmeal',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 2.48 kg CO2e/kg (2010).',
      },
    },

    // ---- Fruits & vegetables (grouped) ----
    'fruit_mix': {
      'ef_per_kg': 1.05, // Other Fruit
      'metadata': {
        'source': 'Poore & Nemecek (2018), Other Fruit',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes':
        'Use as generic mixed fruit factor – table value 1.05 kg CO2e/kg (2010).',
      },
    },
    'vegetable_mix': {
      'ef_per_kg': 0.53, // Other Vegetables
      'metadata': {
        'source': 'Poore & Nemecek (2018), Other Vegetables',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes':
        'Use as generic mixed vegetables factor – table value 0.53 kg CO2e/kg (2010).',
      },
    },
    'tomatoes': {
      'ef_per_kg': 2.09,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Tomatoes',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 2.09 kg CO2e/kg (2010).',
      },
    },

    // ---- Pulses & nuts ----
    'peas': {
      'ef_per_kg': 0.98,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Peas',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 0.98 kg CO2e/kg (2010).',
      },
    },
    'other_pulses': {
      'ef_per_kg': 1.79,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Other Pulses',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 1.79 kg CO2e/kg (2010).',
      },
    },
    'nuts': {
      'ef_per_kg': 0.43,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Nuts',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 0.43 kg CO2e/kg (2010).',
      },
    },
    'groundnuts': {
      'ef_per_kg': 3.23,
      'metadata': {
        'source': 'Poore & Nemecek (2018), Groundnuts',
        'year': 2010,
        'link': 'https://ourworldindata.org/environmental-impacts-of-food',
        'unit': 'kg CO2e per kg food',
        'region': 'Global average',
        'notes': 'Table value: 3.23 kg CO2e/kg (2010).',
      },
    },
  };
}
