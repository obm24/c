// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'c_core_utils.dart';
import 'c_phone_validator.dart';

class AppConstants {
  static const double kDefaultBorderRadius = 11.0;
  static const double kDefaultIconSize = 20.0;
  static const double kDefaultAppTitleFontSize = 45.0;
  static const double kDefaultTitleFontSize = 24.0;
  static const double kDefaultFormTitleFontSize = 20.0;
  static const double kDefaultSubtitleFontSize = 14.0;

  static const double kDefaultFormHeightLarge = 50.0;
  static const double kDefaultFormHeightMedium = 40.0;
  static const double kDefaultButtonHeightLarge = 45.0;
  static const double kDefaultButtonHeightMedium = 40.0;
  static const double kDefaultButtonTextSizeLarge = 16.0;
  static const double kDefaultButtonTextSizeMedium = 14.0;

  /// Retrieves only the main country entries (filtering out the sub-regions).
  static List<String> get kCountriesOnly {
    return kCountriesList
        .where((e) => e.startsWith('assets/images/flags/'))
        .toList();
  }

  static List<String> get kCountryCodes =>
      PhoneCountryMetadata.countryCodeEntries;

  static const List<String> kCountriesList = [
    // Afghanistan
    'assets/images/flags/af.svg Afghanistan',
    'Badakhshan', 'Badghis', 'Baghlan', 'Balkh',
    'Bamian', 'Daykondi', 'Farah', 'Faryab',
    'Ghazni', 'Ghowr', 'Helmand', 'Herat',
    'Jowzjan', 'Kabol', 'Kandahar', 'Kapisa',
    'Khowst', 'Konar', 'Kondoz', 'Laghman',
    'Lowgar', 'Nangarhar', 'Nimruz', 'Nurestan',
    'Oruzgan', 'Paktia', 'Paktika', 'Panjshir',
    'Parvan', 'Samangan', 'Sar-e Pol', 'Takhar',
    'Vardak', 'Zabol',

    // Albania
    'assets/images/flags/al.svg Albania',
    'Berat', 'Diber', 'Durres', 'Elbasan',
    'Fier', 'Gjirokaster', 'Korce', 'Kukes',
    'Lezhe', 'Shkoder', 'Tirane', 'Vlore',

    // Algeria
    'assets/images/flags/dz.svg Algeria',
    'Adrar', 'Ain Defla', 'Ain Temouchent', 'Alger',
    'Annaba', 'Batna', 'Bechar', 'Bejaia',
    'Biskra', 'Blida', 'Bordj Bou Arreridj', 'Bouira',
    'Boumerdes', 'Chlef', 'Constantine', 'Djelfa',
    'El Bayadh', 'El Oued', 'El Tarf', 'Ghardaia',
    'Guelma', 'Illizi', 'Jijel', 'Khenchela',
    'Laghouat', 'M\'Sila', 'Mascara', 'Medea',
    'Mila', 'Mostaganem', 'Naama', 'Oran',
    'Ouargla', 'Oum el Bouaghi', 'Relizane', 'Saida',
    'Setif', 'Sidi Bel Abbes', 'Skikda', 'Souk Ahras',
    'Tamanghasset', 'Tebessa', 'Tiaret', 'Tindouf',
    'Tipaza', 'Tissemsilt', 'Tizi Ouzou', 'Tlemcen',

    // Andorra
    'assets/images/flags/ad.svg Andorra',
    'Andorra la Vella', 'Canillo', 'Encamp', 'Escaldes-Engordany',
    'La Massana', 'Ordino', 'Sant Julia de Loria',

    // Angola
    'assets/images/flags/ao.svg Angola',
    'Bengo', 'Benguela', 'Bie', 'Cabinda',
    'Cuando', 'Cuando Cubango', 'Cuanza Norte', 'Cuanza Sul',
    'Cunene', 'Huambo', 'Huila', 'Icolo e Bengo',
    'Luanda', 'Lunda Norte', 'Lunda Sul', 'Malanje',
    'Moxico', 'Moxico Leste', 'Namibe', 'Uige',
    'Zaire',

    // Antigua and Barbuda
    'assets/images/flags/ag.svg Antigua and Barbuda',
    'Barbuda', 'Redonda', 'Saint George', 'Saint John',
    'Saint Mary', 'Saint Paul', 'Saint Peter', 'Saint Philip',

    // Argentina
    'assets/images/flags/ar.svg Argentina',
    'Autonomous City of Buenos Aires', 'Buenos Aires', 'Catamarca', 'Chaco',
    'Chubut', 'Cordoba', 'Corrientes', 'Entre Rios',
    'Formosa', 'Jujuy', 'La Pampa', 'La Rioja',
    'Mendoza', 'Misiones', 'Neuquen', 'Rio Negro',
    'Salta', 'San Juan', 'San Luis', 'Santa Cruz',
    'Santa Fe', 'Santiago del Estero', 'Tierra del Fuego', 'Tucuman',

    // Armenia
    'assets/images/flags/am.svg Armenia',
    'Aragatsotn', 'Ararat', 'Armavir', 'Gegharkunik',
    'Kotayk', 'Lori', 'Shirak', 'Syunik',
    'Tavush', 'Vayots Dzor', 'Yerevan',

    // Australia
    'assets/images/flags/au.svg Australia',
    'Ashmore and Cartier Islands', 'Australian Antarctic Territory',
    'Australian Capital Territory', 'Christmas Island',
    'Cocos (Keeling) Islands', 'Coral Sea Islands',
    'Heard Island and McDonald Islands', 'Jervis Bay Territory',
    'New South Wales', 'Norfolk Island', 'Northern Territory', 'Queensland',
    'South Australia', 'Tasmania', 'Victoria', 'Western Australia',

    // Austria
    'assets/images/flags/at.svg Austria',
    'Burgenland', 'Carinthia', 'Lower Austria', 'Salzburg',
    'Styria', 'Tyrol', 'Upper Austria', 'Vienna',
    'Vorarlberg',

    // Azerbaijan
    'assets/images/flags/az.svg Azerbaijan',
    'Absheron', 'Agdam', 'Baku', 'Ganja',
    'Nakhchivan Autonomous Republic',

    // Bahamas
    'assets/images/flags/bs.svg Bahamas',
    'Acklins', 'Berry Islands', 'Bimini', 'Cat Island',
    'Central Abaco', 'Central Andros', 'Central Eleuthera', 'City of Freeport',
    'Crooked Island', 'East Grand Bahama', 'Exuma', 'Grand Cay',
    'Harbour Island', 'Hope Town', 'Inagua', 'Long Island',
    'Mangrove Cay', 'Mayaguana', 'Moore\'s Island', 'New Providence',
    'North Abaco', 'North Andros', 'North Eleuthera', 'Ragged Island',
    'Rum Cay', 'San Salvador', 'South Abaco', 'South Andros',
    'South Eleuthera', 'Spanish Wells', 'West Grand Bahama',

    // Bahrain
    'assets/images/flags/bh.svg Bahrain',
    'Capital', 'Muharraq', 'Northern', 'Southern',

    // Bangladesh
    'assets/images/flags/bd.svg Bangladesh',
    'Barisal', 'Chittagong', 'Dhaka', 'Khulna',
    'Mymensingh', 'Rajshahi', 'Rangpur', 'Sylhet',

    // Barbados
    'assets/images/flags/bb.svg Barbados',
    'Christ Church', 'Saint Andrew', 'Saint George', 'Saint James',
    'Saint John', 'Saint Joseph', 'Saint Lucy', 'Saint Michael',
    'Saint Peter', 'Saint Philip', 'Saint Thomas',

    // Belarus
    'assets/images/flags/by.svg Belarus',
    'Brest', 'Gomel', 'Grodno', 'Minsk',
    'Minsk Region', 'Mogilev', 'Vitebsk',

    // Belgium
    'assets/images/flags/be.svg Belgium',
    'Brussels-Capital', 'Flanders', 'Flemish', 'French',
    'German-speaking', 'Wallonia',

    // Belize
    'assets/images/flags/bz.svg Belize',
    'Belize', 'Cayo', 'Corozal', 'Orange Walk',
    'Stann Creek', 'Toledo',

    // Benin
    'assets/images/flags/bj.svg Benin',
    'Alibori', 'Atakora', 'Atlantique', 'Borgou',
    'Collines', 'Donga', 'Kouffo', 'Littoral',
    'Mono', 'Oueme', 'Plateau', 'Zou',

    // Bhutan
    'assets/images/flags/bt.svg Bhutan',
    'Bumthang', 'Chukha', 'Dagana', 'Gasa',
    'Haa', 'Lhuntse', 'Mongar', 'Paro',
    'Pemagatshel', 'Punakha', 'Samdrup Jongkhar', 'Samtse',
    'Sarpang', 'Thimphu', 'Trashi Yangtse', 'Trashigang',
    'Trongsa', 'Tsirang', 'Wangdue Phodrang', 'Zhemgang',

    // Bolivia
    'assets/images/flags/bo.svg Bolivia',
    'Beni', 'Chuquisaca', 'Cochabamba', 'La Paz',
    'Oruro', 'Pando', 'Potosi', 'Santa Cruz',
    'Tarija',

    // Bosnia and Herzegovina
    'assets/images/flags/ba.svg Bosnia and Herzegovina',
    'BrÃ„Âko District', 'Federation of Bosnia and Herzegovina',
    'Republika Srpska',

    // Botswana
    'assets/images/flags/bw.svg Botswana',
    'Central', 'Chobe', 'Ghanzi', 'Kgalagadi',
    'Kgatleng', 'Kweneng', 'North-East', 'North-West',
    'South-East', 'Southern',

    // Brazil
    'assets/images/flags/br.svg Brazil',
    'Acre', 'Alagoas', 'Amapa', 'Amazonas',
    'Bahia', 'Ceara', 'Distrito Federal', 'Espirito Santo',
    'Goias', 'Maranhao', 'Mato Grosso', 'Mato Grosso do Sul',
    'Minas Gerais', 'Para', 'Paraiba', 'Parana',
    'Pernambuco', 'Piaui', 'Rio de Janeiro', 'Rio Grande do Norte',
    'Rio Grande do Sul', 'Rondonia', 'Roraima', 'Santa Catarina',
    'Sao Paulo', 'Sergipe', 'Tocantins',

    // Brunei
    'assets/images/flags/bn.svg Brunei',
    'Belait', 'Brunei-Muara', 'Temburong', 'Tutong',

    // Bulgaria
    'assets/images/flags/bg.svg Bulgaria',
    'Blagoevgrad', 'Burgas', 'Dobrich', 'Gabrovo',
    'Haskovo', 'Kardzhali', 'Kyustendil', 'Lovech',
    'Montana', 'Pazardzhik', 'Pernik', 'Pleven',
    'Plovdiv', 'Razgrad', 'Ruse', 'Shumen',
    'Silistra', 'Sliven', 'Smolyan', 'Sofia (city)',
    'Sofia (province)', 'Stara Zagora', 'Targovishte', 'Varna',
    'Veliko Tarnovo', 'Vidin', 'Vratsa', 'Yambol',

    // Burkina Faso
    'assets/images/flags/bf.svg Burkina Faso',
    'Boucle du Mouhoun', 'Cascades', 'Centre', 'Centre-Est',
    'Centre-Nord', 'Centre-Ouest', 'Centre-Sud', 'Est',
    'Hauts-Bassins', 'Nord', 'Plateau-Central', 'Sahel',
    'Sud-Ouest',

    // Burundi
    'assets/images/flags/bi.svg Burundi',
    'Bubanza', 'Bujumbura Mairie', 'Bujumbura Rural', 'Bururi',
    'Cankuzo', 'Cibitoke', 'Gitega', 'Karuzi',
    'Kayanza', 'Kirundo', 'Makamba', 'Muramvya',
    'Muyinga', 'Mwaro', 'Ngozi', 'Rumonge',
    'Rutana', 'Ruyigi',

    // Cabo Verde
    'assets/images/flags/cv.svg Cabo Verde',
    'Praia',

    // Cambodia
    'assets/images/flags/kh.svg Cambodia',
    'Banteay Meanchey', 'Battambang', 'Kampong Cham', 'Kampong Chhnang',
    'Kampong Speu', 'Kampong Thom', 'Kampot', 'Kandal',
    'Kep', 'Koh Kong', 'Kratie', 'Mondulkiri',
    'Oddar Meanchey', 'Pailin', 'Phnom Penh', 'Preah Sihanouk',
    'Preah Vihear', 'Prey Veng', 'Pursat', 'Ratanakiri',
    'Siem Reap', 'Stung Treng', 'Svay Rieng', 'Takeo',
    'Tboung Khmum',

    // Cameroon
    'assets/images/flags/cm.svg Cameroon',
    'Adamawa', 'Centre', 'East', 'Far North',
    'Littoral', 'North', 'Northwest', 'South',
    'Southwest', 'West',

    // Canada
    'assets/images/flags/ca.svg Canada',
    'Alberta', 'British Columbia', 'Manitoba', 'New Brunswick',
    'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia',
    'Nunavut',
    'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan',
    'Yukon',

    // Central African Republic
    'assets/images/flags/cf.svg Central African Republic',
    'Bamingui-Bangoran', 'Bangui', 'Basse-Kotto', 'Haut-Mbomou',
    'Haute-Kotto', 'Kemo', 'Lobaye', 'Mambere-Kadei',
    'Mbomou', 'Nana-Grebizi', 'Nana-Mambere', 'Ombella-Mpoko',
    'Ouaka', 'Ouham', 'Ouham-Pende', 'Sangha-Mbaere',
    'Vakaga',

    // Chad
    'assets/images/flags/td.svg Chad',
    'Batha', 'Borkou', 'Chari-Baguirmi', 'Ennedi-Est',
    'Ennedi-Ouest', 'Guera', 'Hadjer-Lamis', 'Kanem',
    'Lac', 'Logone Occidental', 'Logone Oriental', 'Mandoul',
    'Mayo-Kebbi Est', 'Mayo-Kebbi Ouest', 'Moyen-Chari', 'N\'Djamena',
    'Ouaddai', 'Salamat', 'Sila', 'Tandjile',
    'Tibesti', 'Wadi Fira',

    // Chile
    'assets/images/flags/cl.svg Chile',
    'Aisen', 'Antofagasta', 'Araucania', 'Arica y Parinacota',
    'Atacama', 'Biobio', 'Coquimbo', 'Los Lagos',
    'Los Rios', 'Magallanes', 'Maule', 'Metropolitana',
    'O\'Higgins', 'Tarapaca', 'Valparaiso', 'Ãƒâ€˜uble',

    // China
    'assets/images/flags/cn.svg China',
    'Anhui', 'Beijing', 'Chongqing', 'Fujian',
    'Gansu', 'Guangdong', 'Guangxi', 'Guizhou',
    'Hainan', 'Hebei', 'Heilongjiang', 'Henan',
    'Hong Kong', 'Hubei', 'Hunan', 'Inner Mongolia',
    'Jiangsu', 'Jiangxi', 'Jilin', 'Liaoning',
    'Macau', 'Ningxia', 'Qinghai', 'Shaanxi',
    'Shandong', 'Shanghai', 'Shanxi', 'Sichuan',
    'Tianjin', 'Tibet', 'Xinjiang', 'Yunnan',
    'Zhejiang',

    // Colombia
    'assets/images/flags/co.svg Colombia',
    'Amazonas', 'Antioquia', 'Arauca', 'Atlantico',
    'Bogota', 'Bolivar', 'Boyaca', 'Caldas',
    'Caqueta', 'Casanare', 'Cauca', 'Cesar',
    'Choco', 'Cordoba', 'Cundinamarca', 'Guainia',
    'Guaviare', 'Huila', 'La Guajira', 'Magdalena',
    'Meta', 'NariÃƒÂ±o', 'Norte de Santander', 'Putumayo',
    'Quindio', 'Risaralda', 'San Andres y Providencia', 'Santander',
    'Sucre', 'Tolima', 'Valle del Cauca', 'Vaupes',
    'Vichada',

    // Comoros
    'assets/images/flags/km.svg Comoros',
    'Anjouan', 'Grande Comore', 'Moheli',

    // Congo (DRC)
    'assets/images/flags/cd.svg Congo (DRC)',
    'Bas-Uele', 'Equateur', 'Haut-Katanga', 'Haut-Lomami',
    'Haut-Uele', 'Ituri', 'Kasai', 'Kasai-Central',
    'Kasai-Oriental', 'Kinshasa', 'Kongo-Central', 'Kwango',
    'Kwilu', 'Lomami', 'Lualaba', 'Lulua',
    'Mai-Ndombe', 'Maniema', 'Mongala', 'Nord-Kivu',
    'Nord-Ubangi', 'Sankuru', 'Sud-Kivu', 'Sud-Ubangi',
    'Tanganyika', 'Tshopo', 'Tshuapa',

    // Congo (Republic)
    'assets/images/flags/cg.svg Congo (Republic)',
    'Bouenza', 'Brazzaville', 'Cuvette', 'Cuvette-Ouest',
    'Kouilou', 'Lekoumou', 'Likouala', 'Niari',
    'Plateaux', 'Pointe-Noire', 'Pool', 'Sangha',

    // Costa Rica
    'assets/images/flags/cr.svg Costa Rica',
    'Alajuela', 'Cartago', 'Guanacaste', 'Heredia',
    'Limon', 'Puntarenas', 'San Jose',

    // Croatia
    'assets/images/flags/hr.svg Croatia',
    'Bjelovar-Bilogora', 'Brod-Posavina', 'City of Zagreb', 'Dubrovnik-Neretva',
    'Istria', 'Karlovac', 'Koprivnica-Krizevci', 'Krapina-Zagorje',
    'Lika-Senj', 'Medjimurje', 'Osijek-Baranja', 'Pozega-Slavonia',
    'Primorje-Gorski Kotar', 'Sibenik-Knin', 'Sisak-Moslavina',
    'Split-Dalmatia',
    'Varazdin', 'Virovitica-Podravina', 'Vukovar-Srijem', 'Zadar',
    'Zagreb County',

    // Cuba
    'assets/images/flags/cu.svg Cuba',
    'Artemisa', 'Camaguey', 'Ciego de Avila', 'Cienfuegos',
    'Granma', 'Guantanamo', 'Holguin', 'Isla de la Juventud',
    'La Habana', 'Las Tunas', 'Matanzas', 'Mayabeque',
    'Pinar del Rio', 'Sancti Spiritus', 'Santiago de Cuba', 'Villa Clara',

    // Cyprus
    'assets/images/flags/cy.svg Cyprus',
    'Famagusta', 'Kyrenia', 'Larnaca', 'Limassol',
    'Nicosia', 'Paphos',

    // Czech Republic
    'assets/images/flags/cz.svg Czech Republic',
    'Central Bohemian', 'Hradec Kralove', 'Karlovy Vary', 'Liberec',
    'Moravian-Silesian', 'Olomouc', 'Pardubice', 'Plzen',
    'Prague', 'South Bohemian', 'South Moravian', 'Usti nad Labem',
    'Vysocina', 'Zlin',

    // CÃƒÂ´te d\'Ivoire
    'assets/images/flags/ci.svg CÃƒÂ´te d\'Ivoire',
    'Abidjan', 'Bas-Sassandra', 'Comoe', 'Denguele',
    'Goh-Djiboua', 'Lacs', 'Lagunes', 'Montagnes',
    'Sassandra-Marahoue', 'Savanes', 'Vallee du Bandama', 'Woroba',
    'Yamoussoukro', 'Zanzan',

    // Denmark
    'assets/images/flags/dk.svg Denmark',
    'Capital Region', 'Central Denmark', 'North Denmark', 'Southern Denmark',
    'Zealand',

    // Djibouti
    'assets/images/flags/dj.svg Djibouti',
    'Ali Sabieh', 'Arta', 'Dikhil', 'Djibouti',
    'Obock', 'Tadjourah',

    // Dominica
    'assets/images/flags/dm.svg Dominica',
    'Saint Andrew', 'Saint David', 'Saint George', 'Saint John',
    'Saint Joseph', 'Saint Luke', 'Saint Mark', 'Saint Patrick',
    'Saint Paul', 'Saint Peter',

    // Dominican Republic
    'assets/images/flags/do.svg Dominican Republic',
    'Azua', 'Baoruco', 'Barahona', 'Dajabon',
    'Distrito Nacional', 'Duarte', 'El Seibo', 'Elias PiÃƒÂ±a',
    'Espaillat', 'Hato Mayor', 'Hermanas Mirabal', 'Independencia',
    'La Altagracia', 'La Romana', 'La Vega', 'Maria Trinidad Sanchez',
    'MonseÃƒÂ±or Nouel', 'Monte Cristi', 'Monte Plata', 'Pedernales',
    'Peravia', 'Puerto Plata', 'Samana', 'San Cristobal',
    'San Jose de Ocoa', 'San Juan', 'San Pedro de Macoris', 'Sanchez Ramirez',
    'Santiago', 'Santiago Rodriguez', 'Santo Domingo', 'Valverde',

    // East Timor
    'assets/images/flags/tl.svg East Timor',
    'Aileu', 'Ainaro', 'Atauro', 'Baucau',
    'Bobonaro', 'Covalima', 'Dili', 'Ermera',
    'LautÃƒÂ©m', 'LiquiÃƒÂ§ÃƒÂ¡', 'Manatuto', 'Manufahi',
    'Oecusse', 'Viqueque',

    // Ecuador
    'assets/images/flags/ec.svg Ecuador',
    'Azuay', 'Bolivar', 'Carchi', 'CaÃƒÂ±ar',
    'Chimborazo', 'Cotopaxi', 'El Oro', 'Esmeraldas',
    'Galapagos', 'Guayas', 'Imbabura', 'Loja',
    'Los Rios', 'Manabi', 'Morona-Santiago', 'Napo',
    'Orellana', 'Pastaza', 'Pichincha', 'Santa Elena',
    'Santo Domingo de los Tsachilas', 'Sucumbios', 'Tungurahua',
    'Zamora-Chinchipe',

    // Egypt
    'assets/images/flags/eg.svg Egypt',
    'Alexandria', 'Aswan', 'Asyut', 'Beheira',
    'Beni Suef', 'Cairo', 'Dakahlia', 'Damietta',
    'Faiyum', 'Gharbia', 'Giza', 'Ismailia',
    'Kafr El Sheikh', 'Luxor', 'Matrouh', 'Minya',
    'Monufia', 'New Valley', 'North Sinai', 'Port Said',
    'Qalyubia', 'Qena', 'Red Sea', 'Sharqia',
    'Sohag', 'South Sinai', 'Suez',

    // El Salvador
    'assets/images/flags/sv.svg El Salvador',
    'Ahuachapan', 'CabaÃƒÂ±as', 'Chalatenango', 'Cuscatlan',
    'La Libertad', 'La Paz', 'La Union', 'Morazan',
    'San Miguel', 'San Salvador', 'San Vicente', 'Santa Ana',
    'Sonsonate', 'Usulutan',

    // England
    'assets/images/flags/gb-eng.svg England',
    'East Midlands', 'East of England', 'London', 'North East',
    'North West', 'South East', 'South West', 'West Midlands',
    'Yorkshire and the Humber',

    // Equatorial Guinea
    'assets/images/flags/gq.svg Equatorial Guinea',
    'Annobon', 'Bioko Norte', 'Bioko Sur', 'Centro Sur',
    'Djibloho', 'Kie-Ntem', 'Litoral', 'Wele-Nzas',

    // Eritrea
    'assets/images/flags/er.svg Eritrea',
    'Anseba', 'Central', 'Gash-Barka', 'Northern Red Sea',
    'Southern', 'Southern Red Sea',

    // Estonia
    'assets/images/flags/ee.svg Estonia',
    'Harju', 'Hiiu', 'Ida-Viru', 'JÃƒÂ¤rva',
    'JÃƒÂµgeva', 'LÃƒÂ¤ÃƒÂ¤ne', 'LÃƒÂ¤ÃƒÂ¤ne-Viru', 'PÃƒÂ¤rnu',
    'PÃƒÂµlva', 'Rapla', 'Saare', 'Tartu',
    'Valga', 'Viljandi', 'VÃƒÂµru',

    // Eswatini
    'assets/images/flags/sz.svg Eswatini',
    'Mbabane',

    // Ethiopia
    'assets/images/flags/et.svg Ethiopia',
    'Addis Ababa', 'Afar', 'Amhara', 'Benishangul-Gumuz',
    'Dire Dawa', 'Gambela', 'Harari', 'Oromia',
    'Sidama', 'Somali', 'South West Ethiopia',
    'Southern Nations Nationalities and Peoples\'',
    'Tigray',

    // Fiji
    'assets/images/flags/fj.svg Fiji',
    'Central', 'Eastern', 'Northern', 'Rotuma',
    'Western',

    // Finland
    'assets/images/flags/fi.svg Finland',
    'Central Finland', 'Central Ostrobothnia', 'Kainuu', 'Kymenlaakso',
    'Lapland', 'North Karelia', 'North Ostrobothnia', 'North Savo',
    'Ostrobothnia', 'Pirkanmaa', 'PÃƒÂ¤ijÃƒÂ¤t-HÃƒÂ¤me', 'Satakunta',
    'South Karelia', 'South Ostrobothnia', 'South Savo', 'Southwest Finland',
    'Uusimaa', 'Ãƒâ€¦land',

    // France
    'assets/images/flags/fr.svg France',
    'Auvergne-RhÃƒÂ´ne-Alpes', 'Bourgogne-Franche-ComtÃƒÂ©', 'Brittany',
    'Centre-Val de Loire',
    'Corsica', 'Grand Est', 'Hauts-de-France', 'Normandy',
    'Nouvelle-Aquitaine', 'Occitanie', 'Pays de la Loire',
    'Provence-Alpes-CÃƒÂ´te d\'Azur',
    'ÃƒÅ½le-de-France',

    // Gabon
    'assets/images/flags/ga.svg Gabon',
    'Estuaire', 'Haut-OgoouÃƒÂ©', 'Moyen-OgoouÃƒÂ©', 'NgouniÃƒÂ©',
    'Nyanga', 'OgoouÃƒÂ©-Ivindo', 'OgoouÃƒÂ©-Lolo', 'OgoouÃƒÂ©-Maritime',
    'Woleu-Ntem',

    // Gambia
    'assets/images/flags/gm.svg Gambia',
    'Banjul', 'Central River', 'Lower River', 'North Bank',
    'Upper River', 'West Coast',

    // Georgia
    'assets/images/flags/ge.svg Georgia',
    'Abkhazia', 'Adjara', 'Guria', 'Imereti',
    'Kakheti', 'Kvemo Kartli', 'Mtskheta-Mtianeti',
    'Racha-Lechkhumi and Kvemo Svaneti',
    'Samegrelo-Zemo Svaneti', 'Samtskhe-Javakheti', 'Shida Kartli', 'Tbilisi',

    // Germany
    'assets/images/flags/de.svg Germany',
    'Baden-WÃƒÂ¼rttemberg', 'Bavaria', 'Berlin', 'Brandenburg',
    'Bremen', 'Hamburg', 'Hesse', 'Lower Saxony',
    'Mecklenburg-Vorpommern', 'North Rhine-Westphalia', 'Rhineland-Palatinate',
    'Saarland',
    'Saxony', 'Saxony-Anhalt', 'Schleswig-Holstein', 'Thuringia',

    // Ghana
    'assets/images/flags/gh.svg Ghana',
    'Ahafo', 'Ashanti', 'Bono', 'Bono East',
    'Central', 'Eastern', 'Greater Accra', 'North East',
    'Northern', 'Oti', 'Savannah', 'Upper East',
    'Upper West', 'Volta', 'Western', 'Western North',

    // Greece
    'assets/images/flags/gr.svg Greece',
    'Attica', 'Central Greece', 'Central Macedonia', 'Crete',
    'Eastern Macedonia and Thrace', 'Epirus', 'Ionian Islands', 'Mount Athos',
    'North Aegean', 'Peloponnese', 'South Aegean', 'Thessaly',
    'Western Greece', 'Western Macedonia',

    // Grenada
    'assets/images/flags/gd.svg Grenada',
    'Carriacou and Petite Martinique', 'Saint Andrew', 'Saint David',
    'Saint George',
    'Saint John', 'Saint Mark', 'Saint Patrick',

    // Guatemala
    'assets/images/flags/gt.svg Guatemala',
    'Alta Verapaz', 'Baja Verapaz', 'Chimaltenango', 'Chiquimula',
    'El Progreso', 'Escuintla', 'Guatemala', 'Huehuetenango',
    'Izabal', 'Jalapa', 'Jutiapa', 'PetÃƒÂ©n',
    'Quetzaltenango', 'QuichÃƒÂ©', 'Retalhuleu', 'SacatepÃƒÂ©quez',
    'San Marcos', 'Santa Rosa', 'SololÃƒÂ¡', 'SuchitepÃƒÂ©quez',
    'TotonicapÃƒÂ¡n', 'Zacapa',

    // Guinea
    'assets/images/flags/gn.svg Guinea',
    'BokÃƒÂ©', 'Conakry', 'Faranah', 'Kankan',
    'Kindia', 'LabÃƒÂ©', 'Mamou', 'NzÃƒÂ©rÃƒÂ©korÃƒÂ©',

    // Guinea-Bissau
    'assets/images/flags/gw.svg Guinea-Bissau',
    'BafatÃƒÂ¡', 'Biombo', 'Bissau', 'Bolama',
    'Cacheu', 'GabÃƒÂº', 'Oio', 'Quinara',
    'Tombali',

    // Guyana
    'assets/images/flags/gy.svg Guyana',
    'Barima-Waini', 'Cuyuni-Mazaruni', 'Demerara-Mahaica',
    'East Berbice-Corentyne',
    'Essequibo Islands-West Demerara', 'Mahaica-Berbice', 'Pomeroon-Supenaam',
    'Potaro-Siparuni',
    'Upper Demerara-Berbice', 'Upper Takutu-Upper Essequibo',

    // Haiti
    'assets/images/flags/ht.svg Haiti',
    'Artibonite', 'Centre', 'Grand\'Anse', 'Nippes',
    'Nord', 'Nord-Est', 'Nord-Ouest', 'Ouest',
    'Sud', 'Sud-Est',

    // Honduras
    'assets/images/flags/hn.svg Honduras',
    'AtlÃƒÂ¡ntida', 'Choluteca', 'ColÃƒÂ³n', 'Comayagua',
    'CopÃƒÂ¡n', 'CortÃƒÂ©s', 'El ParaÃƒÂ­so', 'Francisco MorazÃƒÂ¡n',
    'Gracias a Dios', 'IntibucÃƒÂ¡', 'Islas de la BahÃƒÂ­a', 'La Paz',
    'Lempira', 'Ocotepeque', 'Olancho', 'Santa BÃƒÂ¡rbara',
    'Valle', 'Yoro',

    // Hungary
    'assets/images/flags/hu.svg Hungary',
    'Baranya', 'Borsod-AbaÃƒÂºj-ZemplÃƒÂ©n', 'Budapest', 'BÃƒÂ¡cs-Kiskun',
    'BÃƒÂ©kÃƒÂ©s', 'CsongrÃƒÂ¡d-CsanÃƒÂ¡d', 'FejÃƒÂ©r', 'GyÃ…â€˜r-Moson-Sopron',
    'HajdÃƒÂº-Bihar', 'Heves', 'JÃƒÂ¡sz-Nagykun-Szolnok',
    'KomÃƒÂ¡rom-Esztergom',
    'NÃƒÂ³grÃƒÂ¡d', 'Pest', 'Somogy', 'Szabolcs-SzatmÃƒÂ¡r-Bereg',
    'Tolna', 'Vas', 'VeszprÃƒÂ©m', 'Zala',

    // Iceland
    'assets/images/flags/is.svg Iceland',
    'Capital Region', 'Eastern', 'Northeastern', 'Northwestern',
    'Southern', 'Southern Peninsula', 'Western', 'Westfjords',

    // India
    'assets/images/flags/in.svg India',
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',

    // Indonesia
    'assets/images/flags/id.svg Indonesia',
    'Aceh', 'Bali', 'Banten', 'Bengkulu',
    'Central Java', 'Central Kalimantan', 'Central Papua', 'Central Sulawesi',
    'East Java', 'East Kalimantan', 'East Nusa Tenggara', 'Gorontalo',
    'Highland Papua', 'Jakarta', 'Jambi', 'Lampung',
    'Maluku', 'North Kalimantan', 'North Maluku', 'North Sulawesi',
    'North Sumatra', 'Papua', 'Riau', 'Riau Islands',
    'South Kalimantan', 'South Papua', 'South Sulawesi', 'South Sumatra',
    'Southeast Sulawesi', 'Southwest Papua', 'West Java', 'West Kalimantan',
    'West Nusa Tenggara', 'West Papua', 'West Sulawesi', 'West Sumatra',
    'Yogyakarta',

    // Iran
    'assets/images/flags/ir.svg Iran',
    'Alborz', 'Ardabil', 'Bushehr', 'Chaharmahal and Bakhtiari',
    'East Azerbaijan', 'Fars', 'Gilan', 'Golestan',
    'Hamadan', 'Hormozgan', 'Ilam', 'Isfahan',
    'Kerman', 'Kermanshah', 'Khuzestan', 'Kohgiluyeh and Boyer-Ahmad',
    'Kurdistan', 'Lorestan', 'Markazi', 'Mazandaran',
    'North Khorasan', 'Qazvin', 'Qom', 'Razavi Khorasan',
    'Semnan', 'Sistan and Baluchestan', 'South Khorasan', 'Tehran',
    'West Azerbaijan', 'Yazd', 'Zanjan',

    // Iraq
    'assets/images/flags/iq.svg Iraq',
    'Al Anbar', 'Babil', 'Baghdad', 'Basra',
    'Dhi Qar', 'Diyala', 'Duhok', 'Erbil',
    'Halabja', 'Karbala', 'Kirkuk', 'Kurdistan',
    'Maysan', 'Muthanna', 'Najaf', 'Nineveh',
    'Qadisiyyah', 'Saladin', 'Sulaymaniyah', 'Wasit',

    // Ireland
    'assets/images/flags/ie.svg Ireland',
    'Carlow', 'Cavan', 'Clare', 'Cork',
    'Donegal', 'Dublin', 'Galway', 'Kerry',
    'Kildare', 'Kilkenny', 'Laois', 'Leitrim',
    'Limerick', 'Longford', 'Louth', 'Mayo',
    'Meath', 'Monaghan', 'Offaly', 'Roscommon',
    'Sligo', 'Tipperary', 'Waterford', 'Westmeath',
    'Wexford', 'Wicklow',

    // Israel
    'assets/images/flags/il.svg Israel',
    'Central', 'Haifa', 'Jerusalem', 'Judea and Samaria Area',
    'Northern', 'Southern', 'Tel Aviv',

    // Italy
    'assets/images/flags/it.svg Italy',
    'Abruzzo', 'Aosta Valley', 'Apulia', 'Basilicata',
    'Calabria', 'Campania', 'Emilia-Romagna', 'Friuli-Venezia Giulia',
    'Lazio', 'Liguria', 'Lombardy', 'Marche',
    'Molise', 'Piedmont', 'Sardinia', 'Sicily',
    'Trentino-Alto Adige', 'Tuscany', 'Umbria', 'Veneto',

    // Jamaica
    'assets/images/flags/jm.svg Jamaica',
    'Clarendon', 'Hanover', 'Kingston', 'Manchester',
    'Portland', 'Saint Andrew', 'Saint Ann', 'Saint Catherine',
    'Saint Elizabeth', 'Saint James', 'Saint Mary', 'Saint Thomas',
    'Trelawny', 'Westmoreland',

    // Japan
    'assets/images/flags/jp.svg Japan',
    'Aichi', 'Akita', 'Aomori', 'Chiba',
    'Ehime', 'Fukui', 'Fukuoka', 'Fukushima',
    'Gifu', 'Gunma', 'Hiroshima', 'Hokkaido',
    'Hyogo', 'Ibaraki', 'Ishikawa', 'Iwate',
    'Kagawa', 'Kagoshima', 'Kanagawa', 'Kochi',
    'Kumamoto', 'Kyoto', 'Mie', 'Miyagi',
    'Miyazaki', 'Nagano', 'Nagasaki', 'Nara',
    'Niigata', 'Oita', 'Okayama', 'Okinawa',
    'Osaka', 'Saga', 'Saitama', 'Shiga',
    'Shimane', 'Shizuoka', 'Tochigi', 'Tokushima',
    'Tokyo', 'Tottori', 'Toyama', 'Wakayama',
    'Yamagata', 'Yamaguchi', 'Yamanashi',

    // Jordan
    'assets/images/flags/jo.svg Jordan',
    'Ajloun', 'Amman', 'Aqaba', 'Balqa',
    'Irbid', 'Jerash', 'Karak', 'Ma\'an',
    'Madaba', 'Mafraq', 'Tafilah', 'Zarqa',

    // Kazakhstan
    'assets/images/flags/kz.svg Kazakhstan',
    'Abai', 'Akmola', 'Aktobe', 'Almaty',
    'Astana', 'Atyrau', 'East Kazakhstan', 'Jambyl',
    'Jetisu', 'Karaganda', 'Kostanay', 'Kyzylorda',
    'Mangystau', 'North Kazakhstan', 'Pavlodar', 'Shymkent',
    'Turkistan', 'Ulytau', 'West Kazakhstan',

    // Kenya
    'assets/images/flags/ke.svg Kenya',
    'Baringo', 'Bomet', 'Bungoma', 'Busia',
    'Elgeyo-Marakwet', 'Embu', 'Garissa', 'Homa Bay',
    'Isiolo', 'Kajiado', 'Kakamega', 'Kericho',
    'Kiambu', 'Kilifi', 'Kirinyaga', 'Kisii',
    'Kisumu', 'Kitui', 'Kwale', 'Laikipia',
    'Lamu', 'Machakos', 'Makueni', 'Mandera',
    'Marsabit', 'Meru', 'Migori', 'Mombasa',
    'Murang\'a', 'Nairobi', 'Nakuru', 'Nandi',
    'Narok', 'Nyamira', 'Nyandarua', 'Nyeri',
    'Samburu', 'Siaya', 'Taita-Taveta', 'Tana River',
    'Tharaka-Nithi', 'Trans-Nzoia', 'Turkana', 'Uasin Gishu',
    'Vihiga', 'Wajir', 'West Pokot',

    // Kiribati
    'assets/images/flags/ki.svg Kiribati',
    'Gilbert Islands', 'Line Islands', 'Phoenix Islands',

    // Kosovo
    'assets/images/flags/xk.svg Kosovo',

    // Kuwait
    'assets/images/flags/kw.svg Kuwait',
    'Al Ahmadi', 'Al Asimah', 'Al Farwaniyah', 'Al Jahra',
    'Hawalli', 'Mubarak Al-Kabeer',

    // Kyrgyzstan
    'assets/images/flags/kg.svg Kyrgyzstan',
    'Batken', 'Bishkek', 'Chuy', 'Issyk-Kul',
    'Jalal-Abad', 'Naryn', 'Osh', 'Talas',

    // Laos
    'assets/images/flags/la.svg Laos',
    'Attapeu', 'Bokeo', 'Bolikhamsai', 'Champasak',
    'Houaphanh', 'Khammouane', 'Luang Namtha', 'Luang Prabang',
    'Oudomxay', 'Phongsaly', 'Sainyabuli', 'Salavan',
    'Savannakhet', 'Sekong', 'Vientiane', 'Vientiane Province',
    'Xaisomboun', 'Xiangkhouang',

    // Latvia
    'assets/images/flags/lv.svg Latvia',
    'Daugavpils', 'Jelgava', 'Jurmala', 'Liepaja',
    'Rezekne', 'Riga', 'Ventspils',

    // Lebanon
    'assets/images/flags/lb.svg Lebanon',
    'Akkar', 'Baalbek-Hermel', 'Beirut', 'Beqaa',
    'Keserwan-Jbeil', 'Mount Lebanon', 'Nabatieh', 'North',
    'South',

    // Lesotho
    'assets/images/flags/ls.svg Lesotho',
    'Berea', 'Butha-Buthe', 'Leribe', 'Mafeteng',
    'Maseru', 'Mohale\'s Hoek', 'Mokhotlong', 'Qacha\'s Nek',
    'Quthing', 'Thaba-Tseka',

    // Liberia
    'assets/images/flags/lr.svg Liberia',
    'Bomi', 'Bong', 'Gbarpolu', 'Grand Bassa',
    'Grand Cape Mount', 'Grand Gedeh', 'Grand Kru', 'Lofa',
    'Margibi', 'Maryland', 'Montserrado', 'Nimba',
    'River Cess', 'River Gee', 'Sinoe',

    // Libya
    'assets/images/flags/ly.svg Libya',
    'Benghazi', 'Butnan', 'Derna', 'Ghat',
    'Jabal al Akhdar', 'Jabal al Gharbi', 'Jafara', 'Jufra',
    'Kufra', 'Marj', 'Misrata', 'Murqub',
    'Murzuq', 'Nalut', 'Nuqat al Khams', 'Sabha',
    'Sirte', 'Tripoli', 'Wadi al Hayaa', 'Wadi al Shatii',
    'Wahat', 'Zawiya',

    // Liechtenstein
    'assets/images/flags/li.svg Liechtenstein',
    'Balzers', 'Eschen', 'Gamprin', 'Mauren',
    'Planken', 'Ruggell', 'Schaan', 'Schellenberg',
    'Triesen', 'Triesenberg', 'Vaduz',

    // Lithuania
    'assets/images/flags/lt.svg Lithuania',
    'Alytus', 'Kaunas', 'KlaipÃ„â€”da', 'MarijampolÃ„â€”',
    'PanevÃ„â€”Ã…Â¾ys', 'TauragÃ„â€”', 'TelÃ…Â¡iai', 'Utena',
    'Vilnius', 'Ã…Â iauliai',

    // Luxembourg
    'assets/images/flags/lu.svg Luxembourg',
    'Capellen', 'Clervaux', 'Diekirch', 'Echternach',
    'Esch-sur-Alzette', 'Grevenmacher', 'Luxembourg', 'Mersch',
    'Redange', 'Remich', 'Vianden', 'Wiltz',

    // Madagascar
    'assets/images/flags/mg.svg Madagascar',
    'Alaotra-Mangoro', 'Amoron\'i Mania', 'Analamanga', 'Analanjirofo',
    'Androy', 'Anosy', 'Atsimo-Andrefana', 'Atsimo-Atsinanana',
    'Atsinanana', 'Betsiboka', 'Boeny', 'Bongolava',
    'Diana', 'Fitovinany', 'Haute Matsiatra', 'Ihorombe',
    'Itasy', 'Melaky', 'Menabe', 'Sava',
    'Sofia', 'Vakinankaratra', 'Vatovavy',

    // Malawi
    'assets/images/flags/mw.svg Malawi',
    'Central', 'Northern', 'Southern',

    // Malaysia
    'assets/images/flags/my.svg Malaysia',
    'Johor', 'Kedah', 'Kelantan', 'Kuala Lumpur',
    'Labuan', 'Malacca', 'Negeri Sembilan', 'Pahang',
    'Penang', 'Perak', 'Perlis', 'Putrajaya',
    'Sabah', 'Sarawak', 'Selangor', 'Terengganu',

    // Maldives
    'assets/images/flags/mv.svg Maldives',
    'Addu', 'Fuvahmulah', 'Kulhudhuffushi', 'Male',

    // Mali
    'assets/images/flags/ml.svg Mali',
    'Bamako', 'Bougouni', 'Dioila', 'Douentza',
    'Gao', 'Kayes', 'Kidal', 'Kita',
    'Koulikoro', 'Menaka', 'Mopti', 'Nara',
    'Nioro', 'San', 'Segou', 'Sikasso',
    'Taoudenit', 'Tombouctou',

    // Malta
    'assets/images/flags/mt.svg Malta',
    'Central', 'Gozo', 'North Eastern', 'Northern',
    'South Eastern', 'Southern',

    // Marshall Islands
    'assets/images/flags/mh.svg Marshall Islands',
    'Ailinglaplap', 'Ailuk', 'Arno', 'Aur',
    'Bikar', 'Bikini', 'Bokak', 'Ebon',
    'Enewetak', 'Erikub', 'Jabat', 'Jaluit',
    'Kili', 'Kwajalein', 'Lae', 'Lib',
    'Likiep', 'Majuro', 'Maloelap', 'Mejit',
    'Mili', 'Namorik', 'Namu', 'Rongelap',
    'Rongerik', 'Toke', 'Ujae', 'Ujelang',
    'Utirik', 'Wotho', 'Wotje',

    // Mauritania
    'assets/images/flags/mr.svg Mauritania',
    'Adrar', 'Assaba', 'Brakna', 'Dakhlet Nouadhibou',
    'Gorgol', 'Guidimaka', 'Hodh Ech Chargui', 'Hodh El Gharbi',
    'Inchiri', 'Nouakchott-Nord', 'Nouakchott-Ouest', 'Nouakchott-Sud',
    'Tagant', 'Tiris Zemmour', 'Trarza',

    // Mauritius
    'assets/images/flags/mu.svg Mauritius',
    'Black River', 'Flacq', 'Grand Port', 'Moka',
    'Pamplemousses', 'Plaines Wilhems', 'Port Louis', 'Riviere du Rempart',
    'Rodrigues', 'Savanne',

    // Mexico
    'assets/images/flags/mx.svg Mexico',
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche',
    'Chiapas', 'Chihuahua', 'Coahuila', 'Colima',
    'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo',
    'Jalisco', 'Mexico', 'Mexico City', 'Michoacan',
    'Morelos', 'Nayarit', 'Nuevo Leon', 'Oaxaca',
    'Puebla', 'Queretaro', 'Quintana Roo', 'San Luis Potosi',
    'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas',
    'Tlaxcala', 'Veracruz', 'Yucatan', 'Zacatecas',

    // Micronesia
    'assets/images/flags/fm.svg Micronesia',
    'Chuuk', 'Kosrae', 'Pohnpei', 'Yap',

    // Moldova
    'assets/images/flags/md.svg Moldova',
    'BÃ„Æ’lÃˆâ€ºi', 'ChiÃˆâ„¢inÃ„Æ’u', 'Gagauzia',
    'Left Bank of the Dniester (Transnistria)',
    'Tighina',

    // Monaco
    'assets/images/flags/mc.svg Monaco',
    'Monaco',

    // Mongolia
    'assets/images/flags/mn.svg Mongolia',
    'Arkhangai', 'Bayan-Olgii', 'Bayankhongor', 'Bulgan',
    'Darkhan-Uul', 'Dornod', 'Dornogovi', 'Dundgovi',
    'Govi-Altai', 'GovisÃƒÂ¼mber', 'Khentii', 'Khovd',
    'KhÃƒÂ¶vsgÃƒÂ¶l', 'Orkhon', 'Selenge', 'SÃƒÂ¼khbaatar',
    'TÃƒÂ¶v', 'Ulaanbaatar', 'Uvs', 'Zavkhan',
    'Ãƒâ€“mnÃƒÂ¶govi', 'Ãƒâ€“vÃƒÂ¶rkhangai',

    // Montenegro
    'assets/images/flags/me.svg Montenegro',
    'Bar', 'Budva', 'Cetinje', 'Herceg Novi',
    'Niksic', 'Podgorica',

    // Morocco
    'assets/images/flags/ma.svg Morocco',
    'Beni Mellal-Khenifra', 'Casablanca-Settat', 'Dakhla-Oued Ed-Dahab',
    'Draa-Tafilalet',
    'Fes-Meknes', 'Guelmim-Oued Noun', 'Laayoune-Sakia El Hamra',
    'Marrakesh-Safi',
    'Oriental', 'Rabat-Sale-Kenitra', 'Souss-Massa',
    'Tanger-Tetouan-Al Hoceima',

    // Mozambique
    'assets/images/flags/mz.svg Mozambique',
    'Cabo Delgado', 'Gaza', 'Inhambane', 'Manica',
    'Maputo', 'Maputo Province', 'Nampula', 'Niassa',
    'Sofala', 'Tete', 'Zambezia',

    // Myanmar
    'assets/images/flags/mm.svg Myanmar',
    'Bago', 'Dawei', 'Hpa-an', 'Loikaw',
    'Magway', 'Mandalay', 'Mawlamyine', 'Monywa',
    'Myitkyina', 'Naypyidaw', 'Pathein', 'Sittway',
    'Taunggyi', 'Yangon',

    // Namibia
    'assets/images/flags/na.svg Namibia',
    'Erongo', 'Hardap',

    // Nauru
    'assets/images/flags/nr.svg Nauru',
    'Aiwo', 'Anabar', 'Anean', 'Anibare',
    'Baiti', 'Boe', 'Buada', 'Denigomodu',
    'Ewa', 'Ijuw', 'Meneng', 'Nibok',
    'Uaboe', 'Yaren',

    // Nepal
    'assets/images/flags/np.svg Nepal',
    'Bagmati', 'Gandaki', 'Karnali', 'Koshi',
    'Lumbini', 'Madhesh', 'Sudurpashchim',

    // Netherlands
    'assets/images/flags/nl.svg Netherlands',
    'Bonaire', 'Drenthe', 'Flevoland', 'Friesland',
    'Gelderland', 'Groningen', 'Limburg', 'North Brabant',
    'North Holland', 'Overijssel', 'Saba', 'Sint Eustatius',
    'South Holland', 'Utrecht', 'Zeeland',

    // New Zealand
    'assets/images/flags/nz.svg New Zealand',
    'Auckland', 'Bay of Plenty', 'Canterbury', 'Chatham Islands',
    'Cook Islands', 'Gisborne', 'Hawke\'s Bay', 'ManawatÃ…Â«-Whanganui',
    'Marlborough', 'Nelson', 'Niue', 'Northland',
    'Otago', 'Southland', 'Taranaki', 'Tasman',
    'Waikato', 'West Coast',

    // Nicaragua
    'assets/images/flags/ni.svg Nicaragua',
    'Boaco', 'Carazo', 'Chinandega', 'Chontales',
    'EstelÃƒÂ­', 'Granada', 'Jinotega', 'LeÃƒÂ³n',
    'Madriz', 'Managua', 'Masaya', 'Matagalpa',
    'North Caribbean Coast', 'Nueva Segovia', 'Rivas', 'RÃƒÂ­o San Juan',
    'South Caribbean Coast',

    // Niger
    'assets/images/flags/ne.svg Niger',
    'Agadez', 'Diffa', 'Dosso', 'Maradi',
    'Niamey', 'Tahoua', 'TillabÃƒÂ©ri', 'Zinder',

    // Nigeria
    'assets/images/flags/ng.svg Nigeria',
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra',
    'Bauchi', 'Bayelsa', 'Benue', 'Borno',
    'Cross River', 'Delta', 'Ebonyi', 'Edo',
    'Ekiti', 'Enugu', 'Federal Capital Territory (Abuja)', 'Gombe',
    'Imo', 'Jigawa', 'Kaduna', 'Kano',
    'Katsina', 'Kebbi', 'Kogi', 'Kwara',
    'Lagos', 'Nasarawa', 'Niger', 'Ogun',
    'Ondo', 'Osun', 'Oyo', 'Plateau',
    'Rivers', 'Sokoto', 'Taraba', 'Yobe',
    'Zamfara',

    // North Korea
    'assets/images/flags/kp.svg North Korea',
    'Pyongsong', 'Pyongyang', 'Rason', 'Sariwon',
    'Sinpo', 'Sinuiju', 'Songrim', 'Sunchon',
    'Tanchon', 'Tokchon', 'Wonsan',

    // North Macedonia
    'assets/images/flags/mk.svg North Macedonia',
    'Bitola', 'Kumanovo', 'Skopje', 'Tetovo',

    // Northern Ireland
    'assets/images/flags/gb-nir.svg Northern Ireland',
    'Antrim and Newtownabbey', 'Ards and North Down',
    'Armagh City Banbridge and Craigavon', 'Belfast',
    'Causeway Coast and Glens', 'Derry City and Strabane',
    'Fermanagh and Omagh', 'Lisburn and Castlereagh',
    'Mid and East Antrim', 'Mid Ulster', 'Newry Mourne and Down',

    // Norway
    'assets/images/flags/no.svg Norway',
    'Agder', 'Akershus', 'Buskerud', 'Finnmark',
    'Innlandet', 'MÃƒÂ¸re og Romsdal', 'Nordland', 'Oslo',
    'Rogaland', 'Telemark', 'Troms', 'TrÃƒÂ¸ndelag',
    'Vestfold', 'Vestland', 'ÃƒËœstfold',

    // Oman
    'assets/images/flags/om.svg Oman',
    'Ad Dakhiliyah', 'Ad Dhahirah', 'Al Batinah North', 'Al Batinah South',
    'Al Buraimi', 'Al Wusta', 'Ash Sharqiyah North', 'Ash Sharqiyah South',
    'Dhofar', 'Musandam', 'Muscat',

    // Pakistan
    'assets/images/flags/pk.svg Pakistan',
    'Azad Jammu & Kashmir', 'Balochistan', 'Gilgit-Baltistan', 'Islamabad',
    'Khyber Pakhtunkhwa', 'Punjab', 'Sindh',

    // Palau
    'assets/images/flags/pw.svg Palau',
    'Aimeliik', 'Airai', 'Angaur', 'Hatohobei',
    'Kayangel', 'Koror', 'Melekeok', 'Ngaraard',
    'Ngarchelong', 'Ngardmau', 'Ngatpang', 'Ngchesar',
    'Ngeremlengui', 'Ngiwal', 'Peleliu', 'Sonsorol',

    // Palestine
    'assets/images/flags/ps.svg Palestine',
    'Gaza', 'Hebron', 'Jabalia', 'Jerusalem',
    'Khan Yunis', 'Nablus', 'Rafah',

    // Panama
    'assets/images/flags/pa.svg Panama',
    'Bocas del Toro', 'ChiriquÃƒÂ­', 'CoclÃƒÂ©', 'ColÃƒÂ³n',
    'DariÃƒÂ©n', 'EmberÃƒÂ¡-Wounaan', 'Guna Yala', 'Herrera',
    'Los Santos', 'Naso TjÃƒÂ«r Di', 'NgÃƒÂ¤be-BuglÃƒÂ©', 'PanamÃƒÂ¡',
    'PanamÃƒÂ¡ Oeste', 'Veraguas',

    // Papua New Guinea
    'assets/images/flags/pg.svg Papua New Guinea',
    'Bougainville', 'Central', 'Chimbu', 'East New Britain',
    'East Sepik', 'Eastern Highlands', 'Enga', 'Gulf',
    'Hela', 'Jiwaka', 'Madang', 'Manus',
    'Milne Bay', 'Morobe', 'National Capital District', 'New Ireland',
    'Northern', 'Southern Highlands', 'West New Britain', 'West Sepik',
    'Western', 'Western Highlands',

    // Paraguay
    'assets/images/flags/py.svg Paraguay',
    'Alto Paraguay', 'Alto ParanÃƒÂ¡', 'Amambay', 'AsunciÃƒÂ³n',
    'BoquerÃƒÂ³n', 'CaaguazÃƒÂº', 'CaazapÃƒÂ¡', 'CanindeyÃƒÂº',
    'Central', 'ConcepciÃƒÂ³n', 'Cordillera', 'GuairÃƒÂ¡',
    'ItapÃƒÂºa', 'Misiones', 'ParaguarÃƒÂ­', 'Presidente Hayes',
    'San Pedro', 'Ãƒâ€˜eembucÃƒÂº',

    // Peru
    'assets/images/flags/pe.svg Peru',
    'Amazonas', 'Ancash', 'ApurÃƒÂ­mac', 'Arequipa',
    'Ayacucho', 'Cajamarca', 'Callao', 'Cuzco',
    'Huancavelica', 'HuÃƒÂ¡nuco', 'Ica', 'JunÃƒÂ­n',
    'La Libertad', 'Lambayeque', 'Lima', 'Lima Province',
    'Loreto', 'Madre de Dios', 'Moquegua', 'Pasco',
    'Piura', 'Puno', 'San MartÃƒÂ­n', 'Tacna',
    'Tumbes', 'Ucayali',

    // Philippines
    'assets/images/flags/ph.svg Philippines',
    'BARMM', 'Bicol', 'Cagayan Valley', 'CALABARZON',
    'CAR', 'Caraga', 'Central Luzon', 'Central Visayas',
    'Davao', 'Eastern Visayas', 'Ilocos', 'MIMAROPA',
    'NCR', 'NIR', 'Northern Mindanao', 'SOCCSKSARGEN',
    'Western Visayas', 'Zamboanga Peninsula',

    // Poland
    'assets/images/flags/pl.svg Poland',
    'Greater Poland', 'Kuyavian-Pomeranian', 'Lesser Poland', 'Lower Silesian',
    'Lublin', 'Lubusz', 'Masovian', 'Opole',
    'Podlaskie', 'Pomeranian', 'Silesian', 'Subcarpathian',
    'Warmian-Masurian', 'West Pomeranian', 'Ã…ÂÃƒÂ³dÃ…Âº',
    'Ã…Å¡wiÃ„â„¢tokrzyskie',

    // Portugal
    'assets/images/flags/pt.svg Portugal',
    'Aveiro', 'Azores', 'Beja', 'Braga',
    'BraganÃƒÂ§a', 'Castelo Branco', 'Coimbra', 'Faro',
    'Guarda', 'Leiria', 'Lisbon', 'Madeira',
    'Portalegre', 'Porto', 'SantarÃƒÂ©m', 'SetÃƒÂºbal',
    'Viana do Castelo', 'Vila Real', 'Viseu', 'Ãƒâ€°vora',

    // Qatar
    'assets/images/flags/qa.svg Qatar',
    'Ad Dawhah', 'Al Daayen', 'Al Khor', 'Al Rayyan',
    'Al Shamal', 'Al Wakrah', 'Al-Shahaniya', 'Umm Salal',

    // Romania
    'assets/images/flags/ro.svg Romania',
    'Alba', 'Arad', 'ArgeÃˆâ„¢', 'BacÃ„Æ’u',
    'Bihor', 'BistriÃˆâ€ºa-NÃ„Æ’sÃ„Æ’ud', 'BotoÃˆâ„¢ani', 'BraÃˆâ„¢ov',
    'BrÃ„Æ’ila', 'Bucharest', 'BuzÃ„Æ’u', 'CaraÃˆâ„¢-Severin',
    'Cluj', 'ConstanÃˆâ€ºa', 'Covasna', 'CÃ„Æ’lÃ„Æ’raÃˆâ„¢i',
    'Dolj', 'DÃƒÂ¢mboviÃˆâ€ºa', 'GalaÃˆâ€ºi', 'Giurgiu',
    'Gorj', 'Harghita', 'Hunedoara', 'IalomiÃˆâ€ºa',
    'IaÃˆâ„¢i', 'Ilfov', 'MaramureÃˆâ„¢', 'MehedinÃˆâ€ºi',
    'MureÃˆâ„¢', 'NeamÃˆâ€º', 'Olt', 'Prahova',
    'Satu Mare', 'Sibiu', 'Suceava', 'SÃ„Æ’laj',
    'Teleorman', 'TimiÃˆâ„¢', 'Tulcea', 'Vaslui',
    'Vrancea', 'VÃƒÂ¢lcea',

    // Russia
    'assets/images/flags/ru.svg Russia',
    'Adygea', 'Altai', 'Bashkortostan', 'Buryatia',
    'Chechnya', 'Chuvashia', 'Crimea (disputed)', 'Dagestan',
    'Ingushetia', 'Kabardino-Balkaria', 'Kalmykia', 'Kamchatka',
    'Karachay-Cherkessia', 'Karelia', 'Khakassia', 'Komi',
    'Krasnoyarsk', 'Mari El', 'Mordovia', 'Moscow',
    'Murmansk', 'North Ossetia-Alania', 'Primorsky', 'Sakha',
    'Sevastopol (disputed)', 'St. Petersburg', 'Sverdlovsk', 'Tatarstan',
    'Tuva', 'Tyumen', 'Udmurtia',

    // Rwanda
    'assets/images/flags/rw.svg Rwanda',
    'Eastern', 'Kigali', 'Northern', 'Southern',
    'Western',

    // Saint Kitts and Nevis
    'assets/images/flags/kn.svg Saint Kitts and Nevis',
    'Christ Church Nichola Town', 'Nevis', 'Saint Anne Sandy Point',
    'Saint Kitts',

    // Saint Lucia
    'assets/images/flags/lc.svg Saint Lucia',
    'Anse la Raye', 'Canaries', 'Castries', 'Choiseul',
    'Dennery', 'Gros Islet', 'Laborie', 'Micoud',
    'SoufriÃƒÂ¨re', 'Vieux Fort',

    // Saint Vincent and the Grenadines
    'assets/images/flags/vc.svg Saint Vincent and the Grenadines',
    'Charlotte', 'Grenadines', 'Saint Andrew', 'Saint David',
    'Saint George', 'Saint Patrick',

    // Samoa
    'assets/images/flags/ws.svg Samoa',
    'A\'ana', 'Aiga-i-le-Tai', 'Atua', 'Fa\'asaleleaga',
    'Gaga\'emauga', 'Gagaifomauga', 'Palauli', 'Satupa\'itea',
    'Tuamasaga', 'Va\'a-o-Fonoti', 'Vaisigano',

    // San Marino
    'assets/images/flags/sm.svg San Marino',
    'Acquaviva', 'Borgo Maggiore', 'Chiesanuova', 'City of San Marino',
    'Domagnano', 'Faetano', 'Fiorentino', 'Montegiardino',
    'Serravalle',

    // Sao Tome and Principe
    'assets/images/flags/st.svg Sao Tome and Principe',
    'Cantagalo', 'CauÃƒÂ©', 'LembÃƒÂ¡', 'Lobata',
    'MÃƒÂ©-ZÃƒÂ³chi', 'PrÃƒÂ­ncipe', 'ÃƒÂgua Grande',

    // Saudi Arabia
    'assets/images/flags/sa.svg Saudi Arabia',
    '\'Asir', 'Al Bahah', 'Al Hudud ash Shamaliyah (Northern Borders)',
    'Al Jawf',
    'Al Madinah (Medina)', 'Al Qasim', 'Ar Riyad (Riyadh)',
    'Ash Sharqiyah (Eastern)',
    'Ha\'il', 'Jazan', 'Makkah (Mecca)', 'Najran',
    'Tabuk',

    // Scotland
    'assets/images/flags/gb-sct.svg Scotland',
    'Aberdeen City', 'Aberdeenshire', 'Angus', 'Argyll and Bute',
    'City of Edinburgh', 'Clackmannanshire', 'Dumfries and Galloway',
    'Dundee City',
    'East Ayrshire', 'East Dunbartonshire', 'East Lothian', 'East Renfrewshire',
    'Falkirk', 'Fife', 'Glasgow City', 'Highland',
    'Inverclyde', 'Midlothian', 'Moray', 'Na h-Eileanan Siar (Outer Hebrides)',
    'North Ayrshire', 'North Lanarkshire', 'Orkney Islands',
    'Perth and Kinross',
    'Renfrewshire', 'Scottish Borders', 'Shetland Islands', 'South Ayrshire',
    'South Lanarkshire', 'Stirling', 'West Dunbartonshire', 'West Lothian',

    // Senegal
    'assets/images/flags/sn.svg Senegal',
    'Dakar', 'Diourbel', 'Fatick', 'Kaffrine',
    'Kaolack', 'Kolda', 'KÃƒÂ©dougou', 'Louga',
    'Matam', 'Saint-Louis', 'SÃƒÂ©dhiou', 'Tambacounda',
    'ThiÃƒÂ¨s', 'Ziguinchor',

    // Serbia
    'assets/images/flags/rs.svg Serbia',
    'Belgrade (city)', 'Bor', 'BraniÃ„Âevo', 'Jablanica',
    'Kolubara', 'Kosovo/Metohija', 'MaÃ„Âva', 'Moravica',
    'NiÃ…Â¡ava', 'Pirot', 'Podunavlje', 'Pomoravlje',
    'PÃ„Âinja', 'Rasina', 'RaÃ…Â¡ka', 'Toplica',
    'Vojvodina', 'ZajeÃ„Âar', 'Zlatibor', 'Ã…Â umadija',

    // Seychelles
    'assets/images/flags/sc.svg Seychelles',
    'Anse aux Pins', 'Anse Boileau', 'Anse Etoile', 'Au Cap',
    'Baie Lazare', 'Baie Sainte Anne', 'Beau Vallon', 'Bel Air',
    'Bel Ombre', 'Cascade', 'Glacis', 'Grand Anse (Mahe)',
    'Grand Anse (Praslin)', 'Ile Perseverance', 'La Digue',
    'La Riviere Anglaise',
    'Les Mamelles', 'Mont Buxton', 'Mont Fleuri', 'Outer Islands',
    'Plaisance', 'Pointe La Rue', 'Port Glaud', 'Roche Caiman',
    'Saint Louis', 'Takamaka',

    // Sierra Leone
    'assets/images/flags/sl.svg Sierra Leone',
    'Eastern', 'North Western', 'Northern', 'Southern',
    'Western Area',

    // Singapore
    'assets/images/flags/sg.svg Singapore',
    'Community Development Councils',

    // Slovakia
    'assets/images/flags/sk.svg Slovakia',
    'BanskÃƒÂ¡ Bystrica', 'Bratislava', 'KoÃ…Â¡ice', 'Nitra',
    'PreÃ…Â¡ov', 'TrenÃ„ÂÃƒÂ­n', 'Trnava', 'Ã…Â½ilina',

    // Slovenia
    'assets/images/flags/si.svg Slovenia',
    'Celje', 'Koper', 'Kranj', 'Ljubljana',
    'Maribor',

    // Solomon Islands
    'assets/images/flags/sb.svg Solomon Islands',
    'Central', 'Choiseul', 'Guadalcanal', 'Honiara',
    'Isabel', 'Makira-Ulawa', 'Malaita', 'Rennell and Bellona',
    'Temotu', 'Western',

    // Somalia
    'assets/images/flags/so.svg Somalia',
    'Galmudug', 'Hirshabelle', 'Jubaland', 'Puntland',
    'Somaliland (disputed independence)', 'South West',

    // South Africa
    'assets/images/flags/za.svg South Africa',
    'Eastern Cape', 'Free State', 'Gauteng', 'KwaZulu-Natal',
    'Limpopo', 'Mpumalanga', 'North West', 'Northern Cape',
    'Western Cape',

    // South Korea
    'assets/images/flags/kr.svg South Korea',
    'Busan', 'Daegu', 'Daejeon', 'Gangwon',
    'Gwangju', 'Gyeonggi', 'Incheon', 'Jeju',
    'North Chungcheong', 'North Gyeongsang', 'North Jeolla', 'Sejong',
    'Seoul', 'South Chungcheong', 'South Gyeongsang', 'South Jeolla',
    'Ulsan',

    // South Sudan
    'assets/images/flags/ss.svg South Sudan',
    'Abyei', 'Central Equatoria', 'Eastern Equatoria', 'Jonglei',
    'Lakes', 'Northern Bahr el Ghazal', 'Pibor', 'Ruweng',
    'Unity', 'Upper Nile', 'Warrap', 'Western Bahr el Ghazal',
    'Western Equatoria',

    // Spain
    'assets/images/flags/es.svg Spain',
    'Andalusia', 'Aragon', 'Asturias', 'Balearic Islands',
    'Basque Country', 'Canary Islands', 'Cantabria', 'Castile and LeÃƒÂ³n',
    'Castilla-La Mancha', 'Catalonia', 'Ceuta', 'Extremadura',
    'Galicia', 'La Rioja', 'Madrid', 'Melilla',
    'Murcia', 'Navarre', 'Valencian Community',

    // Sri Lanka
    'assets/images/flags/lk.svg Sri Lanka',
    'Central', 'Eastern', 'North Central', 'North Western',
    'Northern', 'Sabaragamuwa', 'Southern', 'Uva',
    'Western',

    // Sudan
    'assets/images/flags/sd.svg Sudan',
    'Blue Nile', 'Central Darfur', 'East Darfur', 'Gedaref',
    'Gezira', 'Kassala', 'Khartoum', 'North Darfur',
    'North Kordofan', 'Northern', 'Red Sea', 'River Nile',
    'Sennar', 'South Darfur', 'South Kordofan', 'West Darfur',
    'West Kordofan', 'White Nile',

    // Suriname
    'assets/images/flags/sr.svg Suriname',
    'Brokopondo', 'Commewijne', 'Coronie', 'Marowijne',
    'Nickerie', 'Para', 'Paramaribo', 'Saramacca',
    'Sipaliwini', 'Wanica',

    // Sweden
    'assets/images/flags/se.svg Sweden',
    'Blekinge', 'Dalarna', 'Gotland', 'GÃƒÂ¤vleborg',
    'Halland', 'JÃƒÂ¤mtland', 'JÃƒÂ¶nkÃƒÂ¶ping', 'Kalmar',
    'Kronoberg', 'Norrbotten', 'SkÃƒÂ¥ne', 'Stockholm',
    'SÃƒÂ¶dermanland', 'Uppsala', 'VÃƒÂ¤rmland', 'VÃƒÂ¤sterbotten',
    'VÃƒÂ¤sternorrland', 'VÃƒÂ¤stmanland', 'VÃƒÂ¤stra GÃƒÂ¶taland',
    'Ãƒâ€“rebro',
    'Ãƒâ€“stergÃƒÂ¶tland',

    // Switzerland
    'assets/images/flags/ch.svg Switzerland',
    'Aargau', 'Appenzell Ausserrhoden', 'Appenzell Innerrhoden',
    'Basel-Landschaft',
    'Basel-Stadt', 'Bern', 'Fribourg', 'Geneva',
    'Glarus', 'GraubÃƒÂ¼nden', 'Jura', 'Lucerne',
    'NeuchÃƒÂ¢tel', 'Nidwalden', 'Obwalden', 'Schaffhausen',
    'Schwyz', 'Solothurn', 'St. Gallen', 'Thurgau',
    'Ticino', 'Uri', 'Valais', 'Vaud',
    'Zug', 'Zurich',

    // Syria
    'assets/images/flags/sy.svg Syria',
    'Al-Hasakah', 'Aleppo', 'Damascus', 'Daraa',
    'Deir ez-Zor', 'Hama', 'Homs', 'Idlib',
    'Latakia', 'Quneitra', 'Raqqa', 'Rif Dimashq',
    'Suwayda', 'Tartus',

    // Taiwan
    'assets/images/flags/tw.svg Taiwan',
    'Fujian', 'Kaohsiung', 'New Taipei', 'Taichung',
    'Tainan', 'Taipei', 'Taiwan', 'Taoyuan',

    // Tajikistan
    'assets/images/flags/tj.svg Tajikistan',
    'Districts of Republican Subordination', 'Dushanbe', 'Gorno-Badakhshan',
    'Khatlon',
    'Sughd',

    // Tanzania
    'assets/images/flags/tz.svg Tanzania',
    'Arusha', 'Dar es Salaam', 'Dodoma', 'Geita',
    'Iringa', 'Kagera', 'Katavi', 'Kigoma',
    'Kilimanjaro', 'Lindi', 'Manyara', 'Mara',
    'Mbeya', 'Morogoro', 'Mtwara', 'Mwanza',
    'Njombe', 'Pemba North', 'Pemba South', 'Pwani',
    'Rukwa', 'Ruvuma', 'Shinyanga', 'Simiyu',
    'Singida', 'Songwe', 'Tabora', 'Tanga',
    'Zanzibar Central/South', 'Zanzibar North', 'Zanzibar Urban/West',

    // Thailand
    'assets/images/flags/th.svg Thailand',
    'Bangkok', 'Chiang Mai', 'Chonburi', 'Nakhon Ratchasima',
    'Phuket',

    // Togo
    'assets/images/flags/tg.svg Togo',
    'Centrale', 'Kara', 'Maritime', 'Plateaux',
    'Savanes',

    // Tonga
    'assets/images/flags/to.svg Tonga',
    '\'Eua', 'Ha\'apai', 'Niuas', 'Tongatapu',
    'Vava\'u',

    // Trinidad and Tobago
    'assets/images/flags/tt.svg Trinidad and Tobago',
    'Arima', 'Chaguanas', 'Couva-Tabaquite-Talparo', 'Diego Martin',
    'Penal-Debe', 'Point Fortin', 'Port of Spain', 'Princes Town',
    'Rio Claro-Mayaro', 'San Fernando', 'San Juan-Laventille', 'Sangre Grande',
    'Siparia', 'Tobago', 'Tunapuna-Piarco',

    // Tunisia
    'assets/images/flags/tn.svg Tunisia',
    'Ariana', 'Ben Arous', 'Bizerte', 'BÃƒÂ©ja',
    'GabÃƒÂ¨s', 'Gafsa', 'Jendouba', 'Kairouan',
    'Kasserine', 'Kef', 'KÃƒÂ©bili', 'Mahdia',
    'Manouba', 'Medenine', 'Monastir', 'Nabeul',
    'Sfax', 'Sidi Bouzid', 'Siliana', 'Sousse',
    'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan',

    // Turkey
    'assets/images/flags/tr.svg Turkey',
    'Adana', 'Ankara', 'Antalya', 'Bursa',
    'Diyarbakir', 'Erzurum', 'Gaziantep', 'Istanbul',
    'Izmir', 'Konya', 'Mersin',

    // Turkmenistan
    'assets/images/flags/tm.svg Turkmenistan',
    'Ahal', 'Ashgabat', 'Balkan', 'DaÃ…Å¸oguz',
    'Lebap', 'Mary',

    // Tuvalu
    'assets/images/flags/tv.svg Tuvalu',
    'Funafuti', 'Nanumanga', 'Nanumea', 'Niulakita',
    'Niutao', 'Nui', 'Nukufetau', 'Nukulaelae',
    'Vaitupu',

    // Uganda
    'assets/images/flags/ug.svg Uganda',
    'Arua', 'Gulu', 'Jinja', 'Kampala',
    'Mbale', 'Mbarara', 'Soroti', 'Tororo',

    // Ukraine
    'assets/images/flags/ua.svg Ukraine',
    'Cherkasy', 'Chernihiv', 'Chernivtsi', 'Crimea (disputed)',
    'Dnipropetrovsk', 'Donetsk', 'Ivano-Frankivsk', 'Kharkiv',
    'Kherson', 'Khmelnytskyi', 'Kirovohrad', 'Kyiv',
    'Kyiv (Oblast)', 'Luhansk', 'Lviv', 'Mykolaiv',
    'Odesa', 'Poltava', 'Rivne', 'Sevastopol (disputed)',
    'Sumy', 'Ternopil', 'Vinnytsia', 'Volyn',
    'Zakarpattia', 'Zaporizhzhia', 'Zhytomyr',

    // United Arab Emirates
    'assets/images/flags/ae.svg United Arab Emirates',
    'Abu Dhabi', 'Ajman', 'Dubai', 'Fujairah',
    'Ras al-Khaimah', 'Sharjah', 'Umm al-Quwain',

    // United States
    'assets/images/flags/us.svg United States',
    'Alabama', 'Alaska', 'American Samoa', 'Arizona',
    'Arkansas', 'California', 'Colorado', 'Connecticut',
    'Delaware', 'District of Columbia', 'Florida', 'Georgia',
    'Guam', 'Hawaii', 'Idaho', 'Illinois',
    'Indiana', 'Iowa', 'Kansas', 'Kentucky',
    'Louisiana', 'Maine', 'Maryland', 'Massachusetts',
    'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
    'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
    'New Jersey', 'New Mexico', 'New York', 'North Carolina',
    'North Dakota', 'Northern Mariana Islands', 'Ohio', 'Oklahoma',
    'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island',
    'South Carolina', 'South Dakota', 'Tennessee', 'Texas',
    'U.S. Virgin Islands', 'Utah', 'Vermont', 'Virginia',
    'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',

    // Uruguay
    'assets/images/flags/uy.svg Uruguay',
    'Artigas', 'Canelones', 'Cerro Largo', 'Colonia',
    'Durazno', 'Flores', 'Florida', 'Lavalleja',
    'Maldonado', 'Montevideo', 'PaysandÃƒÂº', 'Rivera',
    'Rocha', 'RÃƒÂ­o Negro', 'Salto', 'San JosÃƒÂ©',
    'Soriano', 'TacuarembÃƒÂ³', 'Treinta y Tres',

    // Uzbekistan
    'assets/images/flags/uz.svg Uzbekistan',
    'Andijan', 'Bukhara', 'Fergana', 'Jizzakh',
    'Karakalpakstan', 'Khorezm', 'Namangan', 'Navoiy',
    'Qashqadaryo', 'Samarqand', 'Sirdaryo', 'Surxondaryo',
    'Tashkent', 'Tashkent Region',

    // Vanuatu
    'assets/images/flags/vu.svg Vanuatu',
    'Malampa', 'Penama', 'Sanma', 'Shefa',
    'Tafea', 'Torba',

    // Vatican City
    'assets/images/flags/va.svg Vatican City',

    // Venezuela
    'assets/images/flags/ve.svg Venezuela',
    'Amazonas', 'AnzoÃƒÂ¡tegui', 'Apure', 'Aragua',
    'Barinas', 'BolÃƒÂ­var', 'Capital District', 'Carabobo',
    'Cojedes', 'Delta Amacuro', 'FalcÃƒÂ³n', 'Federal Dependencies',
    'GuÃƒÂ¡rico', 'Lara', 'Miranda', 'Monagas',
    'MÃƒÂ©rida', 'Nueva Esparta', 'Portuguesa', 'Sucre',
    'Trujillo', 'TÃƒÂ¡chira', 'Vargas', 'Yaracuy',
    'Zulia',

    // Vietnam
    'assets/images/flags/vn.svg Vietnam',
    'Bac Ninh', 'Binh Duong', 'Can Tho', 'Da Nang',
    'Dong Nai', 'Haiphong', 'Hanoi', 'Ho Chi Minh City',
    'Nghe An', 'Thanh Hoa',

    // Wales
    'assets/images/flags/gb-wls.svg Wales',
    'Blaenau Gwent', 'Bridgend', 'Caerphilly', 'Cardiff',
    'Carmarthenshire', 'Ceredigion', 'Conwy', 'Denbighshire',
    'Flintshire', 'Gwynedd', 'Isle of Anglesey', 'Merthyr Tydfil',
    'Monmouthshire', 'Neath Port Talbot', 'Newport', 'Pembrokeshire',
    'Powys', 'Rhondda Cynon Taf', 'Swansea', 'Torfaen',
    'Vale of Glamorgan', 'Wrexham',

    // Yemen
    'assets/images/flags/ye.svg Yemen',
    'Abyan', 'Aden', 'Al Bayda', 'Al Dhale',
    'Al Hudaydah', 'Al Jawf', 'Al Mahrah', 'Al Mahwit',
    'Amran', 'Dhamar', 'Hadhramaut', 'Hajjah',
    'Ibb', 'Lahij', 'Marib', 'Raymah',
    'Saada', 'Sanaa', 'Sanaa City', 'Shabwah',
    'Socotra', 'Taiz',

    // Zambia
    'assets/images/flags/zm.svg Zambia',
    'Central', 'Copperbelt', 'Eastern', 'Luapula',
    'Lusaka', 'Muchinga', 'North-Western', 'Northern',
    'Southern', 'Western',

    // Zimbabwe
    'assets/images/flags/zw.svg Zimbabwe',
    'Bulawayo', 'Harare', 'Manicaland', 'Mashonaland Central',
    'Mashonaland East', 'Mashonaland West', 'Masvingo', 'Matabeleland North',
    'Matabeleland South', 'Midlands',
  ];
}

