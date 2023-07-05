const c = @import("c.zig").c;
const Tree = @import("Tree.zig");

const Parser = @This();

handle: *c.TSParser,

pub inline fn new() Parser {
    return Parser{ .handle = c.ts_parser_new().? };
}

pub inline fn setLanguage(self: Parser, language: *anyopaque) bool {
    return c.ts_parser_set_language(
        self.handle,
        @as(*c.TSLanguage, @ptrCast(@alignCast(language))),
    );
}

pub inline fn parseString(self: Parser, string: []const u8) Tree {
    return Tree.from(c.ts_parser_parse_string(
        self.handle,
        null,
        string.ptr,
        string.len,
    ).?);
}

pub inline fn delete(self: Parser) void {
    c.ts_parser_delete(self.handle);
}
