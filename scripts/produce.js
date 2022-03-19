const SOURCE = "src/Main.elm"
const TEMP_FILE = "main.js"
const OUTPUT = "dist/elm.js"
const DIST = "./dist"

const { execSync } = require("child_process")
const fs = require("fs")

if (fs.existsSync(DIST)) {
    removeInDir(DIST)
} else {
    fs.mkdir(DIST)
}

execSync(`elm make ${SOURCE} --optimize --output=${TEMP_FILE}`);
execSync(`uglifyjs ${TEMP_FILE} --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle -o ${OUTPUT}`)
fs.unlinkSync(TEMP_FILE);

execSync(`stylus "src/css/main.styl" -o "${DIST}/style.css" --compress`)
copyDir("./public", DIST);


function copyDir(from, to) {
    fs.readdirSync(from).forEach((i) => {
        fs.copyFileSync(`${from}/${i}`, `${to}/${i}`);
    })
}

function removeInDir(dir) {
    fs.readdirSync(dir).forEach((i) => {
        fs.unlinkSync(`${dir}/${i}`);
    })
}