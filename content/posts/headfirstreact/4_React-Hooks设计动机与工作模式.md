---
title: "4.React Hooks设计动机与工作模式"
date: 2022-06-03T11:16:41+08:00
lastmod: 2022-06-18 10:07:04
draft: false
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

## 函数组件会捕获 render 内部的状态，这是两类组件最大的不同。

React 框架的主要工作，就是及时地把声明式的代码转换为命令式的 DOM 操作，把数据层面的描述映射到用户可见的 UI 变化中去。这就意味着从原则上来讲，React 的数据应该总是紧紧地和渲染绑定在一起的，而类组件做不到这一点。

如果你在这个[在线 Demo](https://codesandbox.io/s/pjqnl16lm7)中尝试点击基于类组件形式编写的 ProfilePage 按钮后 3s 内把用户切换为 Sophie，你就会看到如下图所示的效果：

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfreact/4-1.png)

明明我们是在 Dan 的主页点击的关注，结果却提示了“Followed Sophie”！

这个现象必然让许多人感到困惑：user 的内容是通过 props 下发的，props 作为不可变值，为什么会从 Dan 变成 Sophie 呢？

因为虽然 **props 本身是不可变的，但 this 却是可变的，this 上的数据是可以被修改的**，this.props 的调用每次都会获取最新的 props，而这正是 React 确保数据实时性的一个重要手段。

多数情况下，在 React 生命周期对执行顺序的调控下，this.props 和 this.state 的变化都能够和预期中的渲染动作保持一致。但在这个案例中，我们**通过 setTimeout 将预期中的渲染推迟了 3s，打破了 this.props 和渲染动作之间的这种时机上的关联**，进而导致渲染时捕获到的是一个错误的、修改后的 this.props。这就是问题的所在。

但如果我们把 ProfilePage 改造为一个像这样的函数组件：

```javascript
function ProfilePage(props) {
  const showMessage = () => {
    alert("Followed " + props.user);
  };
  const handleClick = () => {
    setTimeout(showMessage, 3000);
  };
  return <button onClick={handleClick}>Follow</button>;
}
```

事情就会大不一样。

props 会在 ProfilePage 函数执行的一瞬间就被捕获，而 props 本身又是一个不可变值，因此**我们可以充分确保从现在开始，在任何时机下读取到的 props，都是最初捕获到的那个 props**。当父组件传入新的 props 来尝试重新渲染 ProfilePage 时，本质上是基于新的 props 入参发起了一次全新的函数调用，并不会影响上一次调用对上一个 props 的捕获。这样一来，我们便确保了渲染结果确实能够符合预期。

总结：**“函数组件会捕获 render 内部的状态”**，**函数组件真正地把数据和渲染绑定到了一起。**

**函数组件是一个更加匹配 React 设计理念、也更有利于逻辑拆分与重用的组件表达形式**

## 从核心 API 看 Hooks 的基本形态

### useState()：为函数组件引入状态

```javascript
const [state, setState] = useState(initialState);

//状态和修改状态的 API 名都是可以自定义的
const [text, setText] = useState("初始文本");

//它就像类组件中 state 对象的某一个属性一样，对应着一个单独的状态，允许你存储任意类型的值
// 定义为数组
const [author, setAuthor] = useState(["zzydev", "zzy"]);
// 定义为数值
const [length, setLength] = useState(100);
// 定义为字符串
const [text, setText] = useState("初始文本");
```

{{< notice notice-info >}}
**state 中永远不要保存可以通过计算得到的值。** 比如：

