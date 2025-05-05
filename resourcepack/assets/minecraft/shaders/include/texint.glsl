#version 150

vec4 encodeInt(int i) {
    float a = 1.0;
    if (i < 0) {
        i *= -1;
        a = 0.5;
    }
    int r = i % 255;
    i = i / 255;
    int g = i % 255;
    i = i / 255;
    int b = i % 255;
    return vec4(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0, a);
}

int decodeInt(vec4 ivec) {
    ivec.rgb *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num * int(floor(4.0 * (ivec.a - 0.75) + 0.5));
}