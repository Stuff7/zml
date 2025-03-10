const std = @import("std");
const zml = @import("zml");

const expect = std.testing.expect;

test "lookat: Basic functionality" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 1, 2, 3 };
    const center = zml.Vec3{ 4, 5, 6 };
    const up = zml.Vec3{ 0, 1, 0 };

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ -7.0710677e-1, -4.0824828e-1, -5.7735026e-1, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 8.1649655e-1, -5.7735026e-1, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ 7.0710677e-1, -4.0824828e-1, -5.7735026e-1, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -1.4142134e0, -0e0, 3.4641016e0, 1e0 }));
}

test "lookat: Eye at the origin" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 0, 0, 0 };
    const center = zml.Vec3{ 0, 0, -1 };
    const up = zml.Vec3{ 0, 1, 0 };

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ 1, 0, 0, 0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0, 1, 0, 0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ 0, 0, 1, 0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ 0, 0, 0, 1 }));
}

test "lookat: Eye above the center" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 0, 10, 0 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 0, 1 }; // Looking downwards

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ -1e0, 0e0, -0e0, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 0e0, 1e0, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ 0e0, 1e0, -0e0, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -0e0, -0e0, -1e1, 1e0 }));
}

test "lookat: Look at from a non-zero x, y, z position" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 5, 5, 5 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 1, 0 };

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ 7.0710677e-1, -4.0824825e-1, 5.773502e-1, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 8.164965e-1, 5.773502e-1, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ -7.0710677e-1, -4.0824825e-1, 5.773502e-1, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -0e0, -0e0, -8.660253e0, 1e0 }));
}

test "lookat: Eye at the center = degenerate" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 0, 0, 0 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 1, 0 };

    zml.mat4.lookat(eye, center, up, &mat);
    try expect(zml.mat4.isDegenerate(mat));
}

test "lookat: Large distances" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 1000000, 1000000, 1000000 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 1, 0 };

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ 7.0710677e-1, -4.0824828e-1, 5.7735026e-1, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 8.1649655e-1, 5.7735026e-1, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ -7.0710677e-1, -4.0824828e-1, 5.7735026e-1, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -0e0, -0e0, -1.7320508e6, 1e0 }));
}

test "lookat: Negative eye coordinates" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ -1, -2, -3 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 1, 0 };

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ -9.486834e-1, -1.6903086e-1, -2.6726124e-1, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 8.451543e-1, -5.345225e-1, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ 3.162278e-1, -5.070926e-1, -8.017837e-1, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -0e0, -1.1920929e-7, -3.7416573e0, 1e0 }));
}

test "lookat: Inverted up vector" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 0, 0, 1 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 0, -1 }; // Inverted up vector

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ 0e0, -0e0, -0e0, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 0e0, -0e0, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ 0e0, 0e0, 1e0, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -0e0, -0e0, -1e0, 1e0 }));
}

test "lookat: Zero vector for up = degenerate" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 1, 1, 1 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 0, 0 }; // Invalid up vector

    zml.mat4.lookat(eye, center, up, &mat);
    try expect(zml.mat4.isDegenerate(mat));
}

test "lookat: All vectors aligned" {
    var mat: zml.Mat4 = undefined;
    const eye = zml.Vec3{ 1, 0, 0 };
    const center = zml.Vec3{ 0, 0, 0 };
    const up = zml.Vec3{ 0, 1, 0 }; // Aligned up

    zml.mat4.lookat(eye, center, up, &mat);

    try expect(@reduce(.And, mat[0] == zml.Vec4{ 0e0, 0e0, 1e0, 0e0 }));
    try expect(@reduce(.And, mat[1] == zml.Vec4{ 0e0, 1e0, -0e0, 0e0 }));
    try expect(@reduce(.And, mat[2] == zml.Vec4{ -1e0, 0e0, -0e0, 0e0 }));
    try expect(@reduce(.And, mat[3] == zml.Vec4{ -0e0, -0e0, -1e0, 1e0 }));
}

test "perspective matrix" {
    // Use a 90° field-of-view (fovy = π/2), aspect = 1, near = 1, far = 100.
    var mat: zml.Mat4 = undefined;
    const fovy: f32 = std.math.pi / 2.0;
    const aspect: f32 = 1.0;
    const near_z: f32 = 1.0;
    const far_z: f32 = 100.0;
    zml.mat4.perspective(fovy, aspect, near_z, far_z, &mat);

    // f = 1 / tan(fovy/2) = 1 / tan(π/4) = 1.
    // f_n = 1 / (near_z - far_z) = 1 / (1 - 100) = -1/99 ≈ -0.01010101.
    const f_n: f32 = 1.0 / (near_z - far_z);
    const exp_22: f32 = (near_z + far_z) * f_n; // (1+100)/ (1-100) = 101 * f_n ≈ -1.020202
    const exp_32: f32 = 2 * near_z * far_z * f_n; // 2*1*100 * f_n ≈ -2.020202

    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 1.0, 0, 0, 0 },
        zml.Vec4{ 0, 1.0, 0, 0 },
        zml.Vec4{ 0, 0, exp_22, -1 },
        zml.Vec4{ 0, 0, exp_32, 0 },
    };
    try expect(zml.mat4.approxEq(mat, expected, 0.001));
}

