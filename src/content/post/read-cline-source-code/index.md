---
title: "通过 AI 辅助阅读 cline 的源代码"
publishDate: "21 Mar 2025"
description: "在做 typ.ink 的 AI 助手时，遇到比较多想不清楚的问题，所以想看看 cline 是如何做的，因此开始学习这个项目的代码"
tags: ["AI", "typink"]
---

我在做 typ.ink 的AI助手时，最早是想模仿 github copilot 的交互方式，即用户输入自然语言，服务器返回文本和代码，对于代码自己再做一个 Diff 查看器，让用户能一键接受代码到编辑器中。这种方式本来已经跑通了，但是后来我又看了一下竞品，比如说豆包，人家有生图功能和联网检索功能，感觉这2个功能对于写文档来说还是比较重要的，因为大部分人排版都需要图文结合，没有这些功能的话，做了也是白做，没有亮点不可能吸引到用户。

因此我想推翻之前那个简单的只会生成文本和代码的 AI助手重新实现一个多模态，会调用工具的 AI。这种实现还是比较难的，因为我试了几个官方的聊天界面，如deepseek, huggingface chat，我让它们生成一张图片，都是返回不能生成图片因为它们是文本模型。但是很显然可以通过 function tools 调用文生图模型来生成图片。还有搜索也是，虽然模型本身不联网，但是也可以通过一些 function tools 来支持联网检索，给 AI 提供更丰富的上下文信息。

这样在我这个聊天界面就要展示：文本、图片、代码、搜索结果，甚至包括模型的思考过程，如果未来切换到推理模型的话，更甚者还要包括试错和自我更正的能力，就像 cursor 这种编辑器，AI 返回代码后，会在本地运行一下代码，如果发现出错了会自我反思，然后重新返回代码。

虽然说起来简单，但是实际写代码实现还是比较复杂的，所以我想看看这些流行的项目是怎么做的，目前来说最流行的开源 AI 编程插件当然就是 cline 了，类似开源的 github copilot，但是功能更加丰富，所以我准备学习一下这个项目的代码结构，看看它是如何对消息建模，如果跟服务器交互，如何处理服务器返回的多模态的结果的。

## 学习 cline 的消息结构

我没用过 cline，也不想装，因为我已经有github copilot了，所以对于 cline 如何工作的只能看网上介绍先获取一个大致的印象。
接下来我想找的是他们如何定义服务端返回的消息的，上面我已经说过这些消息的结构很多样化。

在 `src/core/assistant-message/index.ts` 里找到如下定义：

```ts
export type AssistantMessageContent = TextContent | ToolUse
```

看到这里我很不理解，就一个文本一个工具，代码跑哪里去了，如何高亮变更的代码，从而让用户能一键应用到编辑器里呢？

所以我问了 AI 这个问题：“在 cline 的代码库中，为什么 AssistantMessageContent 只包括2个类型，cline是如何从 llm 响应中解析出代码变更来的”

AI 的返回也很准确，如下：

```
根据您的代码，我可以看到 AssistantMessageContent 确实只包括两种类型：TextContent 和 ToolUse。

让我解释一下 cline 如何从 LLM 响应中解析代码变更：

Cline 通过 AssistantMessageContent 表示 LLM 的响应，它可以是普通文本（TextContent）或工具使用（ToolUse）。

代码变更是通过 ToolUse 实现的，特别是通过以下几个工具：

write_to_file: 写入文件内容
replace_in_file: 替换文件内容
execute_command: 执行可能影响文件的命令
当 LLM 响应需要修改代码时，它会使用上述工具之一，并通过工具的参数（在 params 字段中）指定修改的内容。

根据代码中定义的 toolParamNames，参数可以包含 path、content、diff 等，这些参数指定了要修改的文件路径和内容。

解析过程应该在 parseAssistantMessage 函数中实现，该函数从 LLM 的原始响应中提取结构化的 AssistantMessageContent 对象。

总的来说，Cline 采用了结构化的方法通过工具使用（Tool Use）概念来处理代码变更，而不是直接从文本中解析代码块。这种设计使得 LLM 可以明确地表达它想要执行的操作，而不是依赖于复杂的文本解析。
```

这样我就理解了，客户端代码解析服务端流式返回的content，对于纯文本部分是解析到 TextContent，如果发现是代码变更，就会解析为 ToolUse，然后判断是完整的代码就可以调用 `write_to_file`，或者是部分代码，就调用 `replace_in_file`

所以我在定义我的消息结构时，完全可以抄 cline 的做法，甚至连 parser 都可以抄，因为都是将服务器返回的 stream，解析到 `AssistantMessageContent[]`

parser 也很简单，代码在 `src/core/assistant-message/parse-assistant-message.ts`

