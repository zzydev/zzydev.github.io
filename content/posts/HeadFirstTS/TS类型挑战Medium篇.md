---
title: "TS类型挑战Medium篇"
date: 2022-06-24T00:59:50+08:00
lastmod: 2022-06-27
draft: true
tags:
  - "typescript"
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

{{< spoiler  "获取函数返回类型">}}
[💯Take a Challenge](https://tsch.js.org/2/play/zh-CN)
不使用 `ReturnType` 实现 TypeScript 的 `ReturnType<T>` 泛型。

例如：

```ts
const fn = (v: boolean) => {
  if (v) return 1;
  else return 2;
};

type a = MyReturnType<typeof fn>; // 应推导出 "1 | 2"
```

答案:

```ts
type ReturnType<T> = T extends (...args: any) => infer R ? R : never;
```

{{< /spoiler >}}

{{< spoiler  "实现 Omit">}}
[💯Take a Challenge](https://tsch.js.org/3/play/zh-CN)
不使用 `Omit` 实现 TypeScript 的 `Omit<T, K>` 泛型。

`Omit` 会创建一个省略 `K` 中字段的 `T` 对象。

例如：

```ts
interface Todo {
  title: string;
  description: string;
  completed: boolean;
}

type TodoPreview = MyOmit<Todo, "description" | "title">;

const todo: TodoPreview = {
  completed: false,
};
```

答案:

```ts
type MyOmit<T, K> = MyPick<T, MyExclude<keyof T, K>>;
```

{{< /spoiler >}}
