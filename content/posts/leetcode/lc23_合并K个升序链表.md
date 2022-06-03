---
title: "Lc23_合并K个升序链表"
date: 2022-06-03T22:47:50+08:00
draft: true
tags:
  - "链表"
  - "优先队列"
  - "hard"
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

[原题链接](https://leetcode-cn.com/problems/merge-k-sorted-lists/)

1. 使用优先队列，将所有链表的头指针加入到优先队列中（小根堆）
2. 当小根堆不为空时，每次将堆顶元素`t`放入新构建的链表中，再将`t`的下一个节点加入到小根堆中

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

    struct Cmp {
        bool operator() (ListNode* a, ListNode* b) {
            return a->val > b->val;
        }
    };

    ListNode* mergeKLists(vector<ListNode*>& lists) {
        //默认大根堆
        priority_queue<ListNode*, vector<ListNode*>, Cmp> heap;
        auto dummy = new ListNode(-1), tail = dummy;
        for (ListNode* l : lists) if (l) heap.push(l);

        while (heap.size()) {
            auto t = heap.top();
            heap.pop();

            tail = tail->next = t;
            if (t->next) heap.push(t->next);
        }

        return dummy->next;
    }
};
```

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
    ListNode* mergeKLists(vector<ListNode*>& lists) {
        ListNode* dummy = new ListNode(0);
        auto cur = dummy;
        auto cmp = [&](ListNode* a, ListNode* b) {
            return a->val > b->val;
        };
        priority_queue<ListNode*, vector<ListNode*>, decltype(cmp)> minheap(cmp);

        for (int i = 0; i < lists.size(); i ++) {
            if (lists[i]) minheap.push(lists[i]);
        }

        while (minheap.size()) {
            auto p = minheap.top();
            cur->next = new ListNode(p->val);
            cur = cur->next;
            minheap.pop();
            if (p->next) minheap.push(p->next);
        }

        return dummy->next;

    }
};
```

