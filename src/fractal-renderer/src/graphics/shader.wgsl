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
    //let constant: vec2<f32> = vec2<f32>(-0.545 + (sin(data.time/3.0) * 0.02), -0.5 + (sin(data.time/11.0) * 0.02)); // Render a Julia set
    let constant = in.domain; // This renders the Mandelbrot set

    var escape_time: u32;
    for (escape_time = 1u; escape_time < MAX_ITERATIONS; escape_time++) {
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
        //let percent: f32 = f32(escape_time - 1u) - log2(log(escape_length) / log(ESCAPE_RANGE)); // Logarithmic scale
        let percent: f32 = f32(escape_time) / f32(MAX_ITERATIONS);
        //let percent = abs(in.domain.x);
        //let percent = (f32(escape_time - 2u) - (log(log(escape_length)) / log(2.0)));
        //let percent = 1.0 - log(escape_length) / log(f32(ESCAPE_RANGE));
        //let percent = f32(escape_time + 2u) - log(log((complex.x * complex.x) + (complex.y * complex.y))) / log(2.0);

        //return vec4<f32>(percent, percent, percent, 1.0);
        return vec4<f32>(map_color_linear(percent), 1.0);
    } else {
        // Draw interior color
        //return vec4<f32>(0.0, 0.0, 0.0, 1.0);
        return vec4<f32>(map_color_linear(1.0), 1.0);
    }
}

fn compute_julia(zn: vec2<f32>, c: vec2<f32>) -> vec2<f32> {
    // Square the complex number
    let real: f32 = (zn.x * zn.x) - (zn.y * zn.y);
    let imaginary: f32 = 2.0 * zn.x * zn.y;

    // Add constant and return
    return vec2<f32>(real, imaginary) + c;
}

const COLOR_COUNT: u32 = 8u;
var<private> COLORS: array<vec3<f32>, COLOR_COUNT> = array<vec3<f32>, COLOR_COUNT>(
    vec3<f32>(0.0, 0.0, 0.0),
    vec3<f32>(1.0, 0.0, 0.0),
    vec3<f32>(1.0, 1.0, 0.0),
    vec3<f32>(0.0, 1.0, 0.0),
    vec3<f32>(0.0, 1.0, 1.0),
    vec3<f32>(0.0, 0.0, 1.0),
    vec3<f32>(1.0, 0.0, 1.0),
    vec3<f32>(1.0, 1.0, 1.0),
);
fn map_color_linear(percent: f32) -> vec3<f32> {
    let clamped_percent = clamp(percent, 0.0, 1.0);
    let expanded_percent = clamped_percent * f32(COLOR_COUNT - 1u);
    let start_index: u32 = u32(floor(expanded_percent));
    var final_color: vec3<f32> = vec3<f32>(0.0);
    if (start_index != (COLOR_COUNT - 1u)) {
        let end_index: u32 = start_index + 1u;

        let start_color = COLORS[start_index];
        let end_color = COLORS[end_index];

        let start_value: f32 = f32(start_index) * (1.0 / f32(COLOR_COUNT - 1u));
        let end_value: f32 = f32(end_index) * (1.0 / f32(COLOR_COUNT - 1u));
        let ratio = (clamped_percent - start_value) / (end_value - start_value);
        final_color = (start_color * (1.0 - ratio)) + (end_color * (ratio));
    } else {
        final_color = COLORS[COLOR_COUNT - 1u];
    }

    // Convert to sRGB color space
    final_color = pow((final_color + 0.055) / 1.055, vec3<f32>(2.4));
    return final_color;
}
// var<private> COLOR_START_POINTS: array<f32, COLOR_COUNT> = array<f32, COLOR_COUNT>(
//     0.0, 0.80, 0.90, 0.95
// );
// fn map_color(percent: f32) -> vec3<f32> {
//     // Determine the colors to mix
//     var end_color_index: u32 = 0u;
//     for (end_color_index = 0u; end_color_index<COLOR_COUNT; end_color_index++) {
//         if (percent < COLOR_START_POINTS[end_color_index]) {
//             // This is the second color
//             break;
//         }
//     }
//     var start_color_index: u32 = end_color_index - 1u;

//     var final_color: vec3<f32> = vec3<f32>(0.0);
//     if (end_color_index != COLOR_COUNT) {
//         // We have a color range
//         var start_color: vec3<f32> = COLORS[start_color_index];
//         var end_color: vec3<f32> = COLORS[end_color_index];

//         // Calculate ratio
//         let start: f32 = COLOR_START_POINTS[start_color_index];
//         let end: f32 = COLOR_START_POINTS[end_color_index];
//         let ratio = (percent - start) / (end - start);

//         // Mix colors
//         final_color = (start_color * (1.0 - ratio)) + (end_color * (ratio));

//     } else {
//         // No interpolation, use the last color
//         final_color = COLORS[COLOR_COUNT - 1u];
//     }

//     // Convert to sRGB color space
//     final_color = pow((final_color + 0.055) / 1.055, vec3<f32>(2.4));
//     return final_color;
// }