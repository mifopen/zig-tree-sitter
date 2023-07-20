const std = @import("std");
const c = @import("c.zig");
const Node = @import("Node.zig");

const TreeCursor = @This();

handle: *c.TSTreeCursor,

pub inline fn from(handle: *c.TSTreeCursor) TreeCursor {
    return TreeCursor{ .handle = handle };
}

pub inline fn getCurrentNode(self: TreeCursor) Node {
    return Node.from(c.ts_tree_cursor_current_node(self.handle));
}

pub inline fn getCurrentFieldName(self: TreeCursor) ?[]const u8 {
    const a = c.ts_tree_cursor_current_field_name(self.handle);
    if (a == null) {
        return null;
    }
    return std.mem.sliceTo(a, 0);
}

pub inline fn getCurrentFieldId(self: TreeCursor) u16 {
    return c.ts_tree_cursor_current_field_id(self.handle);
}

pub inline fn gotoParent(self: TreeCursor) bool {
    return c.ts_tree_cursor_goto_parent(self.handle);
}

pub inline fn gotoFirstChild(self: TreeCursor) bool {
    return c.ts_tree_cursor_goto_first_child(self.handle);
}

pub inline fn gotoNextSibling(self: TreeCursor) bool {
    return c.ts_tree_cursor_goto_next_sibling(self.handle);
}
