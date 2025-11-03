//
//  ContentView.swift
//  DatePickerDemo
//
//  Created by Douglas Jasper on 2025-10-29.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    // --- DatePicker state ---
    @State private var selectedDate = Date()
    
    // --- Season Picker state ---
    @State private var selectedSeason = "Spring"
    private let seasons = ["Spring", "Summer", "Autumn", "Winter"]
    
    // --- Slider state ---
    @State private var age: Double = 25
    
    // --- Background color toggle ---
    @State private var isYellowBackground = false
    
    // --- Alert for confirmation ---
    @State private var showingAlert = false
    
    // Date formatter
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
                    
                    // --- Background Toggle Card ---
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
                    
                    // --- Date Picker Card ---
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
                    
                    // --- Season Picker Card ---
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
                    
                    // --- Age Slider Card ---
                    CardView(title: "Select Your Age") {
                        Slider(value: $age, in: 1...100, step: 1)
                            .tint(.purple)
                            .padding(.horizontal)
                        
                        Text("Age: \(Int(age)) years old")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile Preferences")
            .background(isYellowBackground ? Color.yellow.opacity(0.3) : Color(.systemGroupedBackground))
            .animation(.easeInOut(duration: 0.3), value: isYellowBackground)
            .alert("Notification Scheduled", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("A notification has been scheduled for \(formattedDate).")
            }
            .onAppear {
                requestNotificationPermission()
            }
        }
    }
    
    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // MARK: - Schedule Notification
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Your scheduled event for \(formattedDate) is happening now!"
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(formattedDate)")
                showingAlert = true
            }
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
