const List<Map<String, dynamic>> farmLevels = [
  {
    "name": "Rookie Farmer",
    "xp": 0,
    "chopPoints": 0,
  },
  {
    "name": "Learning Farmer",
    "xp": 200,
    "chopPoints": 1000,
  },
  {
    "name": "Big Farmer",
    "xp": 600,
    "chopPoints": 3000,
  },
  {
    "name": "Expert Farmer",
    "xp": 1800,
    "chopPoints": 9000,
  },
  {
    "name": "Great Farmer",
    "xp": 5400,
    "chopPoints": 27000,
  },
];

Map<String, dynamic>? getNextLevel(int currentLevel) {
  if (currentLevel + 1 < farmLevels.length) {
    return farmLevels[currentLevel + 1];
  }
  return null;
}
int getLevelIndex(int xp, int chopPoints) {
  for (int i = farmLevels.length - 1; i >= 0; i--) {
    if (xp >= farmLevels[i]["xp"] && chopPoints >= farmLevels[i]["chopPoints"]) {
      return i;
    }
  }
  return 0;
}