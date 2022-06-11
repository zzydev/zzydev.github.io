---
title: "1_初见Babel"
date: 2022-06-07T21:10:28+08:00
draft: true
tags:
  - "babel"
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
  image: "https://github.com/zzydev/zzydev_blog_img/blob/master/headfirstbabel/babel.jpeg?raw=true"
  caption: ""
  alt: ""
  relative: false

---

[babel是什么](https://www.babeljs.cn/docs/index.html)

## babel 的编译流程
{{< spoiler "parse">}}
parse 阶段的目的是把源码字符串转换成机器能够理解的抽象语法树(AST)，这个过程分为词法分析、语法分析。

`let name = 'zzydev'`  经过词法分析得到  `let`、  `name`、 `=`、 `"zzydev"`Token串。

词法分析的工作是将一个长长的字符串识别出一个个的单词，这一个个单词就是 Token。
读取token串，把它转化为AST，这个过程就叫语法分析。
{{< /spoiler >}}

{{< spoiler  "transform">}}
transform 阶段是对 parse 生成的 AST 的处理，会进行 AST 的遍历，遍历的过程中处理到不同的 AST 节点会调用注册的相应的 visitor 函数，visitor 函数里可以对 AST 节点进行增删改，返回新的 AST（可以指定是否继续遍历新生成的 AST）。这样遍历完一遍 AST 之后就完成了对代码的修改。
{{< /spoiler >}}

{{< spoiler  "generate">}}
把转换后的 AST 打印成目标代码，并生成 sourcemap
{{< /spoiler >}}



