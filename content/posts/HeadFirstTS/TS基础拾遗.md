---
title: "TS基础拾遗"
date: 2022-06-10T06:19:56+08:00
lastmod: 2022-06-24 01:26:41
draft: false
tags: ["typescript"]
author: ["zzydev"]
description: ""
weight: 1 # 输入1可以顶置文章，用来给文章展示排序，不填就默认按时间排序
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

{{< simple-notice simple-notice-info >}}
本文只记录一些个人觉得比较容易遗忘或需要注意的点，抑或是一些跟本人接触过的其他静态语言不太一样的语法，并不是一份完整的学习教程。  
{{< /simple-notice >}}

{{< spoiler  "函数类型的书写">}}

```typescript
// 函数类型
function info(username: string, age: number): number {
    return age;
}
type Func = (username: string, age: number) => number;
let info: Func = function (username, age) {
    return age;
};

let info = (username: string, age: number): number => {
    return age;
};

// 接口当名字的函数类型
interface ActionContext {
    (state: any, commit: any): void;
}
let actionContext: ActionContext = (state, commit) => {
    console.log(state);
};
```

{{< /spoiler >}}
{{< spoiler  "异步函数、Generator 函数等类型签名">}}

```typescript
async function asyncFunc(): Promise<void> {}

function* genFunc(): Iterable<void> {}

async function* asyncGenFunc(): AsyncIterable<void> {}
```

{{< /spoiler >}}

{{< spoiler  "object、Object 以及 { }">}}
{{< notice notice-warning >}}
**在任何情况下，你都不应该使用 Object、String 等这些装箱类型**  
object 的引入就是为了解决对 Object 类型的错误使用，它代表**所有非原始类型的类型**，即数组、对象与函数类型。
{{< /notice >}}

```javascript
//在 TypeScript 中就表现为 Object 包含了所有的类型:
const tmp1: Object = undefined;
const tmp2: Object = null;
const tmp3: Object = void 0;
const tmp4: Object = "zzydev";
const tmp5: Object = 233;
const tmp6: Object = { name: "zzydev" };
const tmp7: Object = () => {};
const tmp8: Object = [];

/*
和 Object 类似的还有 Boolean、Number、String、Symbol，这几个装箱类型同样包含了一些超出预期的类型。
以 String 为例，它同样包括 undefined、null、void，以及代表的拆箱类型string，
但并不包括其他装箱类型对应的拆箱类型，如boolean与基本对象类型，
*/
const tmp9: String = undefined;
const tmp10: String = null;
const tmp11: String = void 0;
const tmp12: String = "zzydev";
const tmp13: String = 233; // ❎
const tmp14: String = { name: "zzydev" }; // ❎
const tmp15: String = () => {}; // ❎
const tmp16: String = []; // ❎

//{}作为类型签名就是一个合法的，但内部无属性定义的空对象，这类似于Object，⚠️它意味着任何非null/undefined的值：

const tmp25: {} = undefined; // ❎
const tmp26: {} = null; // ❎
const tmp27: {} = void 0; // ❎
const tmp28: {} = "zzydev";
const tmp29: {} = 233;
const tmp30: {} = { name: "zzydev" };
const tmp31: {} = () => {};
const tmp32: {} = [];
//⚠️ 虽然能够将其作为变量的类型，但你实际上无法对这个变量进行任何赋值操作：
const tmp30: {} = { name: "zzydev" };
tmp30.age = 18; // ❎ 类型“{}”上不存在属性“age”。
const tmp31: Object = { name: "zzydev" };
tmp31.age = 18; // ❎ 属性name不存在于类型Object上
```

{{< notice notice-tip >}}
当你不确定某个变量的具体类型，但能确定它不是原始类型，推荐 👍 使用 `Record<string, unknown>` 或 `Record<string, any>` 表示对象，`unknown[]` 或 `any[]` 表示数组，`(...args: any[]) => any`表示函数这样。同样要避免使用`{}`。`{}`意味着任何非`null/undefined`的值，从这个层面上看，使用它和使用`any`一样恶劣。
{{< /notice >}}

{{< /spoiler >}}

{{< spoiler  "对象取值的坑">}}

```typescript
let obj = {username: "zzy", age: 18} // 类型推导
obj["username"]  // ✅

//let 声明，只需要推导至这个值从属的类型即可。 username在这里是string类型
let username = "username"
obj[username] // ❎

//而 const 声明的原始类型变量将不再可变，因此类型可以直接一步到位收窄到最精确的字面量类型
// username在这里是”username“字面量类型
const username = "username"
obj[username] // ✅
--------------------------------------------------
let obj:object | Object = {username: "zzy", age: 18}
const username = "username"

let res = obj[username] // ❎

let res = (obj as any)[username] // ✅
```

