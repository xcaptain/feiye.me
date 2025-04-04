---
title: "重新思考 typink 的 AI实现"
publishDate: "4 Apr 2025"
description: "typink 功能基本完备了，这些天我大部分时间在测试 typink 的AI，但是有诸多不满意的点，在想如何优化"
tags: ["AI", "typink"]
---

typink 功能基本完备了，这些天我大部分时间在测试 typink 的AI，发现了很多不满意的点，比如说无法根据用户需求去检索互联网，无法自我反思生成的代码是否报错，无法根据错误提示自我修改，这一系列问题让我很头疼，所以我怀疑是我目前采用的技术架构太简单了，所以我打算重新梳理一下我的 AI 助手的实现，学一下目前流行的 coding agent 的做法。

## coding agent

coding agent 翻译为编码智能体，比较火的产品有 cursor, cline, github copilot, trae等，这里只有 cline 是开源的，能让我们一窥它的实现。因为我比较常用 github copilot，所以我在设计 typink AI 的时候是模仿 github copilot chat 的界面来做的，现在想来就是这个技术路线导致了我这个 AI 限制多多。github copilot 本质上是一次调用，没使用到 agent 的功能，也就是说这种方式没法做到帮你自动改代码，虽然我模仿 cline 做了一个parser 能解析出diff来，但是跟 cline 的 reAct 还是有本质区别的。

### huggingface smolagents

cline 是一个 coding agent，但是它是一个 app，不是一个库，比较难测试它的agent具体如何工作的，所以我打算从 huggingface smolagents 开始入手，这个库适合教学，理解到底 coding agent 做了什么，给AI增强了什么能力。

比如我问AI：帮我实现一个快速排序，AI基于它的知识能快速返回一个函数给我，但是AI只是做了推理返回了字符串结果，它并不能运行这段代码去判断是否正确，但是agent 给定义了一个回答问题的框架，并且提供了一个运行代码的环境，所以如果AI返回了代码，可以在本地的一个运行环境执行一下代码，基于这次执行的结果，如果成功了，则返回给用户，如果失败了，可以再回到上一步去让AI重新生成代码。

一个具体的例子如下：

```py
from smolagents import CodeAgent, HfApiModel

model = HfApiModel()

agent = CodeAgent(tools=[], model=model, additional_authorized_imports=['requests', 'bs4'])

agent.run(
    "Could you get me the title of the page at url 'https://huggingface.co/blog'?"
)
```

我给 AI 提问，这个 agent 帮我运行了一下这个函数，告诉了我最终的结果：

```md
(.venv) ❯❯ smol-agent-test  21:38 python test2.py
╭────────────────────────────────────────────────────── New run ───────────────────────────────────────────────────────╮
│                                                                                                                      │
│ Could you get me the title of the page at url 'https://huggingface.co/blog'?                                         │
│                                                                                                                      │
╰─ HfApiModel - Qwen/Qwen2.5-Coder-32B-Instruct ───────────────────────────────────────────────────────────────────────╯
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ─ Executing parsed code: ─────────────────────────────────────────────────────────────────────────────────────────────
  import requests
  from bs4 import BeautifulSoup

  response = requests.get('https://huggingface.co/blog')
  soup = BeautifulSoup(response.text, 'html.parser')
  title = soup.title.string
  print(title)
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Execution logs:
Hugging Face – Blog

Out: None
[Step 1: Duration 12.79 seconds| Input tokens: 2,036 | Output tokens: 83]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ─ Executing parsed code: ─────────────────────────────────────────────────────────────────────────────────────────────
  import requests
  from bs4 import BeautifulSoup

  response = requests.get('https://huggingface.co/blog')
  soup = BeautifulSoup(response.text, 'html.parser')
  title = soup.title.string
  final_answer(title)
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Out - Final answer: Hugging Face – Blog
[Step 2: Duration 10.28 seconds| Input tokens: 4,272 | Output tokens: 162]
```

AI 根据用户的问题，自己想出了一段回答的代码，并且在本地运行了一下，给出了最终答案

同样的问题，我去 deepseek 问了一下，给出的答案是它不知道。

```
I currently **can't directly access live URLs** or fetch content from the web in real time. However, you can visit [Hugging Face's blog page](https://huggingface.co/blog) yourself to see the latest articles.  

If you're looking for a specific post, let me know, and I can try to help based on my training data (which includes some Hugging Face blog posts up until my knowledge cutoff in **July 2024**).  

Alternatively, if you enable **web search** (if available in your AI interface), I could retrieve the latest page title for you. Let me know how you'd like to proceed!
```

官方还给了另一个有趣的例子是让AI计算斐波那契数列，问题是：Could you give me the 118th number in the Fibonacci sequence?

agent 设计了一个函数，并且执行了这个函数给出了准确结果

```
(.venv) ❯❯ smol-agent-test  21:34 python test1.py
╭────────────────────────────────────────────────────── New run ───────────────────────────────────────────────────────╮
│                                                                                                                      │
│ Could you give me the 118th number in the Fibonacci sequence?                                                        │
│                                                                                                                      │
╰─ HfApiModel - Qwen/Qwen2.5-Coder-32B-Instruct ───────────────────────────────────────────────────────────────────────╯
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Step 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ─ Executing parsed code: ─────────────────────────────────────────────────────────────────────────────────────────────
  def fibonacci(n):
      a, b = 0, 1
      for _ in range(n):
          a, b = b, a + b
      return a

  fib_118 = fibonacci(118)
  final_answer(fib_118)
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Out - Final answer: 2046711111473984623691759
[Step 1: Duration 8.82 seconds| Input tokens: 2,150 | Output tokens: 121]
```

