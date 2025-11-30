/// ==================== Land Travel Carbon Footprint Calculation ====================
///
/// 用户有多种输入方式，系统会根据用户提供的数据类型选择相应的计算公式。
///
/// 【1. 私人燃油车辆 (Fuel Vehicles)】
///
/// ■ 方式 A: 已知年度燃油用量 (litres/year)
///   - 公式: 年度排放 = 燃油用量 (L) × 每升排放因子 (kg CO₂e/L)
///   - 示例 (汽油):
///     · 输入: 年度加油 1000 升汽油
///     · 排放因子: 2.33086 kg CO₂e/L (DEFRA 2023)
///     · 计算: 1000 L × 2.33086 = 2,330.86 kg CO₂e/year
///   - 示例 (柴油):
///     · 输入: 年度加油 800 升柴油
///     · 排放因子: 2.626 kg CO₂e/L (DEFRA 2023)
///     · 计算: 800 L × 2.626 = 2,100.8 kg CO₂e/year
///
/// ■ 方式 B: 已知年度行驶距离 (km/year)
///   - 公式: 年度排放 = 行驶距离 (km) × 每公里排放因子 (kg CO₂e/km)
///   - 示例 (汽车):
///     · 输入: 年度行驶 15,000 km
///     · 排放因子: 0.16983 kg CO₂e/km (DEFRA 2023, average car)
///     · 计算: 15,000 km × 0.16983 = 2,547.45 kg CO₂e/year
///   - 示例 (摩托车):
///     · 输入: 年度行驶 8,000 km
///     · 排放因子: 0.11367 kg CO₂e/km (DEFRA 2023)
///     · 计算: 8,000 km × 0.11367 = 909.36 kg CO₂e/year
///
/// 【2. 电动车 (Electric Vehicles)】
///
///   - 公式: 年度排放 = (行驶距离 × 电耗 ÷ 100) × 电网排放因子
///   - 步骤:
///     1. 计算年度用电量 (kWh): 距离 (km) × 电耗 (kWh/100km) ÷ 100
///     2. 计算排放: 年度用电量 × 马来西亚电网排放因子 (0.774 kg CO₂e/kWh)
///   - 示例:
///     · 输入: 年度行驶 12,000 km，电耗 18 kWh/100km
///     · 计算用电: 12,000 × 18 ÷ 100 = 2,160 kWh
///     · 电网因子: 0.774 kg CO₂e/kWh (Malaysia Peninsular, 2022)
///     · 计算排放: 2,160 kWh × 0.774 = 1,671.84 kg CO₂e/year
///
/// 【3. 公共交通 (Public Transport)】
///
///   - 公式: 年度排放 = 行驶距离 (km) × 每乘客公里排放因子 (kg CO₂e/passenger-km)
///   - 巴士 (Bus):
///     · 输入: 年度乘坐 2,000 km
///     · 排放因子: 0.0965 kg CO₂e/passenger-km (DEFRA 2022)
///     · 计算: 2,000 km × 0.0965 = 193 kg CO₂e/year
///   - 火车/地铁 (Train/MRT/LRT):
///     · 输入: 年度乘坐 5,000 km
///     · 排放因子: 0.03661 kg CO₂e/passenger-km (GHG Protocol 2023)
///     · 计算: 5,000 km × 0.03661 = 183.05 kg CO₂e/year
///
/// 【4. 步行与骑行 (Walking & Cycling)】
///
///   - 排放: 0 kg CO₂e (零排放)
///   - 说明: 操作阶段无碳排放，用户可记录这些环保出行习惯，但不计入总排放
///
/// 【总排放计算】
///
///   总排放 = 燃油车排放 + 电动车排放 + 公共交通排放 + 0 (步行/骑行)
///
/// 【数据来源】
///   - GHG Protocol Cross-sector Emission Factors Tool v2.0 (2023)
///   - UK DEFRA Greenhouse Gas Conversion Factors (2022-2023)
///   - Energy Commission Malaysia Grid Emission Factor (2022)
///
/// ===============================================================================
class LandTravelEmissionConfig {
  LandTravelEmissionConfig._();

  // ==================== Land Travel Emission Factors ====================
  // Notes:
  // - Private vehicles (fuel): fuel used (L) × fuel EF.
  // - If only distance is known, use per‑km factors by mode.
  // - EV: distance × kWh/100km × grid EF.
  // - Public transport: distance × passenger‑km EF.

