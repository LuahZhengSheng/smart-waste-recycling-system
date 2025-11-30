// ==================== Energy Carbon Footprint Calculator Formulas ====================
//
// 本配置文件用于【家庭能源】碳足迹计算，主要包括：电网用电、太阳能自用、电煤气(LPG)、管道天然气、柴油发电机、生物质燃料。
// 所有计算都统一换算成「年度排放量 kg CO2e/year」，方便和其他类别比较。
//
// ==================== 1. 电网用电 (Grid Electricity) ====================
//
// 基本思路：先得到「年度用电量 kWh/year」，再乘以所在地区的电网排放因子 Grid EF (kg CO2e/kWh)。
//
// 年度排放公式:
//    Annual Emissions (kg CO2e) = Annual kWh × Grid EF
//
// 其中：
//    Annual kWh = Monthly kWh × 12
//    Grid EF   = 按地区选择 (半岛 / 沙巴 / 砂拉越)，单位 kg CO2e/kWh
//
// 使用方式分两种：
//
// A. 用户【知道每月用电量 kWh】
// -------------------------------------------------------
// - 在 Energy Input Screen 选择：
//   「Yes – I know my monthly usage (kWh)」
// - 输入：Average monthly electricity consumption (kWh)
// - 代码逻辑：
//     monthlyKwh = 用户输入的 kWh/月 (无则视为 0)
//     annualKwh  = monthlyKwh × 12
//     gridEmissions = annualKwh × gridEf
//
// - 例子：
//   用户每月用电 500 kWh，居住在半岛 (Grid EF = 0.774 kg CO2e/kWh)
//   annualKwh = 500 × 12 = 6000 kWh/year
//   gridEmissions = 6000 × 0.774 = 4,644 kg CO2e/year
//
// B. 用户【只知道每月电费 RM】
// -------------------------------------------------------
// - 在 Energy Input Screen 选择：
//   「No – I only know my monthly TNB bill (RM)」
// - 输入：Average monthly TNB electricity bill (RM)
//
// - 因为没有 kWh，我们用「电费 ÷ 平均电价」来估算每月 kWh：
//     Estimated Monthly kWh = Monthly Bill (RM) / Tariff Rate (RM/kWh)
//
// - 为了兼顾 TNB 阶梯电价，采用简化三档平均电价：
//   1) 月电费 < RM 300         → 视为低用电家庭，用 0.4443 RM/kWh
//   2) RM 300 ≤ 电费 < RM 700  → 中等偏高用电，用 0.47 RM/kWh (折衷平均值)
//   3) 电费 ≥ RM 700           → 高用电家庭，用 0.5443 RM/kWh
//
// - 代码逻辑 (见 _calculateGridEmissions):
//     monthlyBillRm = 用户输入的电费 RM/月 (无则 0)
//     if bill < 300    → tariffRate = 0.4443
//     else if bill < 700 → tariffRate = 0.47
//     else             → tariffRate = 0.5443
//
//     estimatedMonthlyKwh = monthlyBillRm / tariffRate   (若 tariffRate = 0 则为 0)
//     annualKwh           = estimatedMonthlyKwh × 12
//     gridEmissions       = annualKwh × gridEf
//
// - 例子：
//   用户每月电费约 RM 250，系统判定为低用电家庭：
//     tariffRate = 0.4443 RM/kWh
//     estimatedMonthlyKwh = 250 / 0.4443 ≈ 563 kWh/月
//     annualKwh = 563 × 12 ≈ 6,756 kWh/year
//     若居住在半岛 (Grid EF = 0.774):
//     gridEmissions ≈ 6,756 × 0.774 ≈ 5,226 kg CO2e/year
//
// - 专家模式提示：
//   UI 中会提示：
//   「这里的估算是基于 TNB 住宅电价的平均值，只用于粗略估算 kWh 和碳排，不是精确电费模拟。」
//   更详细的电价来源和公式可在 Info Dialog 中查看 `tariff_metadata`：
//     - 包含 ≤1500 kWh 和 >1500 kWh 的费率
//     - 固定零售收费 RM10/月
//     - 链接至 TNB 新电价结构说明文章
//
//
// ==================== 2. 太阳能自用 (Solar PV Self-consumption) ====================
//
// 核心理念：自用太阳能视为运行期零排放，但会计算「避免的电网排放」。
//          即：如果没有太阳能，这部分电原本会由电网供应并产生排放。
//
// 用户输入：
//   - 是否有太阳能 (Checkbox)
//   - 每月自用发电量 (kWh/month) – 不包括卖回电网的部分
//
// 公式：
//   Annual Solar kWh = Monthly kWh × 12
//   Solar Operational Emissions = 0 × Annual Solar kWh = 0 kg CO2e/year
//
//   Avoided Grid Emissions = Annual Solar kWh × Grid EF
//
// 例子：
//   每月自用 300 kWh，居住在半岛 (Grid EF = 0.774):
//   annualSolar = 300 × 12 = 3,600 kWh/year
//   solarEmissions = 0
//   solarAvoidedEmissions = 3,600 × 0.774 = 2,786.4 kg CO2e/year
//
// UI 中会显示一条绿色提示，告诉用户：
//   「你通过太阳能自用，大约避免了多少 kg/tonnes 的电网排放」
//
//
// ==================== 3. 液化石油气 LPG (Cooking Gas) ====================
//
// 用户输入：每月 LPG 用量 (kg/month)
//
// 步骤 1：年度 LPG 用量
//   Annual LPG (kg) = Monthly LPG (kg) × 12
//
// 步骤 2：换算成能量 (kWh)
//   Conversion Factor = 13.8 kWh/kg
//   Annual LPG Energy (kWh) = Annual LPG (kg) × 13.8
//
// 步骤 3：乘以排放因子
//   LPG EF = 0.23031 kg CO2e/kWh
//   Annual Emissions = Annual LPG Energy × LPG EF
//
// 例子：
//   每月用 7 kg LPG:
//   annualLPG = 7 × 12 = 84 kg/year
//   annualLPGkWh = 84 × 13.8 = 1,159.2 kWh/year
//   lpgEmissions = 1,159.2 × 0.23031 ≈ 267.24 kg CO2e/year
//
//
// ==================== 4. 管道天然气 (Piped Natural Gas) ====================
//
// 用户可以选择两种输入方式：kWh 或 m³：
//   - Input type = 'kwh': 直接输入每月 kWh
//   - Input type = 'm3' : 输入每月体积 m³，由系统换算成 kWh
//
// A. 以 kWh 输入：
//   Annual Gas kWh = Monthly Gas kWh × 12
//
// B. 以 m³ 输入：
//   Conversion Factor = 10.55 kWh/m³
//   Annual Gas kWh = Monthly Gas m³ × 10.55 × 12
//
// 排放因子：
//   Gas EF = 0.20297 kg CO2e/kWh
//
// 年度排放：
//   gasEmissions = Annual Gas kWh × Gas EF
//
// 例子 (以体积计费):
//   每月用 50 m³ 管道气：
//   annualGasKWh = 50 × 10.55 × 12 = 6,330 kWh/year
//   gasEmissions = 6,330 × 0.20297 ≈ 1,284.74 kg CO2e/year
//
//
// ==================== 5. 柴油发电机 (Diesel Generator) ====================
//
// 用户输入：每月柴油用量 (公升/month)
//
// 步骤：
//   Annual Diesel (L) = Monthly Diesel (L) × 12
//   Diesel EF = 2.626 kg CO2e/L
//   dieselEmissions = Annual Diesel (L) × Diesel EF
//
// 例子：
//   每月用 10 L 柴油：
//   annualDiesel = 10 × 12 = 120 L/year
//   dieselEmissions = 120 × 2.626 ≈ 315.12 kg CO2e/year
//
//
// ==================== 6. 生物质燃料 (Biomass: Firewood & Charcoal) ====================
//
// 用户选择燃料类型：
//   - None      → 不使用生物质燃料
//   - Firewood  → 柴火
//   - Charcoal  → 木炭
//
// 均以「每月用量 kg/month」作为输入：
//   Annual Biomass (kg) = Monthly Biomass (kg) × 12
//
// 特殊处理：
//   - Firewood：ef_per_kg = 0.0
//     理由：CO2 视为生物源碳，假设林木再生 → 整体碳中和。
//   - Charcoal：ef_per_kg = 2.96 kg CO2e/kg
//
// 年度排放：
//   biomassEmissions = Annual Biomass (kg) × ef_per_kg
//
// 例子 (使用木炭):
//   每月用 5 kg 木炭：
//   annualBiomass = 5 × 12 = 60 kg/year
//   biomassEmissions = 60 × 2.96 = 177.6 kg CO2e/year
//
//
// ==================== 7. 总年度排放 (Total Annual Emissions) ====================
//
// 应用会分别计算：
//   - gridEmissions
//   - solarEmissions (恒为 0)
//   - lpgEmissions
//   - gasEmissions
//   - dieselEmissions
//   - biomassEmissions
//
// 然后总排放：
//   totalEmissions = gridEmissions
//                  + solarEmissions
//                  + lpgEmissions
//                  + gasEmissions
//                  + dieselEmissions
//                  + biomassEmissions
//
// 注意：solarAvoidedEmissions 只用来展示「太阳能帮助你减少多少电网排放」，不计入总排放中。
//
// ==================== 使用建议 (Energy Input Screen 操作说明) ====================
//
// 1. 先选择「居住地区」(半岛 / Sabah / Sarawak)，确保使用正确的 Grid EF。
// 2. 电网用电：
//    - 如果你看得懂 TNB 账单上的 kWh → 请选择「我知道每月用电量」，直接输入 kWh，精度最高。
//    - 如果你只记得「每月大概电费」，请选择「只知道电费」，输入 RM 金额即可，系统会自动帮你估算 kWh。
// 3. 若家中有太阳能，自用部分请填写在 Solar PV 栏位，可看到「避免的电网排放」。
// 4. 如果你有使用 LPG、管道天然气、柴油发电机或生物质燃料，也可以选择对应选项并填写每月用量。
// 5. 所有输入都以「每月平均值」为单位，系统会统一换算成年度排放进行统计。
//
// ==================================================================================

