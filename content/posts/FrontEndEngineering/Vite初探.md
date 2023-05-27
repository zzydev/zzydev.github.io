---
title: "Vite初探"
date: 2023-03-23T00:09:46+08:00
lastmod:
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

{{< quote-center >}}
大概是一份不完整的 Vite 备忘录  
{{< /quote-center >}}

## no-bundle 是什么

no-bundle 理念：**利用浏览器原生 ES 模块的支持，实现开发阶段的 Dev Server，进行模块的按需加载，而不是先整体打包再进行加载**  
在 Vite 项目中，**一个 import 语句代表一个 HTTP 请求。** Vite 的 Dev Server 来接收这些请求、进行文件转译以及返回浏览器可以运行的代码。当浏览器解析到新的 import 语句，又会发出新的请求，以此类推，直到所有的资源都加载完成。

## CSS 工程化方案

### 自动引入 CSS

```css
/*variable.scss*/
$theme-color: red;

/*index.scss*/
@import "../../variable";

.header {
    color: $theme-color;
}
```

```typescript
// vite.config.ts
import { normalizePath } from "vite";
// 如果类型报错，需要安装 @types/node
import path from "path";

// 全局 scss 文件的路径
// 用 normalizePath 解决 window 下的路径问题
const variablePath = normalizePath(path.resolve("./src/variable.scss"));

export default defineConfig({
    // css 相关的配置
    css: {
        preprocessorOptions: {
            scss: {
                // additionalData 的内容会在每个 scss 文件的开头自动注入
                additionalData: `@import "${variablePath}";`,
            },
        },
    },
});
```

### CSS Modules 自定义生成的类名

```ts
// vite.config.ts
export default {
    css: {
        modules: {
            // 一般我们可以通过 generateScopedName 属性来对生成的类名进行自定义
            // 其中，name 表示当前文件名，local 表示类名
            generateScopedName: "[name]__[local]___[hash:base64:5]",
        },
        preprocessorOptions: {
            // 省略预处理器配置
        },
    },
};
```

### PostCSS 接入 autoprefixer 插件

```ts
// vite.config.ts 增加如下的配置
import autoprefixer from "autoprefixer";

export default {
    css: {
        // 进行 PostCSS 配置
        postcss: {
            plugins: [
                autoprefixer({
                    // 指定目标浏览器
                    overrideBrowserslist: ["Chrome > 40", "ff > 31", "ie 11"],
                }),
            ],
        },
    },
};
```

