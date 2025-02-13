const m = @import("std").math;
const Vec2 = @import("zml.zig").Vec2;
const Sdf = @import("sdf.zig").Sdf;

pub const Shape = struct {
    segments: []Segment,
    contour_ends: []usize,

    pub fn closestSegments(self: Shape, p: Vec2, out_indices: []usize) usize {
        var len: usize = 0;
        var min_dist = m.floatMax(f32);
        for (self.segments, 0..) |segment, i| {
            const dist = switch (segment) {
                .line => |s| Sdf.quickLineDistance(p, s.p0, s.p1),
                .curve => |s| Sdf.quickQuadBezierDistance(p, s.p0, s.p1, s.p2),
            };

            if (dist <= min_dist) {
                if (dist == min_dist) {
                    len += 1;
                } else if (len > 0) {
                    len = 0;
                }
                min_dist = dist;
                out_indices[len] = i;
            }
        }

        return len + 1;
    }
};

pub const Segment = union(enum) {
    curve: struct { p0: Vec2, p1: Vec2, p2: Vec2 },
    line: struct { p0: Vec2, p1: Vec2 },

    pub fn init(points: []Vec2, curve_flags: []const bool, i: usize) ?Segment {
        if (!curve_flags[i]) {
            return null;
        }

        const j = if (i == points.len - 1) 0 else i + 1;
        if (!curve_flags[j]) {
            const k = if (j == points.len - 1) 0 else j + 1;
            return .{ .curve = .{ .p0 = points[i], .p1 = points[j], .p2 = points[k] } };
        }

        return .{ .line = .{ .p0 = points[i], .p1 = points[j] } };
    }

    pub fn count(curve_flags: []const bool) usize {
        var n: usize = 0;
        for (curve_flags) |on_curve| {
            if (on_curve) {
                n += 1;
            }
        }

        return n;
    }
};
