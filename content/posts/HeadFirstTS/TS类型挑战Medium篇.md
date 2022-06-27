---
title: "TS类型挑战Medium篇"
date: 2022-06-24T00:59:50+08:00
lastmod: 2022-06-28
draft: true
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

{{< spoiler  "获取函数返回类型">}}
[💯Take a Challenge](https://tsch.js.org/2/play/)  
不使用 `ReturnType` 实现 TypeScript 的 `ReturnType<T>` 泛型。

例如：

```ts
const fn = (v: boolean) => {
  if (v) return 1;
  else return 2;
};

type a = MyReturnType<typeof fn>; // 应推导出 "1 | 2"
```

答案:

```ts
type ReturnType<T> = T extends (...args: any) => infer R ? R : never;
```

{{< /spoiler >}}

{{< spoiler  "实现 Omit">}}
[💯Take a Challenge](https://tsch.js.org/3/play/)  
不使用 `Omit` 实现 TypeScript 的 `Omit<T, K>` 泛型。

`Omit` 会创建一个省略 `K` 中字段的 `T` 对象。

例如：

```ts
interface Todo {
  title: string;
  description: string;
  completed: boolean;
}

type TodoPreview = MyOmit<Todo, "description" | "title">;

const todo: TodoPreview = {
  completed: false,
};
```

答案:

```ts
type MyOmit<T, K> = MyPick<T, MyExclude<keyof T, K>>;
```

{{< /spoiler >}}

{{< spoiler  "Readonly 2">}}
[💯Take a Challenge](https://tsch.js.org/8/play/)  
Implement a generic `MyReadonly2<T, K>` which takes two type argument `T` and `K`.

`K` specify the set of properties of `T` that should set to Readonly. When `K` is not provided, it should make all properties readonly just like the normal `Readonly<T>`.

For example

```ts
interface Todo {
  title: string;
  description: string;
  completed: boolean;
}

const todo: MyReadonly2<Todo, "title" | "description"> = {
  title: "Hey",
  description: "foobar",
  completed: false,
};

todo.title = "Hello"; // Error: cannot reassign a readonly property
todo.description = "barFoo"; // Error: cannot reassign a readonly property
todo.completed = true; // OK
```

答案:

```ts
type MyReadonly2<T, K extends keyof T = keyof T> = Omit<T, K> & {
  readonly [P in K]: T[P];
};
```

{{< /spoiler >}}

{{< spoiler  "深度 Readonly">}}
[💯Take a Challenge](https://tsch.js.org/9/play/)  
 Implement a generic `DeepReadonly<T>` which make every parameter of an object - and its sub-objects recursively - readonly.

You can assume that we are only dealing with Objects in this challenge. Arrays, Functions, Classes and so on are no need to take into consideration. However, you can still challenge your self by covering different cases as many as possible.

For example

```ts
type X = {
  x: {
    a: 1;
    b: "hi";
  };
  y: "hey";
};

type Expected = {
  readonly x: {
    readonly a: 1;
    readonly b: "hi";
  };
  readonly y: "hey";
};

type Todo = DeepReadonly<X>; // should be same as `Expected`
```

答案:

```ts
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends { [key: string]: any }
    ? DeepReadonly<T[P]>
    : T[P];
};
```

{{< /spoiler >}}

{{< spoiler  "元组转联合类型">}}
[💯Take a Challenge](https://tsch.js.org/10/play)  
实现泛型`TupleToUnion<T>`，它返回元组所有值组成的联合类型。

例如

```ts
type Arr = ["1", "2", "3"];

type Test = TupleToUnion<Arr>; // expected to be '1' | '2' | '3'
```

答案:

```ts
type TupleToUnion<T extends readonly any[]> = T extends [infer R, ...infer args]
  ? R | TupleToUnion<args>
  : never;
```

{{< /spoiler >}}

{{< spoiler  "Chainable Options">}}
[💯Take a Challenge](https://tsch.js.org/12/play/)  
Chainable options are commonly used in Javascript. But when we switch to TypeScript, can you properly type it?

In this challenge, you need to type an object or a class - whatever you like - to provide two function `option(key, value)` and `get()`. In `option`, you can extend the current config type by the given key and value. We should about to access the final result via `get`.

For example

```ts
declare const config: Chainable;

const result = config
  .option("foo", 123)
  .option("name", "type-challenges")
  .option("bar", { value: "Hello World" })
  .get();

// expect the type of result to be:
interface Result {
  foo: number;
  name: string;
  bar: {
    value: string;
  };
}
```

You don't need to write any js/ts logic to handle the problem - just in type level.

You can assume that `key` only accepts `string` and the `value` can be anything - just leave it as-is. Same `key` won't be passed twice.
答案:

```ts
type Chainable<T> = {
  options<K extends string, V>(
    key: K,
    value: V
  ): Chainable<T & { [k in K]: V }>;
  get(): T;
};
```

{{< /spoiler >}}

{{< spoiler  "Last">}}
[💯Take a Challenge](https://tsch.js.org/15/play/)

> TypeScript 4.0 is recommended in this challenge

Implement a generic `Last<T>` that takes an Array `T` and returns its last element.

For example

```ts
type arr1 = ["a", "b", "c"];
type arr2 = [3, 2, 1];

type tail1 = Last<arr1>; // expected to be 'c'
type tail2 = Last<arr2>; // expected to be 1
```

答案:

```ts
type Last<T extends any[]> = T extends [...any[], infer L] ? L : never;
```

{{< /spoiler >}}

{{< spoiler  "Pop">}}
[💯Take a Challenge](https://tsch.js.org/16/play/)

> TypeScript 4.0 is recommended in this challenge

Implement a generic `Pop<T>` that takes an Array `T` and returns an Array without it's last element.

For example

```ts
type arr1 = ["a", "b", "c", "d"];
type arr2 = [3, 2, 1];

type re1 = Pop<arr1>; // expected to be ['a', 'b', 'c']
type re2 = Pop<arr2>; // expected to be [3, 2]
```

**Extra**: Similarly, can you implement `Shift`, `Push` and `Unshift` as well?

答案:

```ts
type Pop<T extends any[]> = T extends []
  ? []
  : T extends [...infer Rest, any]
  ? Rest
  : never;
```

{{< /spoiler >}}

{{< spoiler  "Promise.all">}}
[💯Take a Challenge](https://tsch.js.org/20/play/)
Type the function `PromiseAll` that accepts an array of PromiseLike objects, the returning value should be `Promise<T>` where `T` is the resolved result array.

```ts
const promise1 = Promise.resolve(3);
const promise2 = 42;
const promise3 = new Promise<string>((resolve, reject) => {
  setTimeout(resolve, 100, "foo");
});

// expected to be `Promise<[number, 42, string]>`
const p = Promise.all([promise1, promise2, promise3] as const);
```

答案:

```ts
type PromiseAllType<T> = Promise<{
  [P in keyof T]: T[P] extends Promise<infer R> ? R : T[P];
}>;
declare function PromiseAll<T extends any[]>(
  values: readonly [...T]
): PromiseAllType<T>;
```

{{< /spoiler >}}

{{< spoiler  "Type Lookup">}}
[💯Take a Challenge](https://tsch.js.org/62/play/)  
Sometimes, you may want to lookup for a type in a union to by their attributes.

In this challenge, we would like to get the corresponding type by searching for the common `type` field in the union `Cat | Dog`. In other words, we will expect to get `Dog` for `LookUp<Dog | Cat, 'dog'>` and `Cat` for `LookUp<Dog | Cat, 'cat'>` in the following example.

```ts
interface Cat {
  type: "cat";
  breeds: "Abyssinian" | "Shorthair" | "Curl" | "Bengal";
}

interface Dog {
  type: "dog";
  breeds: "Hound" | "Brittany" | "Bulldog" | "Boxer";
  color: "brown" | "white" | "black";
}

type MyDogType = LookUp<Cat | Dog, "dog">; // expected to be `Dog`
```

答案:

```ts
type LookUp<U extends { type: string }, T extends string> = U extends {
  type: T;
}
  ? U
  : never;
```

{{< /spoiler >}}
{{< spoiler  "Trim Left">}}
[💯Take a Challenge](https://tsch.js.org/106/play/)
Implement `TrimLeft<T>` which takes an exact string type and returns a new string with the whitespace beginning removed.

For example

```ts
type trimed = TrimLeft<"  Hello World  ">; // expected to be 'Hello World  '
```

答案:

```ts
type TrimLeft<Str extends string> = Str extends `${
  | " "
  | "\n"
  | "\t"}${infer Rest}`
  ? TrimLeft<Rest>
  : Str;
```

{{< /spoiler >}}

{{< spoiler  "Trim">}}
[💯Take a Challenge](https://tsch.js.org/108/play/)  
Implement `Trim<T>` which takes an exact string type and returns a new string with the whitespace from both ends removed.

For example

```ts
type trimmed = Trim<"  Hello World  ">; // expected to be 'Hello World'
```

答案:

```ts
type TrimStrRight<Str extends string> = Str extends `${infer Rest}${
  | " "
  | "\n"
  | "\t"}`
  ? TrimStrRight<Rest>
  : Str;

type TrimStrLeft<Str extends string> = Str extends `${
  | " "
  | "\n"
  | "\t"}${infer Rest}`
  ? TrimStrLeft<Rest>
  : Str;

type Trim<Str extends string> = TrimStrRight<TrimStrLeft<Str>>;
```

{{< /spoiler >}}

{{< spoiler  "Capitalize">}}
[💯Take a Challenge](https://tsch.js.org/110/play/)  
Implement `Capitalize<T>` which converts the first letter of a string to uppercase and leave the rest as-is.

For example

```ts
type capitalized = Capitalize<"hello world">; // expected to be 'Hello world'
```

答案:

```ts
type MyCapitalize<Str extends string> =
  Str extends `${infer First}${infer Rest}`
    ? `${Uppercase<First>}${Rest}`
    : Str;
```

{{< /spoiler >}}

{{< spoiler  "Replace">}}
[💯Take a Challenge](https://tsch.js.org/116/play/)  
Implement `Replace<S, From, To>` which replace the string `From` with `To` once in the given string `S`

For example

```ts
type replaced = Replace<"types are fun!", "fun", "awesome">; // expected to be 'types are awesome!'
```

答案:

```ts
type Replace<
  S extends string,
  From extends string,
  To extends string
> = S extends `${infer L}${From}${infer R}`
  ? From extends ""
    ? S
    : `${L}${To}${R}`
  : S;
```

{{< /spoiler >}}

{{< spoiler  "ReplaceAll">}}
[💯Take a Challenge](https://tsch.js.org/119/play/)

答案:

```ts
type ReplaceAll<
  Str extends string,
  From extends string,
  To extends string
> = Str extends `${infer Left}${From}${infer Right}`
  ? From extends ""
    ? Str
    : `${Left}${To}${ReplaceAll<Right, From, To>}`
  : Str;
```

{{< /spoiler >}}

{{< spoiler  "Append Argument">}}
[💯Take a Challenge](https://tsch.js.org/191/play/)  
For given function type `Fn`, and any type `A` (any in this context means we don't restrict the type, and I don't have in mind any type 😉) create a generic type which will take `Fn` as the first argument, `A` as the second, and will produce function type `G` which will be the same as `Fn` but with appended argument `A` as a last one.

For example,

```typescript
type Fn = (a: number, b: string) => number;

type Result = AppendArgument<Fn, boolean>;
// expected be (a: number, b: string, x: boolean) => number
```

> This question is ported from the [original article](https://dev.to/macsikora/advanced-typescript-exercises-question-4-495c) by [@maciejsikora](https://github.com/maciejsikora)
> 答案:

```ts
type AppendArgument<Fn, A> = Fn extends (...args: infer R) => infer T
  ? (...args: [...R, A]) => T
  : never;
```

{{< /spoiler >}}
{{< spoiler  "Permutation">}}
[💯Take a Challenge](https://tsch.js.org/296/play/)  
Implement permutation type that transforms union types into the array that includes permutations of unions.

```typescript
type perm = Permutation<"A" | "B" | "C">; // ['A', 'B', 'C'] | ['A', 'C', 'B'] | ['B', 'A', 'C'] | ['B', 'C', 'A'] | ['C', 'A', 'B'] | ['C', 'B', 'A']
```

答案:

```ts
type Permutation<T, U = T> = [T] extends [never]
  ? []
  : T extends T
  ? [T, ...Permutation<Exclude<U, T>>]
  : never;
```

`[T] extends [never]`是包裹类型条件判断，这里用于处理联合类型为空的情况。  
`T extends T` 用于触发分布式条件类型。  
`<Exclude<U, T>`排除 T 类型，由于 T 此时触发了分布式条件类型的特性，是单独的 T 类型而不是 Union 类型。  
🌰 举个栗子，分析一下执行过程：  
`type res = Permutation<"A" | "B" | "C">` 当 分布式条件类型 T 为 A 时，递归调用 `Permutation<"B" | "C">`，此时结果为 `["A",...["B",Permutation<"C">]]]`与`["A",...["C", Permutation<"B">]]]`。最终得到`["A","B","C"]`与`["A","C","B"]`。
{{< /spoiler >}}

{{< spoiler  "Length of String">}}
[💯Take a Challenge](https://tsch.js.org/298/play/)  
 Compute the length of a string literal, which behaves like `String#length`.
答案:

```ts
type LengthOfString<
  S extends string,
  CountArr extends unknown[] = []
> = S extends `${string}${infer Rest}`
  ? LengthOfString<Rest, [...CountArr, unknown]>
  : CountArr["length"];
```

{{< /spoiler >}}
{{< spoiler  "Flatten">}}
[💯Take a Challenge](https://tsch.js.org/459/play/)  
 In this challenge, you would need to write a type that takes an array and emitted the flatten array type.

For example:

```ts
type flatten = Flatten<[1, 2, [3, 4], [[[5]]]]>; // [1, 2, 3, 4, 5]
```

答案:

```ts
type Flatten<T extends any[]> = T extends [infer L, ...infer R]
  ? L extends any[]
    ? [...Flatten<L>, ...Flatten<R>]
    : [L, ...Flatten<R>]
  : [];
```

{{< /spoiler >}}

{{< spoiler  "Append to object">}}
[💯Take a Challenge](https://tsch.js.org/527/play/)  
 Implement a type that adds a new field to the interface. The type takes the three arguments. The output should be an object with the new field.

For example

```ts
type Test = { id: "1" };
type Result = AppendToObject<Test, "value", 4>; // expected to be { id: '1', value: 4 }
```

答案:

```ts
type AppendToObject<T, K extends keyof any, V> = {
  [P in keyof T | K]: P extends keyof T ? T[P] : V;
};
```

{{< /spoiler >}}

{{< spoiler  "Absolute">}}
[💯Take a Challenge](https://tsch.js.org/529/play/)  
 Implement the `Absolute` type. A type that take string, number or bigint. The output should be a positive number string

For example

```ts
type Test = -100;
type Result = Absolute<Test>; // expected to be "100"
```

答案:

```ts
type Absolute<T extends number | string | bigint> = `${T}` extends `-${infer N}`
  ? N
  : `${T}`;
```

{{< /spoiler >}}
{{< spoiler  "String to Union">}}
[💯Take a Challenge](https://tsch.js.org/531/play/)

Implement the String to Union type. Type take string argument. The output should be a union of input letters

For example：

```ts
type Test = "123";
type Result = StringToUnion<Test>; // expected to be "1" | "2" | "3"
```

答案:

```ts
type StringToUnion<S extends string> = S extends `${infer L}${infer R}`
  ? L | StringToUnion<R>
  : never;
```

{{< /spoiler >}}

{{< spoiler  "Merge">}}
[💯Take a Challenge](https://tsch.js.org/599/play/)  
 Merge two types into a new type. Keys of the second type overrides keys of the first type.

For example：

```ts
type foo = {
  name: string;
  age: string;
};
type coo = {
  age: number;
  sex: string;
};

type Result = Merge<foo, coo>; // expected to be {name: string, age: number, sex: string}
```

答案:
后面的属性的值会覆盖前面相同属性的值

```ts
type Merge<F, S> = {
  [P in keyof F | keyof S]: P extends keyof S
    ? S[P]
    : P extends keyof F
    ? F[P]
    : never;
};
```

{{< /spoiler >}}
{{< spoiler  "KebabCase">}}
[💯Take a Challenge](https://tsch.js.org/612/play/)  
 `FooBarBaz` -> `foo-bar-baz`
答案:

```ts
type KebabCase<S extends string> = S extends `${infer S1}${infer S2}`
  ? S2 extends Uncapitalize<S2>
    ? `${Uncapitalize<S1>}${KebabCase<S2>}`
    : `${Uncapitalize<S1>}-${KebabCase<S2>}`
  : S;
```

{{< /spoiler >}}
{{< spoiler  "Diff">}}
[💯Take a Challenge](https://tsch.js.org/645/play/)  
Get an `Object` that is the difference between `O` & `O1`
答案:

```ts
type DiffKeys<T, U> = Exclude<keyof T | keyof U, keyof (T | U)>;
type Diff<O, O1> = {
  [K in DiffKeys<O, O1>]: K extends keyof O
    ? O[K]
    : K extends keyof O1
    ? O1[K]
    : never;
};
```

`keyof T| keyof U` 表示 T 和 U 的所有属性组成的联合类型  
`keyof (T | U)` 表示 T 和 U 的公共属性
{{< /spoiler >}}
{{< spoiler  "AnyOf">}}
[💯Take a Challenge](https://tsch.js.org/949/play/)  
Implement Python liked `any` function in the type system. A type takes the Array and returns `true` if any element of the Array is true. If the Array is empty, return `false`.

For example:

```ts
type Sample1 = AnyOf<[1, "", false, [], {}]>; // expected to be true.
type Sample2 = AnyOf<[0, "", false, [], {}]>; // expected to be false.
```

答案:

```ts
type False = 0 | "" | false | [] | { [key: string]: never };
type AnyOf<T extends readonly any[]> = T[number] extends False ? false : true;
```

{{< /spoiler >}}
{{< spoiler  "IsNever">}}
[💯Take a Challenge](https://tsch.js.org/1042/play/)  
Implement a type IsNever, which takes input type `T`.
If the type of resolves to `never`, return `true`, otherwise `false`.

For example:

```ts
type A = IsNever<never>; // expected to be true
type B = IsNever<undefined>; // expected to be false
type C = IsNever<null>; // expected to be false
type D = IsNever<[]>; // expected to be false
type E = IsNever<number>; // expected to be false
```

答案:

```ts
// never
type TestNever<T> = T extends never ? 1 : 2;
//包裹类型
type IsNever<T> = [T] extends [never] ? true : false;
```

{{< /spoiler >}}

{{< spoiler  "IsUnion">}}
[💯Take a Challenge](https://tsch.js.org/1097/play/)  
Implement a type `IsUnion`, which takes an input type `T` and returns whether `T` resolves to a union type.

For example:

    ```ts
    type case1 = IsUnion<string>  // false
    type case2 = IsUnion<string|number>  // true
    type case3 = IsUnion<[string|number]>  // false
    ```

答案:

```ts
type IsUnion<T, U = T> = [T] extends [never]
  ? false
  : T extends T //触发分布式条件类型，让每个类型单独传入处理的
  ? [U] extends [T] // 在这里,U是联合类型,T是单独的类型，所以使用[B] extends [A]来判断是不是联合类型
    ? false
    : true
  : never;
```

{{< /spoiler >}}
{{< spoiler  "ReplaceKeys">}}
[💯Take a Challenge](https://tsch.js.org/1130/play/)  
Implement a type ReplaceKeys, that replace keys in union types, if some type has not this key, just skip replacing,
A type takes three arguments.

For example:

```ts
type NodeA = {
  type: "A";
  name: string;
  flag: number;
};

type NodeB = {
  type: "B";
  id: number;
  flag: number;
};

type NodeC = {
  type: "C";
  name: string;
  flag: number;
};

type Nodes = NodeA | NodeB | NodeC;

type ReplacedNodes = ReplaceKeys<
  Nodes,
  "name" | "flag",
  { name: number; flag: string }
>; // {type: 'A', name: number, flag: string} | {type: 'B', id: number, flag: string} | {type: 'C', name: number, flag: string} // would replace name from string to number, replace flag from number to string.

type ReplacedNotExistKeys = ReplaceKeys<Nodes, "name", { aa: number }>; // {type: 'A', name: never, flag: number} | NodeB | {type: 'C', name: never, flag: number} // would replace name to never
```

答案:

```ts
type ReplaceKeys<U, T, Y> = {
  [P in keyof U]: P extends T ? (P extends keyof Y ? Y[P] : never) : U[P];
};
```

{{< /spoiler >}}
{{< spoiler  "Remove Index Signature">}}
[💯Take a Challenge](https://tsch.js.org/1367/play/)  
 Implement `RemoveIndexSignature<T>` , exclude the index signature from object types.

For example:

```

type Foo = {
  [key: string]: any;
  foo(): void;
}

type A = RemoveIndexSignature<Foo>  // expected { foo(): void }

```

答案:

```ts
type NeverIndex<P> = string extends P ? never : number extends P ? never : P;
type RemoveIndexSignature<T> = {
  [P in keyof T as NeverIndex<P>]: T[P];
};
```

索引签名的键为`string`或者`number`，所以我们通过 `string extends P` 和 `number extends P` 的形式排除此索引签名。
{{< /spoiler >}}

{{< spoiler  "Percentage Parser">}}
[💯Take a Challenge](https://tsch.js.org/1978/play/)  
Implement PercentageParser<T extends string>.
According to the `/^(\+|\-)?(\d*)?(\%)?$/` regularity to match T and get three matches.

The structure should be: [`plus or minus`, `number`, `unit`]
If it is not captured, the default is an empty string.

For example:

```ts
type PString1 = "";
type PString2 = "+85%";
type PString3 = "-85%";
type PString4 = "85%";
type PString5 = "85";

type R1 = PercentageParser<PString1>; // expected ['', '', '']
type R2 = PercentageParser<PString2>; // expected ["+", "85", "%"]
type R3 = PercentageParser<PString3>; // expected ["-", "85", "%"]
type R4 = PercentageParser<PString4>; // expected ["", "85", "%"]
type R5 = PercentageParser<PString5>; // expected ["", "85", ""]
```

答案:

```ts
// your answers
type PercentageParser<
  A extends string,
  P = "",
  N extends string = "",
  S = ""
> = A extends `${infer First}${infer Rest}`
  ? First extends "-" | "+"
    ? PercentageParser<Rest, First, N, S>
    : First extends "%"
    ? PercentageParser<Rest, P, N, First>
    : PercentageParser<Rest, P, `${N}${First}`, S>
  : [P, N, S];
```

{{< /spoiler >}}
{{< spoiler  "Drop Char">}}
[💯Take a Challenge](https://tsch.js.org/2070/play/)  
Drop a specified char from a string.

For example:

```ts
type Butterfly = DropChar<" b u t t e r f l y ! ", " ">; // 'butterfly!'
```

答案:

```ts
type DropChar<
  S extends string,
  C extends string
> = S extends `${infer Prefix}${C}${infer Suffix}`
  ? DropChar<`${Prefix}${Suffix}`, C>
  : S;
```

{{< /spoiler >}}
{{< spoiler  "MinusOne">}}
[💯Take a Challenge](https://tsch.js.org/2257/play/)  
Given a number (always positive) as a type. Your type should return the number decreased by one.

For example:

```ts
type Zero = MinusOne<1>; // 0
type FiftyFour = MinusOne<55>; // 54
```

答案:

```ts
//存在最大递归调用深度，比较大的数字会出错，这个方法过不了题目中Expect<Equal<MinusOne<1101>, 1100>>这个测试用例。

type BuildArr<
  Length extends number,
  Elem = unknown,
  Arr extends unknown[] = []
> = Arr["length"] extends Length ? Arr : BuildArr<Length, Elem, [...Arr, Elem]>;

type Subtract<
  Num1 extends number,
  Num2 extends number
> = BuildArray<Num1> extends [...arr1: BuildArr<Num2>, ...arr2: infer Rest]
  ? Rest["length"]
  : never;
```

{{< /spoiler >}}
{{< spoiler  "PickByType">}}
[💯Take a Challenge](https://tsch.js.org/2595/play/)  
From `T`, pick a set of properties whose type are assignable to `U`.

For Example

```typescript
type OnlyBoolean = PickByType<
  {
    name: string;
    count: number;
    isReadonly: boolean;
    isEnable: boolean;
  },
  boolean
>; // { isReadonly: boolean; isEnable: boolean; }
```

答案:

```ts
type PickByType<T, U> = {
  [P in keyof T as T[P] extends U ? P : never]: T[P];
};
```

{{< /spoiler >}}
{{< spoiler  "StartsWith">}}
[💯Take a Challenge](https://tsch.js.org/2688/play/)
Implement `StartsWith<T, U>` which takes two exact string types and returns whether `T` starts with `U`

For example

```typescript
type a = StartsWith<"abc", "ac">; // expected to be false
type b = StartsWith<"abc", "ab">; // expected to be true
type c = StartsWith<"abc", "abcd">; // expected to be false
```

答案:

```ts
type StartsWith<S extends string, C extends string> = S extends `${C}${string}`
  ? true
  : false;
```

{{< /spoiler >}}

{{< spoiler  "EndsWith">}}
[💯Take a Challenge](https://tsch.js.org/2693/play/)  
Implement `EndsWith<T, U>` which takes two exact string types and returns whether `T` ends with `U`

For example:

```typescript
type a = EndsWith<"abc", "bc">; // expected to be false
type b = EndsWith<"abc", "abc">; // expected to be true
type c = EndsWith<"abc", "d">; // expected to be false
```

答案:

```ts
type EndsWith<S extends string, C extends string> = S extends `${string}${C}`
  ? true
  : false;
```

{{< /spoiler >}}
{{< spoiler  "PartialByKeys">}}
[💯Take a Challenge](https://tsch.js.org/2757/play/)  
 Implement a generic `PartialByKeys<T, K>` which takes two type argument `T` and `K`.

`K` specify the set of properties of `T` that should set to be optional. When `K` is not provided, it should make all properties optional just like the normal `Partial<T>`.

For example

```typescript
interface User {
  name: string;
  age: number;
  address: string;
}

type UserPartialName = PartialByKeys<User, "name">; // { name?:string; age:number; address:string }
```

答案:

```ts
type CopyKeys<T> = {
  [P in keyof T]: T[P];
};
type PartialByKeys<T, K extends keyof any = keyof T> = CopyKeys<
  Partial<Pick<T, Extract<keyof T, K>>> & Omit<T, K>
>;
```

{{< /spoiler >}}
{{< spoiler  "RequiredByKeys">}}
[💯Take a Challenge](https://tsch.js.org/2759/play/)  
Implement a generic `RequiredByKeys<T, K>` which takes two type argument `T` and `K`.

`K` specify the set of properties of `T` that should set to be required. When `K` is not provided, it should make all properties required just like the normal `Required<T>`.

For example

```typescript
interface User {
  name?: string;
  age?: number;
  address?: string;
}

type UserRequiredName = RequiredByKeys<User, "name">; // { name: string; age?: number; address?: string }
```

答案:

```ts
type CopyKeys<T> = {
  [P in keyof T]: T[P];
};
type RequiredByKeys<T, K extends keyof any = keyof T> = CopyKeys<
  Required<Pick<T, Extract<keyof T, K>>> & Omit<T, K>
>;
```

{{< /spoiler >}}
{{< spoiler  "Mutable">}}
[💯Take a Challenge](https://tsch.js.org/2793/play/)  
Implement the generic `Mutable<T>` which makes all properties in `T` mutable (not readonly).

For example

```typescript
interface Todo {
  readonly title: string;
  readonly description: string;
  readonly completed: boolean;
}

type MutableTodo = Mutable<Todo>; // { title: string; description: string; completed: boolean; }
```

答案:

```ts
type MyMutable<T> = {
  -readonly [P in keyof T]: T[P];
};
```

{{< /spoiler >}}
{{< spoiler  "OmitByType">}}
[💯Take a Challenge](https://tsch.js.org/2852/play/)  
From `T`, pick a set of properties whose type are not assignable to `U`.

For Example

```typescript
type OmitBoolean = OmitByType<
  {
    name: string;
    count: number;
    isReadonly: boolean;
    isEnable: boolean;
  },
  boolean
>; // { name: string; count: number }
```

答案:

```ts
type OmitByType<T, U> = {
  [P in keyof T as U extends T[P] ? never : P]: T[P];
};
```

{{< /spoiler >}}
{{< spoiler  "ObjectEntries">}}
[💯Take a Challenge](https://tsch.js.org/2946/play/)  
Implement the type version of `Object.entries`

For example

```typescript
interface Model {
  name: string;
  age: number;
  locations: string[] | null;
}
type modelEntries = ObjectEntries<Model>; // ['name', string] | ['age', number] | ['locations', string[] | null];
```

答案:

```ts
type ObjectEntries<T> = {
  [K in keyof Required<T>]: [K, T[K] extends undefined ? T[K] : Required<T>[K]];
}[keyof T];
```

{{< /spoiler >}}
{{< spoiler  "Shift">}}
[💯Take a Challenge](https://tsch.js.org/3062/play/)  
 Implement the type version of `Array.shift`

For example

```typescript
type Result = Shift<[3, 2, 1]>; // [2, 1]
```

答案:

```ts
type Shift<T extends unknown[]> = T extends []
  ? []
  : T extends [unknown, ...infer Rest]
  ? Rest
  : never;
```

{{< /spoiler >}}

{{< spoiler  "Tuple to Nested Object">}}
[💯Take a Challenge](https://tsch.js.org/3188/play/)  
Given a tuple type `T` that only contains string type, and a type `U`, build an object recursively.

```typescript
type a = TupleToNestedObject<["a"], string>; // {a: string}
type b = TupleToNestedObject<["a", "b"], number>; // {a: {b: number}}
type c = TupleToNestedObject<[], boolean>; // boolean. if the tuple is empty, just return the U type
```

答案:

```ts
type TupleToNestedObject<T extends any[], U> = T extends [
  infer F,
  ...infer Rest
]
  ? F extends string
    ? { [P in F]: TupleToNestedObject<Rest, U> }
    : never
  : U;
```

{{< /spoiler >}}
{{< spoiler  "Reverse">}}
[💯Take a Challenge](https://tsch.js.org/3192/play/)  
Implement the type version of `Array.reverse`

For example:

```typescript
type a = Reverse<["a", "b"]>; // ['b', 'a']
type b = Reverse<["a", "b", "c"]>; // ['c', 'b', 'a']
```

答案:

```ts
type Reverse<T extends any[]> = T extends [...infer R, infer L]
  ? [L, ...Reverse<R>]
  : [];
```

{{< /spoiler >}}

{{< spoiler  "Flip Arguments">}}
[💯Take a Challenge](https://tsch.js.org/3196/play/)  
Implement the type version of lodash's `_.flip`.

Type `FlipArguments<T>` requires function type `T` and returns a new function type which has the same return type of T but reversed parameters.

For example:

```typescript
type Flipped = FlipArguments<
  (arg0: string, arg1: number, arg2: boolean) => void
>;
// (arg0: boolean, arg1: number, arg2: string) => void
```

答案:

```ts
type FlipArguments<T> = T extends (...args: infer A) => infer R
  ? (...args: Reverse<A>) => R
  : never;
```

{{< /spoiler >}}
{{< spoiler  "FlattenDepth">}}
[💯Take a Challenge](https://tsch.js.org/3243/play/)  
Recursively flatten array up to depth times.

For example:

```typescript
type a = FlattenDepth<[1, 2, [3, 4], [[[5]]]], 2>; // [1, 2, 3, 4, [5]]. flattern 2 times
type b = FlattenDepth<[1, 2, [3, 4], [[[5]]]]>; // [1, 2, 3, 4, [[5]]]. Depth defaults to be 1
```

If the depth is provided, it's guaranteed to be positive integer.
答案:

```ts
type FlattenDepth<
  T extends any[],
  D extends number = 1,
  U extends any[] = []
> = T extends [infer F, ...infer R]
  ? U["length"] extends D
    ? T
    : F extends any[]
    ? [...FlattenDepth<F, D, [0, ...U]>, ...FlattenDepth<R, D>]
    : [F, ...FlattenDepth<R, D, U>]
  : T;
```

{{< /spoiler >}}
{{< spoiler  "BEM style string">}}
[💯Take a Challenge](https://tsch.js.org/3326/play/)  
The Block, Element, Modifier methodology (BEM) is a popular naming convention for classes in CSS.

For example, the block component would be represented as `btn`, element that depends upon the block would be represented as `btn__price`, modifier that changes the style of the block would be represented as `btn--big` or `btn__price--warning`.

Implement `BEM<B, E, M>` which generate string union from these three parameters. Where `B` is a string literal, `E` and `M` are string arrays (can be empty).
答案:

```ts
type Preprocess<T extends any[], P extends string> = T extends []
  ? ""
  : `${P}${T[number]}`;
type BEM<
  B extends string,
  E extends string[],
  M extends string[]
> = `${B}${Preprocess<E, "__">}${Preprocess<M, "--">}`;
```

{{< /spoiler >}}
{{< spoiler  "InorderTraversal">}}
[💯Take a Challenge](https://tsch.js.org/3376/play/)  
Implement the type version of binary tree inorder traversal.

For example:

```typescript
const tree1 = {
  val: 1,
  left: null,
  right: {
    val: 2,
    left: {
      val: 3,
      left: null,
      right: null,
    },
    right: null,
  },
} as const;

type A = InorderTraversal<typeof tree1>; // [1, 3, 2]
```

答案:

```ts
interface TreeNode {
  val: number;
  left: TreeNode | null;
  right: TreeNode | null;
}

type InorderTraversal<
  T extends TreeNode | null,
  U extends TreeNode = NonNullable<T>
> = T extends TreeNode
  ? [...InorderTraversal<U["left"]>, U["val"], ...InorderTraversal<U["right"]>]
  : [];
```

{{< /spoiler >}}
