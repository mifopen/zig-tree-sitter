const std = @import("std");
const testing = std.testing;
const c = @import("c.zig");
const Parser = @import("Parser.zig");

// json parser copied from https://github.com/tree-sitter/tree-sitter-json/blob/40a81c01a40ac48744e0c8ccabbaba1920441199/src/parser.c
extern fn tree_sitter_json() *anyopaque;

// typescript parser copied from https://github.com/tree-sitter/tree-sitter-typescript/blob/3429d8c77d7a83e80032667f0642e6cb19d0c772/typescript/src/parser.c
extern fn tree_sitter_typescript() *anyopaque;

test "version" {
    try testing.expectEqual(14, c.TREE_SITTER_LANGUAGE_VERSION);
}

// https://tree-sitter.github.io/tree-sitter/using-parsers#an-example-program
test "an example program" {
    const parser = Parser.new();
    defer parser.delete();

    const language = tree_sitter_json();
    _ = parser.setLanguage(language);

    const source_code = "[1, null]";
    const tree = parser.parseString(source_code);
    defer tree.delete();

    const root_node = tree.getRoot();

    const array_node = root_node.getNamedChild(0);
    const number_node = array_node.getNamedChild(0);

    try testing.expectEqualStrings("document", root_node.getType());
    try testing.expectEqualStrings("array", array_node.getType());
    try testing.expectEqualStrings("number", number_node.getType());

    try testing.expectEqual(@as(u32, 1), root_node.getChildCount());
    try testing.expectEqual(@as(u32, 5), array_node.getChildCount());
    try testing.expectEqual(@as(u32, 2), array_node.getNamedChildCount());
    try testing.expectEqual(@as(u32, 0), number_node.getChildCount());

    const string = root_node.getString();
    defer std.heap.raw_c_allocator.free(string);

    try testing.expectEqualStrings("(document (array (number) (null)))", string);
}

test "typescript" {
    const parser = Parser.new();
    defer parser.delete();

    const language = tree_sitter_typescript();
    _ = parser.setLanguage(language);

    const source_code = "function foo(a: string): number {}";
    const tree = parser.parseString(source_code);
    defer tree.delete();

    const root_node = tree.getRoot();

    const string = root_node.getString();
    defer std.heap.raw_c_allocator.free(string);

    try testing.expectEqualStrings("(program (function_declaration name: (identifier) parameters: (formal_parameters (required_parameter pattern: (identifier) type: (type_annotation (predefined_type)))) return_type: (type_annotation (predefined_type)) body: (statement_block)))", string);
}

test "cursor" {
    const parser = Parser.new();
    defer parser.delete();

    const language = tree_sitter_typescript();
    _ = parser.setLanguage(language);

    const source_code = "var a = 1;";
    const tree = parser.parseString(source_code);
    defer tree.delete();

    const root_node = tree.getRoot();
    const cursor = root_node.getCursor();
    defer cursor.delete();

    try testing.expectEqualStrings("program", cursor.getCurrentNode().getType());
    try testing.expect(cursor.getCurrentFieldName() == null);
    try testing.expect(cursor.getCurrentFieldId() == 0);
    try testing.expect(!cursor.gotoParent());
    try testing.expect(!cursor.gotoNextSibling());
    try testing.expect(cursor.gotoFirstChild());
    try testing.expectEqualStrings("variable_declaration", cursor.getCurrentNode().getType());
    try testing.expect(cursor.gotoFirstChild());
    try testing.expectEqualStrings("var", cursor.getCurrentNode().getType());
}

test "positions" {
    const parser = Parser.new();
    defer parser.delete();

    const language = tree_sitter_typescript();
    _ = parser.setLanguage(language);

    const source_code = "var a = 1;";
    const tree = parser.parseString(source_code);
    defer tree.delete();

    const root_node = tree.getRoot();
    const cursor = root_node.getCursor();
    defer cursor.delete();

    _ = cursor.gotoFirstChild();
    _ = cursor.gotoFirstChild();
    _ = cursor.gotoNextSibling();
    _ = cursor.gotoFirstChild();

    const node = cursor.getCurrentNode();
    try testing.expectEqual(@as(u32, 4), node.getStartByte());
    try testing.expectEqual(@as(u32, 5), node.getEndByte());
    try testing.expectEqual(@as(u32, 0), node.getStartPoint().row);
    try testing.expectEqual(@as(u32, 4), node.getStartPoint().column);
    try testing.expectEqual(@as(u32, 0), node.getEndPoint().row);
    try testing.expectEqual(@as(u32, 5), node.getEndPoint().column);
}