{{< notice notice-note >}}
![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-7.png)
对于 let 声明，只需要推导至这个值从属的类型即可。而 const 声明的**原始类型**变量将不再可变，因此类型可以直接一步到位收窄到最精确的字面量类型，但对象类型变量仍可变（但同样会要求其属性值类型保持一致）。
![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-8.png)
{{< /notice >}}

{{< /spoiler >}}

{{< spoiler  "联合类型">}}
们还可以将各种类型混合到一起:

```typescript
interface Tmp {
    mixed: true | string | 599 | {} | (() => {}) | (1 | 2);
}
```

这里有几点需要注意的：

-   对于联合类型中的函数类型，需要使用括号()包裹起来
-   函数类型并不存在字面量类型，因此这里的 (() => {}) 就是一个合法的函数类型
-   你可以在联合类型中进一步嵌套联合类型，但这些嵌套的联合类型最终都会被展平到第一级中

联合类型的常用场景之一是通过多个对象类型的联合，来实现手动的互斥属性，即这一属性如果有字段 1，那就没有字段 2：

```typescript
interface Tmp {
    user:
        | {
              vip: true;
              expires: string;
          }
        | {
              vip: false;
              promotion: string;
          };
}

declare var tmp: Tmp;

if (tmp.user.vip) {
    console.log(tmp.user.expires);
}
```

{{< /spoiler >}}

{{< spoiler  "never">}}
never 类型不携带任何的类型信息，因此会在联合类型中被直接移除
![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-1.png)

void 和 never 的类型兼容性：
never 是所有类型的子类型，但只有 never 类型的变量能够赋值给另一个 never 类型变量

```typescript
declare let v1: never;
declare let v2: void;

v1 = v2; // ❎ 类型 void 不能赋值给类型 never
v2 = v1;

//抛出错误的函数返回never类型
function justThrow(): never {
    throw new Error();
}
//在类型流的分析中，一旦一个返回值类型为never的函数被调用，那么下方的代码都会被视为无效的代码（即无法执行到）：
function foo(input: number) {
    if (input > 1) {
        justThrow();
        // 等同于 return 语句后的代码，即 Dead Code
        const name = "zzydev";
    }
}
```

**never 的应用场景之一：**

```typescript
// dataFlowAnalysisWithNever 方法穷尽了 DataFlow 的所有可能类型。
// 使用 never 避免出现未来扩展新的类没有对应类型的实现, 目的就是写出类型绝对安全的代码。
type DataFlow = string | number;
function dataFlowAnalysisWithNever(dataFlow: DataFlow) {
    if (typeof dataFlow === "string") {
        console.log("字符串类型:", dataFlow.length);
    } else if (typeof dataFlow === "number") {
        console.log("数值类型:", dataFlow.toFixed(2));
    } else {
        let data = dataFlow; // data现在为never类型，假如以后DateFlow的类型加上boolean,那data就变成boolean类型
    }
}
dataFlowAnalysisWithNever("zzy");
dataFlowAnalysisWithNever(3.1415926);
```

{{< /spoiler >}}

{{< spoiler  "数字枚举和字符串枚举">}}

```typescript
//数字枚举
enum A {
    A = 10,
    B = 12,
    // 没有写值，默认以上一个值自增1
    C,
    D,
}
console.log(A["B"]); // 12  数字枚举 可以双重映射 由键到值，也可以由值到键
console.log(A[10]); // A

// 在数字型枚举中，你可以使用延迟求值的枚举值:
const returnNum = () => 100 + 499;
enum Items {
    Foo = returnNum(),
    Bar = 599,
    Baz,
}

//⚠️注意，延迟求值的枚举值是有条件的。
//如果你使用了延迟求值，那么没有使用延迟求值的枚举成员必须放在使用常量枚举值声明的成员之后，或者放在第一位：
enum Items {
    First, // 第一位
    Foo = returnNum(),
    //这里不能放未赋值成员
    Bar = 599,
    Baz, // 常量枚举成员之后
}

// 常量枚举
const enum Items {
    Foo,
    Bar,
    Baz,
}
//对于常量枚举，你只能通过枚举成员访问枚举值（而不能通过值访问成员）
const fooValue = Items.Foo;
// 编译产物: const fooValue = 0 /* Foo */; // 0

//  字符串枚举
enum WeekEnd {
    Monday = "monday",
    Tuesday = "tuesday",
    Wensday = "wensday",
    ThirsDay = "thirsDay",
    Friday = "friday",
    Sarturday = "sarturday",
    Sunday = "sunday",
}

console.log(WeekEnd.Monday);
console.log(WeekEnd["Monday"]);
console.log(WeekEnd["monday"]); // ❎ 不能反向映射
console.log(weekEnd[1]); // ❎
```

