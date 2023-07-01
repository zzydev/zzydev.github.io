---
title: "TS设计模式"
date: 2023-06-29T04:37:14+08:00
lastmod:
draft: true
tags:
    - ""
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

## 工厂模式

```ts
interface IProduct {
    name: string;
    fn1: () => void;
    fn2: () => void;
}

class Product1 implements IProduct {
    constructor(public name: string) {}
    fn1() {
        console.log("product1");
    }
    fn2() {
        console.log("product1");
    }
}

class Product2 implements IProduct {
    constructor(public name: string) {}
    fn1() {
        console.log("product2");
    }
    fn2() {
        console.log("product1");
    }
}

class Creator {
    // 依赖倒置原则 （依赖抽象，而不是具体）
    create(type: string, name: string): IProduct {
        if (type === "p1") {
            return new Product1(name);
        }
        if (type === "p2") {
            return new Product2(name);
        }
        throw new Error();
    }
}
```

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/DesignPatterns/factory01.png)
