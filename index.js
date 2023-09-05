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
addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);

  if (url.pathname !== '/' && files.includes(url.pathname.slice(1))) {
    event.respondWith(handleFile(request));
  } else {
    event.respondWith(handleDirectoryListing());
  }
});

// 处理文件请求
async function handleFile(request) {
  const filePath = path.join(rootDirectory, request.url.slice(1));
  const data = await fs.promises.readFile(filePath, 'utf-8');

  return new Response(data, {
    headers: {
      'Content-Type': 'text/plain',
    },
  });
}

// 处理目录列表请求
async function handleDirectoryListing() {
  const indexHtmlPath = path.join(rootDirectory, 'index.html');
  const data = await fs.promises.readFile(indexHtmlPath, 'utf-8');

  return new Response(data, {
    headers: {
      'Content-Type': 'text/html',
    },
  });
}
