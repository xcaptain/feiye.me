---
title: "deepseek服务降级"
publishDate: "2025-02-08T00:00:00Z"
---

昨天测试MyPod Space插件的时候，发现无法总结网页内容了，一检查才发现是deepseek接口报错了，没正确返回json，怀疑是最近一两周deepseek太火了，用的人很多，导致接口负载太大，也有可能是受到了恶意攻击，反正我是没法调通接口了。不过还是有别的办法，cloudflare workers ai 还提供了开源的 deepseek-r1 模型凑合也能用，不过要自己稍微处理一下结果，把思考过程给去掉。
