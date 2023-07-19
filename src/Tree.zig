const c = @import("c.zig");
const Node = @import("Node.zig");

const Tree = @This();

handle: *c.TSTree,

pub inline fn from(handle: *c.TSTree) Tree {
    return Tree{ .handle = handle };
}

pub inline fn getRoot(self: Tree) Node {
    return Node.from(c.ts_tree_root_node(self.handle));
}

pub inline fn delete(self: Tree) void {
    c.ts_tree_delete(self.handle);
}