test "ortho projection matrix" {
    // Use left=-10, right=10, bottom=-5, top=5, nearZ=0.1, farZ=100.
    var mat: zml.Mat4 = undefined;
    const left: f32 = -10;
    const right: f32 = 10;
    const bottom: f32 = -5;
    const top: f32 = 5;
    const nearZ: f32 = 0.1;
    const farZ: f32 = 100;
    zml.mat4.ortho(left, right, bottom, top, nearZ, farZ, &mat);

    const rl: f32 = 1 / (right - left); // 1/20 = 0.05
    const tb: f32 = 1 / (top - bottom); // 1/10 = 0.1
    const f_n: f32 = -1 / (farZ - nearZ); // -1/(100-0.1) ≈ -0.01001
    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 2 * rl, 0, 0, 0 },
        zml.Vec4{ 0, 2 * tb, 0, 0 },
        zml.Vec4{ 0, 0, f_n, 0 },
        zml.Vec4{ -(right + left) * rl, -(top + bottom) * tb, nearZ * f_n, 1 },
    };
    try expect(zml.mat4.approxEq(mat, expected, 0.001));
}

test "scale matrix" {
    var mat: zml.Mat4 = undefined;
    zml.mat4.scale(&mat, zml.Vec3{ 2, 3, 4 });
    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 2, 0, 0, 0 },
        zml.Vec4{ 0, 3, 0, 0 },
        zml.Vec4{ 0, 0, 4, 0 },
        zml.Vec4{ 0, 0, 0, 1 },
    };
    try expect(zml.mat4.approxEq(mat, expected, 0.0001));
}

test "translate matrix" {
    var mat: zml.Mat4 = zml.mat4.identity();
    zml.mat4.translate(&mat, zml.Vec3{ 5, -3, 2 });
    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 1, 0, 0, 0 },
        zml.Vec4{ 0, 1, 0, 0 },
        zml.Vec4{ 0, 0, 1, 0 },
        zml.Vec4{ 5, -3, 2, 1 },
    };
    try expect(zml.mat4.approxEq(mat, expected, 0.0001));
}

test "quaternion to rotation matrix (identity quaternion)" {
    var mat: zml.Mat4 = undefined;
    // Identity quaternion: no rotation.
    zml.mat4.quat(zml.Vec4{ 0, 0, 0, 1 }, &mat);
    try expect(zml.mat4.approxEq(mat, zml.mat4.identity(), 0.0001));
}

test "quatRotate: rotate identity matrix by 90° about Z" {
    // Define quaternion for a 90° rotation about Z.
    // In a left-handed system (with camera looking along -Z), a rotation by 90° about Z
    // can be represented by q = (0, 0, sin(π/4), cos(π/4)).
    var res: zml.Mat4 = undefined;
    const q: zml.Vec4 = zml.Vec4{ 0, 0, 0.70710678, 0.70710678 };
    zml.mat4.quatRotate(zml.mat4.identity(), q, &res);
    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 0, 1, 0, 0 },
        zml.Vec4{ -1, 0, 0, 0 },
        zml.Vec4{ 0, 0, 1, 0 },
        zml.Vec4{ 0, 0, 0, 1 },
    };
    try expect(zml.mat4.approxEq(res, expected, 0.0001));
}

test "mulRot: multiply two rotation matrices" {
    // m1: 90° rotation about X.
    const m1: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 1, 0, 0, 0 },
        zml.Vec4{ 0, 0, -1, 0 },
        zml.Vec4{ 0, 1, 0, 0 },
        zml.Vec4{ 0, 0, 0, 1 },
    };
    // m2: 90° rotation about Z.
    const m2: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 0, -1, 0, 0 },
        zml.Vec4{ 1, 0, 0, 0 },
        zml.Vec4{ 0, 0, 1, 0 },
        zml.Vec4{ 0, 0, 0, 1 },
    };
    var res: zml.Mat4 = undefined;
    zml.mat4.mulRot(m1, m2, &res);

    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 0, 0, 1, 0 },
        zml.Vec4{ 1, 0, 0, 0 },
        zml.Vec4{ 0, 1, 0, 0 },
        zml.Vec4{ 0, 0, 0, 1 },
    };
    try expect(zml.mat4.approxEq(res, expected, 0.0001));
}
