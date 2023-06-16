import SwiftUI

struct Note: Codable {
    var name: String
    var description: String
}

struct NoteDetailView: View {
    var note: Note
    
    var body: some View {
        VStack {
            Text(note.description)
                .font(.custom("Font1", size: 18))
        }
        .padding()
        .navigationTitle(note.name)
    }
}

struct DiaryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var showCard = false
    @State var bootomState = CGSize.zero
    @State var showFull = false
    @State private var notes: [Note] = []
 
    func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: "FlowerData") {
            do {
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                print("Ошибка при декодировании данных: \(error)")
            }
        }
    }
    
    func saveData() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: "FlowerData")
        } catch {
            print("Ошибка при кодировании данных: \(error)")
        }
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                DiaryTitleView()
                
                List {
                    ForEach(notes, id: \.name) { note in
                        NavigationLink(destination: NoteDetailView(note: note)) {
                            Text(note.name)
                        }
                        .padding(8)
                        .listRowBackground(colorScheme == .light ? Color.yellow : Color.blue)
                    }
                    .onDelete { indices in
                        notes.remove(atOffsets: indices)
                        saveData()
                    }
                }
                .foregroundColor(colorScheme == .light ? .black : .white)
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(colorScheme == .light ? .white : .black)
                .padding(.top, 100)
                
                Button(action: {
                    self.showCard.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
                .padding(.top, -335)
                .padding(.leading, 290)
                
                BottomDiaryCardView(notes: $notes, showCard: $showCard)
                    .offset(x: 0, y: showCard ? 0 : 1000)
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
            
        }.onAppear() {
            loadSavedData()
        }
        
    }
}

struct DiaryTitleView: View {
    var body: some View {
        VStack {
            HStack {
                Text("tabview-diary".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            Spacer()
        }
    }
}

struct BottomDiaryCardView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var notes: [Note]
    @Binding var showCard: Bool
    
    @State private var nameText: String = ""
    @State private var descriptionText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(width: 40, height: 5)
                .cornerRadius(3)
                .opacity(0.7)
            Text("addding-entry".localized)
                .font(.custom("Add Entry", size: 25))
                .foregroundColor(colorScheme == .light ? .black : .white)
            
            VStack {
                TextField("note-name".localized, text: $nameText)
                    .padding()
                    .font(.custom("Font", size: 20))
                    .frame(width: 330)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .light ? .gray : .white, lineWidth: 1)
                    )
                    .padding(.top, 5)
                
                TextEditor(text: $descriptionText)
                    .scrollContentBackground(.hidden)
                    .background(colorScheme == .light ? .white : .blue)
                    .padding()
                    .multilineTextAlignment(.leading)
                    .frame(width: 330, height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .light ? .gray : .white, lineWidth: 1)
                    )
                    .padding(.top, 5)
                    
                
                Button(action: {
                    saveButtonTapped()
                    self.showCard.toggle()
                }) {
                    Text("save-button".localized)
                        .padding()
                        .background(colorScheme == .light ? .black : .green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
            .onAppear {
                loadSavedData()
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .frame(maxWidth: 370, maxHeight: 500)
        .background(colorScheme == .light ? .white : .blue)
        .cornerRadius(30)
        .shadow(radius: 20)
    }
    
    func saveButtonTapped() {
        if !nameText.isEmpty && !descriptionText.isEmpty {
            let newNote = Note(name: nameText, description: descriptionText)
            notes.append(newNote)
            saveData()
            nameText = ""
            descriptionText = ""
        }
    }
    
    func saveData() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: "FlowerData")
        } catch {
            print("Ошибка при кодировании данных: \(error)")
        }
    }
    
    func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: "FlowerData") {
            do {
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                print("Ошибка при декодировании данных: \(error)")
            }
        }
    }
}
