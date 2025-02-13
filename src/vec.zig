const m = @import("std").math;

pub fn Vec(comptime len: usize, T: type) type {
    return struct {
        const V = @Vector(len, T);

        pub fn fill(s: T) V {
            return @as(@Vector(len, T), @splat(s));
        }

        pub fn lerp(from: V, to: V, t: T) V {
            const s = fill(m.clamp(t, 0, 1));
            const v = to - from;
            return from + s * v;
        }

        pub fn scale(v: V, s: T) V {
            return v * fill(s);
        }

        pub fn normalize(a: V) V {
            const n = norm(a);

            if (n < m.floatEps(T)) {
                return fill(0);
            }

            return scale(a, 1.0 / n);
        }

        pub fn rotate(v: V, angle: T, axis: V) V {
            if (len == 3) {
                const c = m.cos(angle);
                const s = m.sin(angle);

                const k = normalize(axis);

                var v2 = scale(cross(k, v), s);
                const v1 = scale(v, c) + v2;

                v2 = scale(k, dot(k, v) * (1 - c));
                return v1 + v2;
            }
            if (len == 2) {
                const c = m.cos(angle);
                const s = m.sin(angle);

                const x1 = v[0];
                const y1 = v[1];

                return V{
                    c * x1 - s * y1,
                    s * x1 + c * y1,
                };
            }
        }

        pub fn cross(a: V, b: V) if (len == 2) T else if (len >= 3) V {
            if (len == 2) {
                return a[0] * b[1] - a[1] * b[0];
            }

            var ret: V = undefined;
            ret[0] = a[1] * b[2] - a[2] * b[1];
            ret[1] = a[2] * b[0] - a[0] * b[2];
            ret[2] = a[0] * b[1] - a[1] * b[0];
            return ret;
        }

        pub fn distance(a: V, b: V) T {
            return m.sqrt(distance2(a, b));
        }

        pub fn distance2(a: V, b: V) T {
            const diff = b - a;
            return @reduce(.Add, diff * diff);
        }

        pub fn norm(a: V) T {
            return m.sqrt(norm2(a));
        }

        pub fn norm2(a: V) T {
            return dot(a, a);
        }

        pub fn dot(a: V, b: V) T {
            return @reduce(.Add, a * b);
        }

        pub fn lt(a: V, b: V) bool {
            return @reduce(.And, a < b);
        }

        pub fn eq(a: V, b: V) bool {
            return @reduce(.And, a == b);
        }

        pub fn approxEq(v: V, w: V, tol: T) bool {
            var i: usize = 0;
            while (i < len) : (i += 1) {
                if (@abs(v[i] - w[i]) > tol) return false;
            }
            return true;
        }

        pub fn eqEps(a: V, b: V) bool {
            return @reduce(.And, @abs(a - b) <= @as(V, fill(m.floatEps(T))));
        }
    };
}

pub const vec2 = Vec(2, f32);
pub const Vec2 = @Vector(2, f32);

pub const vec3 = Vec(3, f32);
pub const Vec3 = @Vector(3, f32);

pub const vec4 = Vec(4, f32);
pub const Vec4 = @Vector(4, f32);

pub const Uvec2 = @Vector(2, usize);
pub const uvec2 = Vec(2, usize);

pub fn quatMul(p: Vec4, q: Vec4) Vec4 {
    return Vec4{
        p[3] * q[0] + p[0] * q[3] + p[1] * q[2] - p[2] * q[1],
        p[3] * q[1] - p[0] * q[2] + p[1] * q[3] + p[2] * q[0],
        p[3] * q[2] + p[0] * q[1] - p[1] * q[0] + p[2] * q[3],
        p[3] * q[3] - p[0] * q[0] - p[1] * q[1] - p[2] * q[2],
    };
}

pub fn quatv(angle: f32, axis: Vec3) Vec4 {
    const a = angle * 0.5;
    const c = m.cos(a);
    const s = m.sin(a);

    const k = vec3.normalize(axis);

    return Vec4{
        s * k[0],
        s * k[1],
        s * k[2],
        c,
    };
}

pub fn eulerXYZQuatRH(angles: Vec3) Vec4 {
    const xs = m.sin(angles[0] * 0.5);
    const xc = m.cos(angles[0] * 0.5);
    const ys = m.sin(angles[1] * 0.5);
    const yc = m.cos(angles[1] * 0.5);
    const zs = m.sin(angles[2] * 0.5);
    const zc = m.cos(angles[2] * 0.5);

    return Vec4{
        xc * ys * zs + xs * yc * zc,
        xc * ys * zc - xs * yc * zs,
        xc * yc * zs + xs * ys * zc,
        xc * yc * zc - xs * ys * zs,
    };
}
