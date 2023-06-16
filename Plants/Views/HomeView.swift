import SwiftUI
import SceneKit
import UserNotifications

struct HomeView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var bootomState = CGSize.zero
    @State var showCard = false
    @State var showFull = false
    @State var tapped = false
    @State var showInfo = false
    
    @Binding var index: Int
    @Binding var select: Bool
    @Binding var models: [Model]
    
    let col = Color(#colorLiteral(red: 0.7608050108, green: 0.8164883852, blue: 0.9259157777, alpha: 1))
    let coll = Color(#colorLiteral(red: 0.8278793693, green: 0.8877033591, blue: 1, alpha: 1))
    
    var body: some View {
        ZStack {
            ZStack {
                
                HomeTitleView()
                    .onAppear {
                        loadData()
                        if select {
                            self.showCard = false
                            self.showFull = false
                            self.tapped = false
                            self.showInfo = false
                        }
                    }

                if models.isEmpty {
                    Button(action: {
                        self.showCard.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorScheme == .light ? .green : .white)
                    }
                } else {
                    
                    Button(action: {
                        self.showCard.toggle()
                    }) {
                        Text("add-plant".localized)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(width: 200, height: 60)
                            .background(
                                ZStack {
                                    col
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .foregroundColor(.white)
                                        .blur(radius: 4)
                                        .offset(x: -8, y: -8)
                                    
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(
                                            LinearGradient(gradient: Gradient(colors: [coll, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .padding(2)
                                        .blur(radius: 2)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: tapped ? Color.white : col, radius: 20, x: 20, y: 20)
                            .shadow(color: tapped ? col : Color.white, radius: 20, x: -20, y: -20)
                    }
                    .padding(.top, 590)
                    .scaleEffect(tapped ? 1.2 : 1)
                    .animation(.spring())
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                        self.tapped = isPressing
                    }) {
                        self.tapped = false
                    }
                    
                    FlowersCardView(models: $models, showInfo: $showInfo, index: $index)
                }
                
                SettingsView()
                    .opacity(showCard ? 0.4 : 1)
                    .offset(y: showCard ? -200 : 0)
                    .animation(
                        Animation
                            .default
                            .delay(0.1)
                    )
                
                BottomCardView(models: $models, showCard: $showCard, index: $index)
                    .offset(x: 0, y: showCard ? 0 : 1400)
                    .offset(y: bootomState.height)
                    .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
                    .gesture(DragGesture().onChanged { value in
                        self.bootomState = value.translation
                        if self.showFull {
                            self.bootomState.height += 0
                        }
                        if self.bootomState.height < 0 {
                            self.bootomState.height = 0
                        }
                    }
                        .onEnded { value in
                            if self.bootomState.height > 50 {
                                self.showCard = false
                            }
                            
                            if (self.bootomState.height < 0 && !self.showFull) || (self.bootomState.height < 250 && self.showFull){
                                self.bootomState.height = 0
                                self.showFull = true
                            } else {
                                self.bootomState = .zero
                                self.showFull = false
                            }
                        }
                    )
            }
            .offset(y: showInfo ? -320 : 0)
            .scaleEffect(showInfo ? 0.9 : 1)
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
        }
    }
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedFlowers") {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([Model].self, from: savedData) {
                models = decodedData
            }
        }
    }
}

struct BottomCardView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var models: [Model]
    @Binding var showCard: Bool
    @Binding var index: Int
    
    @State private var nameText: String = ""
    @State private var flower: String = ""
    @State private var showTime = false
    @State private var repeatsDaily = true
    @State private var selectedTime = Date()
    @State private var selectedDays: [Int] = []
    let dayOfWeekString = ["monday".localized, "tuesday".localized, "wednesday".localized, "thursday".localized, "friday".localized, "saturday".localized, "sunday".localized]
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(width: 40, height: 5)
                .cornerRadius(3)
                .opacity(0.7)
            Text("adding-plant".localized)
                .multilineTextAlignment(.center)
                .font(.custom("Add Plants", size: 25))
                .lineSpacing(4)
                .foregroundColor(colorScheme == .light ? .black : .white)
            
            TextField("plant-name".localized, text: $nameText)
                .padding()
                .font(.custom("Font", size: 20))
                .frame(width: 330)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .light ? .gray : .white, lineWidth: 1)
                )
                .padding(.top, 5)
            
            TextField("plant-type".localized, text: $flower)
                .padding()
                .font(.custom("Font", size: 20))
                .frame(width: 330)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .light ? .gray : .white, lineWidth: 1)
                )
                .padding(.top, 5)
            
            Spacer()
            
            Button(action: {
                self.showTime = true
            }) {
                Image(systemName: "hourglass")
                    .resizable()
                    .frame(width: 50, height: 70)
            }.sheet(isPresented: $showTime) {
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    
                    Toggle("repeat-daily".localized, isOn: $repeatsDaily)
                        .padding()
                    if(!repeatsDaily) {
                    
                        VStack {
                            ForEach(1...7, id: \.self) { day in
                                Button(action: {
                                    toggleDaySelection(day)
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 120, height: 40)
                                            .cornerRadius(8)
                                            .foregroundColor(selectedDays.contains(day) ? Color.blue : Color.gray)
                                        Text(dayOfWeekString[day - 1])
                                            .padding(10)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    
                    Button("set-notification".localized) {
                        self.showTime = false
                    }
                    .padding()
                    Spacer()
                }
            }
            
            Spacer()
            
            Button(action: {
                saveData()
                self.nameText = ""
                self.flower = ""
                self.showCard = false
            }) {
                ZStack {
                    Rectangle()
                        .frame(width: 150, height: 40)
                        .cornerRadius(10)
                    Text("save-plant".localized)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .frame(maxWidth: 370, maxHeight: 500)
        .background(colorScheme == .light ? .white : .blue)
        .cornerRadius(30)
        .shadow(radius: 20)
    }
    
    private func saveData() {
        let newFlower = Model(name: flower, modelName: "Plant.usdz", flowerName: nameText, selectedTime: selectedTime, selectedDays: selectedDays)
        models.append(newFlower)
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(models) {
            UserDefaults.standard.set(encodedData, forKey: "SavedFlowers")
        }
    }
    
    private func toggleDaySelection(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.removeAll(where: { $0 == day })
        } else {
            selectedDays.append(day)
        }
    }
}

struct HomeTitleView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Happy Plants")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            Spacer()
        }
    }
}

