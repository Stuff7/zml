const std = @import("std");
const zml = @import("zml");

const expect = std.testing.expect;
const m = std.math;

test "Transform matrix composition" {
    var tf = zml.Transform.init();
    tf.translation = zml.Vec3{ 3, -2, 5 };
    tf.scale = zml.Vec3{ 2, 2, 2 };
    // Rotate: simulate a rotation of 90° about Z.
    tf.rotate(zml.Vec3{ 0, 0, m.pi / 2.0 });

    var out: zml.Mat4 = undefined;
    tf.matrix(&out);
    // Expected composition:
    // 1. Scale S = diag(2,2,2,1).
    // 2. Rotation by 90° about Z produces R:
    //      { {  0, 1, 0, 0 },
    //        { -1, 0, 0, 0 },
    //        {  0, 0, 1, 0 },
    //        {  0, 0, 0, 1 } }
    // 3. The product S*R is:
    //      row0: ( 0, 2, 0, 0)
    //      row1: (-2, 0, 0, 0)
    //      row2: ( 0, 0, 2, 0)
    //      row3: ( 0, 0, 0, 1)
    // 4. Then translation T is applied via:
    //      row3 = (3 * row0) + (-2 * row1) + (5 * row2) + (0,0,0,1)
    //           = 3*(0,2,0,0) + (-2)*(-2,0,0,0) + 5*(0,0,2,0) + (0,0,0,1)
    //           = (0,6,0,0) + (4,0,0,0) + (0,0,10,0) + (0,0,0,1)
    //           = (4, 6, 10, 1)
    const expected: zml.Mat4 = zml.Mat4{
        zml.Vec4{ 0, 2, 0, 0 },
        zml.Vec4{ -2, 0, 0, 0 },
        zml.Vec4{ 0, 0, 2, 0 },
        zml.Vec4{ 4, 6, 10, 1 },
    };
    try std.testing.expect(zml.mat4.approxEq(out, expected, 0.01));
}

test "Transform rotate accumulates rotations" {
    var tf = zml.Transform.init();
    // First, rotate 90° about Z.
    tf.rotate(zml.Vec3{ 0, 0, m.pi / 2.0 });
    // Then, rotate 90° about Z again.
    tf.rotate(zml.Vec3{ 0, 0, m.pi / 2.0 });
    // The combined rotation should be 180° about Z.
    // For a 180° rotation about Z, the rotation matrix is:
    //   | -1  0  0  0 |
    //   |  0 -1  0  0 |
    //   |  0  0  1  0 |
    //   |  0  0  0  1 |
    var out: zml.Mat4 = undefined;
    tf.matrix(&out);
    // Since translation and scale are identity here, we extract the rotation part:
    // First column is approximately (-1, 0, 0) and second is (0, -1, 0).
    try expect(@abs(out[0][0] + 1) < 0.01);
    try expect(@abs(out[0][1]) < 0.01);
    try expect(@abs(out[1][0]) < 0.01);
    try expect(@abs(out[1][1] + 1) < 0.01);
}
