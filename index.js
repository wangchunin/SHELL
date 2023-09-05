addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const path = url.pathname

  // 如果请求的路径不是根目录下的文件，则返回默认的 Cloudflare Pages 网页
  if (path !== '/') {
    return fetch(request)
  }

  const response = new Response()
  const headers = { 'Content-Type': 'text/html' }
  const files = await getFiles()

  // 构建文件列表的 HTML
  const fileList = files.map(file => `<li><a href="/${file}">${file}</a></li>`).join('')
  const html = `
    <html>
      <head>
        <title>文件列表</title>
      </head>
      <body>
        <h1>文件列表</h1>
        <ul>${fileList}</ul>
      </body>
    </html>
  `

  response.headers.set('Content-Type', 'text/html')
  response.body = html

  return response
}

async function getFiles() {
  // 使用 GitHub API 获取仓库根目录下的文件列表
  const response = await fetch('https://api.github.com/repos/wangchunin/SHELL/contents')
  const data = await response.json()

  // 过滤出文件，并返回文件名列表
  const files = data.filter(item => item.type === 'file').map(item => item.name)
  return files
}
