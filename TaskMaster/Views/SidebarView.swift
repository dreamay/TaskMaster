import SwiftUI
import AppKit

struct SidebarView: View {
    @Binding var selectedNav: NavigationItem
    var unreadCount: Int
    var onSettings: () -> Void
    var onHelp: () -> Void
    
    @State private var hoveredNav: NavigationItem?
    @State private var showContextMenu = false
    @State private var contextMenuItem: NavigationItem?
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Items
            VStack(spacing: 2) {
                ForEach(NavigationItem.allCases) { item in
                    SidebarNavItem(
                        item: item,
                        isSelected: selectedNav == item,
                        unreadCount: item == .inbox ? unreadCount : 0,
                        isHovered: hoveredNav == item
                    )
                    .onTapGesture {
                        selectedNav = item
                    }
                    .onHover { hovering in
                        hoveredNav = hovering ? item : nil
                    }
                    .contextMenu {
                        if item == .lists || item == .tags {
                            Button("新建") {
                                // Handle new
                            }
                            Button("重命名") {
                                // Handle rename
                            }
                            Button("删除") {
                                // Handle delete
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            
            Spacer()
            
            // Bottom Toolbar
            HStack {
                Button(action: onSettings) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help("设置")
                
                Spacer()
                
                Button(action: onHelp) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 16))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help("帮助")
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
    }
}

struct SidebarNavItem: View {
    let item: NavigationItem
    let isSelected: Bool
    let unreadCount: Int
    let isHovered: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 15, weight: .medium))
                .frame(width: 20, height: 20)
            
            Text(item.rawValue)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            
            Spacer()
            
            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 18, minHeight: 18)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
        )
        .contentShape(Rectangle())
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor
        } else if isHovered {
            return Color.primary.opacity(0.08)
        }
        return Color.clear
    }
}
