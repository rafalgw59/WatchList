
import SwiftUI

struct MovieSeriesCell: View {
    var title: String
    var releaseDate: Date
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .frame(height: 150)
            
            Text(title)
                .font(.headline)
                .padding(.top, 8)
            
            Text("Time Remaining: \(timeRemaining())")
                .font(.subheadline)
                .padding(.bottom, 8)
        }
        .padding(10)
    }
    
    private func timeRemaining() -> String {

        return "X days left"
    }
}

struct MovieSeriesCell_Previews: PreviewProvider {
    static var previews: some View {
        MovieSeriesCell(title: "Sample Movie", releaseDate: Date())
    }
}