// =============================================================================
// PARSING EXTENSION
// =============================================================================
extension FlagStringParsing on String {
  /// Extracts the SVG asset path from the string (e.g., 'assets/images/flags/eg.svg')
  String get flagSvgPath {
    if (startsWith('assets/images/flags/')) {
      return split(' ').first;
    }
    return '';
  }

  /// Extracts the text portion without the SVG path (e.g., 'Egypt' or '+20')
  String get textWithoutFlag {
    if (startsWith('assets/images/flags/')) {
      final firstSpaceIdx = indexOf(' ');
      if (firstSpaceIdx != -1) {
        return substring(firstSpaceIdx + 1).trim();
      }
    }
    return this;
  }
}

// =============================================================================
// READY-TO-USE WIDGET FOR YOUR DROPDOWNS
// Use this inside your UI files instead of a standard `Text` widget
// Example: CountryFlagWidget(textData: countryCodeString)
// =============================================================================
class CountryFlagWidget extends StatelessWidget {
  final String textData;

  const CountryFlagWidget({super.key, required this.textData});

  @override
  Widget build(BuildContext context) {
    final path = textData.flagSvgPath;
    final label = textData.textWithoutFlag;

    return Row(
      mainAxisSize: MainAxisSize.min, // Prevents overflow issues in dropdowns
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (path.isNotEmpty) ...[
          // Creates a border around the flag like in your screenshot!
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 0.5),
            ),
            child: SvgPicture.asset(
              path,
              width: 24,
              height: 16,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style:
              const TextStyle(fontSize: 14), // Matches standard dropdown text
        ),
      ],
    );
  }
}

