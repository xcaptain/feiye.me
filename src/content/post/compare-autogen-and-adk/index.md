---
title: "比较 AutoGen 和 agent development kit"
publishDate: "13 Apr 2025"
description: "9号google发布了一个最新的智能体开发框架简称adk，看了一下介绍简单尝试了一下，结合前几天看的autogen做一些对比"
tags: ["AI", "autogen", "adk"]
---

智能体框架越出越多，都快学不过来了，最早看了 cline 的实现，觉得里面的循环逻辑很难剥离出来复用，又看了 huggingface 的 smolagents，发现它只能用来生成 python 代码去做一些AI无法做到的事。上篇博客写的 autogen，功能倒是很强大，能够快速搭建一个多智能体应用，协同解决用户需求。前几天也就是9号，google 又发布了自己的 agent development kit 框架也是用来简化智能体开发流程的。在这篇文章，我还是以实现 typink AI 为目标，比较 microsoft autogen 和 google agent development kit 在开发上的异同，最终决定我使用什么框架。

## typink AI 背景介绍

前几篇文章一直在说我想要实现一个 typink AI 智能体，能够根据用户的需求生成正确的 typst 代码，并且确保文本内容是结构清晰的。跟目前的 coding agent 有点像都是 text to code，但是目前的 coding agent 大部分都是闭源的，就一个 cline 开源，还是大部分都是手写的代码，直接调用底层的 llm 接口实现跟用户交互的，虽然代码很简单，但是毕竟是一年多以前的架构，到今天已经有点过时了，所以需求学习最新的 agent 框架，了解行业内的人认为的未来发展趋势。

## microsoft autogen

在上篇博客中详细介绍了我学习和理解 autogen 的经过，并且我已经快速实现了一个可以生成准确可编译 typst 代码的 agent。架构很简单，我的app是 serverless 架构部署在 cloudflare pages 上的，因为autogen是一个python应用，无法部署在浏览器内也无法部署在 cloudflare workers上，所以只能部署到容器中。这样的话用户请求 cloudflare pages，然后cloudflare pages 请求部署在容器里的autogen 智能体app，返回 stream, 再通过 cloudflare pages 中转一下stream 返回给浏览器就行，AI处理的业务逻辑都写在容器里。

在容器里运行的那个多智能体也很简单，primary agent 设置好提示词，让它负责按要求生成typst代码变更，critic agent 设置好提示词让它去校验 primary agent 生成的内容，而这个agent要搭配一些工具，去lint生成的typst代码，判断是否能编译，如果不能就让 primary agent 再去生成一次。lint完了之后就让AI去检测内容，比如判断返回的内容跟用户的需求是否一致，是否符合当前文件上下文等等。

这个流程看起来很简单，但是如果要自己动手实现可不容易，cline 的代码生成就没有这一步，cline是默认AI生成的代码都是可编译的，因为cline不知道该如何去lint代码。replit, cursor 这些会自动试错，不过人家是在虚拟机里面，通过computer-use, browser-use 这些库来判断项目是否能运行，浏览器是否能打开正确页面，太重型了。我只是想要实现一个AI文本编辑器，如果也用这一套成本太高了，效率也低，但是好在autogen 让我能快速在critic agent里面集成工具，至于 primary agent 和 critic agent 之间如何通信就不是我要操心的了，框架已经定义好了，这也是最难做的一步。让我自己来实现一下2个agent通信，我毫无头绪不知道该怎么做。

## google agent development kit

我们都知道AI能调用外部工具是因为有 tool_use 这个能力，通过这个能力，我们可以在提示词里让AI生成调用某个工具的参数，然后触发调用。基于这个能力，anthropic 出了一个 MCP协议，也就是让外部工具可以通过通用的mcp client来调用，在MCP之前如果要操作一个sqlite数据库，得自己写提示词去生成查询，但是有了MCP 用别人写好的 MCP server就行，所以我们说 MCP 是连接 AI 和工具的。

我们可以理解智能体系统为 Agent to Agent(A2A)，就是说一个智能体调用另一个智能体，这其实就是 multi-agent system，但是google把它标准化了，做成了一个公开的协议。MCP协议是24年12月份由anthropic开源的，然后迅速得到了社区的认可，google看红了眼也想学着做标准，所以在25年的4月提出了自己的 A2A 协议，并且做了了一个开发框架(adk) 来实现这个协议。

google adk 是如何做到智能体之间通信（ A2A ）的呢？

先回忆一下 autogen 是怎么做的？就是将单智能体丢到一个 team 里面，例如一个 team 里面有2个agent，那么如何组织这2个agent的呢？有两种办法：

1. RoundRobinGroupChat
2. SelectorGroupChat

就是组内2个 agent 要么是连续轮换，要么是前一个选择后一个。

google adk 有一个路由的概念，就是定义一个agent的时候可以定义sub_agents，这样在 root agent 里面可以决定是自己来处理用户请求，还是交给 sub agent 去处理。

所以就目前来看，adk 和 autogen 解决的问题是一样的，不过 google 在尝试做自己的标准，而微软只是提供了开发工具没有提供标准。

这就好比以前的 react 和 angular 框架，都能用来做前端，但是 react 只定义了组件树，如何处理路由，如何写样式人家是不管的，但是 angular 就是一个大而全的框架，严格定义了路由怎么写，样式怎么写。

## 总结

autogen 和 agent 都能开发多智能体应用，开发体验的区别类似 react 和 angular 的区别。最大的区别在于 adk 支持路由功能。路由在前端、后端、app中都广泛应用，能够用来划分模块降低复杂度，现在智能体也有路由了，在这种开发模式下我们可以轻松扩展AI功能，而不影响其它模块。
