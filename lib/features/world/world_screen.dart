import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'artist_detail_screen.dart';

class WorldScreen extends ConsumerStatefulWidget {
  const WorldScreen({super.key});

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  final List<OrigamiArtist> _artists = [
    OrigamiArtist(
      name: 'Akira Yoshizawa',
      country: 'Japan',
      flag: '🇯🇵',
      lifespan: '1911–2005',
      specialty: 'Father of modern origami',
      biography: 'Widely considered the father of modern origami, Yoshizawa defined 20th-century origami art. A farmer\'s son who taught himself to fold, he created ~50,000 unique models in his lifetime (only a few hundred were diagrammed in his 18 books). He pioneered the wet-folding technique (dampening paper to sculpt curves) and developed the Yoshizawa–Randlett diagramming notation used worldwide. His work elevated origami to fine art, earning him Japan\'s Order of the Rising Sun (1983) and global exhibitions.',
      links: ['Atarashii Origami Geijutsu (New Origami Art, his flagship book series)', 'Akira Yoshizawa demonstrating origami (1965)'],
    ),
    OrigamiArtist(
      name: 'Ekaterina Lukasheva',
      country: 'Russia/USA',
      flag: '🇷🇺',
      lifespan: 'b.1986',
      specialty: 'Curved origami and tessellations',
      biography: 'A contemporary origami designer known for curved origami and tessellations. She started folding in her teens ("first tried folding at 14 when a math professor brought in a kusudama book") and earned a Ph.D. in mathematics. Lukasheva has authored at least three–four origami books of her designs. She specializes in modular and repetitive geometric patterns (often spiral or kaleidoscopic), creating complex 3D tessellations with no glue. Her clean photographs and meticulous diagrams have garnered international attention.',
      links: ['kusudama.me (her origami website)', 'Kusudama & tessellation books by Lukasheva'],
    ),
    OrigamiArtist(
      name: 'Meenakshi Mukerji',
      country: 'India/USA',
      flag: '🇮🇳',
      lifespan: '1964–2024',
      specialty: 'Modular and single-sheet origami',
      biography: 'An origami artist and teacher from India who popularized modular and single-sheet origami. She designed vibrant geometric modules (flowers, kusudamas) and floral models, often posting free diagrams on her site origamee.net. Mukerji authored several origami books (at least eight by some accounts) and led workshops worldwide. She was honored with OrigamiUSA\'s Florence Temko Award in 2005 for her contributions. Mukerji was an active educator up until her death in 2024, and her work broadened interest in origami in India and beyond.',
      links: ['origamee.net (site with her tutorials)', 'several books on origami design'],
    ),
    OrigamiArtist(
      name: 'Robert J. Lang',
      country: 'USA',
      flag: '🇺🇸',
      lifespan: 'b.1961',
      specialty: 'Mathematical origami',
      biography: 'A physicist-turned-origami-designer renowned for mathematically complex folds. Lang has been folding since age 6 and is credited with bringing computational algorithms to origami design. His official site notes "over 800 designs" are catalogued and diagrammed, and he has authored or coauthored around 20+ origami books. Lang\'s animals and insects (e.g. ants, butterflies, a famous pteranodon model) are extremely intricate. He wrote Origami Design Secrets and developed software for planning folds. Lang\'s origami has practical applications: he consulted for NASA (foldable space telescopes, airbags) and protein folding research. Lang is widely published and was the first Westerner invited to Japan\'s origami masters convention.',
      links: ['langorigami.com (his site with diagrams and publications)'],
    ),
    OrigamiArtist(
      name: 'Paolo Bascetta',
      country: 'Italy',
      flag: '🇮🇹',
      lifespan: 'b.1948',
      specialty: 'Geometric modular origami',
      biography: 'An Italian origami artist and math teacher, Bascetta favors geometric modular origami. He discovered origami in his 20s ("found an origami book at age 26") and has been folding for over 40 years. He has created many original models published in books and magazines worldwide. Bascetta\'s designs emphasize simplicity and geometry; he especially likes polyhedral modules and "transparencies" (folds that reveal inner shapes). His most famous model is the Bascetta Star, a sturdy modular star unit "known and appreciated all over the world" (even used to teach geometry). He has taught origami internationally (guest of honor at many conventions) and in 2020 experimented with an origami book for the visually impaired.',
      links: ['paolobascetta.com (official site with his books like Folding and Creatività Modulare)'],
    ),
    OrigamiArtist(
      name: 'Jo Nakashima',
      country: 'Japan/Brazil',
      flag: '🇧🇷',
      lifespan: 'b.1983',
      specialty: 'YouTube origami instruction',
      biography: 'A popular origami instructor on YouTube. Nakashima is a Japanese-Brazilian ("nikkei") who started posting video tutorials in 2007. His channel "Origami with Jo Nakashima" now has millions of subscribers, making it one of the largest origami channels. He creates both original models and teaches others\' designs (animals, flowers, characters, etc.). By 2010 origami videos were his full-time career. Nakashima also provides free PDFs/diagrams on his site. His accessible, visually clear tutorials have introduced many to folding; he is known for neat intermediate designs like origami birds, stars, and boxes.',
      links: ['jo-nakashima.com.br (his website)', 'YouTube channel Origami with Jo Nakashima'],
    ),
    OrigamiArtist(
      name: 'Mariya Sinayskaya',
      country: 'Russia/South Africa',
      flag: '🇿🇦',
      lifespan: 'b.1980',
      specialty: 'Modular tessellations and kusudama',
      biography: 'A modular origami artist celebrated for elegant tessellations and kusudama. Described by publisher Walter Foster as a "masterful origami creator" whose work is "beautiful and complex", Sinayskaya designs Sonobe-based stars, flowers and interlocking grids without using glue. She lives in South Africa and runs the GoOrigami blog. In her 2016 book Zen Origami, she published 20 of her modular creations, complete with hand-drawn diagrams and 400 sheets of included paper. Her aesthetic emphasizes symmetry and calm; each photograph by Sinayskaya is carefully composed. She has 10,000+ followers on her site\'s social channels.',
      links: ['goorigami.com (Sinayskaya\'s site featuring her models)', 'Zen Origami by M. Sinayskaya (book)'],
    ),
    OrigamiArtist(
      name: 'Mariano Zavala',
      country: 'Peru',
      flag: '🇵🇪',
      lifespan: 'b.?',
      specialty: 'Realistic wildlife models',
      biography: 'A self-taught origami artist from Lima, known for realistic wildlife and pop-culture models. Zavala shares his creations via Facebook and YouTube, often focusing on animals, insects and dinosaurs. An interview notes he "loves three-dimensional sculptures that he can work with hands" and he "excels in making amazing animals and insects by folding paper". He primarily folds designs by other artists (available in books) but sometimes creates originals. Zavala has become a social-media celebrity, posting systematic tutorials of his models. His portfolio includes origami beetles, chameleons, caribou and even cartoon characters; beetles are his favorite.',
      links: ['Mariano Zavala\'s YouTube channel (MarianoZB Origami)', 'social media for tutorials and photo galleries'],
    ),
    OrigamiArtist(
      name: 'Tomoko Fuse',
      country: 'Japan',
      flag: '🇯🇵',
      lifespan: 'b.1951',
      specialty: 'Modular origami pioneer',
      biography: 'A modular origami pioneer. Fuse is famous for geometric designs (cubes, stellated polyhedra, boxes, spirals). According to the Echigo-Tsumari art project, "Fuse Tomoko…is known as a pioneer of \'Modular Origami\'". She has written dozens of books (in Japanese and translated abroad) demonstrating how to fold complex interlocking units and decorate 3D puzzles. Her work often uses two or more sheets of paper per model, producing intricate polyhedral spheres and lattices. Fuse\'s influence is global: many origami artists credit her books for teaching modular techniques.',
      links: ['Unit Origami: Multidimensional Transformations', 'Modular Origami Polyhedra by Tomoko Fuse'],
    ),
    OrigamiArtist(
      name: 'John Montroll',
      country: 'USA',
      flag: '🇺🇸',
      lifespan: 'b.1943',
      specialty: 'Mathematical origami author',
      biography: 'A leading American origami author and mathematician. Montroll\'s publications have "significantly increased the global repertoire of original designs". He introduced fundamental folds (e.g. the double rabbit-ear and the Insect Base) used in many animal models. He has written 30+ origami books (e.g. Animal Origami for the Enthusiast) featuring hundreds of his original animal and plant designs, all using a single square with no cuts or glue. Montroll is celebrated for clear diagrams and for adapting origami to educational settings. His career (first book in 1988) spans decades of workshops and media appearances promoting origami.',
      links: ['johnmontroll.com (personal site with model gallery and publications)'],
    ),
    OrigamiArtist(
      name: 'Éric Joisel',
      country: 'France',
      flag: '🇫🇷',
      lifespan: '1956–2010',
      specialty: 'Wet-folded figurative art',
      biography: 'A French origami sculptor celebrated for wet-folded figurative art. Joisel specialized in wet-folding (moistening paper to create sculptural forms) and created lifelike origami figures (humans, animals, mythical beings). He "specialized in the wet-folding method, creating figurative art sculptures using sheets of paper and water, without the use of any adhesive". Joisel\'s detailed pieces (e.g. commedia dell\'arte characters, musicians with instruments) took months of work each. His sculptures were exhibited globally (including the Louvre) and featured in the origami documentary Between the Folds. Joisel published many crease patterns himself, blending origami with classical sculpture.',
      links: ['ericjoisel.fr (archival site of Joisel\'s works)', 'Angela\'s Christmas, Jack-o\'-Lantern Jack (books by Joisel)'],
    ),
    OrigamiArtist(
      name: 'Satoshi Kamiya',
      country: 'Japan',
      flag: '🇯🇵',
      lifespan: 'b.1981',
      specialty: 'Complex modern designs',
      biography: 'Renowned for some of the most complex modern designs. Kamiya began folding at age two and by 1995 was designing his own models. He has created hundreds of designs, many requiring 100–250+ steps. His most famous model is the Ryu-Zin 3.5 (a detailed dragon), which is so intricate that even its crease pattern is asymmetrical. Kamiya has published three hefty books (each with dozens of diagrams) compiling his advanced models. He often draws inspiration from nature, mythology and manga. His work (e.g. feathered phoenixes, military airplanes) is the benchmark for complexity in origami, inspiring advanced folders worldwide.',
      links: ['folders.jp (Kamiya\'s site with news of his books)'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);
    
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Origami Around the World',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover talented origami artists from around the globe',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              
              // 3D Spinning Globe
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                        AppTheme.secondaryColor.withValues(alpha: 0.3),
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                                  AppTheme.secondaryColor.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '🌍',
                                style: TextStyle(fontSize: 80),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Featured Artists',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _artists.length,
                  itemBuilder: (context, index) {
                    final artist = _artists[index];
                    return _buildArtistCard(artist);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtistCard(OrigamiArtist artist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistDetailScreen(artist: artist),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    artist.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${artist.country} • ${artist.lifespan}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist.specialty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

