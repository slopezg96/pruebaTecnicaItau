platform :ios, '16.0'
workspace 'BookStore.xcworkspace'
use_frameworks!

# No se agregaron pods de networking (Alamofire) ni de imágenes (Kingfisher/SDWebImage):
# el networking se resuelve con URLSession dentro del XCFramework propio
# (BookStoreNetworkingKit) y la carga de portadas usa AsyncImage nativo de SwiftUI.
# SwiftLint queda como único pod, para mantener el linter fuera del código de la app.
target 'BookStore' do
  project 'BookStore.xcodeproj'
  pod 'SwiftLint'
end
