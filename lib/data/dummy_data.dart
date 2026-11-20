import 'package:flutter/material.dart';
import '../app/tokens.dart';
import 'models.dart';

const UserProfile kCurrentUser = UserProfile(
  name: 'Priya Nair',
  handle: '@priyawrites',
  initials: 'PN',
  avatarBg: Color(0xFFCFC8E8),
  avatarFg: Color(0xFF241C4A),
  streakDays: 12,
  dailyGoalMinutes: 30,
  minutesReadToday: 18,
);

const List<Color> kCoverPalette = [
  Color(0xFF2F2B3A),
  Color(0xFFCFC8E8),
  Color(0xFFD8C7B8),
  Color(0xFF1E2A2F),
  Color(0xFFE8E1D3),
  Color(0xFFDDE3E0),
  Color(0xFFE6DCD0),
  Color(0xFFC9BBF3),
  Color(0xFF3A4A3F),
];

const List<String> kGenres = [
  'Fiction',
  'Poetry',
  'Romance',
  'Mystery',
  'Fantasy',
  'Philosophy',
  'Short stories',
  'Self-growth',
  'Sci-fi',
  'Non-fiction',
  'History',
  'Thriller',
];

const List<Book> kDummyBooks = [
  Book(
    id: 'salt',
    title: 'The Salt Orchard',
    author: 'Meera Kulkarni',
    genre: 'Fiction',
    rating: 4.7,
    reads: '12.4k',
    chapters: 24,
    currentChapter: 12,
    minutesLeft: 18,
    progress: 0.64,
    status: BookStatus.reading,
    blurb:
        'At the edge of an old coastal estate, two estranged sisters tend a grove of citrus trees that somehow flourish in brine-soaked soil. Over a single monsoon season, hidden ledgers and unsent letters force them to decide what is worth keeping. A quiet, luminous novel about inheritance, weather, and return.',
    coverBg: Color(0xFFE8E1D3),
    coverFg: Color(0xFF2A2623),
    hasPremiumChapters: true,
    isTrending: true,
    isNewChapterToday: true,
    spineWidth: 38,
    spineHeight: 178,
  ),
  Book(
    id: 'paper-moons',
    title: 'Paper Moons',
    author: 'Arjun Sen',
    genre: 'Poetry',
    rating: 4.8,
    reads: '9.2k',
    chapters: 16,
    currentChapter: 5,
    minutesLeft: 24,
    progress: 0.31,
    status: BookStatus.reading,
    blurb:
        'Small poems written on train tickets, café napkins, and late-night margins between Kolkata and Pune. Each piece holds a brief encounter with strangers, rain, and borrowed light.',
    coverBg: Color(0xFF2F2B3A),
    coverFg: Color(0xFFF4F1EA),
    hasPremiumChapters: true,
    isTrending: true,
    isNewChapterToday: true,
    spineWidth: 34,
    spineHeight: 164,
  ),
  Book(
    id: 'quiet-rivers',
    title: 'Quiet Rivers',
    author: 'Nadia Okafor',
    genre: 'Fiction',
    rating: 4.5,
    reads: '6.1k',
    chapters: 18,
    currentChapter: 2,
    minutesLeft: 35,
    progress: 0.08,
    status: BookStatus.reading,
    blurb:
        'A cartographer returns to her grandfather’s river town to map channels that disappear every dry season. Along the banks, she uncovers stories the town agreed never to write down.',
    coverBg: Color(0xFF1E2A2F),
    coverFg: Color(0xFFE8E1D3),
    hasPremiumChapters: false,
    isTrending: true,
    spineWidth: 36,
    spineHeight: 172,
  ),
  Book(
    id: 'small-hours',
    title: 'A Map of Small Hours',
    author: 'Clara Lindqvist',
    genre: 'Philosophy',
    rating: 4.6,
    reads: '8.7k',
    chapters: 14,
    currentChapter: 1,
    minutesLeft: 42,
    progress: 0.0,
    status: BookStatus.saved,
    blurb:
        'Reflections on attention, unhurried mornings, and why our best thoughts arrive when no clock is being watched. Fourteen short essays designed to be read one cup of tea at a time.',
    coverBg: Color(0xFFCFC8E8),
    coverFg: Color(0xFF241C4A),
    hasPremiumChapters: true,
    isTrending: true,
    spineWidth: 34,
    spineHeight: 182,
  ),
  Book(
    id: 'late-bloom',
    title: 'Late Bloom',
    author: 'Tessa Mori',
    genre: 'Romance',
    rating: 4.4,
    reads: '15.1k',
    chapters: 12,
    currentChapter: 1,
    minutesLeft: 19,
    progress: 0.0,
    status: BookStatus.saved,
    blurb:
        'A botanist restoring a glasshouse and an archivist cataloguing seed packets keep missing each other by minutes. Their correspondence in the greenhouse logbook slowly turns into something unmistakable.',
    coverBg: Color(0xFFD8C7B8),
    coverFg: Color(0xFF2A2623),
    hasPremiumChapters: false,
    isTrending: true,
    isNewChapterToday: true,
    spineWidth: 32,
    spineHeight: 158,
  ),
  Book(
    id: 'glass-harbour',
    title: 'Glass Harbour',
    author: 'Julian Vance',
    genre: 'Mystery',
    rating: 4.9,
    reads: '21.3k',
    chapters: 22,
    currentChapter: 22,
    minutesLeft: 0,
    progress: 1.0,
    status: BookStatus.finished,
    blurb:
        'When a lighthouse keeper vanishes before a winter gale, a visiting watchmaker finds seven stopped clocks in the tower. Every dial points to a different secret held by the harbour town.',
    coverBg: Color(0xFF3A4A3F),
    coverFg: Color(0xFFF4F1EA),
    hasPremiumChapters: true,
    isTrending: true,
    spineWidth: 42,
    spineHeight: 186,
  ),
  Book(
    id: 'winter-ledger',
    title: 'The Winter Ledger',
    author: 'Sora Takahashi',
    genre: 'Mystery',
    rating: 4.7,
    reads: '11.8k',
    chapters: 20,
    currentChapter: 20,
    minutesLeft: 0,
    progress: 1.0,
    status: BookStatus.finished,
    blurb:
        'Inside an alpine inn snowed in for four days, a retired bookbinder notices a missing page in the guest register. A taut, atmospheric puzzle with warmth at its centre.',
    coverBg: Color(0xFFDDE3E0),
    coverFg: Color(0xFF1E2A2F),
    hasPremiumChapters: true,
    isTrending: true,
    spineWidth: 36,
    spineHeight: 166,
  ),
  Book(
    id: 'seventeen-windows',
    title: 'Seventeen Windows',
    author: 'Priya Nair',
    genre: 'Short stories',
    rating: 4.6,
    reads: '1.4k',
    chapters: 8,
    currentChapter: 1,
    minutesLeft: 12,
    progress: 1.0,
    status: BookStatus.mine,
    blurb:
        'Seventeen brief glimpses into the apartments across a courtyard during a warm October week. Written in spare sentences that linger long after the lights go out.',
    coverBg: Color(0xFFE6DCD0),
    coverFg: Color(0xFF2A2623),
    hasPremiumChapters: false,
    isShortBook: true,
    spineWidth: 30,
    spineHeight: 152,
  ),
  Book(
    id: 'notes-orchard',
    title: 'Notes from the Orchard',
    author: 'Priya Nair',
    genre: 'Fiction',
    rating: 4.8,
    reads: '3.2k',
    chapters: 6,
    currentChapter: 6,
    minutesLeft: 28,
    progress: 0.72,
    status: BookStatus.mine,
    blurb:
        'Field notes, sketches, and linked chapters following a family home through six seasons of rain, harvest, and quiet repair. A work in progress published chapter by chapter.',
    coverBg: Color(0xFFC9BBF3),
    coverFg: Color(0xFF241C4A),
    hasPremiumChapters: false,
    isNewChapterToday: true,
    spineWidth: 38,
    spineHeight: 176,
  ),
  Book(
    id: 'rain-on-slate',
    title: 'Rain on Slate',
    author: 'Kabir Deshmukh',
    genre: 'Short stories',
    rating: 4.5,
    reads: '5.4k',
    chapters: 9,
    currentChapter: 1,
    minutesLeft: 15,
    progress: 0.0,
    status: BookStatus.saved,
    blurb:
        'Nine concise stories set in hillside railway stations where travellers wait out sudden storms. Each chapter takes under fifteen minutes to finish.',
    coverBg: Color(0xFF2F2B3A),
    coverFg: Color(0xFFE8E1D3),
    hasPremiumChapters: false,
    isShortBook: true,
    isTrending: true,
    spineWidth: 32,
    spineHeight: 160,
  ),
  Book(
    id: 'clockmaker-letters',
    title: 'Letters to a Clockmaker',
    author: 'Elena Morales',
    genre: 'Romance',
    rating: 4.6,
    reads: '10.3k',
    chapters: 15,
    currentChapter: 1,
    minutesLeft: 18,
    progress: 0.0,
    status: BookStatus.saved,
    blurb:
        'When an antique pocket watch arrives at a Lisbon workshop with an unsigned note inside the lid, a year of thoughtful letters begins across two cities.',
    coverBg: Color(0xFFE8E1D3),
    coverFg: Color(0xFF2A2623),
    hasPremiumChapters: true,
    isShortBook: true,
    isTrending: true,
    spineWidth: 35,
    spineHeight: 170,
  ),
  Book(
    id: 'still-water-mind',
    title: 'Still Water Mind',
    author: 'Rohan Iyer',
    genre: 'Self-growth',
    rating: 4.7,
    reads: '18.9k',
    chapters: 10,
    currentChapter: 1,
    minutesLeft: 14,
    progress: 0.0,
    status: BookStatus.finished,
    blurb:
        'Practical essays on building a calmer creative rhythm without rigid schedules. Drawn from ten years of journaling, walking, and deliberate reading.',
    coverBg: Color(0xFFDDE3E0),
    coverFg: Color(0xFF1E2A2F),
    hasPremiumChapters: false,
    isShortBook: true,
    isTrending: true,
    isNewChapterToday: true,
    spineWidth: 34,
    spineHeight: 162,
  ),
  Book(
    id: 'amber-corridor',
    title: 'The Amber Corridor',
    author: 'Maren Solberg',
    genre: 'Mystery',
    rating: 4.3,
    reads: '7.6k',
    chapters: 28,
    currentChapter: 1,
    minutesLeft: 46,
    progress: 0.0,
    status: BookStatus.saved,
    blurb:
        'A museum restorer cleaning a seventeenth-century seascape discovers a second map painted underneath the tide line. Her quiet inquiry soon draws unwelcome notice.',
    coverBg: Color(0xFFD8C7B8),
    coverFg: Color(0xFF191919),
    hasPremiumChapters: true,
    spineWidth: 44,
    spineHeight: 188,
  ),
  Book(
    id: 'notes-on-walking',
    title: 'Notes on Walking',
    author: 'Hana Kim',
    genre: 'Philosophy',
    rating: 4.8,
    reads: '14.2k',
    chapters: 8,
    currentChapter: 1,
    minutesLeft: 11,
    progress: 0.0,
    status: BookStatus.finished,
    blurb:
        'Why four miles at dusk untangles problems a desk never can. A pocket-sized meditation on pace, city streets, and noticing what stays still.',
    coverBg: Color(0xFF3A4A3F),
    coverFg: Color(0xFFF4F1EA),
    hasPremiumChapters: false,
    isShortBook: true,
    spineWidth: 30,
    spineHeight: 154,
  ),
];

