---
title: "9.如何理解Fiber架构的迭代动机与设计思想"
date: 2022-06-06T19:15:48+08:00
lastmod: 2022-06-18 16:55:46
draft: true
tags:
  - "react"
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

## 前置知识：单线程的 JavaScript 与多线程的浏览器

**JavaScript 线程和渲染线程必须是互斥的**：这两个线程不能够穿插执行，必须串行。**当其中一个线程执行时，另一个线程只能挂起等待。**

在这样的机制下，若 JavaScript 线程长时间地占用了主线程，那么**渲染层面的更新就不得不长时间地等待，界面长时间不更新，带给用户的体验就是所谓的“卡顿”。**一般页面卡顿的时候，你会做什么呢？我个人的习惯是更加频繁地在页面上点来点去，期望页面能够给我哪怕一点点的响应。遗憾的是，**事件线程也在等待 JavaScript，这就导致你触发的事件也将是难以被响应的。**

## 为什么会产生“卡顿”这样的困局？

**Stack Reconciler 需要的（同步递归）调和时间很长**，这就意味着 **JavaScript 线程将长时间地占用主线程**，进而导致我们上文中所描述的渲染卡顿/卡死、交互长时间无响应等问题。

## 设计思想：Fiber 是如何解决问题的

**Fiber 就是比线程还要纤细的一个过程**，也就是所谓的“**纤程**”。纤程的出现，意在**对渲染过程实现更加精细的控制**。

- 从架构角度 Fiber 是对 React 核心算法（即调和过程）的重写
- 从编码角度 Fiber 是 React 内部所定义的一种数据结构，它是 Fiber 树结构的节点单位，也就是 React 16 新架构下的“虚拟 DOM”
- 从工作流的角度 Fiber 节点保存了组件需要更新的状态和副作用，一个 Fiber 同时也对应着一个工作单元。

Fiber 架构的应用目的，按照 React 官方的说法，是实现“**增量渲染**”。所谓“增量渲染”，通俗来说就是**把一个渲染任务分解为多个渲染任务，而后将其分散到多个帧里面**。不过严格来说，增量渲染其实也只是一种手段，实现增量渲染的目的，是为了**实现任务的可中断、可恢复，并给不同的任务赋予不同的优先级**，最终达成更加顺滑的用户体验。

## Fiber 架构核心：“可中断”“可恢复”与“优先级”

### React15 架构

React15 架构可以分为两层：

- Reconciler（协调器）—— 负责找出变化的组件
- Renderer（渲染器）—— 负责将变化的组件渲染到页面上

#### Reconciler 协调器

我们知道，在`React`中可以通过`this.setState`、`this.forceUpdate`、`ReactDOM.render`等 API 触发更新。

每当有更新发生时，**Reconciler**会做如下工作：

- 调用函数组件、或 class 组件的`render`方法，将返回的 JSX 转化为虚拟 DOM
- 将虚拟 DOM 和上次更新时的虚拟 DOM 对比
- 通过对比找出本次更新中变化的虚拟 DOM
- 通知**Renderer**将变化的虚拟 DOM 渲染到页面上