struct FlowersCardView: View {
    
    @Binding var models: [Model]
    @Binding var showInfo: Bool
    @Binding var index: Int
    
    @State var showingActionSheet = false
    
    
    var body: some View {
        
            VStack {
                SceneView(scene: getScene(), options: [.autoenablesDefaultLighting, .allowsCameraControl])
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    .onTapGesture {
                        self.showInfo.toggle()
                    }
                    .gesture(
                        LongPressGesture()
                            .onEnded { _ in
                                showingActionSheet = true
                            }
                    )
                    .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(title: Text("delete-plant?".localized), message: Text("u-sure?".localized), buttons: [.destructive(Text("delete".localized), action: {
                            deleteModel()
                        }), .cancel()])
                    }
                
                ZStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                if index > 0 {
                                    index -= 1
                                }
                            }
                        }, label:  {
                            Image(systemName: "arrowshape.left")
                                .font(.system(size: 40, weight: .bold))
                                .opacity(index == 0 ? 0.3 : 1)
                                .padding(.leading, 40)
                        })
                        .disabled(index == 0 ? true : false)
                        
                        Spacer(minLength: 0)
                        
                        Button(action: {
                            withAnimation {
                                if index < models.count {
                                    index += 1
                                }
                            }
                        }, label: {
                            Image(systemName: "arrowshape.right")
                                .font(.system(size: 40, weight: .bold))
                                .opacity(index == models.count - 1 ? 0.3 : 1)
                                .padding(.trailing, 40)
                        })
                        .disabled(index == models.count - 1 ? true : false)
                    }
                    ZStack {
                        Button(action: {
                            self.showInfo.toggle()
                        }) {
                            if models.indices.contains(index) {
                                Text(models[index].flowerName)
                                    .font(.system(size: 30, weight: .bold))
                                    .padding(.horizontal)
                                    .padding(.vertical, 30)
                            }
                        }
                    }
                }
                
            }
        
            Spacer()
            
            PlantInfo(models: $models, index: $index)
                .background(Color.black.opacity(0.001))
                .frame(height: 500)
                .offset(y: showInfo ? 350 : 600)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
                .onTapGesture {
                    self.showInfo.toggle()
                }
                
        
    }
    
    func getScene() -> SCNScene? {
        do {
            if models.indices.contains(index) {
                return try SCNScene(named: models[index].modelName)
            } else {
                return nil
            }
        } catch {
            print("Failed to load scene: \(error)")
            return nil
        }
    }
    
    func deleteModel() {
        models.remove(at: index)
        saveModelsToUserDefaults()
        if index >= models.count {
            index = models.count - 1
        }
    }
    
    func saveModelsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(models) {
            UserDefaults.standard.set(encodedData, forKey: "SavedFlowers")
        }
    }
}

struct Model: Codable, Equatable {
    static var nextID: Int = 0
    
    var id: Int
    var name: String
    var modelName: String
    var flowerName: String
    var selectedTime: Date
    var selectedDays: [Int]
    var notificationIdentifier: String?
    
    init(name: String, modelName: String, flowerName: String, selectedTime: Date, selectedDays: [Int]) {
        self.id = Model.nextID
        self.name = name
        self.modelName = modelName
        self.flowerName = flowerName
        self.selectedTime = selectedTime
        self.selectedDays = selectedDays
        Model.nextID += 1
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Happy Plants"
        notificationContent.body = "take-care \(flowerName)".localized
        notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Not.wav"))
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let notificationIdentifier = "Notification-\(id)"
        self.notificationIdentifier = notificationIdentifier
        
        let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { error in
            if let error = error {
                print("Не удалось добавить уведомление: \(error)")
            } else {
                print("Уведомление успешно добавлено")
            }
        }
    }
    
    mutating func deleteNotification() {
        if let notificationIdentifier = self.notificationIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
            self.notificationIdentifier = nil
        }
    }
}
