const m = @import("std").math;
const zml = @import("zml.zig");

pub const Mat4 = [4]zml.Vec4;
pub const mat4 = struct {
    pub fn identity() Mat4 {
        return Mat4{
            zml.Vec4{ 1, 0, 0, 0 },
            zml.Vec4{ 0, 1, 0, 0 },
            zml.Vec4{ 0, 0, 1, 0 },
            zml.Vec4{ 0, 0, 0, 1 },
        };
    }

    pub fn fill(s: f32) Mat4 {
        return Mat4{ zml.vec4.fill(s), zml.vec4.fill(s), zml.vec4.fill(s), zml.vec4.fill(s) };
    }

    pub fn approxEq(a: zml.Mat4, b: zml.Mat4, tol: f32) bool {
        for (a, 0..) |row, i| {
            if (!zml.vec4.approxEq(row, b[i], tol))
                return false;
        }
        return true;
    }

    pub fn isDegenerate(matrix: zml.Mat4) bool {
        const det = zml.vec4.dot(matrix[0], zml.vec4.cross(matrix[1], matrix[2]));
        return det == 0.0;
    }

    pub fn lookat(eye: zml.Vec3, center: zml.Vec3, up: zml.Vec3, dest: *Mat4) void {
        const f = zml.vec3.normalize(center - eye);
        const s = zml.vec3.normalize(zml.vec3.cross(f, up));
        const u = zml.vec3.cross(s, f);

        dest[0][0] = s[0];
        dest[0][1] = u[0];
        dest[0][2] = -f[0];
        dest[1][0] = s[1];
        dest[1][1] = u[1];
        dest[1][2] = -f[1];
        dest[2][0] = s[2];
        dest[2][1] = u[2];
        dest[2][2] = -f[2];
        dest[3][0] = -zml.vec3.dot(s, eye);
        dest[3][1] = -zml.vec3.dot(u, eye);
        dest[3][2] = zml.vec3.dot(f, eye);
        dest[0][3] = 0;
        dest[1][3] = 0;
        dest[2][3] = 0;
        dest[3][3] = 1;
    }

    pub fn perspective(fovy: f32, aspect: f32, near_z: f32, far_z: f32, dest: *Mat4) void {
        @memset(dest, zml.Vec4{ 0, 0, 0, 0 });

        const f = 1 / m.tan(fovy * 0.5);
        const f_n = 1 / (near_z - far_z);

        dest[0][0] = f / aspect;
        dest[1][1] = f;
        dest[2][2] = (near_z + far_z) * f_n;
        dest[2][3] = -1;
        dest[3][2] = 2 * near_z * far_z * f_n;
    }

    pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, nearZ: f32, farZ: f32, dest: *Mat4) void {
        @memset(dest, zml.Vec4{ 0, 0, 0, 0 });

        const rl = 1 / (right - left);
        const tb = 1 / (top - bottom);
        const f_n = -1 / (farZ - nearZ);

        dest[0][0] = 2 * rl;
        dest[1][1] = 2 * tb;
        dest[2][2] = f_n;
        dest[3][0] = -(right + left) * rl;
        dest[3][1] = -(top + bottom) * tb;
        dest[3][2] = nearZ * f_n;
        dest[3][3] = 1;
    }

    pub fn scale(self: *Mat4, v: zml.Vec3) void {
        self.* = identity();
        self[0][0] = v[0];
        self[1][1] = v[1];
        self[2][2] = v[2];
    }

    pub fn mul(m1: Mat4, m2: Mat4, dest: Mat4) void {
        const a00 = m1[0][0];
        const a01 = m1[0][1];
        const a02 = m1[0][2];
        const a03 = m1[0][3];
        const a10 = m1[1][0];
        const a11 = m1[1][1];
        const a12 = m1[1][2];
        const a13 = m1[1][3];
        const a20 = m1[2][0];
        const a21 = m1[2][1];
        const a22 = m1[2][2];
        const a23 = m1[2][3];
        const a30 = m1[3][0];
        const a31 = m1[3][1];
        const a32 = m1[3][2];
        const a33 = m1[3][3];
        const b00 = m2[0][0];
        const b01 = m2[0][1];
        const b02 = m2[0][2];
        const b03 = m2[0][3];
        const b10 = m2[1][0];
        const b11 = m2[1][1];
        const b12 = m2[1][2];
        const b13 = m2[1][3];
        const b20 = m2[2][0];
        const b21 = m2[2][1];
        const b22 = m2[2][2];
        const b23 = m2[2][3];
        const b30 = m2[3][0];
        const b31 = m2[3][1];
        const b32 = m2[3][2];
        const b33 = m2[3][3];

        dest[0][0] = a00 * b00 + a10 * b01 + a20 * b02 + a30 * b03;
        dest[0][1] = a01 * b00 + a11 * b01 + a21 * b02 + a31 * b03;
        dest[0][2] = a02 * b00 + a12 * b01 + a22 * b02 + a32 * b03;
        dest[0][3] = a03 * b00 + a13 * b01 + a23 * b02 + a33 * b03;
        dest[1][0] = a00 * b10 + a10 * b11 + a20 * b12 + a30 * b13;
        dest[1][1] = a01 * b10 + a11 * b11 + a21 * b12 + a31 * b13;
        dest[1][2] = a02 * b10 + a12 * b11 + a22 * b12 + a32 * b13;
        dest[1][3] = a03 * b10 + a13 * b11 + a23 * b12 + a33 * b13;
        dest[2][0] = a00 * b20 + a10 * b21 + a20 * b22 + a30 * b23;
        dest[2][1] = a01 * b20 + a11 * b21 + a21 * b22 + a31 * b23;
        dest[2][2] = a02 * b20 + a12 * b21 + a22 * b22 + a32 * b23;
        dest[2][3] = a03 * b20 + a13 * b21 + a23 * b22 + a33 * b23;
        dest[3][0] = a00 * b30 + a10 * b31 + a20 * b32 + a30 * b33;
        dest[3][1] = a01 * b30 + a11 * b31 + a21 * b32 + a31 * b33;
        dest[3][2] = a02 * b30 + a12 * b31 + a22 * b32 + a32 * b33;
        dest[3][3] = a03 * b30 + a13 * b31 + a23 * b32 + a33 * b33;
    }

    pub fn mulAdds(a: zml.Vec4, s: f32, dest: *zml.Vec4) void {
        dest[0] += a[0] * s;
        dest[1] += a[1] * s;
        dest[2] += a[2] * s;
        dest[3] += a[3] * s;
    }

    pub fn translate(mat: *Mat4, v: zml.Vec3) void {
        mulAdds(mat[0], v[0], &mat[3]);
        mulAdds(mat[1], v[1], &mat[3]);
        mulAdds(mat[2], v[2], &mat[3]);
    }

    pub fn translateTo(mat: *Mat4, position: zml.Vec3) void {
        mat[3][0] = position[0];
        mat[3][1] = position[1];
        mat[3][2] = position[2];
    }

    pub fn quatRotate(mat: Mat4, q: zml.Vec4, dest: *Mat4) void {
        var rot: Mat4 = undefined;
        quat(q, &rot);
        mulRot(mat, rot, dest);
    }

    pub fn quat(q: zml.Vec4, dest: *Mat4) void {
        const norm = zml.vec4.norm(q);
        const s: f32 = if (norm > 0.0) 2 / norm else 0;

        const x = q[0];
        const y = q[1];
        const z = q[2];
        const w = q[3];

        const xx = s * x * x;
        const xy = s * x * y;
        const wx = s * w * x;
        const yy = s * y * y;
        const yz = s * y * z;
        const wy = s * w * y;
        const zz = s * z * z;
        const xz = s * x * z;
        const wz = s * w * z;

        dest[0][0] = 1 - yy - zz;
        dest[1][1] = 1 - xx - zz;
        dest[2][2] = 1 - xx - yy;

        dest[0][1] = xy + wz;
        dest[1][2] = yz + wx;
        dest[2][0] = xz + wy;

        dest[1][0] = xy - wz;
        dest[2][1] = yz - wx;
        dest[0][2] = xz - wy;

        dest[0][3] = 0;
        dest[1][3] = 0;
        dest[2][3] = 0;
        dest[3][0] = 0;
        dest[3][1] = 0;
        dest[3][2] = 0;
        dest[3][3] = 1;
    }

    pub fn mulRot(m1: Mat4, m2: Mat4, dest: *Mat4) void {
        const a00 = m1[0][0];
        const a01 = m1[0][1];
        const a02 = m1[0][2];
        const a03 = m1[0][3];
        const a10 = m1[1][0];
        const a11 = m1[1][1];
        const a12 = m1[1][2];
        const a13 = m1[1][3];
        const a20 = m1[2][0];
        const a21 = m1[2][1];
        const a22 = m1[2][2];
        const a23 = m1[2][3];
        const a30 = m1[3][0];
        const a31 = m1[3][1];
        const a32 = m1[3][2];
        const a33 = m1[3][3];

        const b00 = m2[0][0];
        const b01 = m2[0][1];
        const b02 = m2[0][2];
        const b10 = m2[1][0];
        const b11 = m2[1][1];
        const b12 = m2[1][2];
        const b20 = m2[2][0];
        const b21 = m2[2][1];
        const b22 = m2[2][2];

        dest[0][0] = a00 * b00 + a10 * b01 + a20 * b02;
        dest[0][1] = a01 * b00 + a11 * b01 + a21 * b02;
        dest[0][2] = a02 * b00 + a12 * b01 + a22 * b02;
        dest[0][3] = a03 * b00 + a13 * b01 + a23 * b02;

        dest[1][0] = a00 * b10 + a10 * b11 + a20 * b12;
        dest[1][1] = a01 * b10 + a11 * b11 + a21 * b12;
        dest[1][2] = a02 * b10 + a12 * b11 + a22 * b12;
        dest[1][3] = a03 * b10 + a13 * b11 + a23 * b12;

        dest[2][0] = a00 * b20 + a10 * b21 + a20 * b22;
        dest[2][1] = a01 * b20 + a11 * b21 + a21 * b22;
        dest[2][2] = a02 * b20 + a12 * b21 + a22 * b22;
        dest[2][3] = a03 * b20 + a13 * b21 + a23 * b22;

        dest[3][0] = a30;
        dest[3][1] = a31;
        dest[3][2] = a32;
        dest[3][3] = a33;
    }
};
