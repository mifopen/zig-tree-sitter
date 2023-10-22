const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tree_sitter = b.dependency("tree_sitter", .{}).artifact("tree-sitter");

    _ = b.addModule("zig-tree-sitter", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "zig-tree-sitter",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(tree_sitter);
    lib.installLibraryHeaders(tree_sitter);
    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.linkLibrary(tree_sitter);
    tests.installLibraryHeaders(tree_sitter);
    tests.addCSourceFiles(.{
        .files = &[_][]const u8{
            "src/json_parser.c",
            "src/typescript_parser.c",
            "src/typescript_scanner.c",
        },
    });
    const run_main_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
