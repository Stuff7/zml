const zml = @import("zml.zig");

pub const Transform = struct {
    translation: zml.Vec3,
    scale: zml.Vec3,
    rotation: zml.Vec4,

    pub fn init() Transform {
        return Transform{
            .translation = zml.Vec3{ 0, 0, 0 },
            .rotation = zml.eulerXYZQuatRH(zml.Vec3{ 0, 0, 0 }),
            .scale = zml.vec3.fill(1),
        };
    }

    pub fn matrix(self: *Transform, out: *zml.Mat4) void {
        zml.mat4.scale(out, self.scale);
        zml.mat4.quatRotate(out.*, self.rotation, out);
        zml.mat4.translate(out, self.translation);
    }

    pub fn rotate(self: *Transform, axis: zml.Vec3) void {
        const angle = zml.vec3.norm(axis);

        if (angle > 0) {
            const normalizedAxis = zml.vec3.scale(axis, 1 / angle);
            const rotation = zml.quatv(angle, normalizedAxis);
            self.rotation = zml.quatMul(rotation, self.rotation);
        }
    }
};
