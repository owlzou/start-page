const SOURCE = "src/Main.elm";
const TEMP_FILE = "main.js";
const DIST = "./dist";

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

if (fs.existsSync(DIST)) {
  console.log("清理 dist 文件夹");
  removeInDir(DIST);
} else {
  fs.mkdirSync(DIST);
}

if (!fs.existsSync(path.join(DIST, "js"))) {
  fs.mkdirSync(path.join(DIST, "js"));
}


/* fs.readdirSync("./public/js").forEach((i) => {
  console.log(`压缩 ./public/js/${i}`);
  execSync(
    `npx minify ./public/js/${i} --out-file ${path.join(DIST, "js", i)}`
  );
}); */

console.log("编译&压缩 Elm");
execSync(`elm make ${SOURCE} --optimize --output=${TEMP_FILE}`);
execSync(
  `uglifyjs ${TEMP_FILE} --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle -o ${DIST}/js/elm.js`
);
fs.unlinkSync(TEMP_FILE);

console.log("编译 CSS");
execSync(`stylus "src/css/main.styl" -o "${DIST}/style.css" --compress`);

copyDirFile("./public", DIST);

/* --------------------------------- HELPER --------------------------------- */

function copyDirFile(from, to) {
  fs.readdirSync(from).forEach((i) => {
    if (fs.statSync(path.join(from, i)).isFile()) {
      console.log(`复制 ${i}`);
      fs.copyFileSync(path.join(from, i), path.join(to, i));
    }
  });
}

function removeInDir(dir) {
  fs.readdirSync(dir).forEach((i) => {
    const file = path.join(dir, i);
    if (fs.statSync(file).isDirectory()) {
      removeInDir(file);
      fs.rmdirSync(file);
    } else {
      fs.unlinkSync(file);
    }
  });
}
