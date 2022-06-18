---
title: "3.数据是如何在React组件之间流动的？"
date: 2022-06-03T10:35:11+08:00
lastmod: 2022-06-17 21:57:38
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

React 的核心特征是“数据驱动视图”，即 `UI = render(data)`

## 基于 props 的单向数据流

所谓单向数据流，指的就是当前组件的 state 以 props 的形式流动时，只能流向组件树中比自己层级更低的组件。 比如在父-子组件这种嵌套关系中，只能由父组件传 props 给子组件，而不能反过来。
![3-1](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfreact/3-1.webp)

## 父子组件通信

```javascript
// 子组件
function Child(props) {
  return (
    <div className="child">
      <p>{`子组件所接收到的来自父组件的文本内容是：[${props.fatherText}]`}</p>
    </div>
  );
}
//父组件
class Father extends React.Component {
  // 初始化父组件的 state
  state = {
    text: "初始化的父组件的文本",
  };
  // 按钮的监听函数，用于更新 text 值
  changeText = () => {
    this.setState({
      text: "改变后的父组件文本",
    });
  };
  // 渲染父组件
  render() {
    return (
      <div className="father">
        <button onClick={this.changeText}>
          点击修改父组件传入子组件的文本
        </button>
        {/* 引入子组件，并通过 props 下发具体的状态值实现父-子通信 */}
        <Child fatherText={this.state.text} />
      </div>
    );
  }
}
```

## 子-父组件通信

考虑到 props 是单向的，子组件并不能直接将自己的数据塞给父组件，但 props 的形式也可以是多样的。假如父组件传递给子组件的是一个**绑定了自身上下文的函数**，那么子组件在调用该函数时，就可以将想要交给父组件的数据**以函数入参的形式给出去**，以此来间接地实现数据从子组件到父组件的流动。

```javascript
class Child extends React.Component {
  // 初始化子组件的 state
  state = {
    text: '子组件的文本'
  }
  // 子组件的按钮监听函数
  changeText = () => {
    // changeText 中，调用了父组件传入的 changeFatherText 方法
    this.props.changeFatherText(this.state.text)
  }
  render() {
    return (
      <div className="child">
        {/* 注意这里把修改父组件文本的动作放在了 Child 里 */}
        <button onClick={this.changeText}>
          点击更新父组件的文本
        </button>
      </div>
    );
  }
}

class Father extends React.Component {
  // 初始化父组件的 state
  state = {
    text: "初始化的父组件的文本"
  };
  // 这个方法会作为 props 传给子组件，用于更新父组件 text 值。newText 正是开放给子组件的数据通信入口
  changeText = (newText) => {
    this.setState({
      text: newText
    });
  };
  // 渲染父组件
  render() {
    return (
      <div className="father">
        <p>{`父组件的文本内容是：[${this.state.text}]`}</p>
        {/* 引入子组件，并通过 props 中下发可传参的函数 实现子-父通信 */}
        <Child
          changeFatherText={this.changeText}
        />
      </div>
    );
  }
```

## 兄弟组件通信

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfreact/3-2.webp)

```javascript
function Child(props) {
  return (
    <div className="child">
      <p>{`子组件所接收到的来自父组件的文本内容是：[${props.fatherText}]`}</p>
    </div>
  );
}
class NewChild extends React.Component {
  state = {
    text: "来自 newChild 的文本",
  };
  // NewChild 组件的按钮监听函数
  changeText = () => {
    // changeText 中，调用了父组件传入的 changeFatherText 方法
    this.props.changeFatherText(this.state.text);
  };
  render() {
    return (
      <div className="child">
        {/* 注意这里把修改父组件文本（同时也是 Child 组件的文本）的动作放在了 NewChild 里 */}
        <button onClick={this.changeText}>点击更新 Child 组件的文本</button>
      </div>
    );
  }
}
class Father extends React.Component {
  // 初始化父组件的 state
  state = {
    text: "初始化的父组件的文本",
  };
  // 传给 NewChild 组件按钮的监听函数，用于更新父组件 text 值（这个 text 值同时也是 Child 的 props）
  changeText = (newText) => {
    this.setState({
      text: newText,
    });
  };
  // 渲染父组件
  render() {
    return (
      <div className="father">
        {/* 引入 Child 组件，并通过 props 中下发具体的状态值 实现父-子通信 */}
        <Child fatherText={this.state.text} />
        {/* 引入 NewChild 组件，并通过 props 中下发可传参的函数 实现子-父通信 */}
        <NewChild changeFatherText={this.changeText} />
      </div>
    );
  }
}
```

