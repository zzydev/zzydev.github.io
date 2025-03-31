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

[vite config](https://cn.vitejs.dev/config/)

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
[cssnano](https://github.com/cssnano/cssnano): 智能压缩 CSS  
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

## 静态资源处理

### 配置别名

方便静态资源引入

```ts
// vite.config.ts
import path from 'path';

{
  resolve: {
    // 别名配置
    alias: {
      '@assets': path.join(__dirname, 'src/assets')
    }
  }
}
```

### SVG 组件方式加载

React 项目使用 [vite-plugin-svgr](https://github.com/pd4d10/vite-plugin-svgr)插件。
在 vite 配置文件添加这个插件:

```ts
// vite.config.ts
import svgr from "vite-plugin-svgr";

{
    plugins: [
        // 其它插件省略
        svgr(),
    ];
}
```

注意要在 tsconfig.json 添加如下配置，否则会有类型错误:

```json
{
    "compilerOptions": {
        // ...
        "types": ["vite-plugin-svgr/client"]
    }
}
```

在项目中使用 svg 组件：

```ts
import { ReactComponent as ReactLogo } from "@assets/icons/logo.svg";

export function Header() {
    return (
        // 其他组件内容省略
        <ReactLogo />
    );
}
```