{{< /spoiler >}}

{{< spoiler  "枚举的编译成ES5的真面目">}}

```javascript
//这就是数字枚举双向映射的原因
var A;
(function (A) {
    A[(A["A"] = 10)] = "A";
    A[(A["B"] = 12)] = "B";
    A[(A["C"] = 13)] = "C";
    A[(A["D"] = 14)] = "D";
})(A || (A = {}));

var WeekEnd;
(function (WeekEnd) {
    WeekEnd["Monday"] = "monday";
    WeekEnd["Tuesday"] = "tuesday";
    WeekEnd["Wensday"] = "wensday";
    WeekEnd["ThirsDay"] = "thirsDay";
    WeekEnd["Friday"] = "friday";
    WeekEnd["Sarturday"] = "sarturday";
    WeekEnd["Sunday"] = "sunday";
})(WeekEnd || (WeekEnd = {}));
```

{{< /spoiler >}}

{{< spoiler  "可选参数与rest参数">}}

```typescript
// 在函数逻辑中注入可选参数默认值
//⚠️可选参数必须位于必选参数之后
function foo1(name: string, age?: number): number {
    const inputAge = age || 18; // 使用 age 或者 18
    return name.length + inputAge;
}

// 直接为可选参数声明默认值
function foo2(name: string, age: number = 18): number {
    const inputAge = age;
    return name.length + inputAge;
}

// rest参数
function foo(arg1: string, ...rest: any[]) {}
// 使用元组类型进行标注
function foo(arg1: string, ...rest: [number, boolean]) {}
```

{{< /spoiler >}}

{{< spoiler  "函数重载">}}

```typescript
type MessageType = "image" | "audio" | string; //微信消息类型
type Message = {
    id: number;
    type: MessageType;
    sendmessage: string;
};

let messages: Message[] = [
    //let messages: Array<Message> = [
    {
        id: 1,
        type: "image",
        sendmessage: "我要涩涩.png",
    },
    {
        id: 2,
        type: "audio",
        sendmessage: "深夜在浅色床单痛哭失声.mp4",
    },
    {
        id: 3,
        type: "audio",
        sendmessage: "你干嘛~(ikun纯享版).flac",
    },
    {
        id: 4,
        type: "image",
        sendmessage: "不可以涩涩.png",
    },
    {
        id: 5,
        type: "image",
        sendmessage: "医业丁真，鉴定为九十割几把.png",
    },
];

//不用函数重载来实现
//函数结构不分明,可读性，可维护性变差
function getMessage(
    value: number | MessageType
): Message | undefined | Array<Message> {
    if (typeof value === "number") {
        return messages.find((msg) => value === msg.id);
    } else {
        return messages.filter((msg) => value === msg.type);
    }
}

console.log(getMessage("audio"));
// TS没有办法运行之前根据传递的值来推导方法最终返回的数据的数据类型
// 只可以根据方法定义的类型展现
//let msg=getMessage(1)
//⚠️ console.log(msg.sendMessage)//错误 类型“Message | Message[]”上不存在属性“sendMessage”。
//  类型“Message”上存在属性“sendMessage”
let msg = (<Message>getMessage(1)).sendmessage;
console.log("msg:", msg);

function getMessage(value: number): Message; //第一个根据数字id来查询单个消息的重载签名
function getMessage(value: MessageType, readRecordCount: number): Message[]; //第二个根据消息类型来查询消息数组的重载签名
//实现签名参数个数可以少于重载签名的参数个数，但实现签名如果准备包含重载签名的某个位置的参数 ，那实现签名就必须兼容所有重载签名该位置的参数类型【联合类型或 any 或 unknown 类型的一种】。
//不管重载签名返回值类型是何种类型，实现签名都可以返回 any 类型 或 unknown类型，当然一般我们两者都不选择，让 TS 默认为实现签名自动推导返回值类型。
//由于实现签名第二个参数有默认值，所以这里的重载签名可以没有第二个参数，也可以在实现签名的参数加上可选?
function getMessage(value: any, value2: any = 1) {
    // function getMessage(value: any, value2?: any) {
    if (typeof value === "number") {
        return messages.find((msg) => {
            return msg === msg.id;
        });
    } else {
        return messages.filter((msg) => value === msg.type).splice(0, value2);
    }
}

getMessage(1);
```

{{< /spoiler >}}

{{< spoiler  "类声明和类表达式">}}