1.  从 props 传递过来的值。有时候 props 传递过来的值无法直接使用，而是要通过一定的计算后再在 UI 上展示，比如说排序。那么我们要做的就是每次用的时候，都重新排序一下，或者利用某些 cache 机制，而不是将结果直接放到 state 里。
2.  从 URL 中读到的值。有时我们要读取 URL 中的参数，把它作为组件的一部分状态。那么我们可以在每次需要用的时候，从 URL 中读取，而不是读出来放在 state 中。
3.  从 cookie、localStorage 中读取的值。通常每次要用的时候直接去读取，而不是读出来放到 state 中。
    {{< /notice >}}
    state 虽然便于维护状态，但也有自己的弊端。一旦组件有自己状态，意味着组件如果重新创建，就需要有恢复状态的过程，这通常会让组件变得更复杂。比如一个组件想在服务器端请求获取一个用户列表并显示，如果把读取到的数据放到本地的 state 里，那么每个用到这个组件的地方，就都需要重新获取一遍。

### useEffect()：允许函数组件执行副作用操作

useEffect 能够为函数组件引入副作用。过去我们习惯放在 componentDidMount、componentDidUpdate 和 componentWillUnmount 三个生命周期里来做的事，现在可以放在 useEffect 里来做，比如操作 DOM、订阅事件、调用外部 API 获取数据等。

{{< notice notice-tip >}}
useEffect 是每次组件 render 完后判断依赖并执行
{{< /notice >}}

- 没有依赖项，则每次 render 后都会重新执行。

```javascript
useEffect(() => {
  // 每次 render 完都会执行
  console.log("re-rendered");
});
```

- 仅在挂载阶段执行一次的副作用：传入回调函数，且这个函数的返回值不是一个函数，同时传入一个空数组作为依赖项。对应到 Class 组件就是 componentDidMount。

```javascript
useEffect(() => {
  // 这里是业务逻辑
  console.log("did mount");
}, []);
```

- 仅在挂载阶段和卸载阶段执行的副作用：传入回调函数，且这个函数的返回值是一个函数，同时传入一个空数组。假如回调函数本身记为 A， 返回的函数记为 B，那么将在挂载阶段执行 A，卸载阶段执行 B。这个机制就几乎等价于类组件中的 componentWillUnmount。

```javascript
useEffect(() => {
  // 这里是 A 的业务逻辑

  // 返回一个函数记为 B
  return () => {};
}, []);
```

useEffect 回调中返回的函数被称为“清除函数”，当 React 识别到清除函数时，会在卸载时执行清除函数内部的逻辑。这个规律不会受第二个参数或者其他因素的影响，只要你在 useEffect 回调中返回了一个函数，它就会被作为清除函数来处理。

- 每一次渲染都触发，且卸载阶段也会被触发的副作用：传入回调函数，且这个函数的返回值是一个函数，同时不传第二个参数。

```javascript
useEffect(() => {
  // 这里是 A 的业务逻辑

  // 返回一个函数记为 B
  return () => {};
});
//React 在每一次渲染都去触发 A 逻辑，并且在下一次 A 逻辑被触发之前去触发 B 逻辑。
```

- 根据一定的依赖条件来触发的副作用：传入回调函数（若返回值是一个函数，仍然仅影响卸载阶段对副作用的处理，此处不再赘述），同时传入一个非空的数组。

```javascript
useEffect(() => {
  // 这是回调函数的业务逻辑

  // 若 xxx 是一个函数，则 xxx 会在组件卸载时被触发
  return xxx;
}, [num1, num2, num3]);
/*
数组中的变量一般都是来源于组件本身的数据（props 或者 state）。
若数组不为空，那么 React 就会在新的一次渲染后去对比前后两次的渲染，
查看数组内是否有变量发生了更新（只要有一个数组元素变了，就会被认为更新发生了），
并在有更新的前提下去触发 useEffect 中定义的副作用逻辑。
*/
```

### 理解 Hooks 的依赖

Hooks(useEffect、useCallback、useMemo) 提供了让你监听某个数据变化的能力。这个变化可能会触发组件的刷新，也可能是去创建一个副作用，又或者是刷新一个缓存。那么定义要监听哪些数据变化的机制，其实就是指定 Hooks 的依赖项。

那么在定义依赖项时，我们需要注意以下三点：

