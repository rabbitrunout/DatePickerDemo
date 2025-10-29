import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()  // Holds the date from DatePicker

    // Date formatter for displaying nicely
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        VStack(spacing: 30) {
            Text("Select a Date")
                .font(.title)
                .bold()
            
            // DatePicker
            DatePicker("Pick a date:", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical) // Modern graphical style in iOS 18
                .padding()
            
            // Label displaying selected date
            Text("Selected Date: \(formattedDate)")
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