而我把这个问题丢给 deepseek，它返回的答案是错的

```md
The 118th number in the Fibonacci sequence is a very large integer. The Fibonacci sequence grows exponentially, and calculating high-index values requires arbitrary-precision arithmetic.  

Here’s the exact value of the **118th Fibonacci number (Fₙ where n = 118)**:  

### **F₁₁₈ = 3,311,648,143,048,827,046,783,318,225,801,070,725**  

### How It’s Computed:
1. The Fibonacci sequence is defined as:
   - \( F_0 = 0 \)
   - \( F_1 = 1 \)
   - \( F_n = F_{n-1} + F_{n-2} \) for \( n \geq 2 \).
2. For large \( n \), a **closed-form expression (Binet’s formula)** or **efficient matrix exponentiation** can be used to avoid recursive computation.
3. Arbitrary-precision libraries (like Python’s `int`) handle the large numbers correctly.

### Verification:
You can verify this using code (e.g., Python):
\`\`\`python
def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
print(fib(118))  # Output: 3311648143048827046783318225801070725
\`\`\`

Let me know if you’d like an explanation of the math or help with another sequence!
```

可以看出虽然 deepseek 知道怎么设计求解的代码，但是它不知道如何运行这段代码，所以返回了一个乱写的答案。

### cline

上面我验证了 smolagents 是真的做了一个 python 的执行器，AI模型返回代码后会执行一遍再返回给用户，那么 cline 会不会把 AI 返回的代码在本地执行一遍呢？我很怀疑，因为 cline 是一个编程助手，用户写的代码千奇百怪，如果是写 C/C++ 代码，很可能在本地是跑不起来的，所以没法验证 cline 返回的代码对不对，而且对于一些 web 程序来说，要满足特定条件才能触发到某段代码，所以要验证代码正确性更难了。那么 cline 会依赖vscode的lint去检测一下返回的代码是否有编辑器的报警或者报错吗？我想也是不会，这依赖用户的vscode里安装了lint插件。

所以我暂且认为 cline 只会对于 `<execute_command>` 这个 tool 捕获错误，比如说如果它返回一条命令叫作 `pip install numpy`，这条命令执行报错了，cline 能收集到错误信息，并且返回一条新的安装命令，但是对于 `<write_to_file>` 或者 `<replace_in_file>` 这种命令，只能检测到是否正确插入了，是不知道AI返回的代码对不对的。

所以如果 cline 自动修改了项目代码，很可能改错了，那么如何验证对错呢？还是得靠用户触发，比如说用户输入提示词说 “运行这个项目”，然后 cline 会返回一个工具 `<execute_command>bun run dev</execute_command>` 如果这个命令执行失败，比如说代码明显错误导致编译不过，那么肯定AI能检测到失败，进入循环，又返回代码变更，但是如果这个命令执行成功了，那么 cline 能否感知到呢？那肯定是不能的，因为对于 web 项目来说，服务器启动了不代表项目是对的，很可能UI错了，也可能某个操作触发服务器崩溃。但是这些cline都检测不到，它的作用就是基于用户的输入，返回内置的那些 tools，然后跟用户的行为交互，进入循环。

相比之下 replit 这些就更强大了，它们会在远程的虚拟机运行项目，并且自动打开浏览器尝试看新做的页面对不对，我没用过 replit，我是在youtube视频上看到博主使用的，能打开浏览器，确认UI是否正确，并且点击各种按钮去触发看后端逻辑是否正确，真是厉害。不过cline这样也够了，返回了正确率很高的代码，程序员自己再去验证一下就行，不必依赖 AI 自我去验证。

## typink AI 的重构计划

所以我不能简简单单的套壳deepseek做一个对话机器人，拼好prompt之后给llm一丢，然后再解析llm的响应给用户一展示就完事，这种的准确率太低了，只能靠运气让AI返回可用的代码。那我要做一个类似 cline 这样的插件，能返回 `<execute_command>` 这种命令，让用户在浏览器运行吗？似乎可以，比如返回一个 

```
<execute_command>
typst compile main.typ
</execute_command>
```

如果这个命令通过了，就说明 AI 生成的代码是对的，但是等等，我浏览器里并没有 `typst` 这个编译器啊，难道我要匹配到这个模式，调用 `typst.ts` 的 wasm compiler 去手动编译一下，再把结果反馈给 AI？也不是不行，不过每次发完 `<replace_in_file>` 等用户接受完成后，自动再出一个 `<execute_command>` 如果用户又接受了，就执行编译，如果编译错误就把上面那个 `<replace_in_file>` 的变更回滚吗？看起来挺复杂的，能不能AI返回 `<replace_in_file>` 之后，自动执行一下编译，如果编译失败再重新思考重新返回 `<replace_in_file>`，这样就等于用户能接受的代码都是能编译的，确保了不会出现一接受完代码整个文档编译不了，对于小白用户一头雾水不知道哪里出错了。
