import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State var SelectedView = 1
    @State var select = true
    @State var models: [Model] = []
    @State var index = 0
    
    var body: some View {
            TabView(selection: $SelectedView ) {
                PlantsView(models: $models, index: $index)
                    .tabItem {
                        Image(systemName: "leaf")
                            .renderingMode(.template)
                        Text("tabview-plants".localized)
                    }.tag(2)
                
                HomeView(index: $index, select: $select, models: $models)
                    .tabItem {
                        Image(systemName: "house.fill")
                            .renderingMode(.template)
                        Text("tabview-home".localized)
                    }.tag(1)
                
                DiaryView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("tabview-diary".localized)
                    }.tag(3)
                
            }
            .accentColor(colorScheme == .light ? .black : .white)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
