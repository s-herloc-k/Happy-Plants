import SwiftUI

enum Theme {
    static let primary = Color("Primary")
}

enum SchemeType: Int, Identifiable, CaseIterable {
    var id: Self {self}
    case system
    case light
    case dark
}

extension SchemeType {
    var title: String {
        switch self {
        case .system:
            return "system-theme".localized
        case .light:
            return "light-theme".localized
        case .dark:
            return "dark-theme".localized
        }
    }
}

struct SettingsView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State var showCard = false
    @State var bootomState = CGSize.zero
    @State var showFull = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        self.showCard.toggle()
                    }) {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                }
                .padding(.top, 20)
                .padding(.leading, 290)
                Spacer()
            }
            
            SettingsCardView(showCard: $showCard)
                .offset(x: 0, y: showCard ? 0 : 1200)
                .offset(y: bootomState.height)
                .animation(.timingCurve(0.4, 0.8, 0.2, 1, duration: 1))
        }
    }
}

struct SettingsCardView: View {
    
    @AppStorage("systemThemeVal") private var systemTheme: Int = SchemeType.allCases.first!.rawValue
    @Environment(\.colorScheme) private var colorScheme
    
    private var themeNow: String {colorScheme == .light ? "Light theme" : "Dark Theme"}
    private var selectedTheme: ColorScheme? {
        guard let theme = SchemeType(rawValue: systemTheme) else {return nil}
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return nil
        }
    }
    
    @Binding var showCard: Bool
    
    var body: some View {
        
        VStack {
            
            Text("settings-label".localized)
                .multilineTextAlignment(.center)
                .font(.custom("Settings", size: 25))
                .lineSpacing(4)
                .padding(.top, 10)
            
            Button(action: {
                self.showCard.toggle()
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .rotationEffect(.degrees(45))
                    .frame(width: 35, height: 35)
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
            .padding(.top, -42)
            .padding(.leading, 290)
            
            Section {
                Text("theme-label".localized)
                    .font(.custom("Theme", size: 20))
                Picker("Picker", selection: $systemTheme) {
                    ForEach(SchemeType.allCases) { item in
                        Text(item.title)
                            .tag(item.rawValue)
                    }
                } .pickerStyle(SegmentedPickerStyle())
            }
            Spacer()
            
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .frame(maxWidth: 370, maxHeight: 500)
        .background(colorScheme == .light ? .white : .blue)
        .cornerRadius(30)
        .shadow(radius: 20)
        .preferredColorScheme(selectedTheme)
        
    }
}