// =============================================================================
// COUNTRY ADMINISTRATIVE REGION UTILITY
// =============================================================================
class CountryAdminInfo {
  final String label; // e.g. 'Governorate', 'State', 'Province'
  final List<String> regions; // e.g. ['Cairo', 'Giza', ...]

  const CountryAdminInfo({required this.label, required this.regions});

  static const CountryAdminInfo none = CountryAdminInfo(label: '', regions: []);

  // Internal robust mapping mapping country name strictly to admin region type
  static const Map<String, String> _adminTypes = {
    'Afghanistan': 'Province',
    'Albania': 'County',
    'Algeria': 'Province',
    'Andorra': 'Parish',
    'Angola': 'Province',
    'Antigua and Barbuda': 'Parish',
    'Argentina': 'Province',
    'Armenia': 'Province',
    'Australia': 'State',
    'Austria': 'State',
    'Azerbaijan': 'District',
    'Bahamas': 'District',
    'Bahrain': 'Governorate',
    'Bangladesh': 'Division',
    'Barbados': 'Parish',
    'Belarus': 'Region',
    'Belgium': 'Region',
    'Belize': 'District',
    'Benin': 'Department',
    'Bhutan': 'District',
    'Bolivia': 'Department',
    'Bosnia and Herzegovina': 'Region',
    'Botswana': 'District',
    'Brazil': 'State',
    'Brunei': 'District',
    'Bulgaria': 'Province',
    'Burkina Faso': 'Region',
    'Burundi': 'Province',
    'Cabo Verde': 'Region',
    'Cambodia': 'Province',
    'Cameroon': 'Region',
    'Canada': 'Province',
    'Central African Republic': 'Prefecture',
    'Chad': 'Province',
    'Chile': 'Region',
    'China': 'Province',
    'Colombia': 'Department',
    'Comoros': 'Region',
    'Congo (DRC)': 'Province',
    'Congo (Republic)': 'Department',
    'Costa Rica': 'Province',
    "CÃƒÂ´te d'Ivoire": 'District',
    'Croatia': 'County',
    'Cuba': 'Province',
    'Cyprus': 'District',
    'Czech Republic': 'Region',
    'Denmark': 'Region',
    'Djibouti': 'Region',
    'Dominica': 'Parish',
    'Dominican Republic': 'Province',
    'East Timor': 'Municipality',
    'Ecuador': 'Province',
    'Egypt': 'Governorate',
    'El Salvador': 'Department',
    'Equatorial Guinea': 'Province',
    'Eritrea': 'Region',
    'Estonia': 'County',
    'Eswatini': 'Region',
    'Ethiopia': 'State',
    'Fiji': 'Division',
    'Finland': 'Region',
    'France': 'Region',
    'Gabon': 'Province',
    'Gambia': 'Region',
    'Georgia': 'Region',
    'Germany': 'State',
    'Ghana': 'Region',
    'Greece': 'Region',
    'Grenada': 'Parish',
    'Guatemala': 'Department',
    'Guinea': 'Region',
    'Guinea-Bissau': 'Region',
    'Guyana': 'Region',
    'Haiti': 'Department',
    'Honduras': 'Department',
    'Hungary': 'County',
    'Iceland': 'Region',
    'India': 'State',
    'Indonesia': 'Province',
    'Iran': 'Province',
    'Iraq': 'Governorate',
    'Ireland': 'County',
    'Israel': 'District',
    'Italy': 'Region',
    'Jamaica': 'Parish',
    'Japan': 'Prefecture',
    'Jordan': 'Governorate',
    'Kazakhstan': 'Region',
    'Kenya': 'County',
    'Kiribati': 'Region',
    'Kosovo': 'Region',
    'Kuwait': 'Governorate',
    'Kyrgyzstan': 'Region',
    'Laos': 'Province',
    'Latvia': 'Municipality',
    'Lebanon': 'Governorate',
    'Lesotho': 'District',
    'Liberia': 'County',
    'Libya': 'District',
    'Liechtenstein': 'Municipality',
    'Lithuania': 'County',
    'Luxembourg': 'Canton',
    'Madagascar': 'Region',
    'Malawi': 'Region',
    'Malaysia': 'State',
    'Maldives': 'Atoll',
    'Mali': 'Region',
    'Malta': 'Region',
    'Marshall Islands': 'Municipality',
    'Mauritania': 'Region',
    'Mauritius': 'District',
    'Mexico': 'State',
    'Micronesia': 'State',
    'Moldova': 'District',
    'Monaco': 'Municipality',
    'Mongolia': 'Province',
    'Montenegro': 'Municipality',
    'Morocco': 'Region',
    'Mozambique': 'Province',
    'Myanmar': 'Region',
    'Namibia': 'Region',
    'Nauru': 'District',
    'Nepal': 'Province',
    'Netherlands': 'Province',
    'New Zealand': 'Region',
    'Nicaragua': 'Department',
    'Niger': 'Region',
    'Nigeria': 'State',
    'North Korea': 'Region',
    'North Macedonia': 'Municipality',
    'Norway': 'County',
    'Oman': 'Governorate',
    'Pakistan': 'Province',
    'Palau': 'State',
    'Palestine': 'Region',
    'Panama': 'Province',
    'Papua New Guinea': 'Province',
    'Paraguay': 'Department',
    'Peru': 'Region',
    'Philippines': 'Region',
    'Poland': 'Voivodeship',
    'Portugal': 'District',
    'Qatar': 'Municipality',
    'Romania': 'County',
    'Russia': 'Region',
    'Rwanda': 'Province',
    'Saint Kitts and Nevis': 'Parish',
    'Saint Lucia': 'Quarter',
    'Saint Vincent and the Grenadines': 'Parish',
    'Samoa': 'District',
    'San Marino': 'Municipality',
    'Sao Tome and Principe': 'District',
    'Saudi Arabia': 'Province',
    'Senegal': 'Region',
    'Serbia': 'District',
    'Seychelles': 'District',
    'Sierra Leone': 'Province',
    'Singapore': 'Subdivision',
    'Slovakia': 'Region',
    'Slovenia': 'Municipality',
    'Solomon Islands': 'Province',
    'Somalia': 'Region',
    'South Africa': 'Province',
    'South Korea': 'Province',
    'South Sudan': 'State',
    'Spain': 'Region',
    'Sri Lanka': 'Province',
    'Sudan': 'State',
    'Suriname': 'District',
    'Sweden': 'County',
    'Switzerland': 'Canton',
    'Syria': 'Governorate',
    'Taiwan': 'Municipality',
    'Tajikistan': 'Province',
    'Tanzania': 'Region',
    'Thailand': 'Province',
    'Togo': 'Region',
    'Tonga': 'Division',
    'Trinidad and Tobago': 'Region',
    'Tunisia': 'Governorate',
    'Turkey': 'Province',
    'Turkmenistan': 'Region',
    'Tuvalu': 'Atoll',
    'Uganda': 'District',
    'Ukraine': 'Oblast',
    'United Arab Emirates': 'Emirate',
    'England': 'Region',
    'Northern Ireland': 'Local Government District',
    'Scotland': 'Council Area',
    'Wales': 'Principal Area / Unitary Authority',
    'United States': 'State',
    'Uruguay': 'Department',
    'Uzbekistan': 'Region',
    'Vanuatu': 'Province',
    'Vatican City': 'None',
    'Venezuela': 'State',
    'Vietnam': 'Province',
    'Yemen': 'Governorate',
    'Zambia': 'Province',
    'Zimbabwe': 'Province'
  };

  /// Resolves the [CountryAdminInfo] for the supplied [countryEntry].
  static CountryAdminInfo resolve(String? countryEntry) {
    if (countryEntry == null || countryEntry.isEmpty) return none;

    final list = AppConstants.kCountriesList;
    int headerIdx = -1;
    for (int i = 0; i < list.length; i++) {
      if (list[i] == countryEntry) {
        headerIdx = i;
        break;
      }
    }
    if (headerIdx < 0) return none;

    // Use our new extension to pull only the country name!
    String countryName = countryEntry.textWithoutFlag;
    String adminLabel = _adminTypes[countryName] ?? 'Region';
    if (adminLabel.toLowerCase() == 'none') return none;

    final regions = <String>[];

    for (int i = headerIdx + 1; i < list.length; i++) {
      final entry = list[i];
      // Stop when we hit the next country header
      if (entry.startsWith('assets/images/flags/')) break;
      regions.add(entry.trim());
    }

    return CountryAdminInfo(
      label: adminLabel,
      regions: regions,
    );
  }
}
