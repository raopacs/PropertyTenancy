import SwiftUI

@available(iOS 17.0, *)
public struct CollapsibleView<Content: View>: View {
    let title: String
    let content: Content
    let headerActions: AnyView?
    @State private var isExpanded: Bool = false
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.headerActions = nil
    }

    public init<HeaderActions: View>(title: String,
                                     @ViewBuilder actions: () -> HeaderActions,
                                     @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.headerActions = AnyView(actions())
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header - always visible
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                if let headerActions {
                    headerActions
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
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
        CollapsibleView(title: "Personal Information") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Name: John Doe")
                Text("Email: john@example.com")
                Text("Phone: +1 234 567 8900")
            }
        }
        
        CollapsibleView(title: "Address Details") {
        }
        
        CollapsibleView(title: "Additional Notes") {
            Text("This is a sample note that can contain any content including other components.")
                .foregroundColor(.secondary)
        }
    }
    .padding()
} 
