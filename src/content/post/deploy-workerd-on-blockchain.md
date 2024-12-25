---
title: "基于区块链来部署 workerd"
publishDate: "24 Dec 2024"
description: "上周研究了一下在区块链上部署代理软件，想来想去感觉这个市场还是太小了，有需求的人不够多，思来想去发现还是纯socks5的应用面太窄了，一番调研发现workerd功能丰富多了，这篇文章就将讨论一下部署workerd的可行性"
tags: ["cloudflare", "web3", "serverless"]
---

workerd 是cloudflare开源的 serverless 运行时，有人拿它来部署前端网站，有人拿它来部署翻墙节点。我拿 cloudflare pages部署过几个网站，也使用过 D1, R2, AI 等服务，但是对于 cloudflare workers 是如何工作的还不是很明白，因此在写这篇文章的过程中我会去搜索一些信息，然后加深一下理解。然后看看能不能把 workerd 部署到区块链上，就像[上篇博客](/posts/build-a-proxy-on-blockchain)讨论的把socks5代理部署到区块链上那样

## 先介绍一下我是怎么使用 cloudflare pages 的

我因为喜欢用 svelte 框架，因此都是用框架自带的 cloudflare adapter 来跟 cloudflare workers 交互的。

编译项目：

```bash
bun run build
```

这时候资产会生成到 `.svelte-kit/cloudflare/`

要部署到 cloudflare workers 上的话，将这个文件夹手动通过后台上传上去就行。如果想先在本地试验一下的话，就执行：

```shell
wrangler pages dev .svelte-kit/cloudflare/
```

这条命令其实就是在本地模拟了一个cloudflare 服务器上的环境，使用 miniflare 这个本地运行的软件，执行js，运行sqlite数据库，跑对象存储。

注意到我说 cloudflare pages 和 worker 其实指的是同一个东西，不过 pages 输出的是网页，worker 输出的是json，底层技术都是一样的，都是基于 workerd

## 什么是 serverless runtime

上面说到在本地开启 miniflare 模拟了一个 cloudflare workers 的环境，那么这个环境是什么呢，解决了什么问题呢？还是从历史说起。

最早大家搞开发都是在服务器或自己的开发机器上先跑一个 nginx，然后配置好站点，然后 proxy_pass 到后端的服务器上。这种方式可以在一台服务器上配置几十个站点，如：

```
site1.example.com
site2.example.com
...
```

只不过需要启动几十个对应的后端，去监听对应的端口，然后nginx跟这些后端服务器之间走网络通信，虽然本机的网络很快。但是这种方式也是有成本的，比如说最简单的服务器 `python -m http.server` 就算不接受请求，至少也要占用十几MB的内存，啥都没干就浪费这么多资源。

至于说什么是 serverless，还得对照着源码看，今天我下载了官方开源的代码来学习一下，代码见：[https://github.com/cloudflare/workerd](https://github.com/cloudflare/workerd)

按照文档本地构建完后，启动一个例子是用：

```bash
./workerd serve my-config.capnp
```

到这里我们可以猜测，是否在每个边缘节点上，都跑着一个守护进程，去解析 `my-config.capnp` 文件，而这个配置文件里面定义了这台机器上部署的所有worker项目的信息。

问了一下 GPT，他说是，所以对于多个worker项目，配置文件类似：

```capnp
const config :Workerd.Config = (
  services = [
    // 可以在同一个进程中定义多个服务
    (name = "chat1", worker = .chatWorker1),
    (name = "chat2", worker = .chatWorker2),
    (name = "blog", worker = .blogWorker)
  ]
);
```

又问了一下是如何路由请求的，GPT说是根据域名来决定路由到哪个服务上。

```capnp
const config :Workerd.Config = (
  services = [
    (name = "chat1", worker = .chatWorker1, 
     external = (
       http = (
         hostPattern = "chat1.example.com"
       )
     )),
    (name = "chat2", worker = .chatWorker2,
     external = (
       http = (
         hostPattern = "chat2.example.com"
       )
     ))
  ]
);
```

这就明确了，我们部署的每个 worker 都有一个域名。

那么跟传统的 web server 有什么区别呢？以nginx为例，也是可以通过 proxy_pass 将请求代理到后面的多个服务器上。可以理解为 nginx需要后面启动多个服务器，通过网络io通信，但是 workerd 是启动一个进程，但是进程内部定义了很多 worker，这些worker没有请求进来的时候等于是不占用资源，但是一旦 workerd 收到一个 http 请求，则会发出一个 fetch 事件，对应的 worker 微服务（函数）收到这个事件会被激活，然后就会按照预定的逻辑处理。

简单说就是 nginx 80 到 app的3000端口 要通过网络io，但是 workerd的80到 app 只要发一个事件就行。

cloudflare 一个 worker 就是一个js文件，最大限制是 5M，部署 100万个 worker项目，占用的硬盘也不过才 5T，这点运营成本对 cloudflare 来说是很低的。

## 再总结一下serverless和vps的区别

VPS就好比是把毛坯的商场租给你，你想怎么装修自便。serverless就是房东把商场规划好了，一个摊位一个摊位的，你想卖什么租自己的摊位，缴纳摊位费就行。

目前 vultr 上面最便宜的 VPS 大概是6美金一个月，我付费订阅的 cloudflare 是5美金一个月，虽然我付费了cloudflare 但是人家提供了免费额度，不想付费也是可以的，但是VPS就不可能免费给你了，那样成本太高。

到现在基本可以明白为什么新的开发者都喜欢使用 cloudflare 来部署自己的项目了吧。

## workerd 能不能用来部署到区块链上

最近在 youtube 上总是看到广告说用 USDT 购买 VPS，这种需求我是没有的，但是以众筹的形式募集机器，然后搭建一个类似 cloudflare workers 的边缘计算网络，让用户付费，然后再把费用拿去奖励这些机器的所有者，这个想法能不能做呢？

目前来看很难，但是能做。

1. 收集可信志愿者的机器信息
2. 开发一个控制面接收用户部署的项目
3. 让用户机器去同步控制面里面的项目列表
4. 维护一个DNS记录，解析到所有边缘节点的ip。比如：worker3.dev 解析到 ip1, ip2, ip3，这样实现请求的就近访问
5. 每个志愿者的机器上跑一个workerd 进程，对外提供服务
6. 区块链上接受用户充值，然后定时将奖励分配给志愿者的钱包
