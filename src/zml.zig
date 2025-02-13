const m = @import("std").math;

pub usingnamespace @import("transform.zig");
pub usingnamespace @import("camera.zig");
pub usingnamespace @import("vec.zig");
pub usingnamespace @import("matrix.zig");
pub usingnamespace @import("sdf.zig");
pub usingnamespace @import("shape.zig");

pub fn sqr(T: type, n: T) T {
    return n * n;
}

pub fn eqlEps(T: type, a: T, b: T) bool {
    return @abs(a - b) <= m.floatEps(T);
}
