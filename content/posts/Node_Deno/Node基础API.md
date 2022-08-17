---
title: "Node基础API"
date: 2022-06-20T14:50:48+08:00
draft: true
tags:
  - "node"
author: ["zzydev"]
description: ""
weight: # 输入1可以顶置文章，用来给文章展示排序，不填就默认按时间排序
slug: ""
comments: true
showToc: true # 显示目录
TocOpen: true # 自动展开目录
hidemeta: false # 是否隐藏文章的元信息，如发布日期、作者等
disableShare: false # 底部不显示分享栏
showbreadcrumbs: true #顶部显示当前路径
cover:
  image: ""
  caption: ""
  alt: ""
  relative: false
---

### node 学习资源推荐

[node 中英对照文档](http://nodejs.cn/api/)
{{< douban src="https://book.douban.com/subject/25768396/" >}}
{{< douban src="https://book.douban.com/subject/30247892/" >}}

### node 基础概念

#### 异步 IO

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/node/1-1.png)

#### 事件驱动架构

[事件驱动实现 - 发布订阅模式](https://zzydev.top/posts/headfirstreact/3_%E6%95%B0%E6%8D%AE%E6%98%AF%E5%A6%82%E4%BD%95%E5%9C%A8react%E7%BB%84%E4%BB%B6%E4%B9%8B%E9%97%B4%E6%B5%81%E5%8A%A8%E7%9A%84/#%E5%8F%91%E5%B8%83-%E8%AE%A2%E9%98%85%E6%A8%A1%E5%9E%8B%E7%BC%96%E7%A0%81%E5%AE%9E%E7%8E%B0)

```javascript
const EventEmitter = require("events");
const myEvent = new EventEmitter();
myEvent.on("事件1", () => {
  console.log("事件1执行了");
});
myEvent.emit("事件1");
```

#### node 的主线程是单线程的

运行 JS 代码的主线程是单线程的  
libuv 存在存放多个线程的线程池

#### node 的应用场景

BFF 层
![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/node/1-2.png)
{{< spoiler  "常见模块基础用法">}}

#### fs 模块

```javascript
const data = fs.readFileSync("./data.json", (err, data) => {
  //错误优先的回调函数
  if (err) {
    throw err;
  }
  console.log(data.toString());
});

async function() {
  const {promisify} = require("util");
  const readFile = promisify(fs.readFile);
  const data = await readFile("./data.json");
  console.log(data.toString());
}
```

#### buffer 模块

```javascript
const buf1 = Buffer.alloc(10);
console.log("buf1:", buf1); // buf1: <Buffer 00 00 00 00 00 00 00 00 00 00>
// 两个16进制的 00 有8个bit, 代表1个字节

const buf2 = Buffer.from("郑");
console.log("buf2:", buf2); // buf2: <Buffer e9 83 91> 把"郑"存到缓冲区里。

const buf3 = Buffer.concat([buf1, buf2]); // 合并两个缓冲区
console.log("buf3:", buf3, buf3.toString());
//buf3: <Buffer 00 00 00 00 00 00 00 00 00 00 e9 83 91> 郑
```

#### stream 模块

```javascript
const rs = fs.createReadStream("./01.png");
const ws = fs.createWriteStream("./02.png");
rs.pipe(ws);
```

#### process 模块

[process](http://nodejs.cn/api/process/process_memoryusage.html)

```javascript
// 资源： CPU 内存
Buffer.alloc(1000);
console.log(process.memoryUsage());
// {
//  rss: 4935680,
//  heapTotal: 1826816,
//  heapUsed: 650472,
//  external: 49879,
//  arrayBuffers: 9386 + 1000
// }

console.log(process.cpuUsage());

// 运行环境：工作目录、node环境、cpu架构、用户环境、系统平台
console.log(process.cwd());
console.log(process.version);
console.log(process.versions);
console.log(process.arch);
console.log(process.env.NODE_ENV);
console.log(process.env.PATH);
console.log(process.platform);
```

{{< /spoiler >}}