class EnergyEmissionConfig {
  EnergyEmissionConfig._();

  // ==================== Energy Emission Factors ====================
  // Residential energy use (electricity + LPG / natural gas / diesel / biomass)

  static const Map<String, Map<String, dynamic>> energyEmissionFactors = {
    // ---------- Grid electricity (Malaysia, by region) ----------
    'electricity_peninsular': {
      'grid_ef': 0.774,
      'tariff_info': {
        'base_rate_below_1500': 0.4443, // RM/kWh for ≤1,500 kWh/month
        'base_rate_above_1500': 0.5443, // RM/kWh for >1,500 kWh/month
        'retail_charge': 10.0, // RM/month
        'tariff_source': 'TNB new electricity tariff structure (July 2025)',
        'tariff_link': 'https://paultan.org/2025/06/21/tnb-new-electricity-tariff-calculation-from-july-2025/',
      },
      'metadata': {
        'source': 'Energy Commission Malaysia – Grid Emission Factor (GEF)',
        'year': 2022,
        'link':
        'https://myenergystats.st.gov.my/documents/d/guest/grid-emission-factor-gef-in-malaysia',
        'unit': 'kg CO2e per kWh',
        'region': 'Peninsular Malaysia',
        'notes':
        'Official 2022 grid EF: 0.774 Gg CO2e/GWh. Tariff info from TNB July 2025 restructure.',
      },
      // 🔥 新增 tariff_metadata
      'tariff_metadata': {
        'source': 'Tenaga Nasional Berhad (TNB) - New Electricity Tariff Structure',
        'year': 2025,
        'link': 'https://paultan.org/2025/06/21/tnb-new-electricity-tariff-calculation-from-july-2025/',
        'unit': 'RM per kWh',
        'region': 'Peninsular Malaysia',
        'notes':
        'Effective July 2025:\n\n'
            '📊 Base Rates:\n'
            '• ≤1,500 kWh/month: RM 0.4443/kWh (44.43 sen/kWh)\n'
            '• >1,500 kWh/month: RM 0.5443/kWh (54.43 sen/kWh)\n\n'
            '💰 Additional Charges:\n'
            '• Retail charge: RM 10.00/month (fixed)\n'
            '• AFA: Adjusted Fuel Allowance (variable based on fuel costs)\n\n'
            '📝 Calculation Formula:\n'
            'Total Bill = (kWh × tariff rate) + RM 10 + AFA\n\n'
            'Example: 1,200 kWh usage\n'
            '= (1,200 × 0.4443) + 10 + AFA\n'
            '= RM 533.16 + 10 + AFA\n'
            '= RM 543.16 + AFA',
      },
    },
    'electricity_sabah': {
      'grid_ef': 0.525,
      'metadata': {
        'source': 'Energy Commission Malaysia – Grid Emission Factor (GEF)',
        'year': 2022,
        'link':
        'https://myenergystats.st.gov.my/documents/d/guest/grid-emission-factor-gef-in-malaysia',
        'unit': 'kg CO2e per kWh',
        'region': 'Sabah',
        'notes': 'Official 2022 grid EF: 0.525 Gg CO2e/GWh.',
      },
    },
    'electricity_sarawak': {
      'grid_ef': 0.199,
      'metadata': {
        'source': 'Energy Commission Malaysia – Grid Emission Factor (GEF)',
        'year': 2022,
        'link':
        'https://myenergystats.st.gov.my/documents/d/guest/grid-emission-factor-gef-in-malaysia',
        'unit': 'kg CO2e per kWh',
        'region': 'Sarawak',
        'notes': 'Official 2022 grid EF: 0.199 Gg CO2e/GWh.',
      },
    },

    // ---------- Solar PV ----------
    'solar_pv': {
      'grid_ef': 0.0,
      'metadata': {
        'source':
        'Common practice in operational GHG accounting for renewable energy',
        'year': 2023,
        'link': 'https://www.ipcc-nggip.iges.or.jp/public/2006gl/',
        'unit': 'kg CO2e per kWh',
        'region': 'Malaysia',
        'notes':
        'Solar PV self-consumption: operational emissions = 0. Manufacturing/installation emissions not counted in operational footprint.',
      },
    },

    // ---------- LPG ----------
    'lpg': {
      'ef_per_kwh': 0.23031,
      'conversion_factor': 13.8, // kWh per kg LPG (net CV)
      'metadata': {
        'source':
        'UK BEIS/DEFRA – Conversion Factors 2022: LPG (net calorific value), stationary combustion',
        'year': 2022,
        'link':
        'https://www.climatiq.io/data/emission-factor/1ab2ceb6-75b8-4daa-b840-83ddb3a301c5',
        'unit': 'kg CO2e per kWh (fuel energy, net CV)',
        'region': 'United Kingdom (used as global default for Malaysia)',
        'notes':
        'Exact EF: 0.23031 kg CO2e/kWh. For kg LPG, convert using 13.8 kWh/kg (typical LPG net CV).',
      },
    },

    // ---------- Piped natural gas ----------
    'natural_gas': {
      'ef_per_kwh': 0.20297,
      'conversion_factor': 10.55, // kWh per m³ natural gas
      'metadata': {
        'source':
        'DEFRA – Greenhouse gas reporting: conversion factors 2023, Natural gas kWh (Net CV)',
        'year': 2023,
        'link':
        'https://unfccc.int/sites/default/files/resource/GHG_emissions_calculator_ver01.3.xlsx',
        'unit': 'kg CO2e per kWh (net calorific value)',
        'region': 'United Kingdom (used as global default)',
        'notes':
        'Exact EF: 0.20297 kg CO2e/kWh. For m³ input, convert using 10.55 kWh/m³.',
      },
    },

    // ---------- Diesel generator ----------
    'diesel_generator': {
      'ef_per_liter': 2.626,
      'metadata': {
        'source':
        'GHG Protocol Cross-sector Emission Factors Tool v2.0 – Diesel (100% mineral diesel)',
        'year': 2023,
        'link':
        'https://ghgprotocol.org/sites/default/files/2024-05/Emission_Factors_for_Cross_Sector_Tools_V2.0.xlsx',
        'unit': 'kg CO2e per liter',
        'region': 'UK (used as global default for Malaysia)',
        'notes':
        'Exact factor from GHG Protocol. Use for diesel generators in residential or small commercial setups.',
      },
    },

    // ---------- Biomass ----------
    'firewood': {
      'ef_per_kg': 0.0,
      'metadata': {
        'source':
        'IPCC Guidelines – biomass CO2 treated as biogenic and climate-neutral',
        'year': 2019,
        'link': 'https://www.ipcc-nggip.iges.or.jp/public/2006gl/',
        'unit': 'kg CO2e per kg wood (CO2 only)',
        'region': 'Global default',
        'notes':
        'Firewood CO2 treated as neutral in household calculators (biomass regrowth assumption); non-CO2 (CH4, N2O) not counted.',
      },
    },
    'charcoal': {
      'ef_per_kg': 2.96,
      'metadata': {
        'source':
        'Regional residential combustion studies in Southeast Asia (ASEAN ACCEPT research)',
        'year': 2021,
        'link':
        'https://accept.aseanenergy.org/assessment-of-emissions-from-residential-combustion-in-southeast-asia-and-improvement-options/',
        'unit': 'kg CO2e per kg charcoal (approx.)',
        'region': 'Southeast Asia (used for Malaysia)',
        'notes':
        'Approximate factor for charcoal cooking. Actual value depends on production method.',
      },
    },
  };
}
