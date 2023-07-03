const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-tree-sitter",
        .target = target,
        .optimize = optimize,
    });

    lib.addCSourceFile("upstream/lib/src/lib.c", &.{});
    lib.addIncludePath("upstream/lib/src");
    lib.addIncludePath("upstream/lib/include");

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.linkLibrary(lib);
    main_tests.addIncludePath("upstream/lib/src");
    main_tests.addIncludePath("upstream/lib/include");

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