```typescript
// 类声明
class Foo {
    // =========通过构造函数为类成员赋值 ================
    private prop: string;

    constructor(inputProp: string) {
        this.prop = inputProp;
    }
    // ==============================================

    // 上面代码可以简写为这一行：
    constructor(private prop: string) {}

    protected print(addon: string): void {
        console.log(`${this.prop} and ${addon}`);
    }

    public get propA(): string {
        return `${this.prop}+A`;
    }

    // ⚠️ setter 方法不允许进行返回值的类型标注
    public set propA(value: string) {
        this.prop = `${value}+A`;
    }
}

// 类表达式
const Foo = class {
    prop: string;

    constructor(inputProp: string) {
        this.prop = inputProp;
    }

    print(addon: string): void {
        console.log(`${this.prop} and ${addon}`);
    }

    // ...
};
```

{{< /spoiler >}}

{{< spoiler  "static与单件设计模式">}}

```javascript
//   第一步：把构造器设置为私有的，不允许外部来创建类的对象
//   第二步: 至少应该提供一个外部访问的方法或属性，外部可以通过这个方法或属性来得到一个对象
//          所以应该把这个方法设置为静态方法
//   第三步：外部调用第二步提供的静态方法来获取一个对象
// 懒汉式
export default class MyLocalStorage {
  static localstorage: MyLocalStorage//静态引用属性
  static count: number = 3;//静态的基本类型属性
  private constructor() {
    console.log("这是TS的单件设计模式的静态方法的构造器");
  }
  // 提供一个外部访问的方法,
  // 通过这个方法用来提供外部得到一个对象的方法

  //   1. 带static关键字的方法就是一个静态方法
  //   2. 静态方法和对象无关，外部的对象变量不能调用静态方法和静态属性，
  //   3. 外部可以通过类名来调用
  //   静态方法不可以访问实例属性或实例方法
  public static getInstance() {
  //  静态方法通过this来获取静态成员
    if (!this.localstorage) {//如果静态对象属性指向创建对象
      console.log("我是一个undefined的静态属性，用来指向一个对象空间的静态属性")
      this.localstorage = new MyLocalStorage()
    }
    return this.localstorage
  }

  public setItem(key: string, value: any) {
    localStorage.setItem(key, JSON.stringify(value))
  }

  public getItem(key: string) {
    let value = localStorage.getItem(key)
    return value != null ? JSON.parse(value) : null;
  }
}


/*
let oo = new MyLocalStorage.getInstance(); //❎ 错误  TS已经屏蔽了去new一个类中的方法

MyLocalStorage.prototype.newFn = function () {}
//❎ 错误 TS类可以访问prototype原型对象属性，但无法在prototype原型对象属性增加新的方法或属性

MyLocalStorage.prototype.setItem = function () {} //✅ 正确  但是可以覆盖类上已经存在的方法
*/

```

编译成 javaScript 的代码：  
**静态成员直接被挂载在函数体上，而实例成员挂载在原型上**  
**静态成员不会被实例继承，它始终只属于当前定义的这个类（以及其子类）。而原型对象上的实例成员则会沿着原型链进行传递，也就是能够被继承。**

```javascript
"use strict";
exports.__esModule = true;
var MyLocalStorage = /** @class */ (function () {
    function MyLocalStorage() {
        console.log("这是TS的单件设计模式的静态方法的构造器");
    }

    MyLocalStorage.getInstance = function () {
        if (!this.localstorage) {
            console.log(
                "我是一个undefined的静态属性，用来指向一个对象空间的静态属性"
            );
            this.localstorage = new MyLocalStorage();
        }
        return this.localstorage;
    };

    MyLocalStorage.prototype.setItem = function (key, value) {
        localStorage.setItem(key, JSON.stringify(value));
    };
    MyLocalStorage.prototype.getItem = function (key) {
        var value = localStorage.getItem(key);
        return value != null ? JSON.parse(value) : null;
    };
    MyLocalStorage.count = 3;
    return MyLocalStorage;
})();
exports["default"] = MyLocalStorage;
```

```typescript
// 饿汉式
class MyLocalStorage {
    static localstorage: MyLocalStorage = new MyLocalStorage();
    static count: number = 3;
    private constructor() {
        console.log("这是TS的单件设计模式的静态方法的构造器");
    }

    public setItem(key: string, value: any) {
        localStorage.setItem(key, JSON.stringify(value));
    }

    public getItem(key: string) {
        let value = localStorage.getItem(key);
        return value != null ? JSON.parse(value) : null;
    }
}
```

无论你是否创建对象，创建多少个对象，是否调用该静态方法或静态属性，TS 都会为这个静态方法或静态属性分配内存空间，注意：静态成员和对象无关。  
一旦为静态方法或静态属性分配好空间，就一直保存到内存中，直到服务器重启或者控制台程序执行结束才被释放。

{{< /spoiler >}}

{{< spoiler  "TS继承">}}
[回顾手写 JS 继承]("https://zzydev.top/posts/eight-part-essay/有手就行/#手写JS继承")

