// index.js

const express = require('express');
const fetch = require('node-fetch');

const app = express();
const PORT = process.env.PORT || 3000;

app.get('*', async (req, res) => {
  const path = req.path;

  // 获取 GitHub 仓库的目录和文件
  const response = await fetch(`https://api.github.com/repos/wangchunin/SHELL/contents${path}`, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; Cloudflare-Worker/1.0)',
      'Accept': 'application/vnd.github.v3+json'
    }
  });

  if (!response.ok) {
    return res.status(404).send('Not found');
  }

  const data = await response.json();

  if (Array.isArray(data)) {
    // 如果返回的是目录列表，则生成目录的 HTML 页面
    const html = generateDirectoryPage(data, path);
    res.send(html);
  } else {
    // 如果返回的是文件内容，则直接跳转到 GitHub 的文件显示页面
    const fileUrl = data.html_url;
    res.redirect(fileUrl);
  }
});

function generateDirectoryPage(data, currentPath) {
  // 生成目录的 HTML 页面
  let html = '<h1>Directory</h1>';
  html += '<ul>';
  data.forEach(item => {
    const itemName = item.name;
    const itemPath = item.path;
    const isDirectory = item.type === 'dir';
    const link = isDirectory ? `<a href="${itemPath}">${itemName}</a>` : `<a href="${item.html_url}" target="_blank">${itemName}</a>`;
    html += `<li>${link}</li>`;
  });
  html += '</ul>';
  return html;
}

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
