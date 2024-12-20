// index.js

const apiUrl = 'https://api.github.com/repos/wangchunin/SHELL/contents';

async function fetchDirectory(path) {
  const response = await fetch(apiUrl + path, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; Cloudflare-Worker/1.0)',
      'Accept': 'application/vnd.github.v3+json'
    }
  });

  if (!response.ok) {
    throw new Error('Failed to fetch directory');
  }

  const data = await response.json();
  return data;
}

function generateDirectoryPage(data, path) {
  const container = document.getElementById('container');
  container.innerHTML = '';

  const title = document.createElement('h1');
  title.textContent = 'Directory';
  container.appendChild(title);

  const ul = document.createElement('ul');
  container.appendChild(ul);

  data.forEach(item => {
    const li = document.createElement('li');
    ul.appendChild(li);

    const itemName = item.name;
    const itemPath = item.path;
    const isDirectory = item.type === 'dir';

    if (isDirectory) {
      const link = document.createElement('a');
      link.textContent = itemName;
      link.href = itemPath;
      link.addEventListener('click', async (event) => {
        event.preventDefault();
        await showDirectory(itemPath);
      });
      li.appendChild(link);
    } else {
      const link = document.createElement('a');
      link.textContent = itemName;
      link.href = itemPath;
      link.target = '_blank';
      li.appendChild(link);
    }
  });
}

async function showDirectory(path) {
  try {
    const data = await fetchDirectory(path);
    generateDirectoryPage(data, path);
  } catch (error) {
    console.error(error);
  }
}

showDirectory('/');
