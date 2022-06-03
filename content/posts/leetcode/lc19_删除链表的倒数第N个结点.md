---
title: "Lc19_删除链表的倒数第N个结点"
date: 2022-06-03T22:30:45+08:00
draft: true
tags:
  - "链表"
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



[原题链接](https://leetcode.cn/problems/remove-nth-node-from-end-of-list/)

解题思路：

1. 先求出链表长度
2. 求出要删除节点的位置

```cpp
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        ListNode* dummy = new ListNode(0);
        dummy->next = head;
        auto p = dummy;
        auto q = p;
        int len = 0;
        while (p->next) {
            p = p->next;
            len ++;
        }
        int k = len - n ;
        for (int i = 0; i < k; i ++) {
            q = q->next;
        }
        q->next = q->next->next;
        return dummy->next;
    }
};
```