常用插件：  
[postcss-pxtorem](https://github.com/cuth/postcss-pxtorem)：用来将 px 转换为 rem 单位，在适配移动端的场景下很常用  
[postcss-preset-env](https://github.com/csstools/postcss-preset-env):可以编写最新的 CSS 语法，不用担心兼容性问题  
插件站点：[https://www.postcss.parts/](https://www.postcss.parts/)

### CSS In JS

对于 CSS In JS 方案，在构建侧我们需要考虑选择器命名问题、DCE、代码压缩、生成 SourceMap、SSR 等问题，而 styled-components 和 emotion 已经提供了对应的 babel 插件来解决这些问题，我们在 Vite 中要做的就是集成这些 babel 插件。

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react({
      babel: {
        // 加入 babel 插件
        // 以下插件包都需要提前安装
        // 当然，通过这个配置你也可以添加其它的 Babel 插件
        plugins: [
          // 适配 styled-component
          "babel-plugin-styled-components"
          // 适配 emotion
          "@emotion/babel-plugin"
        ]
      },
      // 注意: 对于 emotion，需要单独加上这个配置
      // 通过 `@emotion/react` 包编译 emotion 中的特殊 jsx 语法
      jsxImportSource: "@emotion/react"
    })
  ]
})
```

### 原子化 CSS

接入 [Unocss](https://unocss.dev/integrations/vite)

## Vite 与自动化代码规范工具

### ESLint

`pnpm i eslint -D`  
`npx eslint --init`  
ESLint 会帮我们自动生成.eslintrc.js 配置文件。我们选择不直接使用 npm 安装依赖，所以需要自己手动安装:  
`pnpm i eslint-plugin-react@latest -D`  
`pnpm i @typescript-eslint/eslint-plugin@latest -D`  
`pnpm i @typescript-eslint/parser@latest -D`

```js
// .eslintrc.js
module.exports = {
  //有些全局变量是业务代码引入的第三方库所声明，这里就需要在globals配置中声明全局变量
  /*
   *  "writable"或者 true，表示变量可重写；
   *  "readonly"或者false，表示变量不可重写；
   *   "off"，表示禁用该全局变量。
   */

   globals: {
    // 不可重写
    $: false,
    jQuery: false
  }
  //指定上述的 env 配置后便会启用浏览器和 ES2021 环境，
  //在浏览器环境下，预定义了全局变量window、document等，而在ES2021环境下，预定义了全局变量Promise、Map。会同时启用
    env: {
        browser: true,
        es2021: true,
    },
    extends: [
        //从 ESLint 本身继承；
        "eslint:recommended",
        //从类似 eslint-config-xxx 的 npm 包继承；
        "standard"
        //从 ESLint 插件继承
        //格式一般为: `plugin:${pluginName}/${configName}`
        //使用extends 的配置，ESLint 插件中的繁多配置，我们就不需要一一手动开启了
        "plugin:react/recommended",
        "plugin:@typescript-eslint/recommended",
    ],
    overrides: [],
    //ESLint 底层默认使用 Espree来进行 AST 解析,但还是不支持 TS ，因此需要引入其他的解析器完成 TS 的解析。
    //社区提供了@typescript-eslint/parser这个解决方案，将 TS 代码转换为 Espree 能够识别的格式(即 Estree 格式)，然后在 Eslint 下通过Espree进行格式检查， 以此兼容了 TS 语法。
    parser: "@typescript-eslint/parser",
    parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
        // ecmaFeatures: 为一个对象，表示想使用的额外语言特性，如开启 jsx
    },
    //通过plugins扩展特定的代码规则
    plugins: ["react", "@typescript-eslint"],
    rules: {
        // https://zh-hans.eslint.org/docs/latest/use/configure/rules
        indent: ["error", 4],
        "linebreak-style": ["error", "unix"],
        quotes: ["error", "double"],
        semi: ["error", "always"],
    },
};
```

### Prettier

`pnpm i prettier -D`  
在项目根目录执行`touch .prettierrc.js && code .prettierrc.js`

```js
// .prettierrc.js
module.exports = {
    printWidth: 80, //一行的字符数，如果超过会进行换行，默认为80
    tabWidth: 2, // 一个 tab 代表几个空格数，默认为 2 个
    useTabs: false, //是否使用 tab 进行缩进，默认为false，表示用空格进行缩进
    singleQuote: true, // 字符串是否使用单引号，默认为 false，使用双引号
    semi: true, // 行尾是否使用分号，默认为true
    trailingComma: "none", // 是否使用尾逗号
    bracketSpacing: true, // 对象大括号直接是否有空格，默认为 true，效果：{ a: 1 }
};
```

接下来我们将 Prettier 集成到现有的 ESLint 工具中，首先安装两个工具包:  
`pnpm i eslint-config-prettier -D`  
`pnpm i eslint-plugin-prettier -D`  
其中 `eslint-config-prettier` 用来覆盖 ESLint 本身的规则配置，而 `eslint-plugin-prettier` 则是用于让 Prettier 来接管 `eslint --fix` 即修复代码的能力。

```js
// .eslintrc.js
module.exports = {
 ...
  extends: [
    ...
    // 1. 接入 prettier 的规则
    + "prettier",
    + "plugin:prettier/recommended"
  ],
  // 2. 加入 prettier 的 eslint 插件
  + plugins: ["react", "@typescript-eslint", "prettier"],
  rules: {
    // 3. 注意要加上这一句，开启 prettier 自动修复的功能
    + "prettier/prettier": "error",
  }
};
```

VSCode 中安装 ESLint 和 Prettier 这两个插件，并且在设置区中开启 Format On Save, 接下来在你保存代码的时候 Prettier 便会自动帮忙修复代码格式。

### 样式规范工具: Stylelint

`pnpm i stylelint stylelint-prettier -D`  
`pnpm i stylelint-config-prettier -D`  
`pnpm i stylelint-config-recess-order -D`  
`pnpm i stylelint-config-standard -D`  
`pnpm i stylelint-config-standard-scss -D`

```js
// .stylelintrc.js
module.exports = {
    // 注册 stylelint 的 prettier 插件
    plugins: ["stylelint-prettier"],
    // 继承一系列规则集合
    extends: [
        // standard 规则集合
        "stylelint-config-standard",
        // standard 规则集合的 scss 版本
        "stylelint-config-standard-scss",
        // 样式属性顺序规则
        "stylelint-config-recess-order",
        // 接入 Prettier 规则
        "stylelint-config-prettier",
        "stylelint-prettier/recommended",
    ],
    // 配置 rules
    rules: {
        // 开启 Prettier 自动格式化功能
        "prettier/prettier": true,
    },
};
```

## Husky + lint-staged 的 Git 提交工作流集成

安装依赖： `pnpm i husky -D`  
初始化 Husky： `npx husky install`
注册 Husky 的 pre-commit 钩子： `npx husky add .husky/pre-commit "npm run lint"`
在 package.json 注册 prepare 命令：

```json
{
    "prepare": "husky install"
}
```

接入 commitlint 进行 commit 信息的检查，安装依赖：
`pnpm i commitlint @commitlint/cli @commitlint/config-conventional -D`

commitlint 配置:

```shell
echo "module.exports = {
  extends: ['@commitlint/config-conventional']
}" > .commitlintrc.cjs
```

增加 Husky 的 commit-msg 钩子：`npx husky add .husky/commit-msg "npx --no-install commitlint --edit \"$1\""`  
现在是全量的进行代码规范检查的，实际上这是没必要的，我们只需要对新增的文件内容进行检查即可。这就需要使用到另外一个工具: `lint-staged` 了。安装依赖:  
`pnpm i lint-staged -D`
package.json 中新增一些内容:

```json
{
    "lint-staged": {
        "**/*.{js,jsx,tsx,ts}": ["eslint --fix"]
    }
}
```

在.husky/pre-commit 脚本中，修改一下其中的内容：

```shell
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- lint-staged
```

现在就可以在 git commit 的过程中实现局部的代码风格检查了。
