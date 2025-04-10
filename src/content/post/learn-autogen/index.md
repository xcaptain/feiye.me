---
title: "学习 AutoGen"
publishDate: "09 Apr 2025"
description: "上周末看的书说到autogen是一个流行的用来开发多智能体的框架，所以今天写一篇文章记录一下我学习autogen这个库的过程"
tags: ["AI", "autogen"]
---

上篇博客说到我在清明假期阅读了一本介绍 AI 智能体的书，里面讲到可以使用 autogen 这个库来开发做智能体（multi-agent）应用，所以今天去官网看了一下文档，准备在这里记录一下学习心得。

## Models

模型指的是 openai, claude, deepseek 这些AI接口，模型是智能体的基础，autogen兼容了多种模型provider，提供了统一的接口，方便开发者在多种模型之间切换。

## Messages

消息可以是智能体之间通信，也可以是用户和智能体之间通信，传统的 opanai 接口的消息格式已经不能满足智能体开发了，所以又抽象了一个消息的结构，可以是文本消息，也可以是多模态消息。

### Agent-Agent Messages

智能体之间通信，继承 `BaseChatMessage`，有 `TextMessage`, `MultiModalMessage` 等

### Internal Events

智能体内部通信的消息，比如说内部工具调用，基类 `BaseAgentEvent`, 子类 `ToolCallRequestEvent`, `ToolCallExecutionEvent` 等

### Custom Message Types

如果要开发自己的消息类型，只要继承上面的基类就行

## Agents

智能体定义了如下方法：

`name`: 名字
`on_messages()`: 接受一系列 `Message`，智能体是有状态的，所以只要带最新的消息，不要每次都带上之前的历史
`on_messages_stream()`: 流式返回
`on_reset()`: 清理状态，也许类似 github copilot 的 /clear 命令
`run()`: 说是一个入口函数，调用 `on_messages()`

### Assistant Agent

助手智能体，在上篇博客中我记录了作者使用 chatgpt assistant builder 创建了一个能处理数据科学的助手，应该就是一种 assistant agent，从 助手进化为agent，最大的进步就是调用工具的能力，它的作用是：

1. 接受输入
2. 返回响应
3. 调用工具

### tools

内置工具：

- graphrag
- http
- langchain
- mcp

函数工具：

将一个 python 函数自动转换为一个可以被 AI 调用的工具

langchain 工具：

这里给了一个例子，通过langchain的 PythonAstREPLTool，实现了从网络上读取一个csv文件，读入到一个 dataframe 里面，然后通过这个 PythonAstREPLTool，让这个 df 变为AI可以调用的工具，因此可以通过自然语言来查询这个 df。这不就是现在市面上的什么 ChatExcel，wps灵犀AI 的技术原理吗？拿到了 df 之后，按各种指标画图，或者是询问某一列的信息，分分钟就搞定，再也不用担心直接调用 LLM 返回的内容不准确。

并发工具调用：

如果同时调用多个工具可能会互相影响，需要禁用并发

### 在循环中调用智能体

一般是先调用llm，再执行工具

### 结构化输出

llm 返回的都是字符串，但是可以自定义我们期望的返回格式，这样智能体返回的响应就是我们期望的格式了，之前做 typink AI 的时候还不断设置提示词让AI返回可解析的格式，真是浪费很多时间和精力

## Teams 

团队，就是多智能体团队，多个智能体协同完成同一个目标，看起来这是一个工作群聊，一个智能体往群里丢一个文档，其它智能体看到了就自动去处理这个文档，处理完再发回群聊里，知道最后有个发出停止消息，这些智能体才会停止处理。跟工作流有点像，但是工作流是预先设定好了流程，先做什么再做什么，而群聊是不设定规则，只是群里每个人都有自己的职责，看到有工作就会主动去做。

### RoundRobinGroupChat

看起来是最简单的群聊，官方给了一个写诗的例子：

```py
import asyncio

from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.base import TaskResult
from autogen_agentchat.conditions import ExternalTermination, TextMentionTermination
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.ui import Console
from autogen_core import CancellationToken
from autogen_ext.models.openai import OpenAIChatCompletionClient
from autogen_core.models import ModelInfo
from autogen_core.models._model_client import ModelFamily

# Create an OpenAI model client.
model_client = OpenAIChatCompletionClient(
    model="deepseek-chat",
    model_info=ModelInfo(
        vision = False,
        function_calling = True,
        json_output =  True,
        family = ModelFamily.GPT_4,
        structured_output = True,
    ),
    base_url="https://api.deepseek.com/v1",
    api_key="sk-xxx",
)

# Create the primary agent.
primary_agent = AssistantAgent(
    "primary",
    model_client=model_client,
    system_message="You are a helpful AI assistant.",
)

# Create the critic agent.
critic_agent = AssistantAgent(
    "critic",
    model_client=model_client,
    system_message="Provide constructive feedback. Respond with 'APPROVE' to when your feedbacks are addressed.",
)

# Define a termination condition that stops the task if the critic approves.
text_termination = TextMentionTermination("APPROVE")

# Create a team with the primary and critic agents.
team = RoundRobinGroupChat([primary_agent, critic_agent], termination_condition=text_termination)

async def main() -> None:
    result = await team.run(task="Write a short poem about the fall season.")
    print(result)

asyncio.run(main())
```

