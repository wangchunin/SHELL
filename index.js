const fs = require('fs');
const path = require('path');

const directory = './'; // 目录路径

// 读取目录中的文件列表
fs.readdir(directory, (err, files) => {
  if (err) {
    console.error(err);
    return;
  }

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
});