/// Core 6-chapter const dataset (covering read, current, unread, premium).
const List<BookChapter> kDummyChapters = [
  BookChapter(
    number: 1,
    title: 'Salt on the Gatepost',
    minutes: 11,
    status: ChapterStatus.read,
    words: 1620,
    isPublished: true,
  ),
  BookChapter(
    number: 2,
    title: 'The Lower Citrus Terrace',
    minutes: 14,
    status: ChapterStatus.read,
    words: 1940,
    isPublished: true,
  ),
  BookChapter(
    number: 3,
    title: 'Before the Monsoon Breaks',
    minutes: 12,
    status: ChapterStatus.read,
    words: 1710,
    isPublished: true,
  ),
  BookChapter(
    number: 4,
    title: 'Rain in the Salt Orchard',
    minutes: 18,
    status: ChapterStatus.current,
    words: 2380,
    isPublished: true,
  ),
  BookChapter(
    number: 5,
    title: 'The Tin Box Under the Stairs',
    minutes: 15,
    status: ChapterStatus.unread,
    words: 2050,
    isPublished: true,
  ),
  BookChapter(
    number: 6,
    title: 'High Tide Ledger',
    minutes: 16,
    status: ChapterStatus.premium,
    words: 2190,
    isPublished: false,
  ),
];

