---
title: "TS基础拾遗"
date: 2022-06-10T06:19:56+08:00
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

{{< spoiler  "函数类型">}}
```typescript
// 函数类型
function info(username: string, age: number) : number {
  return age;
}

let info: (username: string, age: number) => number = function(username, age) {
  return age;
}

// 接口当名字的函数类型
interface ActionContext {
  (state: any, commit: any): void
}
let actionContext: Action = (state, commit) => {
  console.log(state)
}
```
{{< /spoiler >}}

{{< spoiler  "string 与 String 的区别">}}

```typescript
//string和String都可以作为类型
let username: string | String = "zzy"

//string. 点不出方法
//String. 可以得到静态方法 如String.fromCharCode、String.fromCodePoint等
```
{{< /spoiler >}}

{{< spoiler  "对象取值的坑">}}
```typescript
let obj = {username: "zzy", age: 18} // 类型推导
obj["username"]  // ✅

let username = "username"
obj[username] // ❎

const username = "username"
obj[username] // ✅
--------------------------------------------------
let obj:object | Object = {username: "zzy", age: 18}
const username = "username"

let res = obj[username] // ❎ 如下图所示

let res = (obj as any)[username] // ✅
```
{{< /spoiler >}}

{{< spoiler  "never的应用场景">}}
```typescript
// dataFlowAnalysisWithNever 方法穷尽了 DataFlow 的所有可能类型。 
// 使用 never 避免出现未来扩展新的类没有对应类型的实现, 目的就是写出类型绝对安全的代码。
type DataFlow = string | number
function dataFlowAnalysisWithNever(dataFlow: DataFlow) {
 
  if (typeof dataFlow === "string") {
    console.log("字符串类型:", dataFlow.length);
  } else if (typeof dataFlow === "number") {
    console.log("数值类型:", dataFlow.toFixed(2));
  }else{
    let data=dataFlow // data现在为never类型，假如以后DateFlow的类型加上boolean,那data就变成boolean类型
  }
}
dataFlowAnalysisWithNever("zzy")
dataFlowAnalysisWithNever(3.1415926)

```
{{< /spoiler >}}


{{< spoiler  "数字枚举和字符串枚举">}}
```typescript
//数字枚举
enum A{
    A = 10,
    B = 12,
    // 没有写值，默认以上一个值自增1
    C ,
    D,
}

console.log(A["B"]) // 12  数字枚举 可以双重映射 由键到值，也可以由值到键
console.log(A[10])  // A

//  字符串枚举
enum WeekEnd {
  Monday = "monday",
  Tuesday = "tuesday",
  Wensday = "wensday",
  ThirsDay = "thirsDay",
  Friday = "friday",
  Sarturday = "sarturday",
  Sunday = "sunday"
}

console.log(WeekEnd.Monday)
console.log(WeekEnd["Monday"])
console.log(WeekEnd["monday"]) // ❎ 不能反向映射
console.log(weekEnd[1]) // ❎
```
{{< /spoiler >}}

{{< spoiler  "枚举的编译成ES5的真面目">}}
```javascript
var A;
(function (A) {
    A[A["A"] = 10] = "A";
    A[A["B"] = 12] = "B";
    A[A["C"] = 13] = "C";
    A[A["D"] = 14] = "D";
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

{{< spoiler  "函数重载">}}
```typescript
type MessageType = "image" | "audio" | string;//微信消息类型
type Message = {
  id: number;
  type: MessageType;
  sendmessage: string;
};

let messages: Message[] = [
  //let messages: Array<Message> = [
  {
    id: 1, type: 'image', sendmessage: "我要涩涩.png",
  },
  {
    id: 2, type: 'audio', sendmessage: "深夜在浅色床单痛哭失声"
  },
  {
    id: 3, type: 'audio', sendmessage: "永远失败"
  },
  {
    id: 4, type: 'image', sendmessage: "不可以涩涩.png"
  },
  {
    id: 5, type: 'image', sendmessage: "810975指的是8月10号打了9盘吃了7鸡，其中还有一个五连鸡..."
  }]

//不用函数重载来实现
//函数结构不分明,可读性，可维护性变差
function getMessage(value: number | MessageType):
  Message | undefined | Array<Message> {
  if (typeof value === "number") {
    return messages.find((msg) => value === msg.id)
  } else {
    return messages.filter((msg) => value === msg.type)
  }
}

console.log(getMessage("audio"));
// TS没有办法运行之前根据传递的值来推导方法最终返回的数据的数据类型
// 只可以根据方法定义的类型展现
//let msg=getMessage(1) 
//⚠️ console.log(msg.sendMessage)//错误 类型“Message | Message[]”上不存在属性“sendMessage”。
//  类型“Message”上不存在属性“sendMessage”
let msg = (<Message>getMessage(1)).sendmessage
console.log("msg:", msg)



function getMessage(value: number): Message//第一个根据数字id来查询单个消息的重载签名
function getMessage(value: MessageType, readRecordCount: number): Message[]//第二个根据消息类型来查询消息数组的重载签名
//实现签名参数个数可以少于重载签名的参数个数，但实现签名如果准备包含重载签名的某个位置的参数 ，那实现签名就必须兼容所有重载签名该位置的参数类型【联合类型或 any 或 unknown 类型的一种】。
//不管重载签名返回值类型是何种类型，实现签名都可以返回 any 类型 或 unknown类型，当然一般我们两者都不选择，让 TS 默认为实现签名自动推导返回值类型。
//由于实现签名第二个参数有默认值，所以这里的重载签名可以没有第二个参数，也可以在实现签名的参数加上可选?
function getMessage(value: any, value2: any = 1) {
// function getMessage(value: any, value2?: any) {
  if (typeof value === "number") {
    return messages.find((msg) => { return msg === msg.id })
  } else {
    return messages.filter((msg) => value === msg.type).splice(0, value2)
  }
}

getMessage(1)

```
{{< /spoiler >}}


{{< spoiler  "单件设计模式">}}
```javascript
//   第一步：把构造器设置为私有的，不允许外部来创建类的实例【对象】
//   第二步: 至少应该提供一个外部访问的方法或属性，外部可以通过这个方法或属性来得到一个对象
//          所以应该把这个方法设置为静态方法
//   第三步：外部调用第二步提供的静态方法来获取一个对象
export default class MyLocalStorage {
  static localstorage: MyLocalStorage//静态引用属性
  static count: number = 3;//静态的基本类型属性
  constructor() {
    console.log("这是TS的单件设计模式的静态方法的构造器");
  }
  // 提供一个外部访问的方法,
  // 通过这个方法用来提供外部得到一个对象的方法

  //   1. 带static关键字的方法就是一个静态方法
  //   2. 静态方法和对象无关，外部的对象变量不能调用静态方法和静态属性，
  //   3. 外部可以通过类名来调用
  //   静态方法不可以访问实例属性或实例方法【对象属性或对象方法】
  public static getInstance() {
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
```
{{< /spoiler >}}



