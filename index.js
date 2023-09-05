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
  </head>
  <body>
    <h1>文件列表</h1>
    <ul>
      ${files.map((file) => `<li><a href="/${file}">${file}</a></li>`).join('\n')}
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

// 处理文件请求
const handleFile = (file) => {
  return (request, response) => {
    const filePath = path.join(rootDirectory, file);
    const data = fs.readFileSync(filePath, 'utf-8');

    response.setHeader('Content-Type', 'text/plain');
    response.end(data);
  };
};

// 注册路由
const express = require('express');
const app = express();

app.get('/', (request, response) => {
  response.sendFile(path.join(__dirname, 'index.html'));
});

files.forEach((file) => {
  app.get(`/${file}`, handleFile(file));
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
