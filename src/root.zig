const std = @import("std");
const Dir = std.fs.Dir;

const build_part1 =
    \\
    \\const std = @import("std");
    \\
    \\// Although this function looks imperative, note that its job is to
    \\// declaratively construct a build graph that will be executed by an external
    \\// runner.
    \\pub fn build(b: *std.Build) void {
    \\    // Standard target options allows the person running `zig build` to choose
    \\    // what target to build for. Here we do not override the defaults, which
    \\    // means any target is allowed, and the default is native. Other options
    \\    // for restricting supported target set are available.
    \\
;

const build_part2 =
    \\
    \\    // Standard release options allow the person running `zig build` to select
    \\    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    \\    const optimize = b.standardOptimizeOption(.{});
    \\
    \\    const exe = b.addExecutable(.{
    \\        .name = "zig-stm32f1-blink.elf",
    \\        .root_source_file = .{ .path = "src/startup.zig" },
    \\        .optimize = optimize,
    \\        .target = target,
    \\    });
    \\
    \\    const vector = b.addObject(.{
    \\        .name = "vector",
    \\        .root_source_file = .{ .path = "src/vector.zig" },
    \\        .optimize = optimize,
    \\        .target = target,
    \\    });
    \\
    \\    exe.addObject(vector);
    \\
    \\    exe.setLinkerScriptPath(.{ .path = "src/l.ld" });
    \\
    \\    b.default_step.dependOn(&exe.step);
    \\
    \\    b.installArtifact(exe);
    \\}
    \\
;

pub fn generate(dir: Dir, target: []const u8) anyerror!void {
    var b = dir.createFile("build.zig", .{}) catch |err| return err;
    defer b.close();
    const br = b.writer();
    _ = try b.write(build_part1);
    try br.print("    const target = {s};", .{target});
    _ = try b.write(build_part2);
}