1. 依赖项中定义的变量一定是会在回调函数中用到的，否则声明依赖项其实是没有意义的。
2. 依赖项一般是一个常量数组，而不是一个变量。因为一般在创建 callback 的时候，你其实非常清楚其中要用到哪些依赖项了。
3. React 会使用**浅比较**来对比依赖项是否发生了变化，所以要**特别注意数组或者对象类型**。如果你是每次创建一个新对象，即使和之前的值是等价的，也会被认为是依赖项发生了变化。这是一个刚开始使用 Hooks 时很容易导致 Bug 的地方。例如下面的代码：

```javascript
function Sample() {
  // 这里在每次组件执行时创建了一个新数组
  const todos = [{ text: "Learn hooks." }];
  useEffect(() => {
    console.log("Todos changed.");
  }, [todos]);
}
```

代码的原意可能是在 todos 变化的时候去产生一些副作用，但是这里的 todos 变量是在函数内创建的，实际上每次都产生了一个新数组。所以在作为依赖项的时候进行引用的比较，实际上被认为是发生了变化的。

## React 为什么要发明 Hooks

### 告别难以理解的 Class:

Class 的“痛点”:

1.  生命周期  
    生命周期的带来的麻烦提现在：学习成本和不合理的逻辑规划方式
2.  React 组件之间是不会相互继承的  
    比如说，你不会创建一个 Button 组件，然后再创建一个 DropdownButton 组件来继承 Button。React 实际上没利用到 Class 的继承特性的。
3.  UI 由状态驱动，很少在外部调用类实例（即组件）的方法。  
    组件所有的方法都是在类内部调用或者作为生命周期函数被自动调用。
4.  this

```javascript
class Example extends Component {
 state = {
   name: 'zzydev',
   age: '99';
 };

 changeAge() {
 // 这里会报错
 this.setState({
 age: '100'
 });
}

 render() {
   return <button onClick={this.changeAge}>{this.state.name}的年龄是{this.state.age}</button>
 }
}
```

changeAge 这个方法：它是 button 按钮的事件监听函数。当我点击 button 按钮时，希望它能够帮我修改状态，但事实是，点击发生后，程序会报错。原因很简单，changeAge 里并不能拿到组件实例的 this。为了解决 this 不符合预期的问题，可以使用 this.changeAga = this.changeAga.bind(this) 或 箭头函数的方式，但这两种方式 **本质上都是在用实践层面的约束来解决设计层面的问题**

### Hooks 如何实现更好的逻辑拆分

过去我们组织自己业务逻辑的方式：先想清楚业务的需要是什么样的，然后将对应的业务逻辑拆到不同的生命周期函数里去。**逻辑与生命周期耦合在一起**。

```javascript
componentDidMount() {
 // 1. 这里发起异步调用
 // 2. 这里从 props 里获取某个数据，根据这个数据更新 DOM
 // 3. 这里设置一个订阅
 // 4. 这里随便干点别的什么
 // ...
}

componentWillUnMount() {
 // 在这里卸载订阅
}

componentDidUpdate() {
 // 1. 在这里根据 DidMount 获取到的异步数据更新 DOM
 // 2. 这里从 props 里获取某个数据，根据这个数据更新 DOM（和 DidMount 的第2步一样）
}

```

像这样的生命周期函数，它的体积过于庞大，做的事情过于复杂，会给阅读和维护者带来很多麻烦。最重要的是，**这些事情之间看上去毫无关联，逻辑就像是被“打散”进生命周期里了一样**。比如，设置订阅和卸载订阅的逻辑，虽然它们在逻辑上是有强关联的，但是却只能被分散到不同的生命周期函数里去处理，这无论如何也不能算作是一个非常合理的设计。

而在 Hooks 的帮助下，我们完全可以把这些繁杂的操作**按照逻辑上的关联拆分进不同的函数组件里：**我们可以有专门管理订阅的函数组件、专门处理 DOM 的函数组件、专门获取数据的函数组件等。Hooks 能够帮助我们**实现业务逻辑的聚合，避免复杂的组件和冗余的代码**。

