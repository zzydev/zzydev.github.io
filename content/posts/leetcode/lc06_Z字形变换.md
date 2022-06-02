---
title: "Lc06_Z字形变换"
date: 2022-06-02T19:05:15+08:00
draft: false
tags:
  - "medium"
  - "数组"
  - "找规律"
author: ["zzydev"]
---

### 题解

题目要求**假设环境不允许存储 64 位整数（有符号或无符号）**所以只能使用 int

我们要保证 `res * 10 + x % 10` 不越界，那么有当 x > 0 时， `res * 10 + x % 10 < INT_MAX` 通过等价变形 `res * 10 < INT_MAX - x % 10` 。

由于 x > 0 所以，`(INT_MAX - x % 10) / 10`不会溢出

同理，当 x < 0，`INT_MIN - x % 10` 负数减负数也不会溢出。

```cpp
class Solution {
public:
    string convert(string s, int numRows) {
        string res = "";
        for (int i = 0; i < numRows; i ++) {
            if (i == 0 || i == numRows - 1) {
                for (int j = i; j < s.size(); j += 2 * numRows - 2) {
                    res += s[j];
                }
            } else {
                for (int j = i, k = 2 * numRows - 2 - i; j < s.size() || k < s.size(); j += 2 * numRows - 2, k += 2 * numRows - 2) {
                    if (j < s.size()) res += s[j];
                    if (k < s.size()) res += s[k];
                }
            }
        }
        return res;
    }
};
```