在这里定义了一个有2个智能体的群聊，一个用来创作诗歌，另一个用来评价诗歌。第一个agent创作完成诗歌后会发到群里，第二个agent会自动去评价，如果它觉得这段内容可以就会返回 APPROVE。在这里其实还可以优化一下，比如说创作者设置更详细的提示词，完善它的人格，让它非常擅长某类创作，而评价的agent也可以设置更详细的提示词，让它去检测押韵，检测行数等等。目前大部分人用AI创作文本或者内容都是自己去评估返回的质量怎样的，而有些人没有这方面专业知识或者没有那么多时间去仔细阅读的话，其实是很难判断AI生成的质量的，所以网上很多人都会有错觉说AI生成的结果AI味很重，这就是因为缺少评估的智能体。

就像是左右互搏，人家AI跟AI之间可以左右互博十几个回合再输出合适的内容，人有这么好的耐心不断引导AI去完善内容吗？所以人类要放下骄傲，未来文字创作肯定是AI的天下，到时候最火的自媒体博主就不一定是新闻专业的高材生了，会用 AI 的人设置好文章评估标准，也许一个初中生就能写出文字优美，观点精辟的爆款文章。


### stop/resume/abort a team

一个team是有状态的，所以可以暂停，停止和恢复，我看 cline 的代码就是有一个大循环，输出内容后暂停，等待用户交互，如果用户接受了那么就再生成后续的内容，跟这个 autogen 的模式差不多，只不过看起来 autogen 封装的更好，只暴露了思想，没有暴露具体的实现代码，这就是一个 app 跟一个 library 的区别。

## 人类的参与

多智能体群聊需要人类的参与，上面说到了可以暂停智能体，所以需要人类的参与的时候就可以利用这个暂停的特性，等到人类提供了反馈再恢复

### 在一次运行中提供反馈

team 就是一个群聊，上面的写诗的例子是用另一个AI当评委来评价AI写出来的诗，如果要人类介入，可以让人类来当评委，有人类决定这首诗是好是坏，然后第一个写作的AI再决定是否要重写。因为第一个AI写完就在等待人类的反馈，所以这种是运行中提供反馈

### 一次运行后提供反馈

还是上面那个写诗的例子，2个AI协作完，给出了一首它们认为很不错的诗，这时候智能体要保存状态，等待人类的反馈，如果人类觉得不行，智能体就会结合人类的反馈意见以及上一次运行的状态，再思考一遍。大部分情况人类应该都是这个时候介入，不然中间思考过程也要介入效率太低了。

## 智能体框架的比较

看完了 autogen 的官方文档，自己动手跑了一点例子，现在结合之前看的 cline, smolagents 这2个项目，以及我想做的 typink AI 来比较一下哪个框架最适合。

易用性：所谓框架不过就是将开发过程中可能遇到的通用的问题抽象出来，让使用者能够少些代码，省得一遍又一遍发明轮子，在这方面 autogen, smolagents 无疑是做得更好，因为 cline 是一个 app，它没有提供外界可以简单使用的库。

human-in-loop：人类的参与，这方面 smolagents 做得最差，我试了几个例子都是全自动完成，人类无法介入。作为一个写作AI，我还是希望人类能够积极参与进来，及时提供反馈意见指导AI下一步方向，autogen,cline 都不错，支持暂停等待用户行为。

typescript sdk: 目前市场上大部分agent框架都是python写的，我的官网因为是用 typescript + sveltekit 写的，所以优先考虑 js/ts 项目，但是很遗憾 autogen,smolagents 都只支持python语言调用，意味着我如果要想使用这些库，我得在容器里跑一个python服务，部署起来还是比较麻烦。

扩展写作能力：autogen 比 smolagents 好，因为smolagents 主要的能力还是在写代码上，而且似乎只支持生成python代码，因为它只内置了一个 python code executor，对于我来说很显然我需要的是一个能生成 typst 代码的agent，所以在这方面 autogen 更胜一筹。

## 总结

综合下来如果要构建我的 typink AI agent，还是使用 autogen 框架比较合适，但是还得设计好架构，未来如果出现了能直接运行在浏览器内的智能体框架，得考虑迁移过去，最合适的智能体运行环境是在本地客户端，而不是在服务器上。
