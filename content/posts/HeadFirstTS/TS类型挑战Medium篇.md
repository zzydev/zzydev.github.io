---
title: "TS类型挑战Medium篇"
date: 2022-06-24T00:59:50+08:00
lastmod: 2022-06-28
draft: false
tags:
  - "typescript"
author: ["zzydev"]
description: ""
weight: 3 # 输入1可以顶置文章，用来给文章展示排序，不填就默认按时间排序
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

{{< spoiler  "Flip">}}
[💯Take a Challenge](https://tsch.js.org/4179/play/)  
Implement the type of `just-flip-object`. Examples:

```typescript
Flip<{ a: "x", b: "y", c: "z" }>; // {x: 'a', y: 'b', z: 'c'}
Flip<{ a: 1, b: 2, c: 3 }>; // {1: 'a', 2: 'b', 3: 'c'}
Flip<{ a: false, b: true }>; // {false: 'a', true: 'b'}
```

No need to support nested objects and values which cannot be object keys such as arrays
答案:

```ts
type Flip<T extends Record<string, boolean | number | string>> = {
  [P in keyof T as `${T[P]}`]: P;
};
```

{{< /spoiler >}}
{{< spoiler  "Fibonacci Sequence">}}
[💯Take a Challenge](https://tsch.js.org/4182/play/)  
Implement a generic Fibonacci\<T\> takes an number T and returns it's corresponding [Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number).

The sequence starts:
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...

For example

```ts
type Result1 = Fibonacci<3>; // 2
type Result2 = Fibonacci<8>; // 21
```

答案:

```ts
type Fibonacci<
  Num extends number,
  PrevArr extends unknown[] = [1],
  CurrentArr extends unknown[] = [],
  IndexArr extends unknown[] = []
> = IndexArr["length"] extends Num
  ? CurrentArr["length"]
  : Fibonacci<
      Num,
      CurrentArr,
      [...PrevArr, ...CurrentArr],
      [...IndexArr, unknown]
    >;
```

{{< /spoiler >}}
{{< spoiler  "AllCombinations">}}
[💯Take a Challenge](https://tsch.js.org/4260/play/)  
Implement type `AllCombinations<S>` that return all combinations of strings which use characters from `S` at most once.

For example:

```ts
type AllCombinations_ABC = AllCombinations<"ABC">;
// should be '' | 'A' | 'B' | 'C' | 'AB' | 'AC' | 'BA' | 'BC' | 'CA' | 'CB' | 'ABC' | 'ACB' | 'BAC' | 'BCA' | 'CAB' | 'CBA'
```

答案:

```ts
type StringToUnion<S extends string> = S extends `${infer F}${infer R}`
  ? F | StringToUnion<R>
  : never;
type Combination<S extends string, U extends string = "", K = S> = [S] extends [
  never
]
  ? U
  : K extends S
  ? Combination<Exclude<S, K>, U | `${U}${K}`>
  : U;
type AllCombination<S extends string> = Combination<StringToUnion<S>>;
```

{{< /spoiler >}}

{{< spoiler  "Greater Than">}}
[💯Take a Challenge](https://tsch.js.org/4425/play/)  
In This Challenge, You should implement a type `GreaterThan<T, U>` like `T > U`

Negative numbers do not need to be considered.

For example

```ts
GreaterThan<2, 1> //should be true
GreaterThan<1, 1> //should be false
GreaterThan<10, 100> //should be false
GreaterThan<111, 11> //should be true
```

答案:

```ts
type GreaterThan<
  Num1 extends number,
  Num2 extends number,
  CountArr extends unknown[] = []
> = Num1 extends Num2
  ? false
  : CountArr["length"] extends Num2
  ? true
  : CountArr["length"] extends Num1
  ? false
  : GreaterThan<Num1, Num2, [...CountArr, unknown]>;
```

{{< /spoiler >}}

{{< spoiler  "Zip">}}
[💯Take a Challenge](https://tsch.js.org/4471/play/)  
In This Challenge, You should implement a type `Zip<T, U>`, T and U must be `Tuple`

```ts
type exp = Zip<[1, 2], [true, false]>; // expected to be [[1, true], [2, false]]
```

答案:

```ts
type Zip<One extends unknown[], Other extends unknown[]> = One extends [
  infer OneFirst,
  ...infer OneRest
]
  ? Other extends [infer OtherFirst, ...infer OtherRest]
    ? [[OneFirst, OtherFirst], ...Zip<OneRest, OtherRest>]
    : []
  : [];
```

{{< /spoiler >}}

{{< spoiler  "IsTuple">}}
[💯Take a Challenge](https://tsch.js.org/4484/play/)  
 Implement a type `IsTuple`, which takes an input type `T` and returns whether `T` is tuple type.

For example:

```typescript
type case1 = IsTuple<[number]>; // true
type case2 = IsTuple<readonly [number]>; // true
type case3 = IsTuple<number[]>; // false
```

答案:

```ts
type IsTuple<T> = [T] extends [never]
  ? false
  : T extends readonly [...params: infer Eles]
  ? NotEqual<Eles["length"], number>
  : false;

type NotEqual<A, B> = (<T>() => T extends A ? 1 : 2) extends <
  T
>() => T extends B ? 1 : 2
  ? false
  : true;
```

{{< /spoiler >}}

{{< spoiler  "Chunk">}}
[💯Take a Challenge](https://tsch.js.org/4499/play/)  
Do you know `lodash`? `Chunk` is a very useful function in it, now let's implement it.
`Chunk<T, N>` accepts two required type parameters, the `T` must be a `tuple`, and the `N` must be an `integer >=1`

```ts
type exp1 = Chunk<[1, 2, 3], 2>; // expected to be [[1, 2], [3]]
type exp2 = Chunk<[1, 2, 3], 4>; // expected to be [[1, 2, 3]]
type exp3 = Chunk<[1, 2, 3], 1>; // expected to be [[1], [2], [3]]
```

答案:

```ts
type Chunk<
  T extends any[],
  Size extends number,
  R extends any[] = []
> = R["length"] extends Size
  ? [R, ...Chunk<T, Size>]
  : T extends [infer F, ...infer L]
  ? Chunk<L, Size, [...R, F]>
  : R["length"] extends 0
  ? []
  : [R];
```

{{< /spoiler >}}
{{< spoiler  "Fill">}}
[💯Take a Challenge](https://tsch.js.org/4518/play/)  
`Fill`, a common JavaScript function, now let us implement it with types.
`Fill<T, N, Start?, End?>`, as you can see,`Fill` accepts four types of parameters, of which `T` and `N` are required parameters, and `Start` and `End` are optional parameters.
The requirements for these parameters are: `T` must be a `tuple`, `N` can be any type of value, `Start` and `End` must be integers greater than or equal to 0.

```ts
type exp = Fill<[1, 2, 3], 0>; // expected to be [0, 0, 0]
```

In order to simulate the real function, the test may contain some boundary conditions, I hope you can enjoy it :)
答案:

```ts
type Fill<T extends any[], U> = T extends [any, ...infer Rest]
  ? [U, ...Fill<Rest, U>]
  : [];
```

{{< /spoiler >}}
{{< spoiler  "Trim Right">}}
[💯Take a Challenge](https://tsch.js.org/4803/play/)  
 Implement `TrimRight<T>` which takes an exact string type and returns a new string with the whitespace ending removed.

For example:

```ts
type Trimed = TrimRight<"   Hello World    ">; // expected to be '   Hello World'
```

答案:

```ts
type TrimRight<Str extends string> = Str extends `${infer Rest}${
  | " "
  | "\n"
  | "\t"}`
  ? TrimRight<Rest>
  : Str;
```

{{< /spoiler >}}
{{< spoiler  "Without">}}
[💯Take a Challenge](https://tsch.js.org/5117/play/)  
Implement the type version of Lodash.without, Without<T, U> takes an Array T, number or array U and returns an Array without the elements of U.

```ts
type Res = Without<[1, 2], 1>; // expected to be [2]
type Res1 = Without<[1, 2, 4, 1, 5], [1, 2]>; // expected to be [4, 5]
type Res2 = Without<[2, 3, 2, 3, 2, 3, 2, 3], [2, 3]>; // expected to be []
```

答案:

```ts
type ToUnion<T> = T extends any[] ? T[number] : T;
type Without<
  T extends any[],
  F,
  U = ToUnion<F>,
  R extends any[] = []
> = T extends [infer First, ...infer Rest]
  ? First extends U
    ? Without<Rest, F, U, [...R]>
    : Without<Rest, F, U, [...R, First]>
  : R;
```

{{< /spoiler >}}
{{< spoiler  "Trunc">}}
[💯Take a Challenge](https://tsch.js.org/5140/play/)
Implement the type version of `Math.trunc`, which takes string or number and returns the integer part of a number by removing any fractional digits.

For example:

```typescript
type A = Trunc<12.34>; // 12
```

答案:

```ts
type Trunc<T extends number | string> = `${T}` extends `${infer L}.${string}`
  ? L
  : `${T}`;
```

{{< /spoiler >}}
{{< spoiler  "IndexOf">}}
[💯Take a Challenge](https://tsch.js.org/5153/play/)  
Implement the type version of Array.indexOf, indexOf<T, U> takes an Array T, any U and returns the index of the first U in Array T.

```ts
type Res = IndexOf<[1, 2, 3], 2>; // expected to be 1
type Res1 = IndexOf<[2, 6, 3, 8, 4, 1, 7, 3, 9], 3>; // expected to be 2
type Res2 = IndexOf<[0, 0, 0], 2>; // expected to be -1
```

答案:

```ts
type IndexOf<T extends any[], U, Index extends any[] = []> = T extends [
  infer First,
  ...infer Rest
]
  ? First extends U
    ? Index["length"]
    : IndexOf<Rest, U, [...Index, 0]>
  : -1;
```

{{< /spoiler >}}
{{< spoiler  "Join">}}
[💯Take a Challenge](https://tsch.js.org/5310/play/)  
Implement the type version of Array.join, Join<T, U> takes an Array T, string or number U and returns the Array T with U stitching up.

```ts
type Res = Join<["a", "p", "p", "l", "e"], "-">; // expected to be 'a-p-p-l-e'
type Res1 = Join<["Hello", "World"], " ">; // expected to be 'Hello World'
type Res2 = Join<["2", "2", "2"], 1>; // expected to be '21212'
type Res3 = Join<["o"], "u">; // expected to be 'o'
```

答案:

```ts
type Join<
  T extends any[],
  U extends string | number,
  R extends string = ""
> = T extends [infer First, ...infer Rest]
  ? Rest["length"] extends 0
    ? `${R extends "" ? "" : `${R}${U}`}${First & string}`
    : Join<Rest, U, `${R extends "" ? "" : `${R}${U}`}${First & string}`>
  : R;
```

{{< /spoiler >}}
{{< spoiler  "LastIndexOf">}}
[💯Take a Challenge](https://tsch.js.org/5317/play/)  
Implement the type version of `Array.lastIndexOf`, `LastIndexOf<T, U>` takes an Array `T`, any `U` and returns the index of the last `U` in Array `T`

For example:

```typescript
type Res1 = LastIndexOf<[1, 2, 3, 2, 1], 2>; // 3
type Res2 = LastIndexOf<[0, 0, 0], 2>; // -1
```

答案:

```ts
type Pop<T extends any[]> = T extends [...infer Rest, any] ? Rest : never;
type LastIndexOf<T extends any[], U, Index extends any[] = Pop<T>> = T extends [
  ...infer Rest,
  infer Last
]
  ? Last extends U
    ? Index["length"]
    : LastIndexOf<Rest, U, Pop<Index>>
  : -1;
```

{{< /spoiler >}}
{{< spoiler  "Unique">}}
[💯Take a Challenge](https://tsch.js.org/5360/play/)  
 Implement the type version of Lodash.uniq, Unique<T> takes an Array T, returns the Array T without repeated values.

```ts
type Res = Unique<[1, 1, 2, 2, 3, 3]>; // expected to be [1, 2, 3]
type Res1 = Unique<[1, 2, 3, 4, 4, 5, 6, 7]>; // expected to be [1, 2, 3, 4, 5, 6, 7]
type Res2 = Unique<[1, "a", 2, "b", 2, "a"]>; // expected to be [1, "a", 2, "b"]
type Res3 = Unique<[string, number, 1, "a", 1, string, 2, "b", 2, number]>; // expected to be [string, number, 1, "a", 2, "b"]
type Res4 = Unique<[unknown, unknown, any, any, never, never]>; // expected to be [unknown, any, never]
```

答案:

```ts
type Unique<T extends any[], R extends any[] = []> = T extends [
  infer First,
  ...infer Rest
]
  ? First extends R[number]
    ? Unique<Rest, [...R]>
    : Unique<Rest, [...R, First]>
  : R;
```

{{< /spoiler >}}
{{< spoiler  "MapTypes">}}
[💯Take a Challenge](https://tsch.js.org/5821/play/)  
Implement `MapTypes<T, R>` which will transform types in object T to different types defined by type R which has the following structure

```ts
type StringToNumber = {
  mapFrom: string; // value of key which value is string
  mapTo: number; // will be transformed for number
};
```

**Examples:**

```ts
type StringToNumber = { mapFrom: string; mapTo: number;}
MapTypes<{iWillBeANumberOneDay: string}, StringToNumber> // gives { iWillBeANumberOneDay: number; }
```

Be aware that user can provide a union of types:

```ts
type StringToNumber = { mapFrom: string; mapTo: number;}
type StringToDate = { mapFrom: string; mapTo: Date;}
MapTypes<{iWillBeNumberOrDate: string}, StringToDate | StringToNumber> // gives { iWillBeNumberOrDate: number | Date; }
```

If the type doesn't exist in our map, leave it as it was:

```ts
type StringToNumber = { mapFrom: string; mapTo: number;}
MapTypes<{iWillBeANumberOneDay: string, iWillStayTheSame: Function}, StringToNumber> // // gives { iWillBeANumberOneDay: number, iWillStayTheSame: Function }
```

答案:

```ts
type GetMapType<
  T,
  R,
  Type = R extends { mapFrom: T; mapTo: infer To } ? To : never
> = [Type] extends [never] ? T : Type;
type MapTypes<T, R> = {
  [P in keyof T]: GetMapType<T[P], R>;
};
```

{{< /spoiler >}}
{{< spoiler  "Construct Tuple">}}
[💯Take a Challenge](https://tsch.js.org/7544/play/)  
Construct a tuple with a given length.

For example

```ts
type result = ConstructTuple<2>; // expect to be [unknown, unkonwn]
```

答案:

```ts
// your answers
type ConstructTuple<
  T extends number,
  R extends unknown[] = []
> = R["length"] extends T ? R : ConstructTuple<T, [...R, unknown]>;
```

{{< /spoiler >}}

{{< spoiler  "Number Range">}}
[💯Take a Challenge](https://tsch.js.org/8640/play/)  
Sometimes we want to limit the range of numbers...
For examples.

```
type result = NumberRange<2 , 9> //  | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

答案:

```ts
type ConstructTuple<
  L extends number,
  Result extends number[] = []
> = Result["length"] extends L
  ? [...Result, 1]
  : ConstructTuple<L, [...Result, 1]>;

type NumberRange<
  L extends number,
  H extends number,
  Temp extends number[] = ConstructTuple<L>,
  Result extends unknown[] = [L]
> = L extends H
  ? Result[number]
  : NumberRange<Temp["length"], H, [...Temp, 1], [...Result, Temp["length"]]>;
```

{{< /spoiler >}}

{{< spoiler  "Combination">}}
[💯Take a Challenge](https://tsch.js.org/8767/play/)  
 Given an array of strings, do Permutation & Combination.
It's also useful for the prop types like video [controlsList](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/controlsList)

```ts
// expected to be `"foo" | "bar" | "baz" | "foo bar" | "foo bar baz" | "foo baz" | "foo baz bar" | "bar foo" | "bar foo baz" | "bar baz" | "bar baz foo" | "baz foo" | "baz foo bar" | "baz bar" | "baz bar foo"`
type Keys = Combination<["foo", "bar", "baz"]>;
```

答案:

```ts
type AllCombinations<T extends string[], S extends string = T[number]> = [
  S
] extends [never]
  ? ""
  : "" | { [K in S]: `${K} ${AllCombinations<never, Exclude<S, K>>}` }[S];

type TrimRight<T extends string, S = T> = T extends `${infer R}${
  | " "
  | "\n"
  | "\t"}`
  ? TrimRight<R>
  : S;
type Combination<T extends string[]> = TrimRight<
  Exclude<AllCombinations<T>, "">
>;
```

{{< /spoiler >}}
{{< spoiler  "Subsequence">}}
[💯Take a Challenge](https://tsch.js.org/8987/play/)  
Given an array of unique elements, return all possible subsequences.

A subsequence is a sequence that can be derived from an array by deleting some or no elements without changing the order of the remaining elements.

For example:

```typescript
type A = Subsequence<[1, 2]>; // [] | [1] | [2] | [1, 2]
```

答案:

```ts
type Subsequence<T extends number[], K extends number[] = []> = T extends [
  infer L,
  ...infer R
]
  ? Subsequence<
      R extends number[] ? R : [],
      K | [...K, ...(L extends number ? [L] : [])]
    >
  : K;
```

{{< /spoiler >}}