```typescript
class Base {
    print() {}
}

class Derived extends Base {
    //派生类对基类成员的访问与覆盖操作
    print() {
        super.print();
        // ...
    }
    //override 关键字，来确保派生类尝试覆盖的方法一定在基类中存在定义
    //在这里 TS 将会给出错误，因为尝试覆盖的方法并未在基类中声明。
    override say() {}
}

//⚠️ 在TypeScript中无法声明静态的抽象成员

//抽象类
abstract class LoginHandler {
    abstract handler(): void;
}
// 其实 interface 也可以描述类的结构
interface LoginHandler {
    hander(): void;
}

class WeChatLoginHandler implements LoginHandler {
    handler() {}
}

class TaoBaoLoginHandler implements LoginHandler {
    handler() {}
}

class TikTokLoginHandler implements LoginHandler {
    handler() {}
}

class Login {
    public static handlerMap: Record<LoginType, LoginHandler> = {
        [LoginType.TaoBao]: new TaoBaoLoginHandler(),
        [LoginType.TikTok]: new TikTokLoginHandler(),
        [LoginType.WeChat]: new WeChatLoginHandler(),
    };
    public static handler(type: LoginType) {
        Login.handlerMap[type].handler();
    }
}

//使用 Newable Interface 来描述一个类的结构（类似于描述函数结构的 Callable Interface）：
class Foo {}
interface FooStruct {
    new (): Foo;
}
declare const NewableFoo: FooStruct;
const foo = new NewableFoo();

// 什么是 Callable Interface
interface FuncFooStruct {
    (name: string): number;
}
```

{{< /spoiler >}}

{{< spoiler "any unknown">}}
unknown 类型和 any 类型有些类似，一个 unknown 类型的变量可以再次赋值为任意其它类型，但只能赋值给 any 与 unknown 类型的变量：

```typescript
let unknownVar: unknown = "zzy";

unknownVar = false;
unknownVar = "zzy";
unknownVar = {
    site: "zzy",
};

unknownVar = () => {};

const val1: string = unknownVar; // ❎
const val2: number = unknownVar; // ❎
const val3: () => {} = unknownVar; // ❎
const val4: {} = unknownVar; // ❎

const val5: any = unknownVar;
const val6: unknown = unknownVar;
```

```typescript
let unknownVar: unknown;
unknownVar.foo(); // 报错：对象类型为 unknown
//类型断言
(unknownVar as { foo: () => {} }).foo();
```

{{< /spoiler >}}

{{< spoiler  "类型断言">}}
类型断言的正确使用方式是，在 TypeScript 类型分析不正确或不符合预期时，将其断言为此处的正确类型：

```typescript
interface IFoo {
    name: string;
}

declare const obj: {
    foo: IFoo;
};

const { foo = {} } = obj; //这里foo的类型是{}
//foo.name ❎
const { foo = {} as IFoo } = obj; //这里foo的类型是IFoo
foo.name;
```

**双重断言**
你的断言类型和原类型的差异太大，需要先断言到一个通用的类，即 any/unknown。这一通用类型包含了所有可能的类型，因此断言到它和从它断言到另一个类型差异不大。

```typescript
const str: string = "linbudu";
// 从 X 类型 到 Y 类型的断言可能是错误的 ...
(str as { handler: () => {} }).handler();

(str as unknown as { handler: () => {} }).handler();
// 使用尖括号断言
(<{ handler: () => {} }>(<unknown>str)).handler();
```

**非空断言**
非空断言其实是类型断言的简化，它使用 ! 语法，即`obj!.func()!.prop`的形式标记前面的一个声明一定是非空的（实际上就是剔除了 null 和 undefined 类型）

```typescript
declare const foo: {
    func?: () => {
        prop?: number | null;
    };
};

foo.func!().prop!.toFixed();

//其应用位置类似于可选链：
foo.func?.().prop?.toFixed();
/*
但不同的是，非空断言的运行时仍然会保持调用链，因此在运行时可能会报错。
而可选链则会在某一个部分收到 undefined 或 null 时直接短路掉，不会再发生后面的调用。
*/

//非空断言的常见场景还有 document.querySelector、Array.find 方法等：
const element = document.querySelector("#id")!;
const target = [1, 2, 3, 233].find((item) => item === 233)!;
```

为什么说非空断言是类型断言的简写：

```typescript
foo.func!().prop!.toFixed();
//等价于
(
    (
        foo.func as () => {
            prop?: number;
        }
    )().prop as number
).toFixed();
```

{{< /spoiler >}}

{{< spoiler  "交叉类型">}}

