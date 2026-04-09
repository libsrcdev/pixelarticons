String bumpMinorVersion(String current) {
  final version = current.split('.').map(int.parse).toList();
  final major = version[0];
  final minor = version[1];
  return '$major.${minor + 1}.0';
}