## 利用“发布-订阅”模式驱动数据流

使用发布-订阅模式的优点在于，监听事件的位置和触发事件的位置是不受限的，只要它们在同一个上下文里，就能够彼此感知。这个特性，太适合用来应对“任意组件通信”这种场景了。

### 发布-订阅模型 API 设计思路

- on()：负责注册事件的监听器，指定事件触发时的回调函数。
- emit()：负责触发事件，可以通过传参使其在触发的时候携带数据 。
- off()：负责监听器的删除。

### 发布-订阅模型编码实现

```javascript
class myEventEmitter {
  constructor() {
    // eventMap 用来存储事件和监听函数之间的关系
    this.eventMap = {};
  }

  // type 这里就代表事件的名称
  on(type, handler) {
    // hanlder 必须是一个函数，如果不是直接报错
    if (!(handler instanceof Function)) {
      throw new Error("hanlder必须是一个函数");
    }
    // 判断 type 事件对应的队列是否存在
    if (!this.eventMap[type]) {
      // 若不存在，新建该队列
      this.eventMap[type] = [];
    }

    // 若存在，直接往队列里推入 handler
    this.eventMap[type].push(handler);
  }

  // 别忘了我们前面说过触发时是可以携带数据的，params 就是数据的载体
  emit(type, params) {
    // 假设该事件是有订阅的（对应的事件队列存在）
    if (this.eventMap[type]) {
      // 将事件队列里的 handler 依次执行出队
      this.eventMap[type].forEach((handler, index) => {
        // 注意别忘了读取 params
        handler(params);
      });
    }
  }

  off(type, handler) {
    if (this.eventMap[type]) {
      // indexOf找不到元素会返回-1，splice从右往左截取，右移运算会将-1变成4294967295
      this.eventMap[type].splice(this.eventMap[type].indexOf(handler) >>> 0, 1);
    }
  }
}
```

```jsx
// 注意这个 myEvent 是提前实例化并挂载到全局的，此处不再重复示范实例化过程

const globalEvent = window.myEvent;

class B extends React.Component {
  // 这里省略掉其他业务逻辑
  state = {
    newParams: "",
  };

  handler = (params) => {
    this.setState({
      newParams: params,
    });
  };

  bindHandler = () => {
    globalEvent.on("someEvent", this.handler);
  };

  render() {
    return (
      <div>
        <button onClick={this.bindHandler}>点我监听A的动作</button>
        <div>A传入的内容是[{this.state.newParams}]</div>
      </div>
    );
  }
}

class A extends React.Component {
  // 这里省略掉其他业务逻辑
  state = {
    infoToB: "哈哈哈哈我来自A",
  };

  reportToB = () => {
    // 这里的 infoToB 表示 A 自身状态中需要让 B 感知的那部分数据
    globalEvent.emit("someEvent", this.state.infoToB);
  };

  render() {
    return <button onClick={this.reportToB}>点我把state传递给B</button>;
  }
}

export default function App() {
  return (
    <div className="App">
      <B />
      <A />
    </div>
  );
}
```

![3-3](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfreact/3-3.webp)

## 使用 Context 维护全局状态

![3-4](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfreact/3-4.png)

