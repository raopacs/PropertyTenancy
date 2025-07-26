import SwiftUI

@available(iOS 17.0, *)
public struct Collapsible<Content: View>: View {
    let title: String
    let content: Content
    @State private var isExpanded: Bool = false
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header - always visible
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content - expandable/collapsible
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.horizontal)
                    
                    content
                        .padding()
                        .background(Color(.systemBackground))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack(spacing: 20) {
        Collapsible(title: "Personal Information") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Name: John Doe")
                Text("Email: john@example.com")
                Text("Phone: +1 234 567 8900")
            }
        }
        
        Collapsible(title: "Address Details") {
            Address()
        }
        
        Collapsible(title: "Additional Notes") {
            Text("This is a sample note that can contain any content including other components.")
                .foregroundColor(.secondary)
        }
    }
    .padding()
} 
