const fs = require('fs');
const path = require('path');

const rootDirectory = __dirname; // 根目录路径

// 生成文件列表
const files = fs.readdirSync(rootDirectory).filter((file) => {
  const filePath = path.join(rootDirectory, file);
  return fs.statSync(filePath).isFile();
});

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
  const handleFile = async (request) => {
    const data = await fs.promises.readFile(path.join(rootDirectory, file), 'utf-8');

    return new Response(data, {
      headers: {
        'Content-Type': 'text/plain',
      },
    });
  };

  // 注册路由
  addRoute(`/${file}`, handleFile);
});