[useContext](https://zh-hans.reactjs.org/docs/hooks-reference.html#usecontext)

```jsx
//作用是创建一个context对象,可以选择性地传入一个defaultValue
const AppContext = React.createContext(defaultValue)
//从创建出的context对象中，可以读取到 Provider 和 Consumer
const { Provider, Consumer } = AppContext

//使用 Provider 对组件树中的根组件进行包裹，
//然后传入名为“value”的属性，这个 value 就是后续在组件树中流动的“数据”，
//它可以被 Consumer 消费。
<Provider value={title: this.state.title, content: this.state.content}>
  <Title />
  <Content />
 </Provider>

//Consumer，顾名思义就是“数据的消费者”，它可以读取 Provider 下发下来的数据
//其特点是需要接收一个函数作为子元素，这个函数需要返回一个组件。
<Consumer>
  {value => <div>{value.title}</div>}
</Consumer>

//注意: 当 Consumer 没有对应的 Provider 时，
//value 参数会直接取创建 context 时传递给 createContext 的 defaultValue。
```

## Redux

![3-5](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/hfreact/3-5.png)
createStore.js

```javascript
const createStore = (reducer, enhancer) => {
  if (enhancer) {
    return enhancer(createStore)(reducer);
  }

  let currentState = void 0;
  let currentListeners = [];

  const getState = () => currentState;

  const dispatch = (action) => {
    currentState = reducer(currentState, action);
    currentListeners.forEach((listener) => listener());
  };

  const subscribe = (listener) => {
    currentListeners.push(listener);
    return () => {
      const index = currentListeners.indexOf(listener);
      currentListeners.splice(index, 1);
    };
  };
  //手动触发一次订阅，加上默认值
  dispatch({ type: "@z—redux/INIT" });

  return {
    getState,
    dispatch,
    subscribe,
  };
};

export default createStore;
```

applyMiddleware.js

```javascript
const applyMiddleware = (...middleware) => {
  return (createStore) => (reducer) => {
    const store = createStore(reducer);
    let dispatch = store.dispatch;
    const midApi = {
      getState: store.getState,
      dispatch: (action, ...args) => dispatch(action, ...args),
    };
    const chain = middleware.map((middleware) => middleware(midApi));
    dispatch = compose(...chain)(store.dispatch);
    return {
      ...store,
      dispatch,
    };
  };
};

const compose = (...funcs) => {
  if (funcs.length === 0) {
    return (arg) => arg;
  }
  if (funcs.length === 1) {
    return funcs[0];
  }
  return funcs.reduce(
    (a, b) =>
      (...args) =>
        a(b(...args))
  );
};

export default applyMiddleware;
```

combineReducer.js

```javascript
const combineReducers =
  (reducers) =>
  (state = {}, action) => {
    let nextState = {};
    let hasChange = false;
    for (let key in reducers) {
      const reducer = reducers[key];
      nextState[key] = reducer(state[key], action);
      hasChange = hasChange || nextState[key] !== state[key];
    }

    hasChange = hasChange || Object.keys(nextState) !== Object.keys(state);
    return hasChange ? nextState : state;
  };

export default combineReducers;
```

## React-Redux

```jsx
import { useReducer } from "react";
import React from "react";
import {
  useCallback,
  useState,
  useEffect,
  useLayoutEffect,
  useContext,
} from "react";

const Context = React.createContext();

export const Provider = ({ store, children }) => {
  return <Context.Provider value={store}>{children}</Context.Provider>;
};

export const connect =
  (mapStateToProps = (state) => state, mapDispatchToProps) =>
  (WrapperComponent) =>
  (props) => {
    const store = useContext(Context);
    const { getState, dispatch, subscribe } = store;
    const stateProps = mapStateToProps(getState());
    let dispatchProps = { dispatch };

    if (typeof mapDispatchToProps === "object") {
      dispatchProps = {
        ...bindActionCreators(mapDispatchToProps, dispatch),
        dispatch,
      };
    } else if (typeof mapDispatchToProps === "function") {
      dispatchProps = mapDispatchToProps(dispatch);
    }
    const forceUpdate = useForceUpdate();
    useLayoutEffect(() => {
      const unsubscribe = subscribe(() => {
        forceUpdate();
      });
      return () => {
        if (unsubscribe) {
          unsubscribe();
        }
      };
    }, []);
    return <WrapperComponent {...props} {...stateProps} {...dispatchProps} />;
  };

function bindActionCreator(creator, dispatch) {
  return (...args) => dispatch(creator(...args));
}

export const bindActionCreators = (creators, dispatch) => {
  let obj = {};
  for (let key in creators) {
    obj[key] = bindActionCreator(creators[key], dispatch);
  }
  return obj;
};

const useForceUpdate = () => {
  const [state, setState] = useState(0);
  //const [, setState] = useReducer((prev) => prev + 1, 0);

  const update = useCallback(() => {
    setState((prev) => prev + 1);
  }, []);
  return update;
};
```
