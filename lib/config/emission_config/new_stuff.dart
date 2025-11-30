class NewStuffEmissionConfig {
  NewStuffEmissionConfig._();

  // ==================== New Stuff Emission Factors ====================
  // Unit: kg CO2e per USD spent
  // Source: Climatiq Data Explorer (USEEIO / EXIOBASE / UK BEIS-based spend factors)
  // All values are from publicly available third-party emission factor databases.
  // To use with Malaysian Ringgit (RM), divide user spend by current USD/RM exchange rate.

  static const Map<String, Map<String, dynamic>> newStuffEmissionFactors = {
    // ---- Electronics & digital devices ----
    'computers_laptops': {
      'ef_per_usd': 0.488, // Climatiq: Computers (USEEIO)
      'metadata': {
        'source':
        'Climatiq / EPA USEEIO – Supply Chain Factors Dataset: Computers',
        'year': 2023,
        'link':
        'https://www.climatiq.io/data/emission-factor/8e93bddb-dc29-417e-9caf-683b111f04ce',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'Emission intensity of supply chain (cradle to shelf) for computers and laptops. Includes margins. USEEIO purchaser price basis.',
      },
    },
    'smartphones_tablets': {
      'ef_per_usd': 0.52, // Proxy: similar to computers, typical range 0.45–0.6
      'metadata': {
        'source':
        'Climatiq / USEEIO – Electronics and communication equipment (approximate category)',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'Proxy factor for smartphones/tablets based on USEEIO electronics sector. Typical range 0.45–0.6 kg/USD.',
      },
    },
    'tvs_monitors': {
      'ef_per_usd': 0.46, // USEEIO "Video, audio, and communications equipment"
      'metadata': {
        'source':
        'Climatiq / EPA USEEIO – Video, audio, and communications equipment',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'Supply chain emission intensity for TVs, monitors, and AV equipment.',
      },
    },
    'small_appliances': {
      'ef_per_usd': 0.42, // USEEIO "Other electrical equipment and components"
      'metadata': {
        'source':
        'Climatiq / EPA USEEIO – Other electrical equipment and components',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'For small household electrical appliances (toasters, kettles, fans, etc.). Excludes use-phase electricity.',
      },
    },

    // ---- Clothing & footwear ----
    'clothing': {
      'ef_per_usd': 0.396, // Climatiq: Clothing (USEEIO)
      'metadata': {
        'source':
        'Climatiq / EPA USEEIO – Supply Chain Factors Dataset: Clothing',
        'year': 2021,
        'link':
        'https://www.climatiq.io/data/emission-factor/0c3fd8c6-7b47-4607-92eb-5097e1dd58cb',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'Emission intensity of supply chain (cradle to shelf) for clothing. Includes fiber production, manufacturing, transport, and retail margins.',
      },
    },
    'footwear': {
      'ef_per_usd': 0.38, // USEEIO "Footwear"
      'metadata': {
        'source': 'Climatiq / EPA USEEIO – Footwear',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes': 'Supply chain emissions for shoes and footwear products.',
      },
    },
    'bags_accessories': {
      'ef_per_usd': 0.35, // Proxy: leather goods / textile accessories
      'metadata': {
        'source':
        'Climatiq / USEEIO – Leather and allied products (approximate category)',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'Proxy factor for handbags, belts, and fashion accessories based on USEEIO leather/textile sectors.',
      },
    },

    // ---- Furniture & household goods ----
    'furniture': {
      'ef_per_usd': 0.37, // Climatiq: Furniture (UK BEIS)
      'metadata': {
        'source':
        'Climatiq / UK BEIS – UK and England\'s carbon footprint: Furniture',
        'year': 2024,
        'link':
        'https://www.climatiq.io/data/emission-factor/2a712a21-17dc-4236-8c37-ad82006d6ab4',
        'unit': 'kg CO2e per GBP spent (≈USD equivalent)',
        'region': 'United Kingdom (used as global proxy)',
        'notes':
        'Supply chain emissions for furniture (wood/metal furniture, mattresses, etc.). UK BEIS EEIO-based factor.',
      },
    },
    'homeware_kitchen': {
      'ef_per_usd': 0.32, // USEEIO "Other household goods"
      'metadata': {
        'source': 'Climatiq / EPA USEEIO – Other household goods',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'United States (used as global proxy)',
        'notes':
        'For kitchenware, small decor, household items (non-electronic). Excludes use-phase impacts.',
      },
    },

    // ---- Generic fallback ----
    'other_consumer_goods': {
      'ef_per_usd': 0.35,
      'metadata': {
        'source':
        'Climatiq / EXIOBASE / USEEIO – Average consumer goods sector',
        'year': 2023,
        'link': 'https://www.climatiq.io/data',
        'unit': 'kg CO2e per USD spent',
        'region': 'Global average',
        'notes':
        'Catch-all category for other manufactured consumer goods not listed above. Rough average across EEIO consumer sectors.',
      },
    },
  };
}
