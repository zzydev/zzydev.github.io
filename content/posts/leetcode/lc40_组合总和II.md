---
title: "Lc40_组合总和II"
date: 2022-06-07T17:33:00+08:00
draft: true
tags:
  - "dfs"
  - "medium"
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

[原题链接](https://leetcode.cn/problems/combination-sum-ii/)

```cpp
class Solution {
public:
    vector<vector<int>> ans;
    vector<int> path;
    vector<vector<int>> combinationSum2(vector<int>& candidates, int target) {
        sort(candidates.begin(), candidates.end());
        dfs(candidates, 0, target);
        return ans;
    }

    void dfs(vector<int>& candidates, int u, int target) {
        if (target == 0) ans.push_back(path);
        for (int i = u; i < candidates.size(); i ++) {
            if (i > u && candidates[i] == candidates[i - 1]) continue;
            path.push_back(candidates[i]);
            target -= candidates[i];
            dfs(candidates, i + 1, target);
            path.pop_back();
            target += candidates[i];
        }
    }
};
```