```ts
import { AssistantMessageContent, TextContent, ToolUse, ToolParamName, toolParamNames, toolUseNames, ToolUseName } from "."

export function parseAssistantMessage(assistantMessage: string) {
    // ...
}
```

100 来行的代码就完成了将 string 解析为 `AssistantMessageContent[]` 也没用到其它的依赖库，可以本地构造一些 assistantMessage 去测试一下这个函数的返回

## cline 是何时开始解析服务端的响应的

上面说到这个 `parseAssistantMessage` 对服务端的消息进行解析，但是是何时做的呢？是等服务器流式响应结束了之后执行一次，还是边流式返回，边执行呢？

在 `src/core/Cline.ts` 里面的 `recursivelyMakeClineRequests` 里面找到了答案，这个文件很长，有3700+行，看起来很费劲，但是找关键地方看看：

```ts
for await (const chunk of stream) {
    switch (chunk.type) {
        case "usage":
            // ...
            break
        case "reasoning":
            // reasoning will always come before assistant message
            reasoningMessage += chunk.reasoning
            await this.say("reasoning", reasoningMessage, undefined, true)
            break
        case "text":
            if (reasoningMessage && assistantMessage.length === 0) {
                // complete reasoning message
                await this.say("reasoning", reasoningMessage, undefined, false)
            }
            assistantMessage += chunk.text
            // parse raw assistant message into content blocks
            const prevLength = this.assistantMessageContent.length
            this.assistantMessageContent = parseAssistantMessage(assistantMessage)
            // ...
    }
}
```

这里可以看出从服务端读到了 stream 后，分块从里面读，拼成一个 `assistantMessage` 字符串，然后交给parser去解析。这就简单了，因为服务器返回stream 是很简单的事，套壳一下 openai 兼容的接口就行，不过似乎返回的每段里面还有 type 字段，看来还得看下人家的服务器是怎么写的，到底是 claude 接口跟 openai 接口格式不一样呢，还是 cline 在之前还自定义了接口

查看了一下 claude 的接口文档：https://docs.anthropic.com/en/api/messages-streaming 没看到有 reasoning 这样的字段，也许是 cline 自定义的。

## cline 是如何发请求到llm的

在上面已经看到了cline如何处理响应的，那么是如何发请求的呢？提示词、上下文都是如何设置的呢？

在 `src/core/Cline.ts` 里面的 `attemptApiRequest` 找到了一些线索，在这个方法中定义好了 systemPrompt, truncatedConversationHistory，然后通过:

```ts
// conversationHistoryDeletedRange is updated only when we're close to hitting the context window, so we don't continuously break the prompt cache
const truncatedConversationHistory = this.contextManager.getTruncatedMessages(
    this.apiConversationHistory,
    this.conversationHistoryDeletedRange,
)
let stream = this.api.createMessage(systemPrompt, truncatedConversationHistory)
```

这个方法得到了 stream，发请求的方法就定义在这个 `createMessage` 里面，这是一个 interface，有很多 provider 都实现了这个接口，我先看claude自家的接口

`src/api/providers/anthropic.ts`

在这个文件中，cline 对接了 claude 的接口，发送请求，然后对响应流做了一个变换，变成了一个自定义的 stream 格式，通过这层变换，将不同服务商的接口都统一起来了，这就使得在 cline 里面可以自定义不同的接口，如 deepseek这些

截一段例子：

```ts
for await (const chunk of stream) {
    switch (chunk.type) {
        case "message_start":
            // tells us cache reads/writes/input/output
            const usage = chunk.message.usage
            yield {
                type: "usage",
                inputTokens: usage.input_tokens || 0,
                outputTokens: usage.output_tokens || 0,
                cacheWriteTokens: usage.cache_creation_input_tokens || undefined,
                cacheReadTokens: usage.cache_read_input_tokens || undefined,
            }
            break
        case "message_delta":
            // tells us stop_reason, stop_sequence, and output tokens along the way and at the end of the message

            yield {
                type: "usage",
                inputTokens: 0,
                outputTokens: chunk.usage.output_tokens || 0,
            }
            break
        case "message_stop":
            // no usage data, just an indicator that the message is done
            break
        case "content_block_start":
            switch (chunk.content_block.type) {
                case "thinking":
                    yield {
                        type: "reasoning",
                        reasoning: chunk.content_block.thinking || "",
                    }
                    break
```

这里解析原始的流，得到包含 usage, reasoning 这种类型的stream

看到这里最核心的部分应该都看到了，如何构造提示词，如何查找历史上下文，如何发请求，如何处理响应流，如何变换为自己的流格式，如何格式化为自己的消息格式，接下来我打算抄到我得 AI助手里，免得自己闭门造车。
