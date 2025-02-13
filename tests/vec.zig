const std = @import("std");
const gm = @import("zml");

const expect = std.testing.expect;
const m = std.math;

test "vec fill" {
    const v2 = gm.vec2.fill(5.0);
    const expected2 = gm.Vec2{ 5.0, 5.0 };
    try expect(gm.vec2.approxEq(v2, expected2, 0.0001));

    const v3 = gm.vec3.fill(3.14);
    const expected3 = gm.Vec3{ 3.14, 3.14, 3.14 };
    try expect(gm.vec3.approxEq(v3, expected3, 0.0001));
}

test "vec lerp" {
    const from = gm.Vec3{ 1.0, 2.0, 3.0 };
    const to = gm.Vec3{ 11.0, 12.0, 13.0 };
    const result = gm.vec3.lerp(from, to, 0.5);
    const expected = gm.Vec3{ 6.0, 7.0, 8.0 };
    try expect(gm.vec3.approxEq(result, expected, 0.001));
}

test "vec scale" {
    const v = gm.Vec3{ 1.0, 2.0, 3.0 };
    const scaled = gm.vec3.scale(v, 3.0);
    const expected = gm.Vec3{ 3.0, 6.0, 9.0 };
    try expect(gm.vec3.approxEq(scaled, expected, 0.001));
}

test "vec normalize" {
    const v = gm.Vec3{ 3.0, 0.0, 0.0 };
    const normed = gm.vec3.normalize(v);
    const expected = gm.Vec3{ 1.0, 0.0, 0.0 };
    try expect(gm.vec3.approxEq(normed, expected, 0.001));

    const zero = gm.Vec3{ 0.0, 0.0, 0.0 };
    const normZero = gm.vec3.normalize(zero);
    const expectedZero = gm.Vec3{ 0.0, 0.0, 0.0 };
    try expect(gm.vec3.approxEq(normZero, expectedZero, 0.0001));
}

test "vec rotate 2D" {
    const v = gm.Vec2{ 1.0, 0.0 };
    const angle = m.pi / 2.0;
    // For 2D rotation, the 'axis' parameter is not used.
    const rotated = gm.vec2.rotate(v, angle, undefined);
    const expected = gm.Vec2{ 0.0, 1.0 };
    try expect(gm.vec2.approxEq(rotated, expected, 0.001));
}

test "vec rotate 3D" {
    const v = gm.Vec3{ 1.0, 0.0, 0.0 };
    const axis = gm.Vec3{ 0.0, 0.0, 1.0 };
    const angle = m.pi / 2.0;
    const rotated = gm.vec3.rotate(v, angle, axis);
    const expected = gm.Vec3{ 0.0, 1.0, 0.0 };
    try expect(gm.vec3.approxEq(rotated, expected, 0.001));
}

test "vec cross 2D" {
    const a = gm.Vec2{ 1.0, 2.0 };
    const b = gm.Vec2{ 3.0, 4.0 };
    const cross2 = gm.vec2.cross(a, b);
    const expected: f32 = 1.0 * 4.0 - 2.0 * 3.0; // -2
    try expect(@abs(cross2 - expected) < 0.001);
}

test "vec cross 3D" {
    const a = gm.Vec3{ 1.0, 0.0, 0.0 };
    const b = gm.Vec3{ 0.0, 1.0, 0.0 };
    const cross3 = gm.vec3.cross(a, b);
    const expected = gm.Vec3{ 0.0, 0.0, 1.0 };
    try expect(gm.vec3.approxEq(cross3, expected, 0.001));
}

test "vec distance and norm" {
    const a = gm.Vec3{ 1.0, 2.0, 3.0 };
    const b = gm.Vec3{ 4.0, 6.0, 3.0 };
    const dist2 = gm.vec3.distance2(a, b); // (3² + 4² + 0²) = 25
    try expect(@abs(dist2 - 25.0) < 0.001);
    const dist = gm.vec3.distance(a, b); // 5
    try expect(@abs(dist - 5.0) < 0.001);

    const v2 = gm.Vec2{ 3.0, 4.0 };
    const n2 = gm.vec2.norm2(v2); // 9 + 16 = 25
    try expect(@abs(n2 - 25.0) < 0.001);
    const n = gm.vec2.norm(v2); // 5
    try expect(@abs(n - 5.0) < 0.001);
}

