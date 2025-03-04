const sokol = @import("sokol");
const sapp = sokol.app;
const sglue = sokol.glue;
const sg = sokol.gfx;
const slog = sokol.log;
const std = @import("std");
const net = @import("std").net;

const state = struct {
    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    var pip: sg.Pipeline = .{};
    var bind: sg.Bindings = .{};
    var pass_action: sg.PassAction = .{};
};

export fn init() void {
    sg.setup(.{ .environment = sglue.environment(), .logger = .{ .func = slog.func } });

    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 1, .g = 0, .b = 0, .a = 1 } };
}

export fn frame() void {
    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() !void {
    //const socket = net.Ip4Address{ .sa = std.posix.sockaddr.in{ .port = 5, .addr = 5 } };
    //_ = socket;
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 640,
        .height = 480,
        .icon = .{ .sokol_default = true },
        .window_title = "clear.zig",
        .logger = .{ .func = slog.func },
        .win32_console_attach = true,
    });
}
