const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zig-tree-sitter", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "zig-tree-sitter",
        .target = target,
        .optimize = optimize,
    });
    linkTreeSitter(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    linkTreeSitter(main_tests);
    main_tests.addCSourceFiles(&[_][]const u8{
        "src/json_parser.c",
        "src/typescript_parser.c",
        "src/typescript_scanner.c",
        "src/typescript_scanner.h",
    }, &.{});
    const run_main_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}

fn linkTreeSitter(step: *std.build.Step.Compile) void {
    step.linkLibC();
    step.addCSourceFile("upstream/lib/src/lib.c", &.{});
    step.addIncludePath("upstream/lib/src");
    step.addIncludePath("upstream/lib/include");
}