test "vec dot product" {
    const a = gm.Vec3{ 1.0, 2.0, 3.0 };
    const b = gm.Vec3{ 4.0, -5.0, 6.0 };
    // dot = 1*4 + 2*(-5) + 3*6 = 12
    const dot = gm.vec3.dot(a, b);
    try expect(@abs(dot - 12.0) < 0.001);
}

test "vec lt and eq" {
    const a = gm.Vec3{ 1.0, 2.0, 3.0 };
    const b = gm.Vec3{ 2.0, 3.0, 4.0 };
    try expect(gm.vec3.lt(a, b));
    const c = gm.Vec3{ 1.0, 2.0, 2.0 };
    try expect(!gm.vec3.lt(a, c));

    const d = gm.Vec3{ 1.0, 2.0, 3.0 };
    try expect(gm.vec3.eq(a, d));
}

test "vec eqEps" {
    const a = gm.Vec3{ 1.0, 2.0, 3.0 };
    const b = gm.Vec3{ 1.0000001, 1.9999999, 3.0000001 };
    try expect(gm.vec3.eqEps(a, b));
}

test "quatMul identity" {
    const id = gm.Vec4{ 0, 0, 0, 1 };
    const q = gm.Vec4{ 0.3, 0.4, 0.5, 0.6 };
    const prod = gm.quatMul(id, q);
    try expect(@abs(prod[0] - q[0]) < 0.001);
    try expect(@abs(prod[1] - q[1]) < 0.001);
    try expect(@abs(prod[2] - q[2]) < 0.001);
    try expect(@abs(prod[3] - q[3]) < 0.001);
}

test "quatMul: 90° about Z squared" {
    // q represents a 90° rotation about Z: (0,0, sin(45°), cos(45°))
    const q: gm.Vec4 = gm.Vec4{ 0, 0, 0.70710678, 0.70710678 };
    const prod = gm.quatMul(q, q);
    // Expected: Two 90° rotations yield a 180° rotation about Z,
    // which is (0,0, ~1, 0) because sin(90°)=1 and cos(90°)=0.
    try expect(@abs(prod[0]) < 0.001);
    try expect(@abs(prod[1]) < 0.001);
    try expect(@abs(prod[2] - 1.0) < 0.001);
    try expect(@abs(prod[3]) < 0.001);
}

test "quatv produces correct quaternion" {
    // 90° rotation about Z axis.
    const q = gm.quatv(m.pi / 2.0, gm.Vec3{ 0, 0, 1 });
    // Expected: (0, 0, sin(45°), cos(45°)) ≈ (0,0,0.70710678, 0.70710678)
    try expect(@abs(q[0]) < 0.001);
    try expect(@abs(q[1]) < 0.001);
    try expect(@abs(q[2] - 0.70710678) < 0.001);
    try expect(@abs(q[3] - 0.70710678) < 0.001);
}

test "eulerXYZQuatRH identity" {
    const angles = gm.Vec3{ 0, 0, 0 };
    const q = gm.eulerXYZQuatRH(angles);
    const expected = gm.Vec4{ 0, 0, 0, 1 };
    try expect(gm.vec4.approxEq(q, expected, 0.001));
}

test "eulerXYZQuatRH: 90° rotation about X" {
    // For Euler angles (π/2, 0, 0), expected quaternion ~ (0.7071, 0, 0, 0.7071)
    const angles = gm.Vec3{ m.pi / 2.0, 0, 0 };
    const q = gm.eulerXYZQuatRH(angles);
    try expect(@abs(q[0] - 0.70710678) < 0.001);
    try expect(@abs(q[1]) < 0.001);
    try expect(@abs(q[2]) < 0.001);
    try expect(@abs(q[3] - 0.70710678) < 0.001);
}
