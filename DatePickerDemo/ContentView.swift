
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    // MARK: - General States
    @State private var selectedDate = Date()
    @State private var selectedSeason = "Spring"
    private let seasons = ["Spring", "Summer", "Autumn", "Winter"]
    @State private var age: Double = 25
    @State private var isYellowBackground = false
    @State private var showingAlert = false
    
    // MARK: - Pizza Order States (simple multi-component)
    private let crusts = ["Thin", "Thick", "Stuffed"]
    private let sauces = ["Tomato", "Pesto", "BBQ"]
    private let toppings = ["Veggie", "Meatlovers", "Hawaiian", "Canadian"]
    
    @State private var selectedCrust = 0
    @State private var selectedSauce = 0
    @State private var selectedTopping = 0
    @State private var pizzaOrderSummary = ""
    
    // MARK: - Dependent Picker States
    private let pizzaCategories = ["Vegetarian", "Meat", "Specialty"]
    private let pizzaOptionsDict: [String: [String]] = [
        "Vegetarian": ["Margherita", "Veggie Delight", "Spinach & Feta"],
        "Meat": ["Meat Lovers", "Pepperoni", "BBQ Chicken"],
        "Specialty": ["Hawaiian", "Canadian", "Four Seasons"]
    ]
    
    @State private var selectedCategory = 0
    @State private var selectedOption = 0
    @State private var dependentOrderSummary = ""
    
    // MARK: - Long Press Gesture States
    @State private var longPressActive = false
    @State private var longPressDetected = false
    @State private var longPressMessage = ""
    
    // Date Formatter
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - Background Toggle Card
                    CardView(title: "Background Color") {
                        Toggle(isOn: $isYellowBackground) {
                            Text("Yellow Background")
                                .font(.headline)
                        }
                        .tint(.yellow)
                        
                        Text(isYellowBackground ? "Background: Yellow" : "Background: Default")
                            .foregroundColor(isYellowBackground ? .orange : .gray)
                            .font(.subheadline)
                    }
                    
                    // MARK: - DatePicker Card
                    CardView(title: "Select a Date") {
                        DatePicker("Pick a date:", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding(.top, 5)
                        
                        Text("Selected Date:")
                            .font(.headline)
                        Text(formattedDate)
                            .foregroundColor(.blue)
                        
                        Button(action: scheduleNotification) {
                            Label("Schedule Notification", systemImage: "bell.badge")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    
                    // MARK: - Season Picker Card
                    CardView(title: "Favorite Season") {
                        Picker("Favorite Season", selection: $selectedSeason) {
                            ForEach(seasons, id: \.self) { season in
                                Text(season)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 160)
                        .clipped()
                        
                        Text("You selected:")
                            .font(.headline)
                        Text(selectedSeason)
                            .foregroundColor(.green)
                    }
                    
                    // MARK: - Age Slider Card
                    CardView(title: "Select Your Age") {
                        Slider(value: $age, in: 1...100, step: 1)
                            .tint(.purple)
                            .padding(.horizontal)
                        
                        Text("Age: \(Int(age)) years old")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    
                    // MARK: - Pizza Order Card (Simple Multi-Component Picker)
                    CardView(title: "Pizza Order") {
                        Text("Choose your pizza:")
                            .font(.headline)
                        
                        HStack(spacing: 0) {
                            Picker("Crust", selection: $selectedCrust) {
                                ForEach(0..<crusts.count, id: \.self) { index in
                                    Text(crusts[index]).tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                            .clipped()
                            
                            Picker("Sauce", selection: $selectedSauce) {
                                ForEach(0..<sauces.count, id: \.self) { index in
                                    Text(sauces[index]).tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                            .clipped()
                            
                            Picker("Topping", selection: $selectedTopping) {
                                ForEach(0..<toppings.count, id: \.self) { index in
                                    Text(toppings[index]).tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                            .clipped()
                        }
                        .frame(height: 120)
                        
                        Button(action: placePizzaOrder) {
                            Text("Place Pizza Order")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                        
                        if !pizzaOrderSummary.isEmpty {
                            Text(pizzaOrderSummary)
                                .font(.headline)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }
                    
                    // MARK: - Dependent Pizza Picker Card
                    CardView(title: "Dependent Pizza Picker") {
                        Text("Select a category and pizza option")
                            .font(.headline)
                        
                        HStack(spacing: 0) {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(0..<pizzaCategories.count, id: \.self) { index in
                                    Text(pizzaCategories[index]).tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                            .clipped()
                            .onChange(of: selectedCategory) { _ in
                                selectedOption = 0 // reset dependent picker
                            }
                            
                            Picker("Option", selection: $selectedOption) {
                                ForEach(0..<(pizzaOptionsDict[pizzaCategories[selectedCategory]]?.count ?? 0), id: \.self) { index in
                                    Text(pizzaOptionsDict[pizzaCategories[selectedCategory]]![index])
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity, maxHeight: 120)
                            .clipped()
                        }
                        .frame(height: 120)
                        
                        Button(action: placeDependentOrder) {
                            Text("Place Dependent Order")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                        
                        if !dependentOrderSummary.isEmpty {
                            Text(dependentOrderSummary)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.green)
                                .padding(.top, 5)
                        }
                    }
                    
                    // MARK: - Long Press Gesture Card
                    CardView(title: "Long Press Gesture") {
                        Text(longPressMessage.isEmpty ? "Long press the box below" : longPressMessage)
                            .font(.headline)
                            .foregroundColor(.purple)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        Rectangle()
                            .fill(longPressActive ? Color.orange : Color.gray.opacity(0.5))
                            .frame(height: 100)
                            .cornerRadius(12)
                            .overlay(
                                Text("Hold me")
                                    .foregroundColor(.white)
                                    .bold()
                            )
                            .onLongPressGesture(minimumDuration: 1.0, pressing: { pressing in
                                if pressing {
                                    if !longPressDetected {
                                        longPressActive = true
                                        longPressMessage = "Pressing..."
                                    }
                                } else {
                                    // User released finger
                                    longPressActive = false
                                    longPressDetected = false
                                    longPressMessage = ""
                                }
                            }, perform: {
                                // Long press threshold reached
                                longPressDetected = true
                                longPressMessage = "Long press detected!"
                            })
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile Preferences")
            .background(isYellowBackground ? Color.yellow.opacity(0.3) : Color(.systemGroupedBackground))
            .animation(.easeInOut(duration: 0.3), value: isYellowBackground)
            .alert("Notification Scheduled", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A notification has been scheduled for \(formattedDate).")
            }
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
    
    // MARK: - Functions
    private func placePizzaOrder() {
        let crust = crusts[selectedCrust]
        let sauce = sauces[selectedSauce]
        let topping = toppings[selectedTopping]
        pizzaOrderSummary = "You ordered a \(crust) crust pizza with \(sauce) sauce and \(topping) toppings."
    }
    
    private func placeDependentOrder() {
        let category = pizzaCategories[selectedCategory]
        let option = pizzaOptionsDict[category]![selectedOption]
        dependentOrderSummary = "You selected a \(option) pizza from the \(category) category."
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error { print("Permission error: \(error.localizedDescription)") }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Your scheduled event for \(formattedDate) is happening now!"
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil { showingAlert = true }
        }
    }
}

// MARK: - Card View Component
struct CardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title3)
                .bold()
                .padding(.bottom, 5)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.15), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
}
