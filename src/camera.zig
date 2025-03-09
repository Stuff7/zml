const std = @import("std");
const zml = @import("zml.zig");

const m = std.math;
const mem = std.mem;

const pi2 = m.pi / 2.0;
const max_pitch: f32 = 89;

pub const Camera = struct {
    yaw: f32,
    pitch: f32,
    roll: f32,
    sensitivity: f32,
    pos: zml.Vec3 = mem.zeroes(zml.Vec3),
    target: zml.Vec3 = mem.zeroes(zml.Vec3),
    right: zml.Vec3 = mem.zeroes(zml.Vec3),
    up: zml.Vec3 = mem.zeroes(zml.Vec3),

    pub fn init(self: *Camera) void {
        const forward = forwardFromSphere(self.yaw, self.pitch);
        self.right = rightFromSphere(self.yaw, self.roll);
        self.up = zml.vec3.normalize(zml.vec3.cross(forward, self.right));
        self.target = self.pos + forward;
    }

    pub fn rotate(self: *Camera, yaw: f32, pitch: f32, roll: f32) void {
        self.yaw += yaw * self.sensitivity;
        self.pitch += pitch * self.sensitivity;
        self.roll += roll * self.sensitivity;

        if (self.pitch > max_pitch) {
            self.pitch = max_pitch;
        }
        if (self.pitch < -max_pitch) {
            self.pitch = -max_pitch;
        }

        while (self.roll > 180) {
            self.roll -= 360;
        }
        while (self.roll < -180) {
            self.roll += 360;
        }

        const forward = forwardFromSphere(self.yaw, self.pitch);
        self.right = rightFromSphere(self.yaw, self.roll);
        self.up = zml.vec3.normalize(zml.vec3.cross(forward, self.right));
        self.target = self.pos + forward;
    }

    pub fn move(self: *Camera, delta: zml.Vec3, speed: f32) void {
        const forward = zml.vec3.normalize(self.target - self.pos);

        const scaledForward = zml.vec3.scale(forward, delta[2] * speed);
        const scaledRight = zml.vec3.scale(self.right, delta[0] * speed);
        const scaledUp = zml.vec3.scale(self.up, delta[1] * speed);

        self.pos = self.pos + scaledForward + scaledRight + scaledUp;
        self.target = self.pos + forward;
    }

    pub fn matrix(self: *Camera, out: *zml.Mat4) void {
        zml.mat4.lookat(self.pos, self.target, self.up, out);
    }
};

pub fn forwardFromSphere(yaw: f32, pitch: f32) zml.Vec3 {
    return zml.Vec3{
        m.cos(m.degreesToRadians(pitch)) * m.sin(m.degreesToRadians(yaw)),
        m.sin(m.degreesToRadians(pitch)),
        m.cos(m.degreesToRadians(pitch)) * m.cos(m.degreesToRadians(yaw)),
    };
}

pub fn rightFromSphere(yaw: f32, roll: f32) zml.Vec3 {
    const v = zml.Vec3{
        m.sin(m.degreesToRadians(yaw) - pi2),
        0,
        m.cos(m.degreesToRadians(yaw) - pi2),
    };

    if (roll == 0) {
        return v;
    }

    const forward = forwardFromSphere(yaw, 0.0);
    return zml.vec3.rotate(v, m.degreesToRadians(roll), forward);
}
