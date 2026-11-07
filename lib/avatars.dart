/// Children choose a picture instead of typing a username (same as the website).
const Map<String, String> avatars = {
  'fox': '🦊',
  'panda': '🐼',
  'tiger': '🐯',
  'frog': '🐸',
  'owl': '🦉',
  'octopus': '🐙',
  'unicorn': '🦄',
  'turtle': '🐢',
  'penguin': '🐧',
  'lion': '🦁',
  'koala': '🐨',
  'rabbit': '🐰',
};

String avatarFor(String name) => avatars[name] ?? '🙂';

String yearName(int year) => year == 0 ? 'Reception' : 'Year $year';
