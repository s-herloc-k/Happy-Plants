import SwiftUI

struct PlantInfo: View {
    
    @Binding var models: [Model]
    @Binding var index: Int
    
    let dayOfWeekString = ["mon".localized, "tue".localized, "wed".localized, "thu".localized, "fri".localized, "sat".localized, "sun".localized]
    
    var daysOfWeek: [String] {
        models[index].selectedDays.sorted().compactMap { day in
            guard day >= 1 && day <= dayOfWeekString.count else {
                return nil
            }
            return dayOfWeekString[day - 1]
        }
    }
    
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter
        }
    
    var dateFormatter2: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter
        }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 15){
                if models.indices.contains(index) {
                    Text("name".localized + ": \(models[index].flowerName)")
                    
                    Text("type".localized + ": \(models[index].name)")
                
                    if models[index].selectedDays.isEmpty {
                        Text("repeat-ed".localized)
                        
                    } else {
                        Text("repeat?".localized + ": \(daysOfWeek.joined(separator: ", "))")
                    }
                
                    Text("selected-time".localized + ": \(dateFormatter.string(from: models[index].selectedTime))")
                    
                    Text("date-added".localized + ": \(dateFormatter2.string(from: models[index].selectedTime))")
                }
            }
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(radius: 30)
            .padding(.horizontal, 30)
            .padding(.bottom, -70)
        }
    }
}