```typescript
type Struct1 = {
    primitiveProp: string;
    objectProp: {
        name: string;
    };
};

type Struct2 = {
    primitiveProp: number;
    objectProp: {
        age: number;
    };
};

type Composed = Struct1 & Struct2;

type PrimitivePropType = Composed["primitiveProp"]; // never  交集为空集
//对于对象类型的交叉类型，其内部的同名属性类型同样会按照交叉类型进行合并
type ObjectPropType = Composed["objectProp"]; // { name: string; age: number; }

// 合并后的 name 同样是 never 类型
type Derived = Struct1 & {
    primitiveProp: number;
};
```

**扩展：接口的合并**

```ts
interface Struct1 {
    primitiveProp: string;
    objectProp: {
        name: string;
    };
}

// 接口“Struct2”错误扩展接口“Struct1”。属性“primitiveProp”的类型不兼容。不能将类型“number”分配给类型“string”。
interface Struct2 extends Struct1 {
    primitiveProp: number;
    objectProp: {
        age: number;
    };
}
```

如果你直接声明多个同名接口，虽然接口会进行合并，但这些同名属性仍然需要属于同一类型：

```ts
interface Struct1 {
    primitiveProp: string;
    objectProp: {
        name: string;
    };
}

interface Struct1 {
    // 后续属性声明必须属于同一类型。属性“primitiveProp”的类型必须为“string”，但此处却为类型“number”。
    primitiveProp: number;
    // 类似的报错
    objectProp: {
        age: number;
    };
}
```

{{< /spoiler >}}

{{< spoiler  "索引类型">}}
索引签名类型主要指的是在接口或类型别名中，通过以下语法来**快速声明一个键值类型一致的类型结构：**

```typescript
interface AllStringTypes {
    [key: string]: string;
}

type AllStringTypes = {
    [key: string]: string;
};

/*
但由于 JavaScript 中，对于 obj[prop] 形式的访问会将数字索引访问转换为字符串索引访问。
所以obj[233] 和 obj['233'] 的效果是一致的。在字符串索引签名类型中我们仍然可以声明数字类型的键。
类似的，symbol 类型也是如此：
*/
const foo: AllStringTypes = {
    zzydev: "233",
    233: "zzydev",
    [Symbol("zzy")]: "symbol",
};

// propA 和 propB 的类型要符合索引签名类型的声明
interface StringOrBooleanTypes {
    propA: number;
    propB: boolean;
    [key: string]: number | boolean;
}
```

{{< /spoiler >}}

{{< spoiler  "索引类型查询与索引类型访问">}}
索引类型查询 keyof：

```typescript
interface Foo {
    zzy: 1;
    233: 2;
}

// "zzy" | 233 注意这里的233仍然是数字
type FooKeys = keyof Foo;

type Any = keyof any;
//相当于
type Any = string | number | symbol;
```

索引类型访问:

```typescript
interface NumberRecord {
    [key: string]: number;
}

type PropType = NumberRecord[string]; // number

interface Foo {
    propA: number;
    propB: boolean;
}

type PropAType = Foo["propA"]; // number
type PropBType = Foo["propB"]; // boolean
type PropType = Foo[string]; // ❎ 在未声明索引签名类型的情况下，不能使用Foo[string]这种方式访问

/*
看起来这里就是普通的值访问，但实际上这里的'propA'和'propB'都是字符串字面量类型，而不是一个JavaScript字符串值。
索引类型查询的本质其实就是，通过键的字面量类型（'propA'）访问这个键对应的键值类型（number）。
*/

//⚠️ 索引类型查询、索引类型访问通常会和映射类型一起搭配使用，前两者负责访问键，而映射类型在其基础上访问键值类型。
interface Foo {
    propA: number;
    propB: boolean;
    propC: string;
}
// string | number | boolean
type PropTypeUnion = Foo[keyof Foo];
```

{{< /spoiler >}}

{{< spoiler  "映射类型">}}
映射类型的主要作用即是基于键名映射到键值类型：

```typescript
type stringify<T> = { [K in keyof T]: string };
type Clone<T> = {
    //索引签名类型 : 索引类型访问
    [K in keyof T]: T[K];
};
```

{{< /spoiler >}}

{{< spoiler  "类型查询运算符typeof">}}
在逻辑代码中使用的 typeof 一定会是 JavaScript 中的 typeof，
类型代码（如类型标注、类型别名中等）中的一定是类型查询的 typeof
为了更好地避免这种情况，也就是隔离类型层和逻辑层，类型查询操作符后是不允许使用表达式的：

```typescript
const isInputValid = (input: string) => {
  return input.length > 0;
};
type isValid = typeof isInputValid("zzy"); // ❎
```

{{< /spoiler >}}

{{< spoiler  "⭐ 类型守卫">}}

