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

struct DataUniform {
    time: f32,
    _padding1: u32,
    _padding2: u32,
    _padding3: u32,
};
@group(0) @binding(0) var<uniform> data: DataUniform;

const MAX_ITERATIONS: u32 = 200u;
const ESCAPE_RANGE: f32 = 2.0;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    var complex: vec2<f32> = in.domain;
    let constant: vec2<f32> = vec2<f32>(-0.545 + (sin(data.time/3.0) * 0.02), -0.5 + (sin(data.time/11.0) * 0.02)); // Render a Julia set
    //let constant = in.domain; // This renders the Mandelbrot set

    var escape_time: u32;
    for (escape_time = 0u; escape_time < MAX_ITERATIONS; escape_time++) {
        complex = compute_julia(complex, constant);

        if (length(complex) > ESCAPE_RANGE) {
            // Outside bounds! Assume to be trending to infinity
            break;
        }
    }

    // Color the pixel based on escape_time
    //let percent: f32 = f32(escape_time) / f32(MAX_ITERATIONS); // Color based on the integer escape_time
    let escape_length = length(complex);
    if (escape_length > ESCAPE_RANGE) {
        // Draw on logarithmic scale
        let percent: f32 = f32(escape_time) - log2(log(length(complex)) / log(ESCAPE_RANGE));
        return vec4<f32>(percent, percent, percent, 1.0);

    } else {
        // Draw interior color
        return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    }
}

fn compute_julia(zn: vec2<f32>, c: vec2<f32>) -> vec2<f32> {
    // Square the complex number
    let real: f32 = (zn.x * zn.x) - (zn.y * zn.y);
    let imaginary: f32 = 2.0 * zn.x * zn.y;

    // Add constant and return
    return vec2<f32>(real, imaginary) + c;
}

fn map_color(percent: f32) -> vec3<f32> {
    const color_count: u32 = 4u;
    const colors: array<vec3<f32>, color_count> = array<vec3<f32>, color_count>(
        vec3<f32>(0.0, 0.0, 0.0),
        vec3<f32>(1.0, 0.0, 0.0),
        vec3<f32>(0.0, 1.0, 0.0),
        vec3<f32>(0.0, 0.0, 1.0),
    );
    const color_end_points: array<f32, color_count> = array<f32, color_count>(
        0.25, 0.5, 0.75, 1.0
    );

    // First determine the color index
    var color_index: u32 = 0;
    for (var i=0u i<color_count; i++) {
        if (percent <= color_end_points[i]) {
            color_index = i;
            break;
        }
    }
}