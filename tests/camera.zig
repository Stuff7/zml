const std = @import("std");
const gm = @import("zml");

const expect = std.testing.expect;
const m = std.math;

const tol: f32 = 0.001;

test "Camera init sets target, right and up" {
    // With yaw = 90°, pitch = 0, roll = 0, the forward vector (from forwardFromSphere) should be:
    // x = cos(0) * sin(90°) = 1, y = sin(0) = 0, z = cos(0) * cos(90°) = 0.
    // In this case, if pos is at (0,0,0), then target becomes (1,0,0).
    var cam = gm.Camera{
        .yaw = 90,
        .pitch = 0,
        .roll = 0,
        .sensitivity = 1.0,
    };
    cam.init();

    const expectedForward = gm.Vec3{ 1, 0, 0 };
    const expectedTarget = expectedForward; // pos + forward
    // Expected right from rightFromSphere with yaw=90, roll=0.
    // rightFromSphere returns a vector computed from (sin(yaw - π/2), 0, cos(yaw - π/2))
    // For yaw=90°: yaw - π/2 = 90° - 90° = 0°, so expected right = (sin0, 0, cos0) = (0, 0, 1)
    const expectedRight = gm.Vec3{ 0, 0, 1 };
    // Expected up = normalize(cross(forward, right))
    // cross(expectedForward, expectedRight) = cross({1,0,0}, {0,0,1}) = {0, -1, 0} (for left-handed, check your convention)
    // Then normalized: {0, -1, 0}.
    const expectedUp = gm.Vec3{ 0, -1, 0 };

    try expect(gm.vec3.approxEq(cam.target, expectedTarget, tol));
    try expect(gm.vec3.approxEq(cam.right, expectedRight, tol));
    try expect(gm.vec3.approxEq(cam.up, expectedUp, tol));
}

test "Camera rotate clamps pitch and wraps roll" {
    var cam = gm.Camera{
        .yaw = 0,
        .pitch = 0,
        .roll = 0,
        .sensitivity = 1.0,
        .pos = gm.Vec3{ 0, 0, 0 },
    };
    cam.init();

    cam.rotate(45, 100, 190);
    // Pitch should be clamped to max_pitch (89) and roll should wrap to within [-180, 180].
    try expect(cam.pitch == 89);
    // For roll: starting from 0, add 190 -> 190, then while (roll > 180) roll -= 360 gives 190 - 360 = -170.
    try expect(cam.roll == -170);
    // Computed target is consistent with the new yaw/pitch.
    const forward = gm.forwardFromSphere(cam.yaw, cam.pitch);
    const expectedTarget = cam.pos + forward;
    try expect(gm.vec3.approxEq(cam.target, expectedTarget, tol));
}

test "Camera move updates pos and target" {
    var cam = gm.Camera{
        .yaw = 0,
        .pitch = 0,
        .roll = 0,
        .sensitivity = 1.0,
        .pos = gm.Vec3{ 0, 0, 0 },
    };
    cam.init();
    // With yaw=0, pitch=0: forwardFromSphere returns: x = cos(0)*sin(0)=0, y = sin(0)=0, z = cos(0)*cos(0)=1.
    // So the camera looks along +Z.
    const delta = gm.Vec3{ 1, 2, 3 };
    cam.move(delta, 2.0);
    // Calculation:
    // forward = (0,0,1)
    // scaledForward = forward * (3*2) = (0,0,6)
    // right (from init) = rightFromSphere(0,0) = (sin(-π/2), 0, cos(-π/2)) = (-1, 0, 0)
    // scaledRight = right * (1*2) = (-2, 0, 0)
    // up (from init) = normalize(cross(forward, right))
    //    = normalize(cross({0,0,1}, {-1,0,0})) = {0, -1, 0}
    // scaledUp = up * (2*2) = (0, -4, 0)
    // New pos = (0,0,0) + (-2, 0, 0) + (0,-4,0) + (0,0,6) = (-2, -4, 6)
    const expectedPos = gm.Vec3{ -2, -4, 6 };
    try std.testing.expect(gm.vec3.approxEq(cam.pos, expectedPos, tol));
    // Target = pos + forward = (-2, -4, 6) + (0,0,1) = (-2, -4, 7)
    const expectedTarget = expectedPos + gm.Vec3{ 0, 0, 1 };
    try std.testing.expect(gm.vec3.approxEq(cam.target, expectedTarget, tol));
}