### 状态复用：Hooks 将复杂的问题变简单

过去我们复用状态逻辑，靠的是 HOC（高阶组件）和 Render Props 这些组件设计模式，这是因为 React 在原生层面并没有为我们提供相关的途径。但这些设计模式并非万能，它们在实现逻辑复用的同时，也破坏着组件的结构，其中一个最常见的问题就是“嵌套地狱”现象。

Hooks 可以视作是 React 为解决状态逻辑复用这个问题所提供的一个原生途径。现在我们可以通过自定义 Hook，达到既不破坏组件结构、又能够实现逻辑复用的效果。

## React Hooks 的局限性

### Hooks 暂时还不能完全地为函数组件补齐类组件的能力

比如 getSnapshotBeforeUpdate、componentDidCatch 这些生命周期，目前都还是强依赖类组件的。

### Hooks 在使用层面有着严格的规则约束

Hooks 的使用规则包括以下两个: 只能在函数组件的顶级作用域使用；只能在函数组件或者其他 Hooks 中使用。
所谓顶层作用域，就是 Hooks 不能在循环、条件判断或者嵌套函数内执行，而必须是在顶层。同时 Hooks 在组件的多次渲染之间，必须按顺序被执行。[Hooks 使用规则背后的”原理“](https://zzydev.top/posts/headfirstreact/5_%E6%B7%B1%E5%85%A5react-hooks%E5%B7%A5%E4%BD%9C%E6%9C%BA%E5%88%B6/)

```javascript
function MyComp() {
  const [count, setCount] = useState(0);
  if (count > 10) {
    // ⚠️ 错误：不能将 Hook 用在条件判断里
    useEffect(() => {
      // ...
    }, [count]);
  }

  // ⚠️ 这里可能提前返回组件渲染结果，后面就不能再用 Hooks 了
  if (count === 0) {
    return "No content";
  }

  // ⚠️ 错误：不能将 Hook 放在可能的 return 之后
  const [loading, setLoading] = useState(false);

  //...
  return <div>{count}</div>;
}
```

Hooks 作为专门为函数组件设计的机制，使用的情况只有两种，**一种是在函数组件内，另外一种则是在自定义的 Hooks 里面。**
但是如果一定要在 Class 组件中使用，那应该如何做呢？其实有一个通用的机制，那就是利用高阶组件的模式，将 Hooks 封装成高阶组件，从而让类组件使用。
举个例子。我们已经定义了监听窗口大小变化的一个 Hook：useWindowSize。那么很容易就可以将其转换为高阶组件：

```javascript
import React from "react";
import { useWindowSize } from "../hooks/useWindowSize";

export const withWindowSize = (Comp) => {
  return (props) => {
    const windowSize = useWindowSize();
    return <Comp windowSize={windowSize} {...props} />;
  };
};
```

那么我们就可以通过如下代码来使用这个高阶组件：

```javascript
import React from "react";
import { withWindowSize } from "./withWindowSize";

class MyComp {
  render() {
    const { windowSize } = this.props;
    // ...
  }
}

// 通过 withWindowSize 高阶组件给 MyComp 添加 windowSize 属性
export default withWindowSize(MyComp);
```

这样，通过 withWindowSize 这样一个高阶组件模式，你就可以把 useWindowSize 的结果作为属性，传递给需要使用窗口大小的类组件，这样就可以实现在 Class 组件中复用 Hooks 的逻辑了。

### 使用 ESLint 插件帮助检查 Hooks 的使用

```shell
yarn add eslint-plugin-react-hooks -S
```

然后在你的 ESLint 配置文件中加入两个规则：rules-of-hooks 和 exhaustive-deps。如下：

```json
{
  "plugins": [
    // ...
    "react-hooks"
  ],
  "rules": {
    // ...
    // 检查 Hooks 的使用规则
    "react-hooks/rules-of-hooks": "error",
    // 检查依赖项的声明
    "react-hooks/exhaustive-deps": "warn"
  }
}
```
