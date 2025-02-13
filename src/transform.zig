const gm = @import("zml.zig");

pub const Transform = struct {
    translation: gm.Vec3,
    scale: gm.Vec3,
    rotation: gm.Vec4,

    pub fn init() Transform {
        return Transform{
            .translation = gm.Vec3{ 0, 0, 0 },
            .rotation = gm.eulerXYZQuatRH(gm.Vec3{ 0, 0, 0 }),
            .scale = gm.vec3.fill(1),
        };
    }

    pub fn matrix(self: *Transform, out: *gm.Mat4) void {
        gm.mat4.scale(out, self.scale);
        gm.mat4.quatRotate(out.*, self.rotation, out);
        gm.mat4.translate(out, self.translation);
    }

    pub fn rotate(self: *Transform, axis: gm.Vec3) void {
        const angle = gm.vec3.norm(axis);

        if (angle > 0) {
            const normalizedAxis = gm.vec3.scale(axis, 1 / angle);
            const rotation = gm.quatv(angle, normalizedAxis);
            self.rotation = gm.quatMul(rotation, self.rotation);
        }
    }
};
