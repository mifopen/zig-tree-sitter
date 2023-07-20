const std = @import("std");
const c = @import("c.zig");
const TreeCursor = @import("TreeCursor.zig");

const Node = @This();

handle: c.TSNode,

pub inline fn from(handle: c.TSNode) Node {
    return Node{ .handle = handle };
}

pub inline fn getNamedChild(self: Node, n: u32) Node {
    return from(c.ts_node_named_child(self.handle, n));
}

pub inline fn getNamedChildCount(self: Node) u32 {
    return c.ts_node_named_child_count(self.handle);
}

pub inline fn getType(self: Node) [:0]const u8 {
    return std.mem.span(c.ts_node_type(self.handle));
}

pub inline fn getChildCount(self: Node) u32 {
    return c.ts_node_child_count(self.handle);
}

pub inline fn getString(self: Node) [:0]const u8 {
    return std.mem.span(c.ts_node_string(self.handle));
}

pub inline fn getCursor(self: Node) TreeCursor {
    return TreeCursor.from(c.ts_tree_cursor_new(self.handle));
}
