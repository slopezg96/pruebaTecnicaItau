# Arquitectura

## Capas (MVVM + Clean Architecture)

```
Presentation  (BookStore/Presentation)
    │  Views SwiftUI + ViewModels (@MainActor, ObservableObject, @Published)
    │  sin lógica de negocio en las Views
    ▼
Domain        (BookStore/Domain)
    │  Entidades puras (Book, CartItem), enum ViewState<T>,
    │  protocolos de repositorio, casos de uso
    │  — sin imports de SwiftUI/UIKit/CoreData/el XCFramework —
    ▼
Data          (BookStore/Data)
    │  Implementaciones de los repositorios, DTOs↔Entity (BookMapper),
    │  fuentes de datos remota (adapta el XCFramework) y local (mock / UserDefaults)
    ▼
BookStoreNetworkingKit  (XCFramework, proyecto Xcode propio)
       API pública: NetworkClientProtocol, URLSessionNetworkClient, Endpoint,
       NetworkError, DTOs y servicio de la Google Books API
```

**Regla de dependencia**: Domain no depende de nada externo (solo Foundation).
Data depende de Domain (implementa sus protocolos) y del XCFramework.
Presentation depende de Domain (a través de los casos de uso) y arma las
dependencias concretas de Data solo en el punto de composición
(`AppDependencyContainer`).

## Flujo de datos

```
View → ViewModel → UseCase (protocolo, Domain) → Repository (protocolo, Domain)
     → Repository impl (Data) → DataSource (remoto vía XCFramework / mock local / UserDefaults)
```

Ejemplo concreto (catálogo):
`CatalogView` → `CatalogViewModel.load()` → `GetBooksUseCase.execute()` →
`BooksRepositoryProtocol.fetchCatalog()` → `BooksRepositoryImpl` intenta
`RemoteBooksDataSource` (adapta `GoogleBooksAPIService` del XCFramework); si
falla o no hay resultados, cae a `MockBooksDataSource` (JSON embebido con
latencia simulada). El resultado se mapea de DTO a `Book` con `BookMapper`
antes de llegar a Domain/Presentation.

## Inyección de dependencias

`AppDependencyContainer` (`BookStore/App/AppDependencyContainer.swift`) es un
factory manual basado en protocolos: construye una única vez los
repositorios compartidos (books, favorites, cart) y expone métodos
`makeXViewModel()` para crear los ViewModels de cada pantalla bajo demanda.
No se usó ningún framework de DI externo.

## Estados explícitos (`ViewState<T>`)

```swift
enum ViewState<T> {
    case loading
    case loaded(T)
    case error(String)
    case empty
}
```

`CatalogViewModel` modela su estado con este enum en vez de banderas
booleanas sueltas (`isLoading`, `hasError`, etc.), con vistas reutilizables
(`LoadingView`, `ErrorStateView`, `EmptyStateView`) para renderizar cada caso.

## Decisiones técnicas y por qué

1. **XCFramework de networking, no de persistencia.** Se eligió networking
   porque es la pieza más natural de encapsular como módulo reutilizable
   e independiente de la fuente de persistencia elegida: la llamada de red
   y su parseo (DTOs de Google Books) viven enteramente dentro del
   framework, detrás de `NetworkClientProtocol`/`BooksAPIServiceProtocol`.

2. **Fuente de datos: Google Books API real + fallback automático a mock.**
   `BooksRepositoryImpl` intenta primero la API real y, ante cualquier
   error o respuesta vacía, cae al catálogo mock local, evitando que el
   catálogo quede bloqueado en un estado de error por inestabilidad de red.
   Esto se validó en la práctica durante el desarrollo: probando la Google
   Books API desde este entorno se recibió `HTTP 429` (rate limit) en
   varias ocasiones, y el fallback permitió que la app siguiera
   funcionando con datos mock sin cambios de código.

3. **Precio de respaldo determinista.** Google Books no siempre devuelve
   `saleInfo.listPrice` (depende de la disponibilidad comercial del volumen
   y de la región). Cuando falta, `BookMapper` deriva un precio determinista
   a partir de un hash del id del volumen (mismo id → siempre el mismo
   precio), para que el catálogo siempre muestre un precio. Es una decisión
   pragmática, documentada también como comentario en el código.

4. **Persistencia de favoritos con `UserDefaults` + `Codable`, no CoreData.**
   El alcance es una lista simple de libros favoritos (sin relaciones,
   queries complejas ni volumen de datos grande); CoreData habría agregado
   complejidad (modelo `.xcdatamodeld`, `NSManagedObjectContext`, mapeos)
   sin beneficio real para este caso de uso.

5. **Carrito en memoria, no persistido.** El carrito vive mientras la app
   está abierta y no necesita sobrevivir a un reinicio.
   `InMemoryCartRepository` vive como instancia compartida en el DI
   container, inyectada tanto en el detalle (agregar) como en el carrito
   (ver/quitar).

6. **CocoaPods con un único pod (SwiftLint).** No se integró ninguna
   librería de networking (Alamofire) ni de imágenes (Kingfisher/SDWebImage)
   porque `URLSession` (dentro del XCFramework) y `AsyncImage` (SwiftUI
   nativo) cubren esas necesidades sin dependencias adicionales. Se
   mantiene CocoaPods igualmente, integrado y funcional, como gestor de
   dependencias del proyecto.

7. **Proyecto Xcode generado con XcodeGen.** El desarrollo se hizo 100%
   desde la línea de comandos, sin editor Xcode disponible para generar los
   `.xcodeproj`/`.xcworkspace` a mano. XcodeGen genera proyectos Xcode
   reproducibles a partir de `project.yml` (fuente de verdad, versionado),
   evitando editar `project.pbxproj` directamente — mucho más frágil y
   propenso a corromperse. Los `.xcodeproj` generados **sí se commitean**
   para que el proyecto compile de inmediato sin depender de tener
   XcodeGen instalado (ver `.gitignore`).

8. **Ruby de Homebrew en vez del Ruby de sistema.** El Ruby de sistema de
   macOS (2.6.10 en este entorno) es demasiado antiguo para instalar las
   versiones actuales de CocoaPods/Fastlane (dependencias transitivas como
   `ffi` requieren Ruby >= 3.0). Se documenta `brew install ruby` +
   Bundler configurado en modo local al proyecto (`vendor/bundle`), sin
   instalar ninguna gem globalmente.

9. **Idioma de commits: español**, con Conventional Commits (`feat:`,
   `fix:`, `build:`, `docs:`, `test:`, `chore:`).

10. **Sin UIKit.** Toda la UI es SwiftUI (`NavigationStack`, `List`,
    `AsyncImage`, `.refreshable`, `.swipeActions`); no fue necesario ningún
    puente a UIKit.

## Testing

11 tests XCTest en `BookStoreTests`:

- `CatalogViewModelTests` — ViewModel de Presentation (loading/loaded/
  empty/error y filtro de favoritos), con dobles de test para el caso de
  uso y el repositorio de favoritos.
- `CartTotalUseCaseTests` — caso de uso puro de Domain.
- `BookMapperTests` — mapeo DTO (Google Books) → entidad `Book`, incluyendo
  el precio de respaldo determinista.
- `FavoritesRepositoryImplTests` — persistencia con `UserDefaults` entre
  instancias del repositorio.

Corridos vía `bundle exec fastlane test` (lane que ejecuta
`xcodebuild test` contra el workspace en el simulador).
