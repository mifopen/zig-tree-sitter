const std = @import("std");
const testing = std.testing;
const c = @import("c.zig").c;

test "getVersion" {
    try testing.expectEqual(14, c.TREE_SITTER_LANGUAGE_VERSION);
}
