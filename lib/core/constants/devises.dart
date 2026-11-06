import 'package:flutter/foundation.dart';

/// Devises proposées à l'onboarding et dans Réglages. Les noms vivent
/// ici, en dur dans les deux langues (`nomFr`/`nomEn`), plutôt que
/// dans les fichiers ARB : avec près de 150 devises, un switch géant
/// ou 150×2 clés de traduction n'apporteraient rien — même principe
/// que `csv_colonnes.dart`, une donnée statique keyée par langue.
@immutable
class DeviseInfo {
  const DeviseInfo({
    required this.code,
    required this.symbole,
    required this.avantLeMontant,
    required this.nomFr,
    required this.nomEn,
    this.principale = false,
  });

  /// Code ISO 4217 : clé de stockage dans Réglages (Hive), stable même
  /// si l'ordre de la liste change.
  final String code;

  /// Signe ou abréviation affiché à côté du montant. Le code ISO lui-
  /// même pour les devises moins connues : jamais faux, juste moins
  /// joli qu'un vrai symbole.
  final String symbole;

  /// `true` pour « $ 2 500 », `false` pour « 2 500 FCFA » — convention
  /// d'affichage usuelle de chaque devise.
  final bool avantLeMontant;

  final String nomFr;
  final String nomEn;

  /// Une des douze devises déjà proposées avant l'ouverture à la liste
  /// mondiale : épinglées en haut de la feuille de sélection sous
  /// « Principales » plutôt que noyées dans ~150 entrées triées par
  /// ordre alphabétique.
  final bool principale;
}

