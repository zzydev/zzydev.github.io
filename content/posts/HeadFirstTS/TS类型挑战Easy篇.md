---
title: "TS类型挑战Easy篇"
date: 2022-06-24T00:59:28+08:00
draft: false
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

{{< spoiler  "Pick">}}
[💯Take a Challenge](https://tsch.js.org/4/play/)  
实现 TS 内置的 `Pick<T, K>`，但不可以使用它。  
**从类型 `T` 中选择出属性 `K`，构造成一个新的类型**。  
例如：

```ts
interface Todo {
  title: string;
  description: string;
  completed: boolean;
}

type TodoPreview = MyPick<Todo, "title" | "completed">;

const todo: TodoPreview = {
  title: "Clean room",
  completed: false,
};
```

答案：

```typescript
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];
};
```

{{< /spoiler >}}

{{< spoiler  "实现 Readonly">}}
[💯Take a Challenge](https://tsch.js.org/7/play/)

不要使用内置的`Readonly<T>`，自己实现一个。  
该 `Readonly` 会接收一个 _泛型参数_，并返回一个完全一样的类型，只是所有属性都会被 `readonly` 所修饰。  
也就是不可以再对该对象的属性赋值。
例如：

```ts
interface Todo {
  title: string;
  description: string;
}

const todo: MyReadonly<Todo> = {
  title: "Hey",
  description: "foobar",
};

todo.title = "Hello"; // Error: cannot reassign a readonly property
todo.description = "barFoo"; // Error: cannot reassign a readonly property
```

答案：

```typescript
type MyReadonly<T> = {
  readonly [P in keyof T]: T[P];
};
```

{{< /spoiler >}}

{{< spoiler  "Tuple To Object">}}
[💯Take a Challenge](https://tsch.js.org/11/play/)

传入一个元组类型，将这个元组类型转换为对象类型，这个对象类型的键/值都是从元组中遍历出来。  
例如：

```ts
const tuple = ["tesla", "model 3", "model X", "model Y"] as const;
type result = TupleToObject<typeof tuple>; // expected { tesla: 'tesla', 'model 3': 'model 3', 'model X': 'model X', 'model Y': 'model Y'}
```

答案：
索引类型

```typescript
type TupleToObject<T extends readonly any[]> = {
  [P in T[number]]: P;
};
// T[number]索引类型访问，得到联合类型："tesla" | "model 3" | "model X" | "model Y"
```

{{< /spoiler >}}

{{< spoiler  "First of Array">}}
[💯Take a Challenge](https://tsch.js.org/14/play/)  
实现一个通用`First<T>`，它接受一个数组`T`并返回它的第一个元素的类型。

例如：

```ts
type arr1 = ["a", "b", "c"];
type arr2 = [3, 2, 1];

type head1 = First<arr1>; // expected to be 'a'
type head2 = First<arr2>; // expected to be 3
```

答案：
简单模式匹配

```typescript
type MyFirst<T extends unknown[]> = T extends [infer R, ...unknown[]]
  ? R
  : never;
```

{{< /spoiler >}}

{{< spoiler  "Length of Tuple">}}

[💯Take a Challenge](https://tsch.js.org/18/play/)

创建一个通用的 Length，接受一个 readonly 的数组，返回这个数组的长度。

例如：

```ts
type tesla = ["tesla", "model 3", "model X", "model Y"];
type spaceX = [
  "FALCON 9",
  "FALCON HEAVY",
  "DRAGON",
  "STARSHIP",
  "HUMAN SPACEFLIGHT"
];

type teslaLength = Length<tesla>; // expected 4
type spaceXLength = Length<spaceX>; // expected 5
```

答案：

```typescript
type MyLength<T extends any> = T extends { length: number }
  ? T["length"]
  : never;
```

{{< /spoiler >}}

{{< spoiler  "Exclude">}}

[💯Take a Challenge](https://tsch.js.org/43/play/)

实现内置的 Exclude <T, U>类型，但不能直接使用它本身。

> 从联合类型 T 中排除 U 的类型成员，来构造一个新的类型。

答案：
分布式条件类型

```typescript
type MyExclude<T, U> = T extends U ? never : T;
```

{{< /spoiler >}}

{{< spoiler  "Awaited">}}
[💯Take a Challenge](https://tsch.js.org/189/play/)

假如我们有一个 Promise 对象，这个 Promise 对象会返回一个类型。在 TS 中，我们用 Promise 中的 T 来描述这个 Promise 返回的类型。请你实现一个类型，可以获取这个类型。

比如：`Promise<ExampleType>`，请你返回 ExampleType 类型。

这个挑战来自于 @maciejsikora 的文章：[original article](https://dev.to/macsikora/advanced-typescript-exercises-question-1-45k4)

答案:

```ts
type MyAwaited<P extends Promise<unknown>> = P extends Promise<infer ValueType>
  ? ValueType extends Promise<unknown>
    ? MyAwaited<ValueType>
    : ValueType
  : never;
```

{{< /spoiler >}}

{{< spoiler  "If">}}
[💯Take a Challenge](https://tsch.js.org/268/play/)  
实现一个 `IF` 类型，它接收一个条件类型 `C` ，一个判断为真时的返回类型 `T` ，以及一个判断为假时的返回类型 `F`。 `C` 只能是 `true` 或者 `false`， `T` 和 `F` 可以是任意类型。

举例:

```ts
type A = If<true, "a", "b">; // expected to be 'a'
type B = If<false, "a", "b">; // expected to be 'b'
```

答案:

```ts
type If<C extends boolean, T, F> = C extends true ? T : F;
```

{{< /spoiler >}}

{{< spoiler  "Concat">}}
[💯Take a Challenge](https://tsch.js.org/533/play/)  
 在类型系统里实现 JavaScript 内置的 `Array.concat` 方法，这个类型接受两个参数，返回的新数组类型应该按照输入参数从左到右的顺序合并为一个新的数组。

举例，

```ts
type Result = Concat<[1], [2]>; // expected to be [1, 2]
```

答案:

```ts
type Concat<T extends any[], U extends any[]> = [...T, ...U];
```

{{< /spoiler >}}

{{< spoiler  "Includes">}}
[💯Take a Challenge](https://tsch.js.org/898/play/)  
在类型系统里实现 JavaScript 的 `Array.includes` 方法，这个类型接受两个参数，返回的类型要么是 `true` 要么是 `false`。

举例来说，

```ts
type isPillarMen = Includes<["Kars", "Esidisi", "Wamuu", "Santana"], "Dio">; // expected to be `false`
```

答案:

```ts
type IsEqual<A, B> = (A extends B ? true : false) &
  (B extends A ? true : false);
type Includes<Arr extends unknown[], FindItem> = Arr extends [
  infer First,
  ...infer Rest
]
  ? IsEqual<First, FindItem> extends true
    ? true
    : Includes<Rest, FindItem>
  : false;
```

{{< /spoiler >}}

{{< spoiler  "Push">}}
[💯Take a Challenge](https://tsch.js.org/3057/play/)  
在类型系统里实现通用的 `Array.push` 。

举例如下，

```typescript
type Result = Push<[1, 2], "3">; // [1, 2, '3']
```

答案:

```ts
type Push<Arr extends unknown[], Elem> = [...Arr, Elem];
```

{{< /spoiler >}}

{{< spoiler  "Unshift">}}
[💯Take a Challenge](https://tsch.js.org/3060/play/)  
实现类型版本的 `Array.unshift`。

举例，

```typescript
type Result = Unshift<[1, 2], 0>; // [0, 1, 2,]
```

答案:

```ts
type Unshift<Arr extends unknown[], Elem> = [Elem, ...Arr];
```

{{< /spoiler >}}

{{< spoiler  "Parameters">}}
[💯Take a Challenge](https://tsch.js.org/3312/play/)  
实现内置的 Parameters<T> 类型，而不是直接使用它，可参考[TypeScript 官方文档](https://www.typescriptlang.org/docs/handbook/utility-types.html#parameterstype)。

答案:

```ts
type MyParameters<Func extends Function> = Func extends (
  ...args: infer Args
) => unknown
  ? Args
  : never;
```

{{< /spoiler >}}
