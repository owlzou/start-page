
/**
 * 编译着色器
 *
 * @param {WebGLRenderingContext} gl - gl上下文
 * @param {string} source - 着色器源码
 * @param {*} type - 类型，gl.VERTEX_SHADER 或 gl.FRAGMENT_SHADER
 * @returns
 */
function createShader(gl, source, type) {
    let shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        throw new Error(`ShaderInfoLog:\n${gl.getShaderInfoLog(shader)}`);
    }
    return shader;
}

/**
 * 编译并连接着色器
 *
 * @export
 * @param {WebGLRenderingContext} gl - gl上下文
 * @param {string} vsource - 顶点着色器源码
 * @param {string} fsource - 片段着色器源码
 * @returns {WebGLProgram|null} - 连接好的WebGLProgram，失败则返回null
 */
function getProgram(gl, vsource, fsource) {
    let vertShader = createShader(gl, vsource, gl.VERTEX_SHADER);
    let fragShader = createShader(gl, fsource, gl.FRAGMENT_SHADER);
    let shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertShader);
    gl.attachShader(shaderProgram, fragShader);
    gl.linkProgram(shaderProgram);
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
        throw new Error(`ProgramInfoLog:\n${gl.getProgramInfoLog(shaderProgram)}`);
    }
    return shaderProgram;
}

/**
 * 简单缓冲绑定
 *
 * @param {*} gl - gl上下文
 * @param {*} shaderProgram - shaderProgram
 * @param {*} name - 着色器里的属性名称
 * @param {*} data - 数据源
 * @param {*} size - 一组数据长度
 * @param {*} offset - 偏移
 * @param {*} stride - 步长
 * @param {*} indices - 索引（如果有）
 * @returns buffer
 */
function simpleBindBuffer(
    gl,
    shaderProgram,
    name,
    data,
    size,
    offset,
    stride,
    indices = null
) {
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data), gl.STATIC_DRAW);
    const index = gl.getAttribLocation(shaderProgram, name);
    gl.vertexAttribPointer(index, size, gl.FLOAT, false, offset, stride);

    if (indices != null) {
        const indexesBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexesBuffer);
        gl.bufferData(
            gl.ELEMENT_ARRAY_BUFFER,
            new Uint16Array(indices),
            gl.STATIC_DRAW
        );
    }
    gl.enableVertexAttribArray(index);
    return buffer;
}

function draw(canvas, vertexSource, fragmentSource, uTime = 0) {
    // 先设定宽高再取gl
    canvas.width = document.documentElement.clientWidth;
    canvas.height = document.documentElement.clientHeight;
    const gl = canvas.getContext("webgl");
    //正方形
    const vertices = [-1, -1, -1, 1, 1, -1, 1, 1];
    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    //创建着色器
    const shaderProgram = getProgram(gl, vertexSource, fragmentSource);
    //设置缓冲
    simpleBindBuffer(gl, shaderProgram, "aPosition", vertices, 2, 0, 0);
    gl.useProgram(shaderProgram);
    //未来添加其他可以绑定的参数也在这里：
    // - canvas 的大小
    gl.uniform2f(
        gl.getUniformLocation(shaderProgram, "uResolution"),
        parseFloat(canvas.width),
        parseFloat(canvas.height)
    );
    // - 运行时间
    gl.uniform1f(gl.getUniformLocation(shaderProgram, "uTime"), uTime / 1000);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
}

async function renderer() {
    const vertexSource = `
attribute vec2 aPosition;
void main(){
    gl_Position=vec4(aPosition,0.0,1.0);
}
`;
    const fragmentSource = await (await fetch("./bg.frag")).text();

    const canvas = document.getElementById("gl");
    window.requestAnimationFrame((timestamp) => anim(timestamp, canvas, vertexSource, fragmentSource));
}

function anim(timestamp, canvas, vertexSource, fragmentSource) {
    draw(canvas, vertexSource, fragmentSource, timestamp);
    window.requestAnimationFrame((timestamp) => anim(timestamp, canvas, vertexSource, fragmentSource));
}

renderer()
window.onresize = renderer