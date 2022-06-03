---
title: "React Hooks设计动机与工作模式"
date: 2022-06-03T11:16:41+08:00
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

## 函数组件会捕获 render 内部的状态，这是两类组件最大的不同。

React 框架的主要工作，就是及时地把声明式的代码转换为命令式的 DOM 操作，把数据层面的描述映射到用户可见的 UI 变化中去。这就意味着从原则上来讲，React 的数据应该总是紧紧地和渲染绑定在一起的，而类组件做不到这一点。

如果你在这个[在线 Demo](https://codesandbox.io/s/pjqnl16lm7)中尝试点击基于类组件形式编写的 ProfilePage 按钮后 3s 内把用户切换为 Sophie，你就会看到如下图所示的效果：

![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a065cbd6-ac26-49c5-a6a7-c931a4867b84/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T032248Z&X-Amz-Expires=86400&X-Amz-Signature=814f17b896135d445ce63e2e2b00f4e059b461869f66700fe51066acddee6d96&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

明明我们是在 Dan 的主页点击的关注，结果却提示了“Followed Sophie”！

这个现象必然让许多人感到困惑：user 的内容是通过 props 下发的，props 作为不可变值，为什么会从 Dan 变成 Sophie 呢？

因为虽然 **props 本身是不可变的，但 this 却是可变的，this 上的数据是可以被修改的**，this.props 的调用每次都会获取最新的 props，而这正是 React 确保数据实时性的一个重要手段。

多数情况下，在 React 生命周期对执行顺序的调控下，this.props 和 this.state 的变化都能够和预期中的渲染动作保持一致。但在这个案例中，我们**通过 setTimeout 将预期中的渲染推迟了 3s，打破了 this.props 和渲染动作之间的这种时机上的关联**，进而导致渲染时捕获到的是一个错误的、修改后的 this.props。这就是问题的所在。

但如果我们把 ProfilePage 改造为一个像这样的函数组件：

```javascript
function ProfilePage(props) {
  const showMessage = () => {
    alert('Followed ' + props.user);
  };
  const handleClick = () => {
    setTimeout(showMessage, 3000);
  };
  return (
    <button onClick={handleClick}>Follow</button>
  );
}
```

事情就会大不一样。

props 会在 ProfilePage 函数执行的一瞬间就被捕获，而 props 本身又是一个不可变值，因此**我们可以充分确保从现在开始，在任何时机下读取到的 props，都是最初捕获到的那个 props**。当父组件传入新的 props 来尝试重新渲染 ProfilePage 时，本质上是基于新的 props 入参发起了一次全新的函数调用，并不会影响上一次调用对上一个 props 的捕获。这样一来，我们便确保了渲染结果确实能够符合预期。

总结：**“函数组件会捕获 render 内部的状态”**，**函数组件真正地把数据和渲染绑定到了一起。**

**函数组件是一个更加匹配React设计理念、也更有利于逻辑拆分与重用的组件表达形式**，React-Hooks 便应运而生。

## 从核心 API 看 Hooks 的基本形态

### useState()：为函数组件引入状态

```javascript
const [state, setState] = useState(initialState);

//状态和修改状态的 API 名都是可以自定义的
const [text, setText] = useState("初始文本");

//它就像类组件中 state 对象的某一个属性一样，对应着一个单独的状态，允许你存储任意类型的值
// 定义为数组
const [author, setAuthor] = useState(["xiuyan", "cuicui", "yisi"]);
// 定义为数值
const [length, setLength] = useState(100);
// 定义为字符串
const [text, setText] = useState("初始文本")
```

### useEffect()：允许函数组件执行副作用操作

```javascript
```