/// Chapters for "Notes from the Orchard" (user's own book in Book Manage).
const List<BookChapter> kMyBookChapters = [
  BookChapter(
    number: 1,
    title: 'The First Morning',
    minutes: 8,
    status: ChapterStatus.read,
    words: 1140,
    isPublished: true,
  ),
  BookChapter(
    number: 2,
    title: 'Lime Trees by the Well',
    minutes: 10,
    status: ChapterStatus.read,
    words: 1480,
    isPublished: true,
  ),
  BookChapter(
    number: 3,
    title: 'Postcards from the Coast',
    minutes: 9,
    status: ChapterStatus.read,
    words: 1290,
    isPublished: true,
  ),
  BookChapter(
    number: 4,
    title: 'A Jar of Preserved Lemons',
    minutes: 12,
    status: ChapterStatus.current,
    words: 1650,
    isPublished: true,
  ),
  BookChapter(
    number: 5,
    title: 'When the Wind Turns East',
    minutes: 7,
    status: ChapterStatus.unread,
    words: 980,
    isPublished: false,
  ),
  BookChapter(
    number: 6,
    title: 'Closing the Veranda',
    minutes: 6,
    status: ChapterStatus.unread,
    words: 740,
    isPublished: false,
  ),
];

/// Full chapter list helper so 24-chapter books display all 24 rows naturally.
List<BookChapter> chaptersForBook(Book book) {
  if (book.id == 'notes-orchard') {
    return kMyBookChapters;
  }
  const titles = [
    'Salt on the Gatepost',
    'The Lower Citrus Terrace',
    'Two Keys on a Ribbon',
    'Where the Wall Meets the Sea',
    'Letters in the Ledger',
    'A Quiet Afternoon in June',
    'The Brass Rain Gauge',
    'Pruning Before Dusk',
    'An Uninvited Surveyor',
    'Lanterns Along the Ditch',
    'The Sound of Wet Gravel',
    'Rain in the Salt Orchard',
    'The Tin Box Under the Stairs',
    'After the Squall',
    'What Grandmother Left Out',
    'A Map Drawn in Pencil',
    'High Tide Ledger',
    'The Eastern Fence',
    'Bitter Peel and Honey',
    'Voices on the Porch',
    'An Early Boat North',
    'The Naming of the Trees',
    'Clear Weather',
    'What Stays Rooted',
  ];

  final count = book.chapters.clamp(6, 24);
  return List.generate(count, (i) {
    final num = i + 1;
    final title = titles[i % titles.length];
    final minutes = 9 + (i * 3) % 11;
    ChapterStatus status;
    if (book.status == BookStatus.finished) {
      status = ChapterStatus.read;
    } else if (book.id == 'salt') {
      if (num < 12) {
        status = ChapterStatus.read;
      } else if (num == 12) {
        status = ChapterStatus.current;
      } else if (num >= 17) {
        status = ChapterStatus.premium;
      } else {
        status = ChapterStatus.unread;
      }
    } else {
      if (num < book.currentChapter) {
        status = ChapterStatus.read;
      } else if (num == book.currentChapter) {
        status = ChapterStatus.current;
      } else if (book.hasPremiumChapters && num > count - 4) {
        status = ChapterStatus.premium;
      } else {
        status = ChapterStatus.unread;
      }
    }
    return BookChapter(
      number: num,
      title: title,
      minutes: minutes,
      status: status,
      words: minutes * 135,
      isPublished: true,
    );
  });
}

