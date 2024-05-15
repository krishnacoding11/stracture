
abstract class BaseUseCase<REPOSITORY> {
  Future<REPOSITORY?> getInstance();
}

// For requests without params
class NoParams {}
