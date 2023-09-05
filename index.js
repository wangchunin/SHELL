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

addEventListener('fetch', (event) => {
  const { request } = event;
  const { pathname } = new URL(request.url);

  if (pathname === '/') {
    // 生成文件列表
    const files = generateFileList(__dirname);

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

    event.respondWith(new Response(html, { headers: { 'Content-Type': 'text/html' } }));
  } else {
    // 处理文件请求
    const filePath = path.join(__dirname, pathname.substr(1));

    fs.readFile(filePath, 'utf-8', (err, data) => {
      if (err) {
        console.error(err);
        event.respondWith(new Response('Internal Server Error', { status: 500 }));
        return;
      }

      event.respondWith(new Response(data, { headers: { 'Content-Type': 'text/plain' } }));
    });
  }
});
