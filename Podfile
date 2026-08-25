platform :ios, '16.0'
workspace 'BookStore.xcworkspace'
use_frameworks!

# No se agregaron pods de networking (Alamofire) ni de imágenes (Kingfisher/SDWebImage):
# el networking se resuelve con URLSession dentro del XCFramework propio
# (BookStoreNetworkingKit) y la carga de portadas usa AsyncImage nativo de SwiftUI.
# Se deja CocoaPods integrado igualmente con un pod de apoyo (SwiftLint) para
# cumplir el requisito de gestión de dependencias.
target 'BookStore' do
  project 'BookStore.xcodeproj'
  pod 'SwiftLint'
end