{{< notice notice-note >}}
{{< quote >}}
你可以在[这里 ](https://zh-hans.reactjs.org/docs/codebase-overview.html#reconcilers)看到`React`官方对**Reconciler**的解释
{{< /quote >}}
{{< /notice >}}

#### React15 架构的缺点

在**Reconciler**中，`mount`的组件会调用[mountComponent ](https://github.com/facebook/react/blob/15-stable/src/renderers/dom/shared/ReactDOMComponent.js#L498)，`update`的组件会调用[updateComponent ](https://github.com/facebook/react/blob/15-stable/src/renderers/dom/shared/ReactDOMComponent.js#L877)。这两个方法都会递归更新子组件。

### React16 架构

React16 架构可以分为三层：

- Scheduler（调度器）—— 调度任务的优先级，高优任务优先进入**Reconciler**
- Reconciler（协调器）—— 负责找出变化的组件
- Renderer（渲染器）—— 负责将变化的组件渲染到页面上

相较于 React15，React16 中新增了**Scheduler（调度器）**

#### Scheduler（调度器）

既然我们以浏览器是否有剩余时间作为任务中断的标准，那么我们需要一种机制，当浏览器有剩余时间时通知我们。

其实部分浏览器已经实现了这个 API，这就是[requestIdleCallback](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/requestIdleCallback)。但是由于以下因素，`React`放弃使用：

- 浏览器兼容性
- 触发频率不稳定，受很多因素影响。比如当我们的浏览器切换 tab 后，之前 tab 注册的`requestIdleCallback`触发的频率会变得很低

基于以上原因，`React`实现了功能更完备的`requestIdleCallback`polyfill，这就是**Scheduler**。除了在空闲时触发回调的功能外，**Scheduler**还提供了多种调度优先级供任务设置。

{{< notice notice-tip >}}

[Scheduler ](https://github.com/facebook/react/blob/1fb18e22ae66fdb1dc127347e169e73948778e5a/packages/scheduler/README.md)是独立于`React`的库

{{< /notice >}}

#### Reconciler（协调器）

我们知道，在 React15 中**Reconciler**是递归处理虚拟 DOM 的。让我们看看[React16 的 Reconciler](https://github.com/facebook/react/blob/1fb18e22ae66fdb1dc127347e169e73948778e5a/packages/react-reconciler/src/ReactFiberWorkLoop.new.js#L1673)。

我们可以看见，更新工作从递归变成了可以中断的循环过程。每次循环都会调用`shouldYield`判断当前是否有剩余时间。

```javascript
function workLoopConcurrent() {
  // Perform work until Scheduler asks us to yield
  while (workInProgress !== null && !shouldYield()) {
    workInProgress = performUnitOfWork(workInProgress);
  }
}
```

那么 React16 是如何解决中断更新时 DOM 渲染不完全的问题呢？

在 React16 中，**Reconciler**与**Renderer**不再是交替工作。当**Scheduler**将任务交给**Reconciler**后，**Reconciler**会为变化的虚拟 DOM 打上代表增/删/更新的标记，类似这样：

```javascript
export const Placement = /*             */ 0b0000000000010;
export const Update = /*                */ 0b0000000000100;
export const PlacementAndUpdate = /*    */ 0b0000000000110;
export const Deletion = /*              */ 0b0000000001000;
```

{{< notice notice-tip >}}

全部的标记见[这里](https://github.com/facebook/react/blob/1fb18e22ae66fdb1dc127347e169e73948778e5a/packages/react-reconciler/src/ReactSideEffectTags.js)

{{< /notice >}}

整个**Scheduler**与**Reconciler**的工作都在内存中进行。只有当所有组件都完成**Reconciler**的工作，才会统一交给**Renderer**。

{{< notice notice-tip >}}

> 你可以在[这里](https://zh-hans.reactjs.org/docs/codebase-overview.html#fiber-reconciler)看到`React`官方对 React16 新**Reconciler**的解释

{{< /notice >}}

#### Renderer（渲染器）

**Renderer**根据**Reconciler**为虚拟 DOM 打的标记，同步执行对应的 DOM 操作。

### 总结

在这套新的架构模式下，更新的处理工作流变成了这样：首先，**每个更新任务都会被赋予一个优先级**。当更新任务抵达调度器时，高优先级的更新任务（记为 A）会更快地被调度进 Reconciler 层；此时若有新的更新任务（记为 B）抵达调度器，调度器会检查它的优先级，若发现 B 的优先级高于当前任务 A，那么当前处于 Reconciler 层的 A 任务就会被中断，调度器会将 B 任务推入 Reconciler 层。当 B 任务完成渲染后，新一轮的调度开始，之前被中断的 **A 任务将会被重新推入 Reconciler 层，继续它的渲染之旅，这便是所谓“可恢复”**。

## Fiber 架构对生命周期的影响

[Fiber 对生命周期的影响](https://zzydev.top/posts/headfirstreact/2_react%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F/#%e7%bb%86%e8%af%b4%e7%94%9f%e5%91%bd%e5%91%a8%e6%9c%9f%e5%ba%9f%e6%97%a7%e7%ab%8b%e6%96%b0%e8%83%8c%e5%90%8e%e7%9a%84%e6%80%9d%e8%80%83)
