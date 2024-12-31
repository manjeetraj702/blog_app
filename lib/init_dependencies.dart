part of 'init_dependencies.main.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
      url: AppSecret.supaBaseUrl, anonKey: AppSecret.anonKey);

  // HIVE


  serviceLocator.registerLazySingleton(() => supabase.client);
  // serviceLocator.registerLazySingleton(() => Hive.box(name: 'blogs'));
  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
}

void _initAuth() {
  // Data Source
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
          serviceLocator(),
        ))
    ..
        // Repository
        registerFactory<AuthRepository>(() => AuthRepositoryImpl(
              serviceLocator(),
              serviceLocator(),
            ))
    // Use cases:
    ..registerFactory(() => UserSignUp(
          serviceLocator(),
        ))
    ..registerFactory(() => UserSignIn(
          serviceLocator(),
        ))
    // Bloc
    ..registerLazySingleton(() => AuthBloc(
          userSignUp: serviceLocator(),
          userSignIn: serviceLocator(),
          currentUser: CurrentUser(
            serviceLocator(),
          ),
          appUserCubit: serviceLocator(),
        ));
}

void _initBlog() {
  // remote Data Source
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )

    // ..registerFactory<BlogLocalDataSource>(() => BlogLocalDataSourceImpl(
    //       serviceLocator(),
    //     )
    // )
  // repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        // serviceLocator(),
      ),
    )
    // use cases
    ..registerFactory(
      () => UploadBlog(serviceLocator()),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator(),
      ),
    )
    // bloc
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
      ),
    );
}
