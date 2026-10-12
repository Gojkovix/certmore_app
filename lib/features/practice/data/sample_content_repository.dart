import '../models/question.dart';
import 'content_repository.dart';

/// VZOREC: nekaj vprašanj za razvoj vmesnika.
///
/// To NI preverjena izpitna snov. Vprašanja nadomesti prava vsebina
/// iz Certmore sistema; v aplikaciji so označena kot vzorčna.
class SampleContentRepository implements ContentRepository {
  const SampleContentRepository();

  @override
  bool get isSample => true;

  @override
  Future<List<Topic>> topics() async => _topics;

  @override
  Future<List<Question>> questions() async => _questions;

  static const _topics = [
    Topic(id: 'ustava', title: 'Ustava in človekove pravice'),
    Topic(id: 'sistem', title: 'Sistem vzgoje in izobraževanja'),
    Topic(id: 'organi', title: 'Organi vzgojno-izobraževalnega zavoda'),
    Topic(id: 'jezik', title: 'Slovenski jezik'),
  ];

  static const _questions = [
    Question(
      id: 'ustava-1',
      topicId: 'ustava',
      text: 'Kateri pravni akt je v Republiki Sloveniji najvišji?',
      options: [
        'Ustava Republike Slovenije',
        'Zakon o organizaciji in financiranju vzgoje in izobraževanja',
        'Uredba vlade',
        'Pravilnik ministrstva',
      ],
      correctIndex: 0,
      explanation:
          'Ustava je najvišji pravni akt države. Zakoni in podzakonski '
          'akti morajo biti z njo v skladu.',
    ),
    Question(
      id: 'ustava-2',
      topicId: 'ustava',
      text: 'Kateri organ presoja skladnost zakonov z ustavo?',
      options: [
        'Vrhovno sodišče',
        'Ustavno sodišče',
        'Državni svet',
        'Varuh človekovih pravic',
      ],
      correctIndex: 1,
      explanation:
          'Ustavno sodišče odloča o skladnosti zakonov z ustavo in lahko '
          'neustavne določbe razveljavi.',
    ),
    Question(
      id: 'ustava-3',
      topicId: 'ustava',
      text: 'Kako ustava ureja osnovnošolsko izobraževanje?',
      options: [
        'Je prostovoljno in plačljivo.',
        'Je obvezno, a ga v celoti plačajo starši.',
        'Je obvezno in se financira iz javnih sredstev.',
        'Ustava ga ne ureja.',
      ],
      correctIndex: 2,
      explanation:
          'Ustava določa, da je osnovnošolsko izobraževanje obvezno in se '
          'financira iz javnih sredstev.',
    ),
    Question(
      id: 'sistem-1',
      topicId: 'sistem',
      text:
          'Kateri zakon ureja pogoje za opravljanje in financiranje '
          'vzgoje in izobraževanja?',
      options: [
        'Zakon o osnovni šoli',
        'Zakon o vrtcih',
        'Zakon o organizaciji in financiranju vzgoje in izobraževanja',
        'Zakon o splošnem upravnem postopku',
      ],
      correctIndex: 2,
      explanation:
          'ZOFVI je krovni zakon, ki ureja organizacijo in financiranje '
          'celotnega sistema vzgoje in izobraževanja.',
    ),
    Question(
      id: 'sistem-2',
      topicId: 'sistem',
      text: 'Koliko let traja obvezna osnovna šola v Sloveniji?',
      options: ['Osem let', 'Devet let', 'Deset let', 'Dvanajst let'],
      correctIndex: 1,
    ),
    Question(
      id: 'sistem-3',
      topicId: 'sistem',
      text:
          'Kdo je pedagoški vodja in poslovodni organ javnega vrtca '
          'ali šole?',
      options: ['Predsednik sveta zavoda', 'Ravnatelj', 'Župan', 'Minister'],
      correctIndex: 1,
      explanation:
          'Ravnatelj hkrati opravlja naloge pedagoškega vodje in '
          'poslovodnega organa.',
    ),
    Question(
      id: 'organi-1',
      topicId: 'organi',
      text: 'Kateri organ upravlja javni vzgojno-izobraževalni zavod?',
      options: ['Svet staršev', 'Učiteljski zbor', 'Svet zavoda', 'Ravnatelj'],
      correctIndex: 2,
    ),
    Question(
      id: 'organi-2',
      topicId: 'organi',
      text: 'Kdo sestavlja učiteljski zbor šole?',
      options: [
        'Vsi strokovni delavci šole',
        'Samo razredniki',
        'Predstavniki staršev in učiteljev',
        'Ravnatelj in pomočniki ravnatelja',
      ],
      correctIndex: 0,
      explanation: 'Učiteljski zbor sestavljajo vsi strokovni delavci šole.',
    ),
    Question(
      id: 'organi-3',
      topicId: 'organi',
      text:
          'Kateri organ razpravlja o pritožbah staršev v zvezi z '
          'vzgojno-izobraževalnim delom?',
      options: ['Svet staršev', 'Strokovni aktiv', 'Učiteljski zbor', 'Občina'],
      correctIndex: 0,
    ),
    Question(
      id: 'jezik-1',
      topicId: 'jezik',
      text: 'Kateri zapis je pravopisno pravilen?',
      options: ['Nasvidenje!', 'Na svidenje!', 'Na-svidenje!', 'Nasvidenje.'],
      correctIndex: 1,
      explanation: 'Pozdrav se piše narazen: na svidenje.',
    ),
    Question(
      id: 'jezik-2',
      topicId: 'jezik',
      text: 'Katera poved ima pravilno postavljeno vejico?',
      options: [
        'Mislim da, bo jutri lepo.',
        'Mislim da bo, jutri lepo.',
        'Mislim, da bo jutri lepo.',
        'Mislim da bo jutri, lepo.',
      ],
      correctIndex: 2,
      explanation: 'Vejica stoji pred veznikom »da«, ki uvaja odvisnik.',
    ),
    Question(
      id: 'jezik-3',
      topicId: 'jezik',
      text: 'Dopolni: Otroci se vračajo ___ šole.',
      options: ['s', 'z', 'iz', 'od'],
      correctIndex: 2,
      explanation:
          'Pri zaprtih prostorih in ustanovah uporabimo par v–iz: '
          'v šolo, iz šole.',
    ),
  ];
}
