const std = @import("std");
const JsonConfig = @import("mcuzig-type/JsonConfig.zig");
const project_build = @import("root.zig");
const project_src = @import("src.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var args = std.process.argsWithAllocator(allocator) catch |err| return err;
    defer args.deinit();

    _ = args.next(); // skip application name
    // Note memory will be freed on exit since using arena

    const config_name = "examples\\stm32f103.json";
    const svd_name = "examples\\STM32F103.svd";
    const dir_name = "zig-cache\\tmp";

    const svdfile = try std.fs.cwd().openFile(svd_name, .{});
    defer svdfile.close();
    const cfgjson = try std.fs.cwd().readFileAlloc(allocator, config_name, std.math.maxInt(usize));
    defer allocator.free(cfgjson);

    var project_root_dir = try std.fs.cwd().openDir(dir_name, .{});
    defer project_root_dir.close();

    project_root_dir.makeDir("src") catch {};

    var project_src_dir = try project_root_dir.openDir("src", .{});
    defer project_src_dir.close();

    const cfg_parsed = try std.json.parseFromSlice(JsonConfig, allocator, cfgjson, .{});
    defer cfg_parsed.deinit();
    const cfg = cfg_parsed.value;

    try project_build.generate(project_root_dir, cfg.target);
    try project_src.generate(allocator, project_src_dir, cfg.memory, svdfile.reader());
}
