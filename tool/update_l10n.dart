// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('lib/l10n/app_en.arb');
  final data = jsonDecode(await file.readAsString());

  data.addAll({
    'catStrength': 'Strength & Muscle Building',
    'goalBodybuildingTitle': 'Bodybuilding',
    'goalBodybuildingDesc':
        'A highly structured training style centred on progressive resistance to maximise muscle growth (hypertrophy) and refine physical proportions. It utilises a combination of compound movements and isolation exercises to target specific muscle groups, aiming for aesthetic symmetry, low body fat, and muscular definition.',
    'goalPowerliftingTitle': 'Powerlifting',
    'goalPowerliftingDesc':
        'A strength sport focusing entirely on maximising the amount of weight a person can lift for a single repetition (1-Rep Max) in three specific barbell exercises: the squat, the bench press, and the deadlift. Training prioritises low repetitions, heavy loads, and central nervous system adaptation over muscle size.',
    'goalOlympicTitle': 'Olympic Weightlifting',
    'goalOlympicDesc':
        'A dynamic and highly technical discipline centred on explosive power, speed, and mobility. Athletes train to master two fast-paced overhead barbell lifts: the snatch and the clean-and-jerk. It requires significant joint flexibility, core stability, and precise technique to drop under a heavy bar quickly.',
    'goalStrongmanTitle': 'Strongman',
    'goalStrongmanDesc':
        "A varied, functional strength discipline that tests an athlete's raw power and endurance using heavy, awkward, and non-traditional implements. Common exercises include lifting Atlas stones, pulling sledges, carrying heavy yokes, and pressing logs, translating gym strength into real-world lifting capabilities.",
    'catAthletic': 'Athletic & Functional Training',
    'goalSportsTitle': 'Sports Performance',
    'goalSportsDesc':
        'Conditioning programs meticulously tailored to the specific physical demands of a competitive sport. This training emphasises explosive power, multidirectional agility, reaction time, and injury prevention, ensuring an athlete peaks physically for their specific season or event.',
    'goalFunctionalTitle': 'Functional Fitness',
    'goalFunctionalDesc':
        'A constantly varied, high-intensity training methodology designed to prepare the body for any physical contingency. It blends elements of aerobic conditioning, gymnastics, and weightlifting to improve overall work capacity, stamina, and everyday physical readiness.',
    'goalCallisthenicsTitle': 'Callisthenics',
    'goalCallisthenicsDesc':
        "A form of strength training that utilises the practitioner's own body weight and gravity as resistance. It emphasises mastering movement through space, starting with basics like push-ups and pull-ups, and progressing to advanced isometric holds requiring immense core control, such as planches and front levers.",
    'goalCombatTitle': 'Combat Sports Conditioning',
    'goalCombatDesc':
        'Specialised physical preparation for martial arts, boxing, and wrestling. It focuses on building the stamina needed for continuous high-intensity rounds, enhancing rotational core power for striking, and developing the grip and neck strength required for grappling.',
    'catRecovery': 'Recovery & Movement Health',
    'goalCorrectiveTitle': 'Corrective Exercises',
    'goalCorrectiveDesc':
        'A systematic approach to identifying and addressing physical imbalances, poor posture, and movement compensations. By selectively stretching tight muscles and strengthening weak ones, this discipline helps alleviate chronic pain and retrains the body to move efficiently.',
    'goalRehabilitationTitle': 'Rehabilitation',
    'goalRehabilitationDesc':
        'Highly structured, progressive exercise protocols are prescribed to help individuals recover safely from injuries, surgeries, or physical trauma. The primary goal is to safely restore the lost range of motion, rebuild atrophied muscles, and return the user to their baseline physical function.',
    'goalMobilityTitle': 'Mobility Training',
    'goalMobilityDesc':
        "A practice focused on actively controlling the body through its full range of motion. Unlike passive stretching, mobility work requires strength and stability at the end ranges of a joint's movement, which keeps joints healthy, prevents injury, and improves overall movement quality.",
    'catCardio': 'Cardiovascular & Endurance',
    'goalHiitTitle': 'HIIT (High-Intensity Interval Training)',
    'goalHiitDesc':
        'A time-efficient cardiovascular methodology alternating between short bursts of near-maximum effort and periods of active recovery or rest. It forces the heart rate to spike quickly, improving cardiovascular capacity, metabolic rate, and caloric burn long after the workout ends.',
    'goalEnduranceTitle': 'Endurance Training',
    'goalEnduranceDesc':
        "Steady-state, aerobic exercise designed to be sustained over long periods. Activities like marathon running, long-distance cycling, or swimming train the heart to pump blood more efficiently and increase the muscles' ability to utilise oxygen, building deep, long-lasting stamina.",
    'catMindbody': 'Mind-Body & Core',
    'goalYogaTitle': 'Yoga',
    'goalYogaDesc':
        'A comprehensive practice that links physical postures with controlled breathing and mental focus. It improves flexibility, balance, and core strength while actively engaging the parasympathetic nervous system to reduce stress and enhance the mind-body connection.',
    'goalPilatesTitle': 'Pilates',
    'goalPilatesDesc':
        'A precision-based training method primarily focused on the deep abdominal core, pelvic floor, and spinal stabilising muscles. Whether performed on a mat or specialised equipment, it emphasises controlled, low-impact movements to improve posture, body alignment, and deep muscular endurance.',
    'catSpecialised': 'Specialised Programs',
    'goalPrenatalTitle': 'Pre & Postnatal Fitness',
    'goalPrenatalDesc':
        'Carefully modified exercise routines designed to safely navigate the biomechanical changes of pregnancy. It focuses on maintaining strength, reducing back pain, and safely rebuilding core stability and pelvic floor function during postpartum recovery.',
    'goalSeniorTitle': 'Senior Fitness',
    'goalSeniorDesc':
        'Exercise programming specifically tailored for ageing populations. It prioritises resistance training to combat age-related muscle loss, weight-bearing exercises to maintain bone density, and balance drills to prevent falls and sustain independent living.',
    'goalYouthTitle': 'Youth Fitness',
    'goalYouthDesc':
        'Age-appropriate developmental programming for children and teenagers. It focuses on teaching fundamental movement patterns, developing neuromuscular coordination, and fostering a healthy, lifelong relationship with physical activity without applying excessive loads to growing bones.',
  });

  await file.writeAsString(JsonEncoder.withIndent('  ').convert(data));
  print('Updated app_en.arb');
}
