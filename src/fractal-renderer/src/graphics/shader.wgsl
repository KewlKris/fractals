// Vertex shader

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec3<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec3<f32>,
};

@vertex
fn vs_main(vertex: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.color = vertex.color;
    out.clip_position = vec4<f32>(vertex.position, 1.0);
    return out;
}

// Fragment shader

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    //return vec4<f32>(in.color, 1.0);
    //return vec4<f32>((in.clip_position.x + 1.0) / 2.0, (in.clip_position.y + 1.0) / 2.0, 0.0, 1.0);

    // if (in.clip_position.x < 50.0) {
    //     return vec4<f32>(1.0, 1.0, 1.0, 1.0);
    // } else {
    //     return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    // }
}
