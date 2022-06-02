---
title: "Lc08_字符串转换整数(aoti)"
date: 2022-06-02T22:30:37+08:00
draft: true
tags:
  - "字符串"
  - "模拟"
  - "medium"
author: ["zzydev"]
---

```cpp
class Solution {
public:
    int myAtoi(string s) {
        int k = 0;
        while (k < s.size() && s[k] == ' ') k ++; //去除前导空格
        if (k == s.size()) return 0;

        int minus = 1;
        if (s[k] == '-') k ++, minus = -1;
        else if (s[k] == '+') k ++;

        int res = 0;
        while (k < s.size() && s[k] >= '0' && s[k] <= '9') {
            int x = s[k] - '0';
            if (minus > 0 && res > (INT_MAX - x) / 10) return INT_MAX;
						//minus = -1，那res是负数，所以 -res * 10 - x < INT_MIN就会溢出
            if (minus < 0 && -res < (INT_MIN + x) / 10) return INT_MIN;
            if (-res * 10 - x == INT_MIN) return INT_MIN;
            res = res * 10 + x;
            k ++ ;
        }
        res *= minus;
        return res;
    }
};
```
