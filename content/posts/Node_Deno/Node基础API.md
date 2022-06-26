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

[node 中英对照文档](http://nodejs.cn/api/)
{{< douban src="https://book.douban.com/subject/25768396/" >}}
{{< douban src="https://book.douban.com/subject/30247892/" >}}

{{< spoiler  "常见模块基础用法">}}
fs 模块

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

buffer 模块

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

stream 模块

```javascript
const rs = fs.createReadStream("./01.png");
const ws = fs.createWriteStream("./02.png");
rs.pipe(ws);
```

{{< /spoiler >}}
