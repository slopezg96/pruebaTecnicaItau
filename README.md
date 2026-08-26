# BookStore — Prueba Técnica iOS

App iOS nativa que simula una tienda de libros: catálogo, detalle, carrito de
compras y favoritos persistentes. SwiftUI + MVVM + Clean Architecture,
CocoaPods, un XCFramework propio de networking y Fastlane vía Bundler.

## Funcionalidades

- **Catálogo**: lista de libros (título, autor, precio), indicador visual de
  favorito, pull-to-refresh, filtro "solo favoritos".
- **Detalle**: portada, título, autor, precio, descripción, marcar/desmarcar
  favorito, agregar al carrito.
- **Carrito**: agregar desde el detalle, ver cantidad y total, quitar libros
  (swipe to delete). Vive en memoria durante la sesión.
- **Favoritos**: persisten entre reinicios de la app (UserDefaults+Codable).
  Se pueden marcar/desmarcar desde el catálogo (swipe) y desde el detalle.
- **Estados explícitos** (`ViewState<T>`): loading / loaded / error (con
  reintentar) / vacío, en catálogo y carrito.

## Requisitos previos

- **Xcode 15 o superior** (desarrollado y probado con Xcode 26.6, simulador
  iOS 26.5).
- **Ruby >= 3.0**. El Ruby de sistema de macOS suele ser muy antiguo (2.6.x)
  para las versiones actuales de CocoaPods/Fastlane. Se recomienda instalar
  uno moderno vía Homebrew:
  ```bash
  brew install ruby
  # agregar /opt/homebrew/opt/ruby/bin al PATH, o usar la ruta completa
  # como se hace en los comandos de abajo.
  ```
- **Bundler** (viene incluido con el Ruby de Homebrew). Todas las gems
  (CocoaPods, Fastlane) se instalan vía Bundler, **no** globalmente.
- **XcodeGen** — opcional. Los `.xcodeproj`/`.xcworkspace` ya están
  commiteados y listos para compilar; solo hace falta si vas a modificar
  `project.yml` y regenerar el proyecto:
  ```bash
  brew install xcodegen
  ```

## Clonar e instalar dependencias

```bash
git clone https://github.com/slopezg96/pruebaTecnicaItau.git
cd pruebaTecnicaItau

# Bundler local al proyecto (instala las gems en ./vendor/bundle, no global)
bundle config set --local path 'vendor/bundle'
bundle install
# Si tu Ruby de sistema es viejo, usá la ruta del Ruby de Homebrew, ej:
# /opt/homebrew/opt/ruby/bin/bundle install

# CocoaPods, vía Bundler
bundle exec pod install
```

## Ejecutar la app

Abrir **`BookStore.xcworkspace`** (no el `.xcodeproj` suelto) en Xcode y
correr el esquema `BookStore` en un simulador de iPhone.

O por línea de comandos:

```bash
xcodebuild -workspace BookStore.xcworkspace -scheme BookStore \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

La app no requiere firma de código para correr en simulador (los targets
tienen `CODE_SIGNING_ALLOWED=NO` en Debug).

## Generar el XCFramework

```bash
./Scripts/build_xcframework.sh
```

Archiva `BookStoreNetworkingKit` para device y simulator y los combina en
`build_xcframework/BookStoreNetworkingKit.xcframework`.

## Fastlane

```bash
bundle exec fastlane test   # corre la suite de tests unitarios (XCTest)
bundle exec fastlane build  # compila la app para simulador, sin firma
```

## Demo de la integración CocoaPods + Fastlane

```bash
./Scripts/demo.sh
```

Encadena `bundle install → pod install → fastlane test → fastlane build`
y abre el reporte HTML de los tests (`fastlane/test_output/report.html`) al
final. Pensado para correr con un solo comando durante una demo en vivo;
detecta automáticamente si hace falta el Ruby de Homebrew (ver
"Requisitos previos").

## Regenerar los proyectos Xcode (solo si modificás project.yml)

```bash
xcodegen generate                                  # target de la app
(cd BookStoreNetworkingKit && xcodegen generate)    # target del XCFramework
bundle exec pod install                             # reintegra CocoaPods
```

Importante: `xcodegen generate` reescribe `BookStore.xcodeproj` desde cero a
partir de `project.yml` y no sabe nada de CocoaPods, así que borra la
integración (`Pods_BookStore.framework`, xcconfig, el build phase "Check
Pods Manifest.lock") que `pod install` había agregado. Por eso, después de
regenerar el proyecto hay que correr `bundle exec pod install` de nuevo
para reintegrarlo.

## Tests

11 tests XCTest cubriendo un ViewModel (`CatalogViewModelTests`), un caso de
uso de Domain (`CartTotalUseCaseTests`), el mapeo DTO→Entity
(`BookMapperTests`) y la persistencia de favoritos
(`FavoritesRepositoryImplTests`):

```bash
bundle exec fastlane test
```

## Decisiones de arquitectura y alcance

Ver [`ARCHITECTURE.md`](./ARCHITECTURE.md) para el detalle completo. Resumen:

- **Datos**: Google Books API real, con **fallback automático** a un
  catálogo mock local embebido si la llamada falla o no trae precio
  comercial.
- **Favoritos**: `UserDefaults` + `Codable`.
- **Carrito**: en memoria (no persistido); vive mientras la app está abierta.
- **XCFramework**: encapsula el networking (URLSession + parseo de la
  respuesta de Google Books).
- **CocoaPods**: se agrega únicamente SwiftLint; no se necesitó ninguna
  librería de networking/imágenes de terceros.
- **100% SwiftUI**, sin UIKit.
- **Commits**: Conventional Commits en español.