const List<BookReview> kDummyReviews = [
  BookReview(
    id: 'r1',
    name: 'Ananya Rao',
    initials: 'AR',
    stars: 5,
    date: '14 Nov',
    text:
        'Unusually calm pacing. I read three chapters every night before sleep and felt like I could smell the wet earth and citrus leaves.',
    helpfulCount: 34,
    avatarBg: Color(0xFFCFC8E8),
    avatarFg: Color(0xFF241C4A),
  ),
  BookReview(
    id: 'r2',
    name: 'Devika Menon',
    initials: 'DM',
    stars: 5,
    date: '11 Nov',
    text:
        'Chapter 12 alone makes the book worth keeping. The dialogue between the sisters never over-explains anything.',
    helpfulCount: 27,
    avatarBg: Color(0xFFE8E1D3),
    avatarFg: Color(0xFF2A2623),
  ),
  BookReview(
    id: 'r3',
    name: 'Siddharth Bose',
    initials: 'SB',
    stars: 4,
    date: '8 Nov',
    text:
        'Takes a couple of chapters to settle into its rhythm, then becomes completely absorbing. Loved the seaside setting.',
    helpfulCount: 19,
    avatarBg: Color(0xFFDDE3E0),
    avatarFg: Color(0xFF1E2A2F),
  ),
  BookReview(
    id: 'r4',
    name: 'Hannah Brooks',
    initials: 'HB',
    stars: 5,
    date: '5 Nov',
    text:
        'Every sentence feels carefully pruned. One of the finest quiet novels I have read this year.',
    helpfulCount: 22,
    avatarBg: Color(0xFFD8C7B8),
    avatarFg: Color(0xFF2A2623),
  ),
  BookReview(
    id: 'r5',
    name: 'Raghav Joshi',
    initials: 'RJ',
    stars: 4,
    date: '2 Nov',
    text:
        'Great companion for a rainy evening commute. Short enough chapters to finish one at a time without losing the thread.',
    helpfulCount: 11,
    avatarBg: Color(0xFFE6DCD0),
    avatarFg: Color(0xFF2A2623),
  ),
  BookReview(
    id: 'r6',
    name: 'Maya Krishnan',
    initials: 'MK',
    stars: 5,
    date: '29 Oct',
    text:
        'The sense of weather and place is extraordinary. I immediately saved two more books by the same author.',
    helpfulCount: 16,
    avatarBg: Color(0xFFC9BBF3),
    avatarFg: Color(0xFF241C4A),
  ),
  BookReview(
    id: 'r7',
    name: 'Liam Carter',
    initials: 'LC',
    stars: 5,
    date: '24 Oct',
    text:
        'Restrained, generous, and deeply human. Not a single wasted scene.',
    helpfulCount: 9,
    avatarBg: Color(0xFF2F2B3A),
    avatarFg: Color(0xFFF4F1EA),
  ),
  BookReview(
    id: 'r8',
    name: 'Neha Sharma',
    initials: 'NS',
    stars: 4,
    date: '19 Oct',
    text:
        'Loved the notebook entries tucked between chapters. Wish there were a map of the orchard at the start!',
    helpfulCount: 14,
    avatarBg: Color(0xFFCFC8E8),
    avatarFg: Color(0xFF241C4A),
  ),
  BookReview(
    id: 'r9',
    name: 'Owen Patel',
    initials: 'OP',
    stars: 5,
    date: '15 Oct',
    text:
        'Finished it in four slow evenings. The ending stays with you without trying too hard to be dramatic.',
    helpfulCount: 8,
    avatarBg: Color(0xFF3A4A3F),
    avatarFg: Color(0xFFF4F1EA),
  ),
  BookReview(
    id: 'r10',
    name: 'Claire Dubois',
    initials: 'CD',
    stars: 4,
    date: '10 Oct',
    text:
        'Beautiful prose and very tender portrait of family memory. Perfect in sepia mode late at night.',
    helpfulCount: 6,
    avatarBg: Color(0xFFE8E1D3),
    avatarFg: Color(0xFF2A2623),
  ),
];