  static const Map<String, Map<String, dynamic>> landTravelEmissionFactors = {
    // ---------- Fuel-based vehicles (exact factors from GHG Protocol cross-sector tool v2.0, based on DEFRA 2023) ----------
    'fuel': {
      'petrol': {
        'ef_per_liter': 2.33086,
        'metadata': {
          'source':
          'GHG Protocol Cross-sector Emission Factors Tool v2.0 (adapted from UK DEFRA 2023) – Petrol (100% mineral petrol, Motor Gasoline)',
          'year': 2023,
          'link':
          'https://ghgprotocol.org/sites/default/files/2024-05/Emission_Factors_for_Cross_Sector_Tools_V2.0.xlsx',
          'unit': 'kg CO2e per liter',
          'region': 'UK (used as global default for Malaysia)',
          'notes':
          'Exact factor from GHG Protocol cross-sector tool Table 1, “Petrol (100% mineral petrol) (Motor Gasoline)”.',
        },
      },
      'diesel': {
        'ef_per_liter': 2.626,
        'metadata': {
          'source':
          'GHG Protocol Cross-sector Emission Factors Tool v2.0 (adapted from UK DEFRA 2023) – Diesel (100% mineral diesel)',
          'year': 2023,
          'link':
          'https://ghgprotocol.org/sites/default/files/2024-05/Emission_Factors_for_Cross_Sector_Tools_V2.0.xlsx',
          'unit': 'kg CO2e per liter',
          'region': 'UK (used as global default for Malaysia)',
          'notes':
          'Exact factor from GHG Protocol cross-sector tool Table 1, “Diesel (100% mineral diesel)”.',
        },
      },
    },

    // ---------- EV (Malaysia grid) ----------
    'electric_vehicle': {
      // Use EV_kWh = distance_km × (kWh_per_100km / 100); emissions = EV_kWh × grid_ef_my.
      'grid_ef_my': 0.774, // 2022 Peninsular reference
      'metadata': {
        'source': 'Energy Commission Malaysia – Grid Emission Factor (GEF)',
        'year': 2022,
        'link':
        'https://myenergystats.st.gov.my/documents/d/guest/grid-emission-factor-gef-in-malaysia',
        'unit': 'kg CO2e per kWh',
        'region': 'Malaysia (Peninsular)',
        'notes':
        'Official 2022 Peninsular grid EF. For distance-based EV emissions, multiply distance by kWh/100km and then by this grid factor.',
      },
    },

    // ---------- Distance-based fallback by mode (exact DEFRA-style values) ----------
    'by_distance': {
      // Used when the user only provides km, not liters/kWh.
      'by_car': {
        'ef_per_km': 0.16983,
        'metadata': {
          'source':
          'UK DEFRA 2023 – Passenger vehicles, cars by size: Average car, per km (including CO2, CH4, N2O, AR5, well-to-tank)',
          'year': 2023,
          'link':
          'https://assets.publishing.service.gov.uk/media/649c5340bb13dc0012b2e2b6/ghg-conversion-factors-2023-condensed-set-update.xlsx',
          'unit': 'kg CO2e per vehicle-km',
          'region': 'United Kingdom (used as global default for Malaysia)',
          'notes':
          'Exact value from DEFRA 2023 table for “Average car – km, CO2e, including WTT”. Prefer fuel-based calculation when fuel data is available.',
        },
      },
      'by_motorcycle': {
        'ef_per_km': 0.11367,
        'metadata': {
          'source':
          'UK DEFRA 2023 – Business travel, land: Motorbike – Average, per km',
          'year': 2023,
          'link':
          'https://mybreeze.app/ef/passenger-vehicles---motorbike---average---defra---2023-06-28-1',
          'unit': 'kg CO2e per vehicle-km',
          'region': 'United Kingdom (used as global default for Malaysia)',
          'notes':
          'Exact factor 0.000113667 tCO2e/km = 0.113667 kg CO2e/km, taken from DEFRA 2023 and exposed via Breeze/Climatiq.',
        },
      },
      'by_bicycle': {
        'ef_per_km': 0.0,
        'metadata': {
          'source': 'Common practice in personal carbon calculators',
          'year': 2020,
          'link': 'https://ourworldindata.org/transport',
          'unit': 'kg CO2e per km',
          'region': 'Global',
          'notes':
          'Cycling operational emissions assumed ≈ 0; embodied bike and extra food emissions are ignored in this calculator.',
        },
      },
      'by_foot': {
        'ef_per_km': 0.0,
        'metadata': {
          'source': 'Common practice in personal carbon calculators',
          'year': 2020,
          'link': 'https://ourworldindata.org/transport',
          'unit': 'kg CO2e per km',
          'region': 'Global',
          'notes':
          'Walking operational emissions set to 0; diet-related emissions are counted under Food, not Transport.',
        },
      },
    },

    // ---------- Public transport (passenger-km) ----------
    'public_transport': {
      'by_bus': {
        'ef_per_passenger_km': 0.0965,
        'metadata': {
          'source':
          'UK BEIS/DEFRA – Average local bus, per passenger-km (CO2e, AR5)',
          'year': 2022,
          'link':
          'https://www.climatiq.io/data/emission-factor/7232e035-6038-41c5-855f-c8b21898a39d',
          'unit': 'kg CO2e per passenger-km',
          'region': 'United Kingdom (used as global default for Malaysia)',
          'notes':
          'Exact factor 0.0965 kg CO2e/passenger-km for “Average local bus” from BEIS/DEFRA conversion factors.',
        },
      },
      'by_train': {
        'ef_per_passenger_km': 0.03661,
        'metadata': {
          'source':
          'GHG Protocol Cross-sector Emission Factors Tool v2.0 – Passenger rail (average), per passenger-km (adapted from DEFRA)',
          'year': 2023,
          'link':
          'https://ghgprotocol.org/sites/default/files/2024-05/Emission_Factors_for_Cross_Sector_Tools_V2.0_0.xlsx',
          'unit': 'kg CO2e per passenger-km',
          'region': 'UK/global default',
          'notes':
          'Exact value from GHG Protocol cross-sector tool Table 14 for average passenger rail; appropriate proxy for LRT/MRT/commuter rail when local factors are unavailable.',
        },
      },
    },
  };
}
