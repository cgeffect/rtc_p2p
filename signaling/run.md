要运行服务端的 Node.js 代码，可以按照以下步骤操作：

### 1. 安装 Node.js 和 npm
- **Node.js**：是一个基于 Chrome V8 引擎的 JavaScript 运行环境，能让 JavaScript 在服务器端运行。
- **npm**：Node.js 的包管理器，用于安装和管理项目依赖。

你可以从 [Node.js 官方网站](https://nodejs.org/) 下载适合你操作系统的安装包，然后按照安装向导进行安装。安装完成后，在终端中输入以下命令来验证是否安装成功：
```bash
node -v
npm -v
```
如果能正常输出版本号，说明安装成功。

### 2. 创建项目目录并初始化
- 在终端中创建一个新的项目目录，例如 `socketio-server`：
```bash
mkdir socketio-server
cd socketio-server
```
- 初始化项目，这会生成一个 `package.json` 文件，用于记录项目的元信息和依赖：
```bash
npm init -y
```
`-y` 参数表示使用默认配置快速初始化项目。

### 3. 安装项目依赖
将之前提供的服务端 Node.js 代码保存为 `server.js` 文件，放到项目目录下。该代码依赖 `express` 和 `socket.io` 这两个包，你可以使用以下命令进行安装：
```bash
npm install express socket.io
```
安装完成后，`package.json` 文件中会记录这两个依赖。

### 4. 运行服务端代码
在终端中，确保当前目录是项目目录，然后运行以下命令启动服务端：
```bash
node server.js
```
如果一切正常，你会在终端中看到类似以下的输出：
```
Server running on port 3000
```
这表示服务端已经成功启动，正在监听 3000 端口。

### 5. 测试服务端
你可以使用 `Socket.IO` 客户端来测试服务端是否正常工作。可以编写一个简单的 HTML 文件，使用 `Socket.IO` 的客户端库连接到服务端，示例代码如下：
```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Socket.IO Test</title>
    <script src="/socket.io/socket.io.js"></script>
    <script>
        const socket = io('http://localhost:3000');

        socket.on('connect', () => {
            console.log('Connected to server');
            socket.emit('sdpMessage', 'Hello, server!');
        });

        socket.on('sdpMessage', (message) => {
            console.log('Received message:', message);
        });
    </script>
</head>

<body>

</body>

</html>
```
将上述代码保存为 `test.html` 文件，然后在浏览器中打开该文件。如果服务端正常工作，你会在浏览器的控制台中看到连接成功的信息，并且服务端也会在终端中显示客户端连接的日志。

### 6. 停止服务端
要停止服务端，在终端中按下 `Ctrl + C` 组合键，服务端会停止运行。

通过以上步骤，你就可以成功运行服务端的 Node.js 代码，并进行简单的测试。 