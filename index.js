const fs = require('fs');
const path = require('path');
const express = require('express');

const app = express();
const rootDirectory = __dirname; // 根目录路径

// 读取根目录下的文件列表
const files = fs.readdirSync(rootDirectory);

// 生成目录列表的 HTML
const html = `
  <!DOCTYPE html>
  <html>
  <head>
    <title>文件列表</title>
    <style>
      ul {
        list-style-type: none;
      }
      li::before {
        content: "📄";
        margin-right: 0.5em;
      }
    </style>
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
app.get('/', (request, response) => {
  response.sendFile(path.join(__dirname, 'index.html'));
});

files.forEach((file) => {
  app.get(`/${file}`, handleFile(file));
});

// 启动服务器
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