```typescript
//判断逻辑封装起来提取到函数外部进行复用
function isString(input: unknown): boolean {
    return typeof input === "string";
}

function foo(input: string | number) {
    if (isString(input)) {
        //❓ 类型“string | number”上不存在属性“replace”。
        // 这里的类型控制流分析做不到跨函数上下文来进行类型的信息收集
        input.replace("zzy", "233");
    }
    if (typeof input === "number") {
    }
    // ...
}
```

为了解决这一类型控制流分析的能力不足，TypeScript 引入了**is 关键字**来显式地提供类型信息。  
在这里 isString 函数称为**类型守卫**，在它的返回值中，我们不再使用 boolean 作为类型标注，而是使用`input is string`
将`input is string`拆开：

-   input 函数的某个参数；
-   is string，即 is 关键字 + 预期类型，即如果这个函数成功返回为 true，那么 is 关键字前这个入参的类型，就会被这个类型守卫调用方后续的类型控制流分析收集到。

```typescript
function isString(input: unknown): input is string {
    return typeof input === "string";
}
```

开发中常用的两个类型守卫：

```typescript
export type Falsy = false | "" | 0 | null | undefined;

export const isFalsy = (val: unknown): val is Falsy => !val;

// 不包括不常用的 symbol 和 bigint
export type Primitive = string | number | boolean | undefined;

export const isPrimitive = (val: unknown): val is Primitive =>
    ["string", "number", "boolean", "undefined"].includes(typeof val);
```

除了使用 typeof 以外，我们还可以使用许多类似的方式来进行**类型保护**，只要它能够在联合类型的类型成员中起到**筛选作用**。

{{< /spoiler >}}

{{< spoiler  "基于 in 与 instanceof 的类型保护">}}
可以通过`key in object`的方式来判断 key 是否存在于 object 或其原型链上（返回 true 说明存在）。

```ts
interface A {
    a: string;
    aOnly: string;
    c: string;
}

interface B {
    b: string;
    bOnly: string;
    c: string;
}

function check(val: A | B) {
    if ("a" in val) {
        //Property 'aOnly' does not exist on type 'A | B'.Property 'aOnly' does not exist on type 'B'
        val.aOnly;
    } else {
        //Property 'bOnly' does not exist on type 'never'
        val.bOnly;
    }
}

function check2(val: A | B) {
    if ("c" in val) {
        //类型 "A | B"上不存在属性 "aOnly"
        val.aOnly;
    } else {
        val.bOnly;
    }
}
```

