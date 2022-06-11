---
title: "1.JSX 是如何变成为 DOM 的"
date: 2022-06-02T17:23:43+08:00
draft: true
tags:
  - "react"
author: ["zzydev"]
---

---

## JSX 的本质：JavaScript 的语法扩展

{{< notice notice-tip >}}

JSX 会被编译为 React.createElement()， React.createElement() 将返回一个叫作“React Element”的 JS 对象。

{{< /notice >}}

Babel 具备将 JSX 语法转换为 javascript 的能力

[Babel 的在线地址](https://babeljs.io/repl#?browsers=defaults%2C%20not%20ie%2011%2C%20not%20ie_mob%2011&build=&builtIns=false&corejs=3.21&spec=false&loose=false&code_lz=Q&debug=false&forceAllTransforms=false&shippedProposals=false&circleciRepo=&evaluate=false&fileSize=false&timeTravel=false&sourceType=module&lineWrap=true&presets=env%2Creact%2Cstage-2&prettier=false&targets=&version=7.18.4&externalPlugins=&assumptions=%7B%7D)

## JSX 是如何映射为 DOM 的

createElement 源码：

```javascript
//React的创建元素方法
export function createElement(type, config, children) {
  // propName 变量用于储存后面需要用到的元素属性
  let propName;
  // props 变量用于储存元素属性的键值对集合
  const props = {};
  // key、ref、self、source 均为 React 元素的属性，此处不必深究
  let key = null;
  let ref = null;
  let self = null;
  let source = null;

  // config 对象中存储的是元素的属性
  if (config != null) {
    // 进来之后做的第一件事，是依次对 ref、key、self 和 source 属性赋值
    if (hasValidRef(config)) {
      ref = config.ref;
    }
    // 此处将 key 值字符串化
    if (hasValidKey(config)) {
      key = "" + config.key;
    }

    self = config.__self === undefined ? null : config.__self;
    source = config.__source === undefined ? null : config.__source;

    // 接着就是要把 config 里面的属性都一个一个挪到 props 这个之前声明好的对象里面
    for (propName in config) {
      if (
        // 筛选出可以提进 props 对象里的属性
        hasOwnProperty.call(config, propName) &&
        !RESERVED_PROPS.hasOwnProperty(propName)
      ) {
        props[propName] = config[propName];
      }
    }
  }

  // childrenLength 指的是当前元素的子元素的个数，减去的 2 是 type 和 config 两个参数占用的长度
  const childrenLength = arguments.length - 2;
  // 如果抛去type和config，就只剩下一个参数，一般意味着文本节点出现了
  if (childrenLength === 1) {
    // 直接把这个参数的值赋给props.children
    props.children = children;
    // 处理嵌套多个子元素的情况
  } else if (childrenLength > 1) {
    // 声明一个子元素数组
    const childArray = Array(childrenLength);
    // 把子元素推进数组里
    for (let i = 0; i < childrenLength; i++) {
      childArray[i] = arguments[i + 2];
    }
    // 最后把这个数组赋值给props.children
    props.children = childArray;
  }

  // 处理 defaultProps
  if (type && type.defaultProps) {
    const defaultProps = type.defaultProps;
    for (propName in defaultProps) {
      if (props[propName] === undefined) {
        props[propName] = defaultProps[propName];
      }
    }
  }

  // 最后返回一个调用ReactElement执行方法，并传入刚才处理过的参数
  return ReactElement(
    type,
    key,
    ref,
    self,
    source,
    ReactCurrentOwner.current,
    props
  );
}
```

## 入参解读：创造一个元素需要知道哪些信息

```javascript
export function createElement(type, config, children)
```

- type：用于标识节点的类型。它可以是类似“h1”“div”这样的标准 HTML 标签字符串，也可以是 React 组件类型或 React fragment 类型。
- config：以对象形式传入，组件所有的属性都会以键值对的形式存储在 config 对象中。
- children：以对象形式传入，它记录的是组件标签之间嵌套的内容，也就是所谓的“子节点”“子元素”。

## createElement 函数拆解

![XwkATe.png](https://s1.ax1x.com/2022/06/05/XwkATe.png)
**createElement 的每一个步骤几乎都是在格式化数据**

createElement 就像是开发者和 ReactElement 调用之间的一个**数据处理层**。它可以从开发者处接受相对简单的参数，然后将这些参数按照 ReactElement 的预期做一层格式化，最终通过调用 ReactElement 来实现元素的创建。整个过程如下图所示：

![1_2](https://github.com/zzydev/zzydev_blog_img/blob/master/headfirstreact/1_2.png?raw=true)

## 出参解读 初识虚拟 dom

ReactElement 源码：

```javascript
const ReactElement = function (type, key, ref, self, source, owner, props) {
  const element = {
    // This tag allows us to uniquely identify this as a React Element
    $$typeof: REACT_ELEMENT_TYPE,

    // Built-in properties that belong on the element
    type: type,
    key: key,
    ref: ref,
    props: props,

    // Record the component responsible for creating this element.
    _owner: owner,
  };
  if (DEV) {
    /*这里是一些针对 __DEV__ 环境下的处理，对于理解主要逻辑意义不大，故省略*/
  }
  return element;
};
```

ReactElement 把传入的参数按照一定的规范，“组装”进了 element 对象里，并把它返回给了 React.createElement，最终 React.createElement 又把它交回到了开发者手中。

![1_3](https://github.com/zzydev/zzydev_blog_img/blob/master/headfirstreact/1_3.png?raw=true)

想要验证这一点，可以打印输出 JSX 部分：

```javascript
const AppJSX = (
  <div className="App">
    <h1 className="title">I am the title</h1>
    <p className="content">I am the content</p>
  </div>
);

console.log(AppJSX);
```

你会发现它确实是一个标准的 ReactElement 对象实例，如下图：

![XwkkwD.png](https://s1.ax1x.com/2022/06/05/XwkkwD.png)

这个 ReactElement 对象实例，本质上是 **以 JavaScript 对象形式存在的对 DOM 的描述** ，也就是 **虚拟 DOM 中的一个节点** 。

**“虚拟 DOM”**需要通过 `ReactDOM.render`方法变成**渲染到页面上的真实 DOM**

在每一个 React 项目的入口文件中，都少不了对 `ReactDOM.render` 函数的调用。
