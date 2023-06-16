import SwiftUI

struct EditView : View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var models: [Model]
    @Binding var index: Int
    
    @State private var nameText: String = ""
    @State private var flower: String = ""
    @State private var showTime = false
    @State private var repeatsDaily = true
    @State private var repeatsDays = false
    @State private var selectedTime = Date()
    @State private var selectedDays: [Int] = []
    
    let dayOfWeekString = ["monday".localized, "tuesday".localized, "wednesday".localized, "thursday".localized, "friday".localized, "saturday".localized, "sunday".localized]
    var model: Model
    
    var body: some View {
        
        VStack(spacing: 20) {

            Text("Change plant")
                .multilineTextAlignment(.center)
                .font(.custom("Add Plants", size: 25))
                .lineSpacing(4)
                .foregroundColor(colorScheme == .light ? .black : .white)
                .onAppear {
                    self.nameText = model.flowerName
                    self.flower = model.name
                }
            
            TextField("", text: $nameText)
                .padding()
                .font(.custom("Font", size: 20))
                .frame(width: 330)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .light ? .gray : .white, lineWidth: 1)
                )
                .padding(.top, 5)
            
            TextField("", text: $flower)
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
                self.selectedTime = model.selectedTime
                self.selectedDays = model.selectedDays
            }) {
                Image(systemName: "hourglass")
                    .resizable()
                    .frame(width: 50, height: 70)
          }
            .sheet(isPresented: $showTime) {
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    
                    Toggle("repeat-daily".localized, isOn: model.selectedDays.isEmpty ? $repeatsDaily : $repeatsDays)
                        .padding()
                    
                    if(!model.selectedDays.isEmpty) {
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
    }
    
    private func saveData() {
        guard let index = models.firstIndex(where: { $0.id == model.id }) else {
            return
        }
        
        models[index].flowerName = nameText
        models[index].name = flower
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

struct PlantsView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State var showCard = false
    @State var bootomState = CGSize.zero
    @State var showFull = false
    
    @Binding var models: [Model]
    @Binding var index: Int
    
    var body: some View {
        
        NavigationView {
            ZStack {
                PlantsTitleView()
                List {
                    ForEach(models, id: \.flowerName) { model in
                            NavigationLink(destination: EditView(models: $models, index: $index, model: model)) {
                            Text(model.flowerName)
                        }
                        .padding(8)
                        .listRowBackground(colorScheme == .light ? Color.yellow : Color.blue)
                    }
                    .onDelete { indices in
                        deleteModel(at: indices)
                        saveModelsToUserDefaults()
                    }
                }
                .foregroundColor(colorScheme == .light ? .black : .white)
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(colorScheme == .light ? .white : .black)
                .padding(.top, 100)
            }

        }.onAppear() {
            loadData()
        }
    }
    
    func deleteModel(at: IndexSet) {
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
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedFlowers") {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([Model].self, from: savedData) {
                models = decodedData
            }
        }
    }
}

struct PlantsTitleView: View {
    var body: some View {
        VStack {
            HStack {
                Text("your-plants".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            Spacer()
        }
    }
}