**可辨识属性**可以是结构层面的，比如结构 A 的属性 prop 是数组，而结构 B 的属性 prop 是对象，或者结构 A 中存在属性 prop 而结构 B 中不存在，或者共同属性字面量差异等。

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-2.png)
使用[instanceof](https://zzydev.top/posts/eight-part-essay/%E6%9C%89%E6%89%8B%E5%B0%B1%E8%A1%8C/#%e6%89%8b%e5%86%99%20instanceof)进行类型保护：

```ts
class FooBase {}

class BarBase {}

class Foo extends FooBase {
    fooOnly() {}
}
class Bar extends BarBase {
    barOnly() {}
}

function handle(input: Foo | Bar) {
    if (input instanceof FooBase) {
        input.fooOnly();
    } else {
        input.barOnly();
    }
}
```

{{< /spoiler >}}

{{< spoiler  "断言守卫">}}
**断言守卫和类型守卫最大的不同点在于，在判断条件不通过时，断言守卫需要抛出一个错误，类型守卫只需要剔除掉预期的类型**  
[👍 官方文档简明易懂：assertion-functions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#assertion-functions)

{{< /spoiler >}}

{{< spoiler  "泛型约束与默认值">}}
在泛型中，我们可以使用 `extends` 关键字来约束传入的泛型参数必须符合要求。  
`A = B`或 `A extends B`意味着 B 是 A 的子类型  
例如：`U extends keyof T`表示`U`的类型被约束在联合类型`keyof T`的范围内

extends 还经常用于条件类型：
`T extends U ? T : never`,条件类型有点像 JavaScript 中的三元表达式  
在条件类型中，有一个特别需要注意的东西就是：分布式条件类型:
![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-3.png)
TypeScript 对联合类型在条件类型中使用时的特殊处理：会把联合类型的每一个元素单独传入做类型计算，最后合并。  
这和联合类型遇到字符串时的处理一样：  
![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-4.png)
{{< /spoiler >}}

{{< spoiler  "对象类型中的泛型">}}

```ts
//这个接口描述了一个通用的响应类型结构，预留出了实际响应数据的泛型坑位，
//然后在你的请求函数中就可以传入特定的响应类型了：
interface IRes<TData = unknown> {
    code: number;
    error?: string;
    data: TData;
}
interface IUserProfileRes {
    name: string;
    homepage: string;
    avatar: string;
}
function fetchUserProfile(): Promise<IRes<IUserProfileRes>> {}

type StatusSucceed = boolean;
function handleOperation(): Promise<IRes<StatusSucceed>> {}
//泛型嵌套的场景也非常常用，比如对存在分页结构的数据，我们也可以将其分页的响应结构抽离出来：
interface IPaginationRes<TItem = unknown> {
    data: TItem[];
    page: number;
    totalCount: number;
    hasNextPage: boolean;
}

function fetchUserProfileList(): Promise<
    IRes<IPaginationRes<IUserProfileRes>>
> {}
```

{{< /spoiler >}}

{{< spoiler  "函数中的泛型">}}
箭头函数的泛型书写 ✍🏻 方式：

```ts
const handle = <T>(input: T): T => {};

//需要注意的是在 tsx 文件中泛型的尖括号可能会造成报错，编译器无法识别这是一个组件还是一个泛型，
//此时你可以让它长得更像泛型一些：
const handle = <T extends any>(input: T): T => {};
```

{{< notice notice-info >}}
不要为了用泛型而用泛型，泛型参数 T 没有被返回值消费，也没有被内部的逻辑消费，这种情况下即使随着调用填充了泛型参数，也是没有意义的。

```ts
//这里完全可以用 any 来进行类型标注
function handle<T>(arg: T): void {
    console.log(arg);
}
```

{{< /notice >}}

{{< /spoiler >}}

{{< spoiler  "类型系统层级">}}

```ts
type Result = String extends {} ? 1 : 2; // 1
type Result1 = {} extends object ? 1 : 2; // 1
type Result2 = object extends Object ? 1 : 2; // 1

//string extends object 并不成立
type Tmp = string extends object ? 1 : 2; //⚠️ 2
```

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-5.png)

```ts
type Result = Object extends any ? 1 : 2; // 1
//⚠️ 将any调过来，值竟然变成了 1 | 2
type Result1 = any extends {} | object | Object ? 1 : 2; // 1 | 2
```

![](https://zzydev-1255467326.cos.ap-guangzhou.myqcloud.com/ts-study/1-6.png)
{{< notice notice-tip >}}
基础的类型层级链：Bottom Type(never) < 对应的字面量类型 < 基础类型 < 装箱类型 < 顶级类型(Object) < Top Type(any/unknown)
{{< /notice >}}

补充：

```ts
type Result1 = [number, string] extends number[] ? 1 : 2; // 2
// let arr: (number| string)[] = [233, "zzy"]
type Result2 = [number, string] extends (number | string)[] ? 1 : 2; // 1

// [] 等价于 any[]
type Result3 = [] extends number[] ? 1 : 2; // 1
type Result4 = [] extends unknown[] ? 1 : 2; // 1
```

{{< /spoiler >}}

{{< spoiler  "infer">}}

```ts
type ArrayItemType<T> = T extends Array<infer ElementType>
    ? ElementType
    : never;
// [string, number] 等效于 (string| number)[]
type ArrayItemTypeResult = ArrayItemType<[string, number]>; // string | number

type ReverseKeyValue<T extends Record<string, unknown>> = T extends Record<
    infer K,
    infer V
>
    ? Record<V & string, K>
    : never;
```

{{< /spoiler >}}

{{< spoiler  "分布式条件类型">}}
[👍 官方文档简明易懂 Distributive Conditional Types](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-8.html#distributive-conditional-types)

在某些情况下，我们也会需要**包裹泛型参数**来禁用掉分布式特性。  
常见包裹类型的书写方式：

```ts
// 包裹泛型① 通过泛型参数被[]包裹
type Wrapped<T> = [T] extends [boolean] ? "Y" : "N";

// 包裹泛型②
export type NoDistribute<T> = T & {};

type Wrapped<T> = NoDistribute<T> extends [boolean] ? "Y" : "N";
```

{{< notice notice-info >}}

```ts
type NeverFalseImpl<T> = T extends never ? true : false;
type res1 = NeverFalseImpl<never>; // never
type res2 = NeverFalseImpl<any>; // boolean

//⚠️ any 作为判断参数时、作为泛型参数时都会产生这一效果:
type Tmp1 = any extends string ? 1 : 2; // 1 | 2
type Tmp2<T> = T extends string ? 1 : 2;
type Tmp2Res = Tmp2<any>; // 1 | 2

//而 never 仅在作为泛型参数时才会产生：(有点中断施法的感觉)
type Tmp3 = never extends string ? 1 : 2; // 1
type Tmp4<T> = T extends string ? 1 : 2;
type Tmp4Res = Tmp4<never>; // never
```

{{< /notice >}}

{{< /spoiler >}}