const List<FamilyMember> kInitialFamilyMembers = [
  FamilyMember(
    id: 'fm1',
    name: 'Priya Nair (you)',
    initials: 'PN',
    subtitle: 'Organizer · priya@okbank',
    status: FamilyMemberStatus.organizer,
    avatarBg: Color(0xFFCFC8E8),
    avatarFg: Color(0xFF241C4A),
  ),
  FamilyMember(
    id: 'fm2',
    name: 'Rohan Nair',
    initials: 'RN',
    subtitle: 'Member · joined 19 Nov',
    status: FamilyMemberStatus.member,
    avatarBg: Color(0xFFE8E1D3),
    avatarFg: Color(0xFF2A2623),
  ),
  FamilyMember(
    id: 'fm3',
    name: 'Asha Nair',
    initials: 'AN',
    subtitle: 'Invited · waiting to join',
    status: FamilyMemberStatus.pending,
    avatarBg: Color(0xFFD8C7B8),
    avatarFg: Color(0xFF2A2623),
  ),
  FamilyMember(
    id: 'fm4',
    name: 'Kabir',
    initials: 'K',
    subtitle: 'Age 9 · Under 13 shelf',
    status: FamilyMemberStatus.kids,
    avatarBg: Color(0xFFDDE3E0),
    avatarFg: Color(0xFF1E2A2F),
  ),
];

