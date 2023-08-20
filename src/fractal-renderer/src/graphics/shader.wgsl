// Vertex shader

struct VertexInput {
    @location(0) position: vec2<f32>,
    @location(1) domain: vec2<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) domain: vec2<f32>,
};

@vertex
fn vs_main(vertex: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.domain = vertex.domain;
    out.clip_position = vec4<f32>(vertex.position.x, vertex.position.y, 0.0, 1.0);
    return out;
}

// Fragment shader

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    var complex: vec2<f32> = in.domain;
    let constant: vec2<f32> = vec2<f32>(-0.67, -0.475);

    for (var i: u32 = 0u; i<200u; i++) {
        complex = compute_julia(complex, constant);

        if (length(complex) > 2.0) {
            // Outside of Julia set
            return vec4<f32>(0.0, 0.0, 0.0, 1.0);
        }
    }

    // Within Julia set!
    return vec4<f32>(1.0, 1.0, 1.0, 1.0);
}

fn compute_julia(zn: vec2<f32>, c: vec2<f32>) -> vec2<f32> {
    // Square the complex number
    let real: f32 = (zn.x * zn.x) - (zn.y - zn.y);
    let imaginary: f32 = 2.0 * zn.x * zn.y;

    // Add constant and return
    return vec2<f32>(real, imaginary) + c;
}