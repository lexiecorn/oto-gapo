/// Helper utility for getting car manufacturer logos
class CarLogoHelper {
  /// Checks if a local asset exists for the given car make
  static String? getLocalAssetPath(String make) {
    if (make.isEmpty) return null;

    final normalizedMake = _normalizeMake(make);

    // Check if we have a local asset for this manufacturer
    // Local assets are stored in assets/icons/car_logos/
    return 'assets/icons/car_logos/$normalizedMake.png';
  }

  /// Gets the best available logo source for the car make
  /// Returns either a local asset path or an external URL
  static String getCarLogoSource(String make) {
    if (make.isEmpty) return '';

    // For now, we'll use external CDN URLs
    // You can add local assets later for common brands
    final normalizedMake = _normalizeMake(make);

    // Using a reliable CDN source
    // Format: https://www.carlogos.org/car-logos/{brand}-logo.png
    return 'https://www.carlogos.org/car-logos/$normalizedMake-logo.png';
  }

  /// Gets multiple fallback URLs to try
  static List<String> getFallbackUrls(String make) {
    if (make.isEmpty) return [];

    final normalizedMake = _normalizeMake(make);

    return [
      // Primary: carlogos.org
      'https://www.carlogos.org/car-logos/$normalizedMake-logo.png',
      // Fallback 1: Alternative pattern
      'https://www.carlogos.org/logo/$normalizedMake-logo.png',
      // Fallback 2: GitHub repository
      'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/optimized/$normalizedMake.png',
    ];
  }

  /// Normalizes the car make name for URL construction
  ///
  /// - Converts to lowercase
  /// - Removes special characters
  /// - Replaces spaces with hyphens
  /// - Handles common abbreviations and brand variations
  static String _normalizeMake(String make) {
    String normalized = make.toLowerCase().trim();

    // Handle common brand variations and special cases
    final brandMapping = {
      'mercedes-benz': 'mercedes',
      'mercedes benz': 'mercedes',
      'bmw': 'bmw',
      'volkswagen': 'vw',
      'chevrolet': 'chevrolet',
      'chevy': 'chevrolet',
      'alfa romeo': 'alfaromeo',
      'aston martin': 'astonmartin',
      'land rover': 'landrover',
      'rolls-royce': 'rollsroyce',
      'rolls royce': 'rollsroyce',
    };

    // Check if there's a mapping for this brand
    if (brandMapping.containsKey(normalized)) {
      normalized = brandMapping[normalized]!;
    }

    // Remove special characters and replace spaces with hyphens
    normalized = normalized
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');

    return normalized;
  }

  /// Gets the domain for a car manufacturer
  ///
  /// This helps construct more reliable logo URLs by using known domains
  static String? getManufacturerDomain(String make) {
    final normalized = _normalizeMake(make);

    final domainMapping = {
      'toyota': 'toyota.com',
      'honda': 'honda.com',
      'ford': 'ford.com',
      'chevrolet': 'chevrolet.com',
      'bmw': 'bmw.com',
      'mercedes': 'mercedes-benz.com',
      'audi': 'audi.com',
      'volkswagen': 'vw.com',
      'nissan': 'nissan.com',
      'hyundai': 'hyundai.com',
      'kia': 'kia.com',
      'mazda': 'mazda.com',
      'subaru': 'subaru.com',
      'lexus': 'lexus.com',
      'tesla': 'tesla.com',
      'volvo': 'volvo.com',
      'porsche': 'porsche.com',
      'jaguar': 'jaguar.com',
      'landrover': 'landrover.com',
      'jeep': 'jeep.com',
      'dodge': 'dodge.com',
      'ram': 'ramtrucks.com',
      'chrysler': 'chrysler.com',
      'gmc': 'gmc.com',
      'buick': 'buick.com',
      'cadillac': 'cadillac.com',
      'mitsubishi': 'mitsubishi-motors.com',
      'suzuki': 'suzuki.com',
      'isuzu': 'isuzu.com',
      'fiat': 'fiat.com',
      'alfaromeo': 'alfaromeo.com',
      'maserati': 'maserati.com',
      'ferrari': 'ferrari.com',
      'lamborghini': 'lamborghini.com',
      'bentley': 'bentley.com',
      'rollsroyce': 'rolls-roycemotorcars.com',
      'astonmartin': 'astonmartin.com',
      'mclaren': 'mclaren.com',
      'mini': 'mini.com',
      'genesis': 'genesis.com',
      'acura': 'acura.com',
      'infiniti': 'infiniti.com',
      'lincoln': 'lincoln.com',
    };

    return domainMapping[normalized];
  }
}
