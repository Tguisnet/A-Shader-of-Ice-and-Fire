#version 450

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_normal1;
uniform float wave_speed;
uniform float total_time;
uniform int mesh_id;

in TES_OUT
{
    vec4 pos;
    vec3 normal;
    vec2 tex_coords;
    mat3 TBN;
    vec4 clip_space;
} gs_in[];

out GS_OUT
{
    vec4 pos;
    vec3 normal;
    vec2 tex_coords;
    mat3 TBN;
    vec4 clip_space;
} gs_out;

vec3 compute_decay(vec2 tex_coords, mat3 TBN)
{
    // Add distortion to texture coordinates
    const float wave_strength = 0.02;
    vec2 distorted_tex_coords = vec2(tex_coords.x + wave_speed, tex_coords.y);
    distorted_tex_coords = texture(texture_diffuse1, distorted_tex_coords).rg * 0.1;
    distorted_tex_coords = tex_coords + distorted_tex_coords;
    distorted_tex_coords.y += wave_speed;

    vec3 normal_distor = texture(texture_normal1, distorted_tex_coords).rgb;
    normal_distor *= 0.5;
    normal_distor = normalize(normal_distor * 2.0 - 1.0);
    normal_distor = normalize(TBN * normal_distor);

    return normal_distor;
}

void set_out(int index)
{
    gs_out.pos = gs_in[index].pos;
    gs_out.normal = gs_in[index].normal;
    gs_out.tex_coords = gs_in[index].tex_coords;
    gs_out.TBN = gs_in[index].TBN;
    gs_out.clip_space = gs_in[index].clip_space;
    gl_Position = gl_in[index].gl_Position;
    gl_ClipDistance[0] = gl_in[index].gl_ClipDistance[0];

    vec3 decay = compute_decay(gs_in[index].tex_coords, gs_in[index].TBN);
    const float decay_strength = 1.1;
    float d = (decay.x + decay.z) * decay_strength;
    gl_Position.y += d;
    gs_out.pos.y += d;
}

void main()
{
    set_out(0);
    EmitVertex();

    set_out(1);
    EmitVertex();

    set_out(2);
    EmitVertex();

    EndPrimitive();
}