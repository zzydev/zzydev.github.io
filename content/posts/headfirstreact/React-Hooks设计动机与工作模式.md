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

![XwAcVS.png](https://s1.ax1x.com/2022/06/05/XwAcVS.png)

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

useEffect 能够为函数组件引入副作用。过去我们习惯放在 componentDidMount、componentDidUpdate 和 componentWillUnmount 三个生命周期里来做的事，现在可以放在 useEffect 里来做，比如操作 DOM、订阅事件、调用外部 API 获取数据等。

- 仅在挂载阶段执行一次的副作用：传入回调函数，且这个函数的返回值不是一个函数，同时传入一个空数组。调用形式如下所示：

```javascript
useEffect(()=>{
  // 这里是业务逻辑 
}, [])
```

- 仅在挂载阶段和卸载阶段执行的副作用：传入回调函数，且这个函数的返回值是一个函数，同时传入一个空数组。假如回调函数本身记为 A， 返回的函数记为 B，那么将在挂载阶段执行 A，卸载阶段执行 B。调用形式如下所示：

```javascript
useEffect(()=>{
  // 这里是 A 的业务逻辑

  // 返回一个函数记为 B
  return ()=>{
  }
}, [])
```

useEffect 回调中返回的函数被称为“清除函数”，当 React 识别到清除函数时，会在卸载时执行清除函数内部的逻辑。这个规律不会受第二个参数或者其他因素的影响，只要你在 useEffect 回调中返回了一个函数，它就会被作为清除函数来处理。

- 每一次渲染都触发，且卸载阶段也会被触发的副作用：传入回调函数，且这个函数的返回值是一个函数，同时不传第二个参数。如下所示：

```javascript
useEffect(()=>{
  // 这里是 A 的业务逻辑
  
  // 返回一个函数记为 B
  return ()=>{

  }
})

```

- 根据一定的依赖条件来触发的副作用：传入回调函数（若返回值是一个函数，仍然仅影响卸载阶段对副作用的处理，此处不再赘述），同时传入一个非空的数组，如下所示：

```javascript
useEffect(()=>{
  // 这是回调函数的业务逻辑 

  // 若 xxx 是一个函数，则 xxx 会在组件卸载时被触发
  return xxx
}, [num1, num2, num3])
```

数组中的变量一般都是来源于组件本身的数据（props 或者 state）。若数组不为空，那么 React 就会在新的一次渲染后去对比前后两次的渲染，查看数组内是否有变量发生了更新（只要有一个数组元素变了，就会被认为更新发生了），并在有更新的前提下去触发 useEffect 中定义的副作用逻辑。

## Why React-Hooks：Hooks 是如何帮助我们升级工作模式的

1. 告别难以理解的 Class：把握 Class 的两大“痛点”
class 的“难以理解”说法的背后是this和生命周期两大痛点。
例如：
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
changeAge 这个方法：它是 button 按钮的事件监听函数。当我点击 button 按钮时，希望它能够帮我修改状态，但事实是，点击发生后，程序会报错。原因很简单，changeAge 里并不能拿到组件实例的 this。为了解决 this 不符合预期的问题，可以使用this.changeAga = this.changeAga.bind(this) 或 箭头函数的方式，但这两种方式   **本质上都是在用实践层面的约束来解决设计层面的问题** 

生命周期的带来的麻烦提现在：学习成本和不合理的逻辑规划方式

2. Hooks 如何实现更好的逻辑拆分

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

3. 状态复用：Hooks 将复杂的问题变简单

过去我们复用状态逻辑，靠的是 HOC（高阶组件）和 Render Props 这些组件设计模式，这是因为 React 在原生层面并没有为我们提供相关的途径。但这些设计模式并非万能，它们在实现逻辑复用的同时，也破坏着组件的结构，其中一个最常见的问题就是“嵌套地狱”现象。

Hooks 可以视作是 React 为解决状态逻辑复用这个问题所提供的一个原生途径。现在我们可以通过自定义 Hook，达到既不破坏组件结构、又能够实现逻辑复用的效果。

## React Hook的局限性

**Hooks 暂时还不能完全地为函数组件补齐类组件的能力**：比如 getSnapshotBeforeUpdate、componentDidCatch 这些生命周期，目前都还是强依赖类组件的。

**Hooks 在使用层面有着严格的规则约束**

