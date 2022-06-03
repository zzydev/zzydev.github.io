---
title: "React生命周期"
date: 2022-06-02T17:58:52+08:00
draft: true
author: ["zzydev"]
---
## React15的生命周期
![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/31d79b95-119c-4f1b-a1b9-27bd97e21d67/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T004402Z&X-Amz-Expires=86400&X-Amz-Signature=6b61da7c13944a45a0bd3c3501a13473545c59dda68c64f25c38aacc13ab08ff&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Mounting 阶段：组件的初始化渲染（挂载）
挂载过程在组件的一生中**仅会发生一次**，在这个过程中，组件被**初始化**，然后会被渲染到真实 DOM 里，完成所谓的“**首次渲染**”。

注意 render 在执行过程中并不会去操作真实 DOM（也就是说不会渲染），它的职能是把需要渲染的内容返回出来。真实 DOM 的渲染工作，在挂载阶段是由 ReactDOM.render 来承接的。

componentDidMount 方法在**渲染结束后被触发**，此时因为真实 DOM 已经挂载到了页面上，我们可以在这个生命周期里**执行真实 DOM 相关的操作，**类似于异步请求、数据初始化这样的操作也大可以放在这个生命周期来做。

### Updating 阶段：组件的更新

#### `componentWillReceiProps(nextProps)` 到底是由什么触发的？

在这个生命周期方法里，`nextProps` 表示的是接收到新 props 内容，而现有的 props （相对于 `nextProps` 的“旧 props”）我们可以通过 `this.props` 拿到，由此便能够感知到 `props` 的变化。

`componentReceiveProps` 并不是由 `props` 的变化触发的，而是**由父组件的更新触发的**。

> 如果父组件导致组件重新渲染，即使props没有更改也会调用此方法（componentWillReceiProps）
> 如果只想处理更改，请确保当前值与变更值的比较               ----React官方

#### **组件自身 setState 触发的更新**

componentWillUpdate 会在 render 前被触发，它和 componentWillMount 类似，允许你在里面做一些不涉及真实 DOM 操作的准备工作；而 componentDidUpdate 则在组件更新完毕后被触发，和 componentDidMount 类似，这个生命周期也经常被用来处理 DOM 操作。此外，我们也常常将 componentDidUpdate 的执行作为子组件更新完毕的标志通知到父组件。

#### render 与性能：初识 `shouldComponentUpdate(nextProps, nextState)`

React 组件会根据 shouldComponentUpdate 的返回值，来决定是否执行该方法之后的生命周期，进而决定是否对组件进行**re-render**（重渲染）。shouldComponentUpdate 的默认值为 true，也就是说“无条件 re-render”。在实际的开发中，我们往往通过手动往 shouldComponentUpdate 中填充判定逻辑，或者直接在项目中引入 `PureComponent` 等最佳实践，来实现“**有条件的** re-render”。

### Unmounting 阶段：组件的卸载

组件销毁的常见原因有以下两个。

- 组件在父组件中被移除了：这种情况相对比较直观
- 组件中设置了 key 属性，父组件在 render 的过程中，发现 key 值和上一次不一致，那么这个组件就会被干掉。

## React16的生命周期

![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/c8dc2724-74fa-4c41-8f14-59542f73200c/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T015646Z&X-Amz-Expires=86400&X-Amz-Signature=84ac11ac7251b4fc069bbacf9f633a315f308e585ac3a8dfa2b4a5e65cfa0d01&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Mounting 阶段：组件的初始化渲染（挂载）

![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/184ae6ea-23b2-44c6-9734-99e78ab6762a/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T015821Z&X-Amz-Expires=86400&X-Amz-Signature=b48d0689fac927896ad1136b352ea7df56b55628a74284e320f1efc085aee413&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

#### 认识 getDerivedStateFromProps(props,state)

getDerivedStateFromProps这个API，其设计的初衷不是试图替换掉**componentWillMount ，**而是试图替换掉componentWillReceiveProps，因此它**有且仅有一个用途:使用 props 来派生/更新 state**

getDerivedStateFromProps 是一个静态方法，静态方法不依赖组件实例而存在，因此你在这个方法内部是访问不到 this 的。

该方法可以接收两个参数：props 和 state，它们分别代表当前组件接收到的来自**父组件的 props** 和当前组件自身的 state。

getDerivedStateFromProps 需要一个对象格式的返回值。如果你没有指定这个返回值，那么大概率会被 React 警告一番。

getDerivedStateFromProps 方法**对 state 的更新动作并非“覆盖”式的更新，而是针对某个属性的定向更新**。比如这里我们在 getDerivedStateFromProps 里返回的是这样一个对象，对象里面有一个 fatherText 属性用于表示“父组件赋予的文本”：

```javascript
{
  fatherText: props.text
}
```

该对象并不会替换掉组件原始的这个 state：
```javascript
this.state = { text: "子组件的文本" };
```

而是仅仅针对 fatherText 这个属性作更新（这里原有的 state 里没有 fatherText，因此直接新增）。更新后，原有属性与新属性是共存的，如下图所示：
![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b81c62c7-3430-4796-9df3-ca2d4bbb3195/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T020924Z&X-Amz-Expires=86400&X-Amz-Signature=043c5a85b11a9cc9b2e0179409e1e2d8c2342eb493ca2fd4b2891a1e83db8efb&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Updating 阶段：组件的更新
![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/53ce7c09-192f-4e85-8af7-e1de531e067b/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T021115Z&X-Amz-Expires=86400&X-Amz-Signature=5dcff78fa243d7bb19b2946416eb979fe33f38452f23e8cc00363b67c1b7f6f1&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

React 16.4 的挂载和卸载流程都是与 React 16.3 保持一致的，差异在于更新流程上：

在 React 16.4 中，任何因素触发的组件更新流程（包括由 this.setState 和 forceUpdate 触发的更新流程）都会触发 getDerivedStateFromProps；

而在 v 16.3 版本时，只有父组件的更新会触发该生命周期。

#### 为什么要用 getDerivedStateFromProps 代替 componentWillReceiveProps？

做合理的减法：

1. getDerivedStateFromProps 直接被定义为 static 方法，static 方法内部拿不到组件实例的 this，这就导致你无法在 getDerivedStateFromProps 里面做任何类似于 this.fetch()、不合理的 this.setState（会导致死循环的那种）这类可能会产生副作用的操作。
2. 这是 React 16 在**强制推行**“只用 getDerivedStateFromProps 来完成 props 到 state 的映射”这一最佳实践。意在确保生命周期函数的行为更加可控可预测，从根源上帮开发者避免不合理的编程方式，避免生命周期的滥用；同时，也是在为新的 Fiber 架构铺路。

#### 消失的 componentWillUpdate 与新增的 getSnapshotBeforeUpdate(prevProps, prevState)

getSnapshotBeforeUpdate方法需要一个返回值，**它的返回值会作为第三个参数给到 componentDidUpdate。它的执行时机是在 render 方法之后，真实 DOM 更新之前。在这个阶段里，我们可以同时获取到更新前的真实 DOM 和更新前后的 state&props 的信息。**

重点把握它与componentDidUpdate 间的通信过程：
```javascript
// 组件更新时调用
getSnapshotBeforeUpdate(prevProps, prevState) {
  console.log("getSnapshotBeforeUpdate方法执行");
  return "haha";
}

// 组件更新后调用
componentDidUpdate(prevProps, prevState, valueFromSnapshot) {
  console.log("componentDidUpdate方法执行");
  console.log("从 getSnapshotBeforeUpdate 获取到的值是", valueFromSnapshot);
}
```

这个生命周期的设计初衷，是为了“与 componentDidUpdate 一起，涵盖过时的 componentWillUpdate 的所有用例”。getSnapshotBeforeUpdate 要想发挥作用，离不开 componentDidUpdate 的配合。

## React16为何两次求变？

### Fiber 会使原本同步的渲染过程变成异步的。

同步渲染的递归调用栈是非常深的，只有最底层的调用返回了，整个渲染过程才会开始逐层返回。这个漫长且不可打断的更新过程，将会带来用户体验层面的巨大风险：同步渲染一旦开始，便会牢牢抓住主线程不放，直到递归彻底完成。在这个过程中，浏览器没有办法处理任何渲染之外的事情，会进入一种无法处理用户交互的状态。因此若渲染时间稍微长一点，页面就会面临卡顿甚至卡死的风险。

而 React 16 引入的 Fiber 架构，恰好能够解决掉这个风险：Fiber 会将一个大的更新任务拆解为许多个小任务。每当执行完一个小任务时，渲染线程都会把主线程交回去，看看有没有优先级更高的工作要处理，确保不会出现其他任务被“饿死”的情况，进而避免同步渲染带来的卡顿。在这个过程中，渲染线程不再“一去不回头”，而是可以被打断的，这就是所谓的“异步渲染”。

### 换个角度看生命周期工作流

Fiber 架构的重要特征就是可以被打断的异步渲染模式。但这个“打断”是有原则的，根据“能否被打断”这一标准，React 16 的生命周期被划分为了 **render** 和 **commit** 两个阶段，而 commit 阶段又被细分为了 pre-commit 和 commit。每个阶段所涵盖的生命周期如下图所示：

![avatar](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/53ce7c09-192f-4e85-8af7-e1de531e067b/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220603%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220603T021115Z&X-Amz-Expires=86400&X-Amz-Signature=5dcff78fa243d7bb19b2946416eb979fe33f38452f23e8cc00363b67c1b7f6f1&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

总的来说，**render 阶段在执行过程中允许被打断，而 commit 阶段则总是同步执行的**。

为什么这样设计呢？简单来说，由于 **render 阶段的操作对用户来说其实是“不可见”的**，所以就算打断再重启，对用户来说也是零感知。而 commit 阶段的操作则涉及真实 DOM 的渲染，再狂的框架也不敢在用户眼皮子底下胡乱更改视图，所以这个过程必须用同步渲染来求稳。

### 细说生命周期“废旧立新”背后的思考

在 Fiber 机制下，**render 阶段是允许暂停、终止和重启的**。当一个任务执行到一半被打断后，下一次渲染线程抢回主动权时，这个任务被重启的形式是“重复执行一遍整个任务”而非“接着上次执行到的那行代码往下走”。**这就导致 render 阶段的生命周期都是有可能被重复执行的**。

带着这个结论，我们再来看看 React 16 打算废弃的是哪些生命周期：

- componentWillMount；
- componentWillUpdate；
- componentWillReceiveProps。

这些生命周期的共性，**就是它们都处于 render 阶段，都可能重复被执行**，而且由于这些 API 常年被滥用，它们在重复执行的过程中都存在着不可小觑的风险。

在“componentWill”开头的生命周期里，你习惯于做的事情可能包括但不限于:

- setState()；
- fetch 发起异步请求；
- 操作真实 DOM。

这些操作的问题（或不必要性）包括但不限于以下 3 点：

1. **完全可以转移到其他生命周期（尤其是 componentDidxxx）里去做**。

   比如在 componentWillMount 里发起异步请求。很多同学因为太年轻，以为这样做就可以让异步请求回来得“早一点”，从而避免首次渲染白屏。

   但是异步请求再怎么快也快不过（React 15 下）同步的生命周期。componentWillMount 结束后，render 会迅速地被触发，所以说**首次渲染依然会在数据返回之前执行**。这样做不仅没有达到你预想的目的，还会导致服务端渲染场景下的冗余请求等额外问题，得不偿失。

2. **在 Fiber 带来的异步渲染机制下，可能会导致非常严重的 Bug**。

   比如 componentWillxxx 里发起了一个付款请求。由于 render 阶段里的生命周期都可以重复执行，在 componentWillxxx 被**打断 + 重启多次**后，就会发出多个付款请求。

   又或者你可能会习惯在 componentWillReceiveProps 里操作 DOM（比如说删除符合某个特征的元素），那么 componentWillReceiveProps 若是执行了两次，你可能就会一口气删掉两个符合该特征的元素。

    getDerivedStateFromProps 为何会在设计层面直接被约束为一个触碰不到 this 的静态方法，其背后的原因也就更加充分了——避免开发者触碰 this，就是在避免各种危险的骚操作。

3. **即使你没有开启异步，React 15 下也有不少人能把自己“玩死”。**

   比如在 componentWillReceiveProps  和 componentWillUpdate 里滥用 setState 导致重复渲染死循环的。

总的来说，**React 16 改造生命周期的主要动机是为了配合 Fiber 架构带来的异步渲染机制**。在这个改造的过程中，React 团队针对生命周期中长期被滥用的部分推行了具有**强制性**的最佳实践**。这一系列的工作做下来，首先是**确保了 Fiber 机制下数据和视图的安全性**，同时也**确保了生命周期方法的行为更加纯粹、可控、可预测**。