/// Original dummy prose for Chapter 12 of "The Salt Orchard".
const List<String> kChapter12Paragraphs = [
  'By four o’clock the sea wind had turned inland, carrying a fine crust of salt across the stone wall and into the lower rows of lime trees. Ira stood beneath the corrugated eaves of the tool shed, listening to the first heavy drops strike the dry leaves one by one, each sound distinct before the storm stitched them together into a steady roar.',
  'Nobody in the town believed citrus could last this close to the water. Twice in her grandfather’s lifetime a cyclone had pushed brackish foam across the terrace, whitening the bark up to the knee. Yet every August the branches hung heavy again, their fruit smaller than inland groves, sharper on the tongue, and faintly mineral in a way visitors never forgot.',
  'She picked up the brass rain gauge from the bench and stepped out along the gravel path. Water was already pooling inside the hollow of the gatepost where her sister used to hide chalk and sea glass. It struck her how quietly a place keeps the shape of old habits, long after the people who made them have learned to live elsewhere.',
  'Near the fourth row, Tara was tying burlap around a young sapling whose stakes had loosened in the morning gusts. She did not look up until Ira reached the ditch, then handed over the wet coil of twine without a word. For a full minute they worked side by side in the rain, knot after knot, their shoulders brushing as the wind shook loose a shower of pale blossoms.',
  '“The eastern drain is blocked again,” Tara said at last, wiping her brow with the back of a forearm. “Leaves from the almond tree. If we wait until dusk, the roots will sit in standing water all night.”',
  'Ira looked down the slope where dark rivulets were threading between the stones. Above them, the sky had settled into the colour of wet slate, neither evening nor afternoon. She fetched the iron rake leaning against the cistern and walked ahead, feeling the cold grit work its way into the edges of her sandals.',
  'When the clog gave way, the trapped water rushed through the culvert with a sudden low sigh, carrying twigs, fallen petals, and a single folded page torn from an old account book. Ira fished the sodden paper from the grate before it could slip into the trench. Even blurred by rain, her grandmother’s upright handwriting was unmistakable across the margin.',
  'Back on the veranda, they laid the sheet flat beside two steaming cups of ginger tea and weighted its corners with smooth river pebbles. Neither of them hurried to read it aloud. Outside, the orchard drank steadily in the dark, every leaf shining where the porch lamp reached, and for the first time since the monsoon began, the house felt large enough for both of them.',
  'Before turning in, Ira wound the hallway clock and checked the latch on the southern shutters. The rain had softened to a patient drizzle, the kind that lingers past midnight and leaves the air clear by morning. Tomorrow they would prune the windward boughs, count the new fruit, and decide together what the ledger meant to pass on.',
];

const List<Color> kEditorCoverDots = [
  FolioColors.coverCream,
  FolioColors.coverLavender,
  FolioColors.coverPlum,
  FolioColors.coverSand,
  FolioColors.coverForest,
  FolioColors.coverSlate,
];

Color foregroundForCover(Color bg) {
  if (bg == FolioColors.coverPlum ||
      bg == FolioColors.coverForest ||
      bg == FolioColors.coverSlate) {
    return FolioColors.plumText;
  }
  if (bg == FolioColors.coverLavender || bg == FolioColors.coverLilac) {
    return FolioColors.coverInkViolet;
  }
  return FolioColors.coverInkWarm;
}
