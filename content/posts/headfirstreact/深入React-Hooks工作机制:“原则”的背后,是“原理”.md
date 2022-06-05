---
title: "深入React Hooks工作机制:“原则”的背后,是“原理”"
date: 2022-06-03T17:34:48+08:00
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

React 团队面向开发者给出了两条 React-Hooks 的使用原则，原则的内容如下：

1. 只在 React 函数中调用 Hook；
2. 不要在循环、条件或嵌套函数中调用 Hook。

原则 2 中强调的所有“不要”，都是在指向同一个目的，那就是要**确保 Hooks 在每次渲染时都保持同样的执行顺序。**
PersonalInfoComponent 里去，看看实际项目中，变量到底是怎么发生变化的。

```javascript
import React, { useState } from "react";
// isMounted 用于记录是否已挂载（是否是首次渲染）
let isMounted = false;
function PersonalInfoComponent() {
  // 定义变量的逻辑不变
  let name, age, career, setName, setCareer;

  // 这里追加对 isMounted 的输出，这是一个 debug 性质的操作
  console.log("isMounted is", isMounted);
  // 这里追加 if 逻辑：只有在首次渲染（组件还未挂载）时，才获取 name、age 两个状态
  if (!isMounted) {
    // eslint-disable-next-line
    [name, setName] = useState("zzy");
    // eslint-disable-next-line
    [age] = useState("99");

    // if 内部的逻辑执行一次后，就将 isMounted 置为 true（说明已挂载，后续都不再是首次渲染了）
    isMounted = true;
  }

  // 对职业信息的获取逻辑不变
  [career, setCareer] = useState("我是一个前端，爱吃小熊饼干");
  // 这里追加对 career 的输出，这也是一个 debug 性质的操作
  console.log("career", career);
  // UI 逻辑的改动在于，name 和 age 成了可选的展示项，若值为空，则不展示
  return (
    <div className="personalInfo">
      {name ? <p>姓名：{name}</p> : null}
      {age ? <p>年龄：{age}</p> : null}
      <p>职业：{career}</p>
      <button
        onClick={() => {
          setName("唔知");
        }}
      >
        修改姓名
      </button>
    </div>
  );
}
export default PersonalInfoComponent;
```

![XwAh2n.png](https://s1.ax1x.com/2022/06/05/XwAh2n.png)

## Hooks 的正常运作，在底层依赖于顺序链表

### 以 useState 为例，分析 React-Hooks 的调用链路


[![XwA4vq.png](https://s1.ax1x.com/2022/06/05/XwA4vq.png)](https://imgtu.com/i/XwA4vq)

在这个流程中，useState 触发的一系列操作最后会落到 mountState 里面去，所以我们重点需要关注的就是 mountState 做了什么事情。

```javascript
// 进入 mounState 逻辑
function mountState(initialState) {
  // 将新的 hook 对象追加进链表尾部
  var hook = mountWorkInProgressHook();

  // initialState 可以是一个回调，若是回调，则取回调执行后的值
  if (typeof initialState === "function") {
    // $FlowFixMe: Flow doesn't like mixed types
    initialState = initialState();
  }

  // 创建当前 hook 对象的更新队列，这一步主要是为了能够依序保留 dispatch
  const queue = (hook.queue = {
    last: null,
    dispatch: null,
    lastRenderedReducer: basicStateReducer,
    lastRenderedState: (initialState: any),
  });

  // 将 initialState 作为一个“记忆值”存下来
  hook.memoizedState = hook.baseState = initialState;

  // dispatch 是由上下文中一个叫 dispatchAction 的方法创建的，这里不必纠结这个方法具体做了什么
  var dispatch = (queue.dispatch = dispatchAction.bind(
    null,
    currentlyRenderingFiber$1,
    queue
  ));
  // 返回目标数组，dispatch 其实就是示例中常常见到的 setXXX 这个函数，想不到吧？哈哈
  return [hook.memoizedState, dispatch];
}
```

从这段源码中我们可以看出，**mounState 的主要工作是初始化 Hooks**。在整段源码中，最需要关注的是 mountWorkInProgressHook 方法，它为我们道出了 Hooks 背后的数据结构组织形式。以下是 mountWorkInProgressHook 方法的源码：

```javascript
function mountWorkInProgressHook() {
  // 注意，单个 hook 是以对象的形式存在的
  var hook = {
    memoizedState: null,
    baseState: null,
    baseQueue: null,
    queue: null,
    next: null,
  };
  if (workInProgressHook === null) {
    // 这行代码每个 React 版本不太一样，但做的都是同一件事：将 hook 作为链表的头节点处理
    firstWorkInProgressHook = workInProgressHook = hook;
  } else {
    // 若链表不为空，则将 hook 追加到链表尾部
    workInProgressHook = workInProgressHook.next = hook;
  }
  // 返回当前的 hook
  return workInProgressHook;
}
```

到这里可以看出，**hook 相关的所有信息收敛在一个 hook 对象里，而 hook 对象之间以单向链表的形式相互串联。**

接下来我们再看更新过程的大图：

[![XwA25Q.png](https://s1.ax1x.com/2022/06/05/XwA25Q.png)](https://imgtu.com/i/XwA25Q)

根据图中高亮部分的提示不难看出，首次渲染和更新渲染的区别，在于**调用的是 `mountState`，还是 `updateState`。mountState 做了什么**，你已经非常清楚了；而 updateState 之后的操作链路，虽然涉及的代码有很多，但其实做的事情很容易理解：**按顺序去遍历之前构建好的链表，取出对应的数据信息进行渲染。**

我们把 mountState 和 updateState 做的事情放在一起来看：**mountState（首次渲染）构建链表并渲染；updateState 依次遍历链表并渲染。**

看到这里，你是不是已经大概知道怎么回事儿了？没错，**hooks 的渲染是通过“依次遍历”来定位每个 hooks 内容的。如果前后两次读到的链表在顺序上出现差异，那么渲染的结果自然是不可控的。**

这个现象有点像我们构建了一个长度确定的数组，数组中的每个坑位都对应着一块确切的信息，后续每次从数组里取值的时候，只能够通过索引（也就是位置）来定位数据。**Hooks 的本质其实是链表。**

### 站在底层视角，重现PersonalInfoComponent

从代码里面，我们可以提取出来的 useState 调用有三个：

```javascript
[name, setName] = useState("zzy");
[age] = useState("99");
[career, setCareer] = useState("我是一个前端，爱吃小熊饼干");

```

[![XwAgUg.png](https://s1.ax1x.com/2022/06/05/XwAgUg.png)](https://imgtu.com/i/XwAgUg)



当首次渲染结束，进行二次渲染的时候，实际发生的 useState 调用只有一个：

```javascript
useState("我是一个前端，爱吃小熊饼干")
```

链表此时的状态如下图所示：

[![XwAWCj.png](https://s1.ax1x.com/2022/06/05/XwAWCj.png)](https://imgtu.com/i/XwAWCj)

更新（二次渲染）的时候会发生什么事情：updateState 会依次遍历链表、读取数据并渲染。注意这个过程就像从数组中依次取值一样，是完全按照顺序（或者说索引）来的。因此 React 不会看你命名的变量名是 career 还是别的什么，它只认你这一次 useState 调用，于是它会认为：你想要的是第一个位置的 hook **。

然后就会有下面这样的效果：

[![XwAf8s.png](https://s1.ax1x.com/2022/06/05/XwAf8s.png)](https://imgtu.com/i/XwAf8s)
