const std = @import("std");

pub fn build(b: *std.Build) !void {
    var info = BuildInfo{
        .kind = .exe,
        .target = b.standardTargetOptions(.{}),
        .bin_name = "zml",
        .optimize = b.standardOptimizeOption(.{}),
        .src_path = "src/main.zig",
        .module = b.addModule("zml", .{ .root_source_file = b.path("src/zml.zig") }),
        .dependencies = @constCast(&[_][]const u8{"zut"}),
    };
    const exe = addBuildOption(b, info, null);
    b.installArtifact(exe);

    const check = addBuildOption(b, info, null);
    const check_step = b.step("check", "Build for LSP Diagnostics");
    check_step.dependOn(&check.step);

    info.kind = .tests;
    const test_step = b.step("test", "Run tests");
    for ([_][]const u8{
        "tests/matrix.zig",
        "tests/vec.zig",
        "tests/transform.zig",
        "tests/camera.zig",
    }) |name| {
        info.src_path = name;
        const tests = addBuildOption(b, info, null);
        const test_run = b.addRunArtifact(tests);
        test_step.dependOn(&test_run.step);
        check_step.dependOn(&tests.step);
    }
}

const BuildInfo = struct {
    kind: enum { tests, exe },
    target: std.Build.ResolvedTarget,
    bin_name: []const u8,
    src_path: []const u8,
    optimize: std.builtin.OptimizeMode,
    module: *std.Build.Module,
    dependencies: [][]const u8,
};

const StepInfo = struct {
    name: []const u8,
    desc: []const u8,
};

fn addBuildOption(
    b: *std.Build,
    info: BuildInfo,
    step: ?StepInfo,
) *std.Build.Step.Compile {
    var name_buf: [256]u8 = undefined;
    const bin_postfix = switch (info.optimize) {
        .Debug => "-dbg",
        .ReleaseFast => "",
        .ReleaseSafe => "-s",
        .ReleaseSmall => "-sm",
    };

    const bin = switch (info.kind) {
        .exe => b.addExecutable(.{
            .name = std.fmt.bufPrint(@constCast(&name_buf), "{s}{s}", .{ info.bin_name, bin_postfix }) catch unreachable,
            .root_source_file = b.path(info.src_path),
            .target = info.target,
            .optimize = info.optimize,
        }),
        .tests => b.addTest(.{
            .root_source_file = b.path(info.src_path),
            .target = info.target,
            .optimize = info.optimize,
        }),
    };

    for (info.dependencies) |name| {
        const dep = b.dependency(name, .{ .target = info.target, .optimize = info.optimize });
        bin.root_module.addImport(name, dep.module(name));
        info.module.addImport(name, dep.module(name));
    }

    bin.root_module.addImport("zml", info.module);

    if (step) |s| {
        const install_step = b.step(s.name, s.desc);
        switch (info.kind) {
            .exe => install_step.dependOn(&b.addInstallArtifact(bin, .{}).step),
            .tests => {
                const exe_tests = b.addRunArtifact(bin);
                install_step.dependOn(&exe_tests.step);
            },
        }
    }

    return bin;
}
