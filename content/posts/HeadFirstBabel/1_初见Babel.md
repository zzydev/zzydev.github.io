---
title: "1_初见Babel"
date: 2022-06-07T21:10:28+08:00
lastmod: 2022-06-19 00:28:56
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
  image: "https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfbabel/babel.jpeg"
  caption: ""
  alt: ""
  relative: false
---

{{< github name="babel" link="https://github.com/babel/babel" description="🐠 Babel is a compiler for writing next generation JavaScript." color="#2b7489" language="typescript" >}}
[babel 是什么](https://www.babeljs.cn/docs/index.html)

## babel 的编译流程

{{< spoiler "parse">}}
parse 阶段的目的是把源码字符串转换成机器能够理解的抽象语法树(AST)，这个过程分为词法分析、语法分析。

`let name = 'zzydev'` 经过词法分析得到 `let`、 `name`、 `=`、 `"zzydev"`Token 串。

词法分析的工作是将一个长长的字符串识别出一个个的单词，这一个个单词就是 Token。
读取 token 串，把它转化为 AST，这个过程就叫语法分析。
{{< /spoiler >}}

{{< spoiler  "transform">}}
transform 阶段是对 parse 生成的 AST 的处理，会进行 AST 的遍历，遍历的过程中处理到不同的 AST 节点会调用注册的相应的 visitor 函数，visitor 函数里可以对 AST 节点进行增删改，返回新的 AST（可以指定是否继续遍历新生成的 AST）。这样遍历完一遍 AST 之后就完成了对代码的修改。
{{< /spoiler >}}

{{< spoiler  "generate">}}
把转换后的 AST 打印成目标代码，并生成 sourcemap  
[sourcemap 原理](http://www.qiutianaimeili.com/html/page/2019/05/89jrubx1soc.html)
{{< /spoiler >}}

## Babel 与 AST

Javascript AST 遵循 [estree 规范](https://github.com/estree/estree)  
[Babel AST spec 与 estree spec 存在偏差](https://babeljs.io/docs/en/babel-parser#output)  
[⭐ Babel AST 规范](https://github.com/babel/babel/blob/master/packages/babel-parser/ast/spec.md)

[在线 AST 可视化工具(一)](https://astexplorer.net/)  
[在线 AST 可视化工具(二)](https://resources.jointjs.com/demos/rappid/apps/Ast/index.html)

[⭐ Babel 类型定义](https://github.com/babel/babel/blob/main/packages/babel-types/src/ast-types/generated/index.ts) 部分源码截取：

```typescript
//每种 AST 都有自己的属性，但是它们也有一些公共属性，其他AST Node通过继承BaseNode来获得公共属性
interface BaseNode {
  type: Node["type"]; //AST 节点的类型
  leadingComments?: ReadonlyArray<Comment> | null; //开始的注释
  innerComments?: ReadonlyArray<Comment> | null; //中间的注释
  trailingComments?: ReadonlyArray<Comment> | null; //结尾的注释
  start?: number | null; //源码字符串的开始下标
  end?: number | null; //源码字符串的结束下标
  loc?: SourceLocation | null; // 开始和结束的行列
  range?: [number, number]; // 相当于[start, end]
  extra?: Record<string, unknown>; //记录一些额外的信息，用于处理一些特殊情况。比如 StringLiteral 修改 value 只是值的修改，而修改 extra.raw 则可以连同单双引号一起修改。
}

## Babel的API
[](https://babeljs.io/docs/en/babel-core/#parse)

export interface SourceLocation {
  start: {
    line: number;
    column: number;
  };

  end: {
    line: number;
    column: number;
  };
}

interface BaseComment {
  value: string;
  start: number;
  end: number;
  loc: SourceLocation;
  type: "CommentBlock" | "CommentLine";
}

export interface CommentBlock extends BaseComment {
  type: "CommentBlock";
}

export interface CommentLine extends BaseComment {
  type: "CommentLine";
}

export type Comment = CommentBlock | CommentLine;
```