/// ~150 devises ISO 4217 en circulation. Les douze premières sont les
/// devises historiques de l'app (zone UEMOA/CEMAC, Maghreb, Europe/
/// Amérique du Nord, Royaume-Uni, Nigeria, Ghana) ; leurs `code`/
/// `symbole`/`avantLeMontant` sont inchangés pour ne pas faire bouger
/// l'affichage des utilisateurs déjà installés.
const List<DeviseInfo> devisesDisponibles = [
  // --- Principales (ordre historique, affichées en premier) ---
  DeviseInfo(code: 'XOF', symbole: 'FCFA', avantLeMontant: false, nomFr: 'Franc CFA (UEMOA)', nomEn: 'CFA Franc (West Africa)', principale: true),
  DeviseInfo(code: 'XAF', symbole: 'FCFA', avantLeMontant: false, nomFr: 'Franc CFA (CEMAC)', nomEn: 'CFA Franc (Central Africa)', principale: true),
  DeviseInfo(code: 'EUR', symbole: '€', avantLeMontant: false, nomFr: 'Euro', nomEn: 'Euro', principale: true),
  DeviseInfo(code: 'CHF', symbole: 'CHF', avantLeMontant: true, nomFr: 'Franc suisse', nomEn: 'Swiss Franc', principale: true),
  DeviseInfo(code: 'CAD', symbole: 'C\$', avantLeMontant: true, nomFr: 'Dollar canadien', nomEn: 'Canadian Dollar', principale: true),
  DeviseInfo(code: 'MAD', symbole: 'DH', avantLeMontant: false, nomFr: 'Dirham marocain', nomEn: 'Moroccan Dirham', principale: true),
  DeviseInfo(code: 'DZD', symbole: 'DA', avantLeMontant: false, nomFr: 'Dinar algérien', nomEn: 'Algerian Dinar', principale: true),
  DeviseInfo(code: 'TND', symbole: 'DT', avantLeMontant: false, nomFr: 'Dinar tunisien', nomEn: 'Tunisian Dinar', principale: true),
  DeviseInfo(code: 'GBP', symbole: '£', avantLeMontant: true, nomFr: 'Livre sterling', nomEn: 'British Pound', principale: true),
  DeviseInfo(code: 'USD', symbole: '\$', avantLeMontant: true, nomFr: 'Dollar américain', nomEn: 'US Dollar', principale: true),
  DeviseInfo(code: 'NGN', symbole: '₦', avantLeMontant: true, nomFr: 'Naira (Nigeria)', nomEn: 'Nigerian Naira', principale: true),
  DeviseInfo(code: 'GHS', symbole: 'GH₵', avantLeMontant: true, nomFr: 'Cedi (Ghana)', nomEn: 'Ghanaian Cedi', principale: true),

  // --- Afrique ---
  DeviseInfo(code: 'EGP', symbole: 'E£', avantLeMontant: true, nomFr: 'Livre égyptienne', nomEn: 'Egyptian Pound'),
  DeviseInfo(code: 'ZAR', symbole: 'R', avantLeMontant: true, nomFr: 'Rand sud-africain', nomEn: 'South African Rand'),
  DeviseInfo(code: 'KES', symbole: 'KSh', avantLeMontant: true, nomFr: 'Shilling kényan', nomEn: 'Kenyan Shilling'),
  DeviseInfo(code: 'UGX', symbole: 'UGX', avantLeMontant: false, nomFr: 'Shilling ougandais', nomEn: 'Ugandan Shilling'),
  DeviseInfo(code: 'TZS', symbole: 'TZS', avantLeMontant: false, nomFr: 'Shilling tanzanien', nomEn: 'Tanzanian Shilling'),
  DeviseInfo(code: 'ETB', symbole: 'ETB', avantLeMontant: false, nomFr: 'Birr éthiopien', nomEn: 'Ethiopian Birr'),
  DeviseInfo(code: 'RWF', symbole: 'RWF', avantLeMontant: false, nomFr: 'Franc rwandais', nomEn: 'Rwandan Franc'),
  DeviseInfo(code: 'BIF', symbole: 'BIF', avantLeMontant: false, nomFr: 'Franc burundais', nomEn: 'Burundian Franc'),
  DeviseInfo(code: 'CDF', symbole: 'CDF', avantLeMontant: false, nomFr: 'Franc congolais', nomEn: 'Congolese Franc'),
  DeviseInfo(code: 'AOA', symbole: 'AOA', avantLeMontant: false, nomFr: 'Kwanza angolais', nomEn: 'Angolan Kwanza'),
  DeviseInfo(code: 'MZN', symbole: 'MZN', avantLeMontant: false, nomFr: 'Metical mozambicain', nomEn: 'Mozambican Metical'),
  DeviseInfo(code: 'ZMW', symbole: 'ZMW', avantLeMontant: false, nomFr: 'Kwacha zambien', nomEn: 'Zambian Kwacha'),
  DeviseInfo(code: 'MWK', symbole: 'MWK', avantLeMontant: false, nomFr: 'Kwacha malawite', nomEn: 'Malawian Kwacha'),
  DeviseInfo(code: 'BWP', symbole: 'BWP', avantLeMontant: false, nomFr: 'Pula botswanais', nomEn: 'Botswana Pula'),
  DeviseInfo(code: 'NAD', symbole: 'N\$', avantLeMontant: true, nomFr: 'Dollar namibien', nomEn: 'Namibian Dollar'),
  DeviseInfo(code: 'SZL', symbole: 'SZL', avantLeMontant: false, nomFr: 'Lilangeni swazi', nomEn: 'Swazi Lilangeni'),
  DeviseInfo(code: 'LSL', symbole: 'LSL', avantLeMontant: false, nomFr: 'Loti lesothan', nomEn: 'Lesotho Loti'),
  DeviseInfo(code: 'MGA', symbole: 'MGA', avantLeMontant: false, nomFr: 'Ariary malgache', nomEn: 'Malagasy Ariary'),
  DeviseInfo(code: 'MUR', symbole: 'MUR', avantLeMontant: false, nomFr: 'Roupie mauricienne', nomEn: 'Mauritian Rupee'),
  DeviseInfo(code: 'SCR', symbole: 'SCR', avantLeMontant: false, nomFr: 'Roupie seychelloise', nomEn: 'Seychellois Rupee'),
  DeviseInfo(code: 'SOS', symbole: 'SOS', avantLeMontant: false, nomFr: 'Shilling somalien', nomEn: 'Somali Shilling'),
  DeviseInfo(code: 'SDG', symbole: 'SDG', avantLeMontant: false, nomFr: 'Livre soudanaise', nomEn: 'Sudanese Pound'),
  DeviseInfo(code: 'SSP', symbole: 'SSP', avantLeMontant: false, nomFr: 'Livre sud-soudanaise', nomEn: 'South Sudanese Pound'),
  DeviseInfo(code: 'ERN', symbole: 'ERN', avantLeMontant: false, nomFr: 'Nakfa érythréen', nomEn: 'Eritrean Nakfa'),
  DeviseInfo(code: 'DJF', symbole: 'DJF', avantLeMontant: false, nomFr: 'Franc djiboutien', nomEn: 'Djiboutian Franc'),
  DeviseInfo(code: 'LRD', symbole: 'LRD', avantLeMontant: false, nomFr: 'Dollar libérien', nomEn: 'Liberian Dollar'),
  DeviseInfo(code: 'SLE', symbole: 'SLE', avantLeMontant: false, nomFr: 'Leone sierra-léonais', nomEn: 'Sierra Leonean Leone'),
  DeviseInfo(code: 'GMD', symbole: 'GMD', avantLeMontant: false, nomFr: 'Dalasi gambien', nomEn: 'Gambian Dalasi'),
  DeviseInfo(code: 'GNF', symbole: 'GNF', avantLeMontant: false, nomFr: 'Franc guinéen', nomEn: 'Guinean Franc'),
  DeviseInfo(code: 'CVE', symbole: 'CVE', avantLeMontant: false, nomFr: 'Escudo cap-verdien', nomEn: 'Cape Verdean Escudo'),
  DeviseInfo(code: 'STN', symbole: 'STN', avantLeMontant: false, nomFr: 'Dobra santoméen', nomEn: 'São Tomé and Príncipe Dobra'),
  DeviseInfo(code: 'KMF', symbole: 'KMF', avantLeMontant: false, nomFr: 'Franc comorien', nomEn: 'Comorian Franc'),
  DeviseInfo(code: 'LYD', symbole: 'LYD', avantLeMontant: false, nomFr: 'Dinar libyen', nomEn: 'Libyan Dinar'),
  DeviseInfo(code: 'ZWL', symbole: 'ZWL', avantLeMontant: false, nomFr: 'Dollar zimbabwéen', nomEn: 'Zimbabwean Dollar'),

  // --- Europe (hors zone euro) ---
  DeviseInfo(code: 'NOK', symbole: 'kr', avantLeMontant: false, nomFr: 'Couronne norvégienne', nomEn: 'Norwegian Krone'),
  DeviseInfo(code: 'SEK', symbole: 'kr', avantLeMontant: false, nomFr: 'Couronne suédoise', nomEn: 'Swedish Krona'),
  DeviseInfo(code: 'DKK', symbole: 'kr', avantLeMontant: false, nomFr: 'Couronne danoise', nomEn: 'Danish Krone'),
  DeviseInfo(code: 'ISK', symbole: 'kr', avantLeMontant: false, nomFr: 'Couronne islandaise', nomEn: 'Icelandic Króna'),
  DeviseInfo(code: 'PLN', symbole: 'zł', avantLeMontant: false, nomFr: 'Zloty polonais', nomEn: 'Polish Zloty'),
  DeviseInfo(code: 'CZK', symbole: 'Kč', avantLeMontant: false, nomFr: 'Couronne tchèque', nomEn: 'Czech Koruna'),
  DeviseInfo(code: 'HUF', symbole: 'Ft', avantLeMontant: false, nomFr: 'Forint hongrois', nomEn: 'Hungarian Forint'),
  DeviseInfo(code: 'RON', symbole: 'lei', avantLeMontant: false, nomFr: 'Leu roumain', nomEn: 'Romanian Leu'),
  DeviseInfo(code: 'BGN', symbole: 'лв', avantLeMontant: false, nomFr: 'Lev bulgare', nomEn: 'Bulgarian Lev'),
  DeviseInfo(code: 'RSD', symbole: 'RSD', avantLeMontant: false, nomFr: 'Dinar serbe', nomEn: 'Serbian Dinar'),
  DeviseInfo(code: 'ALL', symbole: 'ALL', avantLeMontant: false, nomFr: 'Lek albanais', nomEn: 'Albanian Lek'),
  DeviseInfo(code: 'MKD', symbole: 'MKD', avantLeMontant: false, nomFr: 'Denar macédonien', nomEn: 'Macedonian Denar'),
  DeviseInfo(code: 'BAM', symbole: 'BAM', avantLeMontant: false, nomFr: 'Mark convertible', nomEn: 'Bosnia-Herzegovina Convertible Mark'),
  DeviseInfo(code: 'MDL', symbole: 'MDL', avantLeMontant: false, nomFr: 'Leu moldave', nomEn: 'Moldovan Leu'),
  DeviseInfo(code: 'UAH', symbole: '₴', avantLeMontant: false, nomFr: 'Hryvnia ukrainienne', nomEn: 'Ukrainian Hryvnia'),
  DeviseInfo(code: 'BYN', symbole: 'BYN', avantLeMontant: false, nomFr: 'Rouble biélorusse', nomEn: 'Belarusian Ruble'),
  DeviseInfo(code: 'RUB', symbole: '₽', avantLeMontant: false, nomFr: 'Rouble russe', nomEn: 'Russian Ruble'),
  DeviseInfo(code: 'GEL', symbole: '₾', avantLeMontant: false, nomFr: 'Lari géorgien', nomEn: 'Georgian Lari'),
  DeviseInfo(code: 'AMD', symbole: 'AMD', avantLeMontant: false, nomFr: 'Dram arménien', nomEn: 'Armenian Dram'),
  DeviseInfo(code: 'AZN', symbole: 'AZN', avantLeMontant: false, nomFr: 'Manat azerbaïdjanais', nomEn: 'Azerbaijani Manat'),
  DeviseInfo(code: 'TRY', symbole: '₺', avantLeMontant: false, nomFr: 'Livre turque', nomEn: 'Turkish Lira'),
  DeviseInfo(code: 'GIP', symbole: 'GIP', avantLeMontant: false, nomFr: 'Livre de Gibraltar', nomEn: 'Gibraltar Pound'),
  DeviseInfo(code: 'FKP', symbole: 'FKP', avantLeMontant: false, nomFr: 'Livre des Malouines', nomEn: 'Falkland Islands Pound'),
  DeviseInfo(code: 'SHP', symbole: 'SHP', avantLeMontant: false, nomFr: 'Livre de Sainte-Hélène', nomEn: 'Saint Helena Pound'),

  // --- Amériques ---
  DeviseInfo(code: 'MXN', symbole: 'MX\$', avantLeMontant: true, nomFr: 'Peso mexicain', nomEn: 'Mexican Peso'),
  DeviseInfo(code: 'BRL', symbole: 'R\$', avantLeMontant: true, nomFr: 'Real brésilien', nomEn: 'Brazilian Real'),
  DeviseInfo(code: 'ARS', symbole: 'AR\$', avantLeMontant: true, nomFr: 'Peso argentin', nomEn: 'Argentine Peso'),
  DeviseInfo(code: 'CLP', symbole: 'CL\$', avantLeMontant: true, nomFr: 'Peso chilien', nomEn: 'Chilean Peso'),
  DeviseInfo(code: 'COP', symbole: 'CO\$', avantLeMontant: true, nomFr: 'Peso colombien', nomEn: 'Colombian Peso'),
  DeviseInfo(code: 'PEN', symbole: 'S/', avantLeMontant: true, nomFr: 'Sol péruvien', nomEn: 'Peruvian Sol'),
  DeviseInfo(code: 'UYU', symbole: 'UY\$', avantLeMontant: true, nomFr: 'Peso uruguayen', nomEn: 'Uruguayan Peso'),
  DeviseInfo(code: 'PYG', symbole: 'PYG', avantLeMontant: false, nomFr: 'Guarani paraguayen', nomEn: 'Paraguayan Guarani'),
  DeviseInfo(code: 'BOB', symbole: 'Bs', avantLeMontant: true, nomFr: 'Boliviano bolivien', nomEn: 'Bolivian Boliviano'),
  DeviseInfo(code: 'VES', symbole: 'VES', avantLeMontant: false, nomFr: 'Bolivar vénézuélien', nomEn: 'Venezuelan Bolívar'),
  DeviseInfo(code: 'GTQ', symbole: 'GTQ', avantLeMontant: false, nomFr: 'Quetzal guatémaltèque', nomEn: 'Guatemalan Quetzal'),
  DeviseInfo(code: 'HNL', symbole: 'HNL', avantLeMontant: false, nomFr: 'Lempira hondurien', nomEn: 'Honduran Lempira'),
  DeviseInfo(code: 'NIO', symbole: 'NIO', avantLeMontant: false, nomFr: 'Córdoba nicaraguayen', nomEn: 'Nicaraguan Córdoba'),
  DeviseInfo(code: 'CRC', symbole: '₡', avantLeMontant: true, nomFr: 'Colón costaricien', nomEn: 'Costa Rican Colón'),
  DeviseInfo(code: 'PAB', symbole: 'PAB', avantLeMontant: false, nomFr: 'Balboa panaméen', nomEn: 'Panamanian Balboa'),
  DeviseInfo(code: 'DOP', symbole: 'RD\$', avantLeMontant: true, nomFr: 'Peso dominicain', nomEn: 'Dominican Peso'),
  DeviseInfo(code: 'HTG', symbole: 'HTG', avantLeMontant: false, nomFr: 'Gourde haïtienne', nomEn: 'Haitian Gourde'),
  DeviseInfo(code: 'JMD', symbole: 'J\$', avantLeMontant: true, nomFr: 'Dollar jamaïcain', nomEn: 'Jamaican Dollar'),
  DeviseInfo(code: 'TTD', symbole: 'TT\$', avantLeMontant: true, nomFr: 'Dollar de Trinité-et-Tobago', nomEn: 'Trinidad and Tobago Dollar'),
  DeviseInfo(code: 'BBD', symbole: 'BBD', avantLeMontant: false, nomFr: 'Dollar barbadien', nomEn: 'Barbadian Dollar'),
  DeviseInfo(code: 'BSD', symbole: 'BSD', avantLeMontant: false, nomFr: 'Dollar bahaméen', nomEn: 'Bahamian Dollar'),
  DeviseInfo(code: 'BZD', symbole: 'BZD', avantLeMontant: false, nomFr: 'Dollar bélizien', nomEn: 'Belize Dollar'),
  DeviseInfo(code: 'GYD', symbole: 'GYD', avantLeMontant: false, nomFr: 'Dollar guyanien', nomEn: 'Guyanese Dollar'),
  DeviseInfo(code: 'SRD', symbole: 'SRD', avantLeMontant: false, nomFr: 'Dollar surinamais', nomEn: 'Surinamese Dollar'),
  DeviseInfo(code: 'XCD', symbole: 'XCD', avantLeMontant: false, nomFr: 'Dollar des Caraïbes orientales', nomEn: 'East Caribbean Dollar'),
  DeviseInfo(code: 'CUP', symbole: 'CUP', avantLeMontant: false, nomFr: 'Peso cubain', nomEn: 'Cuban Peso'),
  DeviseInfo(code: 'AWG', symbole: 'AWG', avantLeMontant: false, nomFr: 'Florin arubais', nomEn: 'Aruban Florin'),
  DeviseInfo(code: 'ANG', symbole: 'ANG', avantLeMontant: false, nomFr: 'Florin antillais', nomEn: 'Netherlands Antillean Guilder'),
  DeviseInfo(code: 'KYD', symbole: 'KYD', avantLeMontant: false, nomFr: 'Dollar des îles Caïmans', nomEn: 'Cayman Islands Dollar'),
  DeviseInfo(code: 'BMD', symbole: 'BMD', avantLeMontant: false, nomFr: 'Dollar bermudien', nomEn: 'Bermudian Dollar'),

  // --- Asie ---
  DeviseInfo(code: 'CNY', symbole: '¥', avantLeMontant: true, nomFr: 'Yuan chinois', nomEn: 'Chinese Yuan'),
  DeviseInfo(code: 'JPY', symbole: '¥', avantLeMontant: true, nomFr: 'Yen japonais', nomEn: 'Japanese Yen'),
  DeviseInfo(code: 'INR', symbole: '₹', avantLeMontant: true, nomFr: 'Roupie indienne', nomEn: 'Indian Rupee'),
  DeviseInfo(code: 'KRW', symbole: '₩', avantLeMontant: true, nomFr: 'Won sud-coréen', nomEn: 'South Korean Won'),
  DeviseInfo(code: 'IDR', symbole: 'Rp', avantLeMontant: true, nomFr: 'Roupie indonésienne', nomEn: 'Indonesian Rupiah'),
  DeviseInfo(code: 'MYR', symbole: 'RM', avantLeMontant: true, nomFr: 'Ringgit malaisien', nomEn: 'Malaysian Ringgit'),
  DeviseInfo(code: 'SGD', symbole: 'S\$', avantLeMontant: true, nomFr: 'Dollar singapourien', nomEn: 'Singapore Dollar'),
  DeviseInfo(code: 'THB', symbole: '฿', avantLeMontant: true, nomFr: 'Baht thaïlandais', nomEn: 'Thai Baht'),
  DeviseInfo(code: 'PHP', symbole: '₱', avantLeMontant: true, nomFr: 'Peso philippin', nomEn: 'Philippine Peso'),
  DeviseInfo(code: 'VND', symbole: '₫', avantLeMontant: false, nomFr: 'Dong vietnamien', nomEn: 'Vietnamese Dong'),
  DeviseInfo(code: 'PKR', symbole: 'PKR', avantLeMontant: false, nomFr: 'Roupie pakistanaise', nomEn: 'Pakistani Rupee'),
  DeviseInfo(code: 'BDT', symbole: '৳', avantLeMontant: true, nomFr: 'Taka bangladais', nomEn: 'Bangladeshi Taka'),
  DeviseInfo(code: 'LKR', symbole: 'LKR', avantLeMontant: false, nomFr: 'Roupie srilankaise', nomEn: 'Sri Lankan Rupee'),
  DeviseInfo(code: 'NPR', symbole: 'NPR', avantLeMontant: false, nomFr: 'Roupie népalaise', nomEn: 'Nepalese Rupee'),
  DeviseInfo(code: 'MMK', symbole: 'MMK', avantLeMontant: false, nomFr: 'Kyat birman', nomEn: 'Myanmar Kyat'),
  DeviseInfo(code: 'KHR', symbole: 'KHR', avantLeMontant: false, nomFr: 'Riel cambodgien', nomEn: 'Cambodian Riel'),
  DeviseInfo(code: 'LAK', symbole: 'LAK', avantLeMontant: false, nomFr: 'Kip laotien', nomEn: 'Lao Kip'),
  DeviseInfo(code: 'BND', symbole: 'BND', avantLeMontant: false, nomFr: 'Dollar brunéien', nomEn: 'Brunei Dollar'),
  DeviseInfo(code: 'MOP', symbole: 'MOP', avantLeMontant: false, nomFr: 'Pataca macanaise', nomEn: 'Macanese Pataca'),
  DeviseInfo(code: 'HKD', symbole: 'HK\$', avantLeMontant: true, nomFr: 'Dollar de Hong Kong', nomEn: 'Hong Kong Dollar'),
  DeviseInfo(code: 'TWD', symbole: 'NT\$', avantLeMontant: true, nomFr: 'Dollar taïwanais', nomEn: 'New Taiwan Dollar'),
  DeviseInfo(code: 'MNT', symbole: 'MNT', avantLeMontant: false, nomFr: 'Tögrög mongol', nomEn: 'Mongolian Tögrög'),
  DeviseInfo(code: 'KZT', symbole: '₸', avantLeMontant: false, nomFr: 'Tenge kazakh', nomEn: 'Kazakhstani Tenge'),
  DeviseInfo(code: 'UZS', symbole: 'UZS', avantLeMontant: false, nomFr: 'Sum ouzbek', nomEn: 'Uzbekistani Som'),
  DeviseInfo(code: 'KGS', symbole: 'KGS', avantLeMontant: false, nomFr: 'Som kirghize', nomEn: 'Kyrgystani Som'),
  DeviseInfo(code: 'TJS', symbole: 'TJS', avantLeMontant: false, nomFr: 'Somoni tadjik', nomEn: 'Tajikistani Somoni'),
  DeviseInfo(code: 'TMT', symbole: 'TMT', avantLeMontant: false, nomFr: 'Manat turkmène', nomEn: 'Turkmenistani Manat'),
  DeviseInfo(code: 'AFN', symbole: 'AFN', avantLeMontant: false, nomFr: 'Afghani afghan', nomEn: 'Afghan Afghani'),
  DeviseInfo(code: 'BTN', symbole: 'BTN', avantLeMontant: false, nomFr: 'Ngultrum bhoutanais', nomEn: 'Bhutanese Ngultrum'),
  DeviseInfo(code: 'KPW', symbole: 'KPW', avantLeMontant: false, nomFr: 'Won nord-coréen', nomEn: 'North Korean Won'),

  // --- Moyen-Orient ---
  DeviseInfo(code: 'SAR', symbole: 'SAR', avantLeMontant: false, nomFr: 'Riyal saoudien', nomEn: 'Saudi Riyal'),
  DeviseInfo(code: 'AED', symbole: 'AED', avantLeMontant: false, nomFr: 'Dirham des Émirats arabes unis', nomEn: 'UAE Dirham'),
  DeviseInfo(code: 'QAR', symbole: 'QAR', avantLeMontant: false, nomFr: 'Riyal qatari', nomEn: 'Qatari Riyal'),
  DeviseInfo(code: 'KWD', symbole: 'KWD', avantLeMontant: false, nomFr: 'Dinar koweïtien', nomEn: 'Kuwaiti Dinar'),
  DeviseInfo(code: 'BHD', symbole: 'BHD', avantLeMontant: false, nomFr: 'Dinar bahreïni', nomEn: 'Bahraini Dinar'),
  DeviseInfo(code: 'OMR', symbole: 'OMR', avantLeMontant: false, nomFr: 'Rial omanais', nomEn: 'Omani Rial'),
  DeviseInfo(code: 'JOD', symbole: 'JOD', avantLeMontant: false, nomFr: 'Dinar jordanien', nomEn: 'Jordanian Dinar'),
  DeviseInfo(code: 'ILS', symbole: '₪', avantLeMontant: true, nomFr: 'Shekel israélien', nomEn: 'Israeli Shekel'),
  DeviseInfo(code: 'LBP', symbole: 'LBP', avantLeMontant: false, nomFr: 'Livre libanaise', nomEn: 'Lebanese Pound'),
  DeviseInfo(code: 'SYP', symbole: 'SYP', avantLeMontant: false, nomFr: 'Livre syrienne', nomEn: 'Syrian Pound'),
  DeviseInfo(code: 'IQD', symbole: 'IQD', avantLeMontant: false, nomFr: 'Dinar irakien', nomEn: 'Iraqi Dinar'),
  DeviseInfo(code: 'IRR', symbole: 'IRR', avantLeMontant: false, nomFr: 'Rial iranien', nomEn: 'Iranian Rial'),
  DeviseInfo(code: 'YER', symbole: 'YER', avantLeMontant: false, nomFr: 'Rial yéménite', nomEn: 'Yemeni Rial'),

  // --- Océanie ---
  DeviseInfo(code: 'AUD', symbole: 'A\$', avantLeMontant: true, nomFr: 'Dollar australien', nomEn: 'Australian Dollar'),
  DeviseInfo(code: 'NZD', symbole: 'NZ\$', avantLeMontant: true, nomFr: 'Dollar néo-zélandais', nomEn: 'New Zealand Dollar'),
  DeviseInfo(code: 'FJD', symbole: 'FJD', avantLeMontant: false, nomFr: 'Dollar fidjien', nomEn: 'Fijian Dollar'),
  DeviseInfo(code: 'PGK', symbole: 'PGK', avantLeMontant: false, nomFr: 'Kina papouasien', nomEn: 'Papua New Guinean Kina'),
  DeviseInfo(code: 'WST', symbole: 'WST', avantLeMontant: false, nomFr: 'Tala samoan', nomEn: 'Samoan Tala'),
  DeviseInfo(code: 'TOP', symbole: 'TOP', avantLeMontant: false, nomFr: 'Paʻanga tongan', nomEn: 'Tongan Paʻanga'),
  DeviseInfo(code: 'VUV', symbole: 'VUV', avantLeMontant: false, nomFr: 'Vatu vanuatuan', nomEn: 'Vanuatu Vatu'),
  DeviseInfo(code: 'SBD', symbole: 'SBD', avantLeMontant: false, nomFr: 'Dollar des îles Salomon', nomEn: 'Solomon Islands Dollar'),
  DeviseInfo(code: 'XPF', symbole: 'XPF', avantLeMontant: false, nomFr: 'Franc CFP', nomEn: 'CFP Franc'),
];

/// Devise avant l'introduction du choix : les installations existantes
/// ne doivent rien voir changer tant que l'utilisateur ne choisit pas
/// explicitement autre chose.
const deviseParDefautCode = 'XOF';

DeviseInfo deviseDepuisCode(String? code) => devisesDisponibles.firstWhere(
  (d) => d.code == code,
  orElse: () =>
      devisesDisponibles.firstWhere((d) => d.code == deviseParDefautCode),
);

/// Nom localisé d'une devise, pour la feuille de sélection (onboarding
/// et Réglages) — le symbole seul ne suffit pas à distinguer XOF et
/// XAF, tous deux affichés "FCFA", ni les ~150 devises qui partagent
/// leur code ISO comme symbole.
String nomDevise(DeviseInfo devise, String langue) =>
    langue == 'en' ? devise.nomEn : devise.nomFr;
