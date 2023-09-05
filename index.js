const fs = require('fs');
const path = require('path');

const rootDirectory = __dirname; // 根目录路径

// 递归遍历目录结构并生成文件列表
function generateFileList(directory) {
  const files = fs.readdirSync(directory);
  const fileList = [];

  files.forEach((file) => {
    const filePath = path.join(directory, file);
    const stats = fs.statSync(filePath);

    if (stats.isFile()) {
      fileList.push(filePath);
    } else if (stats.isDirectory()) {
      const subDirectoryFiles = generateFileList(filePath);
      fileList.push(...subDirectoryFiles);
    }
  });

  return fileList;
}

// 生成文件列表
const files = generateFileList(rootDirectory);

// 生成目录列表的 HTML
const html = `
  <!DOCTYPE html>
  <html>
  <head>
    <title>文件列表</title>
    <style>
      pre {
        white-space: pre-wrap;
        font-family: monospace;
      }
    </style>
  </head>
  <body>
    <h1>文件列表</h1>
    <ul>
      ${files.map((file) => `<li><a href="${file}">${file}</a></li>`).join('\n')}
    </ul>
  </body>
  </html>
`;

// 将生成的 HTML 写入 index.html 文件
fs.writeFile('index.html', html, (err) => {
  if (err) {
    console.error(err);
    return;
  }
  console.log('目录列表已生成');
});

// 为每个文件创建对应的路由
files.forEach((file) => {
  // 创建路由处理函数
  const handleFile = (request, response) => {
    fs.readFile(file, 'utf-8', (err, data) => {
      if (err) {
        console.error(err);
        response.statusCode = 500;
        response.end('Internal Server Error');
        return;
      }

      response.setHeader('Content-Type', 'text/plain');
      response.end(data);
    });
  };

  // 注册路由
  addEventListener('fetch', (event) => {
    const request = event.request;
    const url = new URL(request.url);

    if (url.pathname === `/${file}`) {
      event.respondWith(new Response(handleFile(request, response)));
    }
  });
});
