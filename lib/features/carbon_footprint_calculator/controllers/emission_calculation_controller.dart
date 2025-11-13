// import 'dart:math';
//
// /// Service class for calculating carbon emissions across different categories
// class EmissionCalculationService {
//   EmissionCalculationService._();
//   static final EmissionCalculationService _instance = EmissionCalculationService._();
//   static EmissionCalculationService get instance => _instance;
//
//   /// Calculate Land Travel Emissions
//   ///
//   /// Parameters:
//   /// - weeklyDistance: Distance traveled per week in km
//   /// - fuelEfficiency: Fuel consumption in L/100km
//   /// - vehicleType: Type of vehicle (Car, Bus, Train, Motorcycle, Bicycle)
//   /// - fuelType: Type of fuel (Petrol, Diesel, Electric, Hybrid)
//   ///
//   /// Returns: Annual CO2e emissions in kg
//   double calculateLandTravelEmissions({
//     required double weeklyDistance,
//     required double fuelEfficiency,
//     required String vehicleType,
//     required String fuelType,
//   }) {
//     // Emission factors (kg CO2e per liter of fuel)
//     final Map<String, double> emissionFactors = {
//       'Petrol': 2.31,
//       'Diesel': 2.68,
//       'Electric': 0.45, // Grid electricity emissions (varies by region)
//       'Hybrid': 1.85,
//       'Hydrogen': 0.0, // Assuming green hydrogen
//     };
//
//     // Vehicle efficiency modifiers (per person usage)
//     final Map<String, double> vehicleModifiers = {
//       'Car': 1.0,
//       'Bus': 0.3, // Shared among passengers
//       'Train': 0.2, // More efficient per person
//       'Motorcycle': 1.2, // Less efficient than cars
//       'Bicycle': 0.0, // No emissions
//       'Walking': 0.0, // No emissions
//       'Scooter': 0.8, // Electric scooters
//     };
//
//     // Zero emission vehicles
//     if (vehicleType == 'Bicycle' || vehicleType == 'Walking') {
//       return 0.0;
//     }
//
//     // Special handling for electric vehicles
//     if (fuelType == 'Electric') {
//       final annualDistance = weeklyDistance * 52;
//       final energyConsumption = annualDistance * (fuelEfficiency / 100); // kWh
//       final vehicleModifier = vehicleModifiers[vehicleType] ?? 1.0;
//       return energyConsumption * emissionFactors['Electric']! * vehicleModifier;
//     }
//
//     // Convert weekly to annual distance
//     final annualDistance = weeklyDistance * 52;
//
//     // Calculate fuel consumption (L/year)
//     final fuelConsumption = (annualDistance * fuelEfficiency) / 100;
//
//     // Get factors
//     final emissionFactor = emissionFactors[fuelType] ?? 2.31;
//     final vehicleModifier = vehicleModifiers[vehicleType] ?? 1.0;
//
//     return fuelConsumption * emissionFactor * vehicleModifier;
//   }
//
//   /// Calculate Air Travel Emissions
//   ///
//   /// Parameters:
//   /// - numberOfFlights: Number of round trips per year
//   /// - averageDistance: Average flight distance in km (one way)
//   /// - flightType: Type of flight (Domestic, Short-haul, Long-haul)
//   ///
//   /// Returns: Annual CO2e emissions in kg
//   double calculateAirTravelEmissions({
//     required double numberOfFlights,
//     required double averageDistance,
//     required String flightType,
//   }) {
//     // Emission factors (kg CO2e per passenger per km)
//     final Map<String, double> emissionFactors = {
//       'Domestic': 0.255,     // Short flights are less efficient
//       'Short-haul': 0.156,   // Medium efficiency (< 1500km)
//       'Long-haul': 0.150,    // More efficient on long distances (> 1500km)
//     };
//
//     final emissionFactor = emissionFactors[flightType] ?? 0.156;
//
//     // Round trip calculation (multiply by 2 for return journey)
//     final totalDistance = numberOfFlights * averageDistance * 2;
//
//     // Apply radiative forcing factor (1.9) for high-altitude emissions
//     final radiativeForcing = 1.9;
//
//     return totalDistance * emissionFactor * radiativeForcing;
//   }
//
//   /// Calculate Food Emissions
//   ///
//   /// Parameters:
//   /// - dietType: Type of diet (Omnivore, Vegetarian, Vegan, Pescatarian)
//   /// - meatConsumption: Weekly consumption of different meat types
//   /// - dairyConsumption: Weekly consumption of dairy products
//   /// - preferLocalFood: Whether user prefers local/seasonal food
//   ///
//   /// Returns: Annual CO2e emissions in kg
//   double calculateFoodEmissions({
//     required String dietType,
//     required Map<String, double> meatConsumption,
//     required Map<String, double> dairyConsumption,
//     required bool preferLocalFood,
//   }) {
//     // Meat emission factors (kg CO2e per serving)
//     final Map<String, double> meatFactors = {
//       'Beef': 6.61,
//       'Pork': 2.45,
//       'Chicken': 1.57,
//       'Fish': 1.70,
//       'Lamb': 5.94,
//     };
//
//     // Dairy emission factors (kg CO2e per serving)
//     final Map<String, double> dairyFactors = {
//       'Milk': 0.63,
//       'Cheese': 2.78,
//       'Eggs': 0.51,
//       'Yogurt': 0.72,
//       'Butter': 3.15,
//     };
//
//     double totalEmissions = 0.0;
//
//     // Calculate meat emissions based on diet type
//     if (dietType != 'Vegan') {
//       meatConsumption.forEach((type, weekly) {
//         if (dietType == 'Vegetarian' && type != 'Fish') {
//           return; // Skip non-fish meat for vegetarians
//         }
//         if (dietType == 'Pescatarian' && type != 'Fish') {
//           return; // Only fish for pescatarians
//         }
//
//         final factor = meatFactors[type] ?? 0.0;
//         totalEmissions += weekly * factor * 52; // Weekly to annual
//       });
//     }
//
//     // Calculate dairy emissions (vegans don't consume dairy)
//     if (dietType != 'Vegan') {
//       dairyConsumption.forEach((type, weekly) {
//         final factor = dairyFactors[type] ?? 0.0;
//         totalEmissions += weekly * factor * 52; // Weekly to annual
//       });
//     }
//
//     // Base emissions from plant foods, grains, processed foods
//     final Map<String, double> baseDietEmissions = {
//       'Omnivore': 650.0,
//       'Vegetarian': 450.0,
//       'Vegan': 350.0,
//       'Pescatarian': 500.0,
//     };
//
//     totalEmissions += baseDietEmissions[dietType] ?? 650.0;
//
//     // Apply local food preference discount
//     if (preferLocalFood) {
//       totalEmissions *= 0.9; // 10% reduction
//     }
//
//     return totalEmissions;
//   }
//
//   /// Calculate Energy/Home Emissions
//   ///
//   /// Parameters:
//   /// - monthlyElectricityUsage: kWh per month
//   /// - heatingType: Type of heating (Gas, Electric, Oil, Heat Pump, Solar)
//   /// - monthlyHeatingUsage: Monthly heating consumption (kWh or L)
//   /// - homeSize: Size category (Small, Medium, Large)
//   /// - renewableEnergy: Percentage of renewable energy used (0-100)
//   ///
//   /// Returns: Annual CO2e emissions in kg
//   double calculateHomeEnergyEmissions({
//     required double monthlyElectricityUsage,
//     required String heatingType,
//     required double monthlyHeatingUsage,
//     required String homeSize,
//     required double renewableEnergyPercent,
//   }) {
//     // Electricity emission factor (kg CO2e per kWh) - varies by grid
//     double electricityFactor = 0.45; // Average grid emissions
//
//     // Apply renewable energy reduction
//     electricityFactor *= (100 - renewableEnergyPercent) / 100;
//
//     // Heating emission factors
//     final Map<String, double> heatingFactors = {
//       'Gas': 0.185, // kg CO2e per kWh equivalent
//       'Electric': electricityFactor,
//       'Oil': 0.245,
//       'Heat Pump': electricityFactor * 0.3, // Heat pumps are 3x more efficient
//       'Solar': 0.0,
//       'Wood': 0.39, // Assuming sustainable wood
//     };
//
//     // Home size multipliers for base consumption
//     final Map<String, double> sizeMultipliers = {
//       'Small': 0.8,
//       'Medium': 1.0,
//       'Large': 1.3,
//       'Very Large': 1.6,
//     };
//
//     final sizeMultiplier = sizeMultipliers[homeSize] ?? 1.0;
//
//     // Calculate annual electricity emissions
//     final annualElectricity = monthlyElectricityUsage * 12 * sizeMultiplier;
//     final electricityEmissions = annualElectricity * electricityFactor;
//
//     // Calculate annual heating emissions
//     final heatingFactor = heatingFactors[heatingType] ?? 0.185;
//     final annualHeating = monthlyHeatingUsage * 12 * sizeMultiplier;
//     final heatingEmissions = annualHeating * heatingFactor;
//
//     return electricityEmissions + heatingEmissions;
//   }
//
//   /// Calculate Consumption/Shopping Emissions
//   ///
//   /// Parameters:
//   /// - monthlySpending: Monthly spending on different categories
//   /// - shoppingHabits: Shopping preferences (New, Used, Eco-friendly, etc.)
//   ///
//   /// Returns: Annual CO2e emissions in kg
//   double calculateConsumptionEmissions({
//     required Map<String, double> monthlySpending,
//     required Map<String, String> shoppingHabits,
//   }) {
//     // Emission factors (kg CO2e per dollar spent)
//     final Map<String, double> spendingFactors = {
//       'Clothing': 0.025,
//       'Electronics': 0.035,
//       'Furniture': 0.020,
//       'Entertainment': 0.015,
//       'Services': 0.010,
//       'Other': 0.020,
//     };
//
//     // Shopping habit modifiers
//     final Map<String, double> habitModifiers = {
//       'New': 1.0,
//       'Used/Second-hand': 0.3,
//       'Eco-friendly': 0.7,
//       'Minimal': 0.5,
//       'Frequent': 1.3,
//     };
//
//     double totalEmissions = 0.0;
//
//     monthlySpending.forEach((category, amount) {
//       final factor = spendingFactors[category] ?? 0.020;
//       final habit = shoppingHabits[category] ?? 'New';
//       final modifier = habitModifiers[habit] ?? 1.0;
//
//       final annualSpending = amount * 12;
//       totalEmissions += annualSpending * factor * modifier;
//     });
//
//     return totalEmissions;
//   }
//
//   /// Calculate overall carbon footprint impact score
//   ///
//   /// Parameters:
//   /// - totalEmissions: Total annual CO2e emissions in kg
//   /// - userLocation: User's country/region for comparison
//   ///
//   /// Returns: Map with impact score and comparison data
//   Map<String, dynamic> calculateImpactScore({
//     required double totalEmissions,
//     String userLocation = 'Global',
//   }) {
//     // Global and regional averages (kg CO2e per person per year)
//     final Map<String, double> regionalAverages = {
//       'Global': 4800.0,
//       'USA': 15500.0,
//       'Europe': 8500.0,
//       'China': 7700.0,
//       'India': 1900.0,
//       'Malaysia': 8500.0,
//       'Singapore': 10200.0,
//       'Australia': 17100.0,
//     };
//
//     final regionalAverage = regionalAverages[userLocation] ?? regionalAverages['Global']!;
//
//     // Calculate percentile compared to regional average
//     final percentageOfAverage = (totalEmissions / regionalAverage) * 100;
//
//     // Determine impact level
//     String impactLevel;
//     String impactDescription;
//
//     if (percentageOfAverage <= 50) {
//       impactLevel = 'Low';
//       impactDescription = 'Your carbon footprint is significantly below average. Great job!';
//     } else if (percentageOfAverage <= 80) {
//       impactLevel = 'Below Average';
//       impactDescription = 'Your carbon footprint is below the regional average. Keep it up!';
//     } else if (percentageOfAverage <= 120) {
//       impactLevel = 'Average';
//       impactDescription = 'Your carbon footprint is around the regional average.';
//     } else if (percentageOfAverage <= 150) {
//       impactLevel = 'Above Average';
//       impactDescription = 'Your carbon footprint is above the regional average. Consider reducing emissions.';
//     } else {
//       impactLevel = 'High';
//       impactDescription = 'Your carbon footprint is significantly above average. Urgent action recommended.';
//     }
//
//     return {
//       'totalEmissions': totalEmissions,
//       'regionalAverage': regionalAverage,
//       'percentageOfAverage': percentageOfAverage,
//       'impactLevel': impactLevel,
//       'impactDescription': impactDescription,
//       'region': userLocation,
//     };
//   }
//
//   /// Calculate emissions by category breakdown
//   ///
//   /// Parameters:
//   /// - categoryEmissions: Map of category names to emission values
//   ///
//   /// Returns: Map with percentage breakdown and insights
//   Map<String, dynamic> calculateCategoryBreakdown({
//     required Map<String, double> categoryEmissions,
//   }) {
//     final totalEmissions = categoryEmissions.values.fold(0.0, (sum, value) => sum + value);
//
//     if (totalEmissions == 0) {
//       return {
//         'breakdown': <String, double>{},
//         'insights': <String>[],
//         'topCategories': <String>[],
//       };
//     }
//
//     // Calculate percentages
//     final breakdown = categoryEmissions.map(
//           (category, emissions) => MapEntry(category, (emissions / totalEmissions) * 100),
//     );
//
//     // Sort categories by emissions (highest first)
//     final sortedCategories = breakdown.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//
//     final topCategories = sortedCategories.take(3).map((e) => e.key).toList();
//
//     // Generate insights
//     final insights = <String>[];
//
//     if (breakdown['transport'] != null && breakdown['transport']! > 40) {
//       insights.add('Transportation is your largest emission source. Consider using public transport or electric vehicles.');
//     }
//
//     if (breakdown['food'] != null && breakdown['food']! > 30) {
//       insights.add('Food contributes significantly to your footprint. Try reducing meat consumption.');
//     }
//
//     if (breakdown['home'] != null && breakdown['home']! > 35) {
//       insights.add('Home energy use is high. Consider renewable energy or better insulation.');
//     }
//
//     if (breakdown['air_travel'] != null && breakdown['air_travel']! > 25) {
//       insights.add('Air travel creates substantial emissions. Consider offsetting flights or reducing frequency.');
//     }
//
//     return {
//       'breakdown': breakdown,
//       'insights': insights,
//       'topCategories': topCategories,
//       'totalEmissions': totalEmissions,
//     };
//   }
//
//   /// Calculate potential emission reductions
//   ///
//   /// Parameters:
//   /// - currentEmissions: Current emissions by category
//   /// - targetReductionPercent: Target reduction percentage (0-100)
//   ///
//   /// Returns: Map with reduction recommendations
//   Map<String, dynamic> calculateReductionPotential({
//     required Map<String, double> currentEmissions,
//     required double targetReductionPercent,
//   }) {
//     final totalCurrent = currentEmissions.values.fold(0.0, (sum, value) => sum + value);
//     final targetReduction = totalCurrent * (targetReductionPercent / 100);
//
//     // Reduction potentials by category (realistic percentages)
//     final Map<String, double> reductionPotentials = {
//       'transport': 0.60, // 60% reduction possible with EVs, public transport
//       'air_travel': 0.80, // High reduction potential by reducing flights
//       'food': 0.50, // 50% reduction with diet changes
//       'home': 0.40, // 40% reduction with efficiency and renewables
//       'consumption': 0.70, // 70% reduction with mindful consumption
//     };
//
//     final recommendations = <Map<String, dynamic>>[];
//     double totalPotentialReduction = 0.0;
//
//     currentEmissions.forEach((category, emissions) {
//       final potential = reductionPotentials[category] ?? 0.3;
//       final maxReduction = emissions * potential;
//       totalPotentialReduction += maxReduction;
//
//       recommendations.add({
//         'category': category,
//         'currentEmissions': emissions,
//         'maxReduction': maxReduction,
//         'potentialPercent': potential * 100,
//         'priority': _getCategoryPriority(category, emissions, totalCurrent),
//       });
//     });
//
//     // Sort by priority (impact potential)
//     recommendations.sort((a, b) => b['priority'].compareTo(a['priority']));
//
//     return {
//       'currentTotal': totalCurrent,
//       'targetReduction': targetReduction,
//       'maxPossibleReduction': totalPotentialReduction,
//       'isTargetAchievable': totalPotentialReduction >= targetReduction,
//       'recommendations': recommendations,
//       'targetReductionPercent': targetReductionPercent,
//     };
//   }
//
//   /// Calculate emission trends over time
//   ///
//   /// Parameters:
//   /// - historicalData: List of emission records with timestamps
//   ///
//   /// Returns: Map with trend analysis
//   Map<String, dynamic> calculateEmissionTrends({
//     required List<Map<String, dynamic>> historicalData,
//   }) {
//     if (historicalData.length < 2) {
//       return {
//         'trend': 'insufficient_data',
//         'changePercent': 0.0,
//         'averageMonthlyChange': 0.0,
//         'prediction': null,
//       };
//     }
//
//     // Sort by date
//     historicalData.sort((a, b) =>
//         DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
//
//     final first = historicalData.first['totalEmissions'] as double;
//     final last = historicalData.last['totalEmissions'] as double;
//     final changePercent = ((last - first) / first) * 100;
//
//     // Calculate average monthly change
//     final monthsDiff = DateTime.parse(historicalData.last['date'])
//         .difference(DateTime.parse(historicalData.first['date']))
//         .inDays / 30.44; // Average days per month
//
//     final averageMonthlyChange = monthsDiff > 0 ? (last - first) / monthsDiff : 0.0;
//
//     String trend;
//     if (changePercent > 10) {
//       trend = 'increasing';
//     } else if (changePercent < -10) {
//       trend = 'decreasing';
//     } else {
//       trend = 'stable';
//     }
//
//     // Simple linear prediction for next period
//     final nextPrediction = last + averageMonthlyChange;
//
//     return {
//       'trend': trend,
//       'changePercent': changePercent,
//       'averageMonthlyChange': averageMonthlyChange,
//       'firstEmissions': first,
//       'lastEmissions': last,
//       'prediction': max(0, nextPrediction), // Cannot be negative
//       'dataPoints': historicalData.length,
//     };
//   }
//
//   /// Helper method to calculate category priority for reductions
//   double _getCategoryPriority(String category, double emissions, double totalEmissions) {
//     final percentage = (emissions / totalEmissions) * 100;
//
//     // Priority weights based on impact and feasibility
//     final Map<String, double> categoryWeights = {
//       'transport': 1.2, // High impact, good feasibility
//       'air_travel': 1.5, // Very high impact per unit
//       'food': 1.0, // Moderate impact, good feasibility
//       'home': 0.8, // Lower immediate impact
//       'consumption': 1.1, // Good impact, high feasibility
//     };
//
//     final weight = categoryWeights[category] ?? 1.0;
//     return percentage * weight;
//   }
//
//   /// Validate emission calculation inputs
//   bool validateInputs({
//     required Map<String, dynamic> inputs,
//     required String category,
//   }) {
//     switch (category) {
//       case 'transport':
//         final distance = inputs['weeklyDistance'] as double?;
//         final efficiency = inputs['fuelEfficiency'] as double?;
//         return distance != null && efficiency != null &&
//             distance >= 0 && efficiency > 0;
//
//       case 'air_travel':
//         final flights = inputs['numberOfFlights'] as double?;
//         final distance = inputs['averageDistance'] as double?;
//         return flights != null && distance != null &&
//             flights >= 0 && distance >= 0;
//
//       case 'food':
//         final meatConsumption = inputs['meatConsumption'] as Map<String, double>?;
//         final dairyConsumption = inputs['dairyConsumption'] as Map<String, double>?;
//         return meatConsumption != null && dairyConsumption != null;
//
//       case 'home':
//         final electricity = inputs['monthlyElectricityUsage'] as double?;
//         final heating = inputs['monthlyHeatingUsage'] as double?;
//         return electricity != null && heating != null &&
//             electricity >= 0 && heating >= 0;
//
//       case 'consumption':
//         final spending = inputs['monthlySpending'] as Map<String, double>?;
//         return spending != null && spending.values.every((value) => value >= 0);
//
//       default:
//         return false;
//     }
//   }
//
//   /// Get emission benchmarks for comparison
//   Map<String, double> getEmissionBenchmarks() {
//     return {
//       'transport_low': 500.0,      // kg CO2e/year
//       'transport_average': 2500.0,
//       'transport_high': 5000.0,
//       'air_travel_low': 0.0,
//       'air_travel_average': 1000.0,
//       'air_travel_high': 3000.0,
//       'food_low': 800.0,
//       'food_average': 1500.0,
//       'food_high': 2500.0,
//       'home_low': 1000.0,
//       'home_average': 2500.0,
//       'home_high': 4000.0,
//       'consumption_low': 500.0,
//       'consumption_average': 1200.0,
//       'consumption_high': 2000.0,
//     };
//   }
// }