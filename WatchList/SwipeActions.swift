
import SwiftUI

struct SwipeActions: View {
    var episode: Episode

    var body: some View {
        HStack {
            Button(action: {
            }) {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(.white)
            }
            .tint(.red)
            

            Button(action: {
            }) {
                Label("Edit", systemImage: "pencil")
                    .foregroundColor(.white)
            }
            .tint(.blue)
        }
    }
}

