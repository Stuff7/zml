const std = @import("std");
const gm = @import("zml.zig");

const dbg = @import("zut").dbg;

const m = std.math;
const Allocator = std.mem.Allocator;
const Shape = @import("shape.zig").Shape;

pub const Sdf = struct {
    direction: gm.Vec2 = gm.Vec2{ 0, 0 },
    projection: gm.Vec2 = gm.Vec2{ 0, 0 },

    pub fn orthogonality(self: Sdf) f32 {
        return @abs(gm.vec2.cross(gm.vec2.normalize(self.direction), gm.vec2.normalize(self.projection)));
    }

    pub fn shapeDistance(self: *Sdf, shape: Shape, p: gm.Vec2) !f32 {
        var min_dist = m.floatMax(f32);

        var prev_sdf = Sdf{};
        var closest_segments: [16]usize = undefined;
        const n = shape.closestSegments(p, &closest_segments);
        for (closest_segments[0..n]) |i| {
            var dist = m.floatMax(f32);

            switch (shape.segments[i]) {
                .curve => |c| dist = self.quadBezierDistance(p, c.p0, c.p1, c.p2),
                .line => |c| dist = self.lineDistance(p, c.p0, c.p1),
            }

            if (gm.eqlEps(f32, @abs(dist), @abs(min_dist))) {
                const curr_ortho = self.orthogonality();
                const prev_ortho = prev_sdf.orthogonality();
                if (curr_ortho < prev_ortho) {
                    continue;
                }
                min_dist = dist;
                prev_sdf = self.*;
            } else if (@abs(dist) < @abs(min_dist)) {
                min_dist = dist;
                prev_sdf = self.*;
            }
        }

        return min_dist;
    }

    pub fn lineDistance(self: *Sdf, p: gm.Vec2, p0: gm.Vec2, p1: gm.Vec2) f32 {
        if (gm.vec2.eqEps(p0, p1)) {
            return m.floatMax(f32);
        }

        const v = p - p0;
        self.direction = p1 - p0;

        const t = m.clamp(gm.vec2.dot(v, self.direction) / gm.vec2.norm2(self.direction), 0, 1);

        const pline = gm.vec2.scale(self.direction, t) + p0;

        const distance = gm.vec2.distance(p, pline);
        const line = pline - p;

        const cross = gm.vec2.cross(self.direction, line) * gm.vec2.norm(line);

        self.projection = p - pline;

        return if (cross < 0) -distance else distance;
    }

    pub fn quadBezierDistance(self: *Sdf, p: gm.Vec2, p0: gm.Vec2, p1: gm.Vec2, p2: gm.Vec2) f32 {
        if (gm.vec2.eqEps(p0, p1) or gm.vec2.eqEps(p2, p1)) {
            return self.lineDistance(p, p0, p2);
        }
        const v = p - p0;
        const v1 = p1 - p0;

        const p1_scl2 = gm.vec2.scale(p1, 2);
        const v1_scl2 = gm.vec2.scale(v1, 2);
        const v2 = (p2 - p1_scl2) + p0;

        const const_dir = gm.vec2.scale((p2 - p1_scl2) + p0, 2);

        const a = gm.vec2.norm2(v2);
        const b = 3 * gm.vec2.dot(v1, v2);
        const c = 2 * gm.vec2.norm2(v1) - gm.vec2.dot(v2, v);
        var d = -gm.vec2.dot(v1, v);
        var roots: [3]f32 = undefined;
        const num_roots = solveCubic(a, b, c, d, &roots);

        var min_dist = m.floatMax(f32);
        var pbezier: gm.Vec2 = undefined;
        var min_p: gm.Vec2 = undefined;
        var min_t: f32 = 0;

        for (0..num_roots + 2) |i| {
            const t = if (i > 1) m.clamp(roots[i - 2], 0, 1) else @as(f32, @floatFromInt(i));
            if (i > 1 and (t == 0 or t == 1)) {
                continue;
            }

            pbezier = gm.vec2.scale(v2, gm.sqr(f32, t)) + gm.vec2.scale(v1_scl2, t) + p0;

            d = gm.vec2.distance(pbezier, p);
            if (d >= min_dist) {
                continue;
            }

            min_t = t;
            min_dist = d;
            min_p = pbezier;
        }

        self.direction = gm.vec2.scale(const_dir, min_t) + v1_scl2;
        self.projection = p - min_p;

        const vbezier = min_p - p;
        const sign = gm.vec2.cross(self.direction, vbezier) * gm.vec2.norm(vbezier);

        return if (sign < 0) -min_dist else min_dist;
    }

    pub fn quickLineDistance(p: gm.Vec2, p0: gm.Vec2, p1: gm.Vec2) f32 {
        const proj = p - p0;
        const dir = p1 - p0;

        const t = std.math.clamp(gm.vec2.dot(proj, dir) / gm.vec2.norm2(dir), 0, 1);
        const c = gm.vec2.scale(dir, t) + p0;

        return gm.vec2.distance2(p, c);
    }

    pub fn quickQuadBezierDistance(p: gm.Vec2, p0: gm.Vec2, p1: gm.Vec2, p2: gm.Vec2) f32 {
        const p1p0 = p1 - p0;
        const p1p0_2 = gm.vec2.scale(p1p0, 2);
        const p2p1 = p2 - p1;

        const a = gm.vec2.norm2(p2p1);
        if (a == 0) {
            return @min(gm.vec2.distance2(p, p0), gm.vec2.distance2(p, p2));
        }
        const b = gm.vec2.dot(p1p0_2, p2p1);
        const c = gm.vec2.norm2(p1p0);

        var disc = gm.sqr(f32, b) - 4 * a * c;
        if (disc < 0) {
            return quickLineDistance(p, p0, p2);
        }

        disc = @sqrt(disc);
        const t1 = m.clamp((-b + disc) / (2 * a), 0, 1);
        const t2 = m.clamp((-b - disc) / (2 * a), 0, 1);
        if ((t1 == 0 or t1 == 1) and (t2 == 0 or t2 == 1)) {
            return @min(gm.vec2.distance2(p, p0), gm.vec2.distance2(p, p2));
        }

        var min_dist = m.floatMax(f32);
        const bt2 = p2 - gm.vec2.scale(p1, 2) + p0;
        inline for ([2]f32{ t1, t2 }) |t| {
            if (t > 0 and t < 1) {
                const min_p = gm.vec2.scale(bt2, gm.sqr(f32, t)) + gm.vec2.scale(p1p0_2, t) + p0;
                const dist = gm.vec2.distance2(p, min_p);
                if (dist < min_dist) {
                    min_dist = dist;
                }
            }
        }

        return @min(gm.vec2.distance2(p, p0), gm.vec2.distance2(p, p2), min_dist);
    }
};

pub fn solveCubic(a: f32, b: f32, c: f32, d: f32, out: *[3]f32) usize {
    if (a == 0) {
        return 0;
    }

    const p = (3 * a * c - b * b) / (3 * a * a);
    const q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (27 * a * a * a);
    const shift = -b / (3 * a);
    const delta = (q * q) / 4 + (p * p * p) / 27;

    if (delta > 0) {
        const u = m.cbrt(-q / 2 + m.sqrt(delta));
        const v = m.cbrt(-q / 2 - m.sqrt(delta));
        out[0] = u + v + shift;
        return 1;
    }

    if (@abs(delta) < m.floatEps(f32)) {
        const u = m.cbrt(-q / 2);
        out[0] = 2 * u + shift;
        out[1] = -u + shift;
        return 2;
    }

    const r = m.sqrt(-p / 3);
    const phi = m.acos(-q / (2 * m.sqrt(-p * p * p / 27)));
    out[0] = 2 * r * m.cos(phi / 3) + shift;
    out[1] = 2 * r * m.cos((phi + 2 * m.pi) / 3) + shift;
    out[2] = 2 * r * m.cos((phi + 4 * m.pi) / 3) + shift;
    return 3;
}
