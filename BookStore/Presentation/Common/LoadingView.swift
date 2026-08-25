import SwiftUI

struct LoadingView: View {
    var message: String = "Cargando..."

    var body: some View {
        ProgressView(message)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
