
mixin LocalRepository<T> {

  Future<T> insert(T note);

  Future<T> update(T note);

  Future<T> delete(T note);

  Future<List<T>> getData();

  Future<void> create();

  //Future<int> getCount(String query);
}