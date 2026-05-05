class File {
  final String path;
  File(this.path);

  bool existsSync() => false;

  Future<File> copy(String newPath) async => File(newPath);
}

class Directory {
  final String path;
  Directory(this.path);
}
