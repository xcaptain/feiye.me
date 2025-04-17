---
title: "微调 LLM"
publishDate: "16 Apr 2025"
description: "前几天尝试了使用多智能体系统加lint来保证typink AI 代码生成的正确性，但是效果还是不太行"
tags: ["AI", "typink"]
---

前几天尝试了使用多智能体系统加lint来保证typink AI 代码生成的正确性，使用了 autogen, adk 也将编译器做成了工具方便在 python 代码中调用，但是生成的typst代码效果还是不太行，我问一些偏门点的问题，如：

- 帮我出一张小学数学试卷
- 帮我生成一个田字格字帖
- 帮我写一个律师函 

这种问题就算反复生成，也是生成不准，关键还是问题太偏门了，AI在训练的时候没看过类似的问题，不知道该如何下手。虽然大部分专业领域的文稿都有专人去写，但是我希望 typink AI 是一个通用的写作AI，我希望它能针对各种场景，生成正确的代码，所以只剩下一条路了，我需要微调大模型，喂一些我能覆盖到的这些专门领域的文档写作模板，启发一下AI，避免它做自己不擅长的领域时胡说八道。至于我微调过的小模型，生成typst代码的准确性能不能比得过通用大模型，我心里也没底，不过先在问题已经存在了，怎么也得试一试，如果成功了就可以用通用大模型来生成内容，用微调的小模型来纠正语法错误。

## 如何微调大模型

我现在的 typink AI 使用了2个通用大模型，分别是 deepseek 和 gemini，这两个模型太大太通用，以至于根本无法微调，官方不支持微调，所以就算我将模型下载到本地微调好了我也无法部署微调后的版本给自己用。

所以我只能退而求其次，找一个参数规模较小的，支持微调的模型，正好 cloudflare workers AI 提供不少这种模型。cloudflare workers 都是部署在全球的边缘设备上的，所以它上面跑的模型基本能在普通设备上运行，也就是说可以我可以下载到本地来微调，然后将 lora adapter 上传到 cloudflare 进行部署。

workers AI 微调的文档见：https://developers.cloudflare.com/workers-ai/features/fine-tunes/

主要意思就是只有特定的一些模型能微调，按照教程需要去 google collab 上面执行一个 ipynb 笔记本，上传微调数据的 csv 文件到 `data` 目录，然后运行这个笔记本等待就行，微调完成会生成 lora adapter 文件，将这2个文件上传到 cloudflare 去就算微调完成

## 使用 google collab

cloudflare官方提供了一个简单的 ipynb 笔记本，运行这个笔记本会使用 `autotrain` 自动读取 csv 文件然后自动训练，听起来是很简单，我要做的只是将我收集的训练数据保存到一个 csv 文件上传到 collab 里面，但是collab运行太慢了，免费用户不给分配计算资源，执行一行代码都要等待好几分钟，更别说后面的训练过程，实在是等不了。

google collab 提供了一个升级运行时的功能，免费用户计算资源少，如果升级为高级用户就有更多的资源，我看了一下价格，高级用户一个月要 1000 多RMB，我考虑了一下我付不起这个钱，因为我不是天天都要训练模型，我只要花几个小时将我的训练代码跑一下，下载结果就行，按月收费对我来说太贵了，因此我决定寻找别的办法。

## 本地训练

我也试了一下本地训练，只要从 google collab 复制下来生成的那个 `conf.yaml` 文件到本机就行。在google collab 白嫖免费的计算资源，等了几分钟生成了这个 yaml 配置文件，下载到本地，直接执行

```py
autotrain --config conf.yaml
```

这个 autotrain 命令来自于 huggingface 开源的 `autotrain-advanced` 库，是一个免代码的微调工具，从上面这个启动命令也可以看出，一行 python 代码都不要写，只要在 yaml 里面定义好模型，数据所在的目录等参数就行。

我配置文件里定义的微调的基座模型是 `qwen/qwq-32b` 模型，执行上面那个 autotrain 命令会先下载模型到我本地的 `~/.cache/huggingface` 目录，下载完之后这个目录达到了 60G，因此如果磁盘可用空间不足60G的话，不要轻易尝试微调。

我的微调文件保存在 `data/train.csv` 文件中，就是一个很简单的文件，里面只放了2行用来演示：

```csv
text
### Human: What is the meaning of life? ### Assistant: 42.
```

如果这个例子跑通，未来我只要往这个 csv 文件里追加更多高质量的训练内容就行。

但是很遗憾，上面那个例子没跑通，提示 process killed，我查了一下应该是内存溢出了。我的笔记本只有32G的内存，根本没法将模型装载进内存，更别说微调，所以本机微调的尝试到此结束

## 租用高性能低价格云服务器

google collab 付不起，本地跑不起，所以只能尝试去租一台用来跑AI的云服务器，搜索了一番，找到一个叫作 Super Ti 的服务商，说是提供 16核64G CPU，4090GPU + 24G vram，然后还提供100G磁盘的机器，一小时2块钱人民币。这个价格合适，就算开机跑5小时也才花10块钱，用完关机就不产生费用了，还是很划算的，所以我充了20块钱进去打算先试试水。

这个网站比较简陋，基本只提供了硬件，不像 google collab 那样不用操心底层硬件和系统软件。像安装vps那样，安装好了操作系统，开机，ssh登录进去，确实是官网贴的配置没有假。

又重复一遍我本机的操作

```
pip install autotrain-advanced
autotrain --config conf.yaml
```

第一次又执行失败，提示磁盘空间不足，是因为默认会把模型保存在 `~/.cache/huggingface` 这个文件夹，而这个文件夹在系统盘里，系统盘只有30G，放不下模型。但是还好有一块额外的数据盘有100G可以用，`/root/superti-tmp` 文件夹是在这个数据盘里的，我只要让 huggingface 的模型保存到这个文件夹就解决了问题。

我的操作如下：

```shell
export HF_ENDPOINT=https://hf-mirror.com
export HF_HOME=/root/superti-tmp/.cache/huggingface
```

配置好这2个环境变量，第一个是因为这台服务器在国内，直接访问huggingface不通，所以需要配置镜像来访问。第二个就是修改缓存文件的目录，使用数据盘而不是系统盘。

再执行一遍上面那个 `autotrain --config conf.yaml` 命令，等了很久模型再次下载完成，但是执行还是失败，这次的错误还是 oom 导致进程退出。看来即使是有 64G 的内存，也没法微调那个 32B 的qwq模型。模型文件才60多G，估计是差不多能放进内存里，可惜就差那么点，这家厂商不提供机器升配置的功能，所有可用的服务器都是64G的，要是能升级到128G，我每小时多出2块钱也行，可惜不能。

如果说qwq32B模型太大，换成 gemma3-12b或者 mistral-small 24b 行不行呢？我也试了，提示说 autotrain 版本太老，没这2个模型的信息，确实 autotrain 上次更新还是3个月前（2025/01），这两个模型都是3月份发布的，很正常，难道说用 autotrain 来微调只能微调24年发布的模型？AI技术日新月异，没理由到了2025年4月了我还基于24年的模型去开发啊。。。

```
Unrecognized configuration class <class 'transformers.models.mistral3.configuration_mistral3.Mistral3Config'> for this kind of AutoModel: AutoModelForCausalLM.
```

于是我将这台机器关机，使用了5小时，啥都没干成，浪费了10块钱。再想别的办法。

## unsloth 微调

虽然 cloudflare 官方提供的是使用 autotrain 的微调教程，但是原理都是lora，所以只要能生成 lora adapter 用任何框架都行，什么是lora呢？我也不了解，大致就是给神经网络多加了一层，导致能够显著影响推理过程吧。查了一下发现比较流行的方式是 unsloth 这个库，号称速度和资源占用都更少，所以我又打算学习下使用这个库来微调。

我还是想先在本地跑通，然后复制代码到云服务器上去跑，这样比较省钱。但是但是，又遇到安装的问题

官方提供的安装命令是：

```
pip install unsloth
```

我在我的windows笔记本上执行报错，提示是编译 xformers 的时候，报了一个 torch 不存在的错误。

python项目依赖管理一直是个很头疼的事情，这些搞AI的人就不能统一一下各种基本软件的版本吗，别一堆乱七八糟的依赖。

### 安装 pytorch

我先尝试去pytorch官网安装最新版的 pytorch，找到的安装命令如下：

```py
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```

我这台笔记本是18年买的dell xps15，内置了一个 rtx 1050 的GPU，所以还是能安装cuda的。上面这条命令执行成功，试一下官方的例子验证一下：

```py
import torch

x = torch.rand(5, 3)
x

print(torch.__version__)
```

都通过了，所以目前我已经在我电脑上全局安装了 pytorch 2.6，另外提一下我的windows系统安装的 python 版本是 3.13.3，从应用商店下载的，会自动更新。

然后再去尝试安装 unsloth，还是失败，一样的报错，我真是服了。

### 安装 xformers

因为上面那个错误是在安装 xformers 的时候编译wheels报的，所以问题在于 xformers 这个库编译的时候没找到 torch 依赖。如果我在系统里预先安装好 xformers 那么不就不用编译安装了？
搜索了一下 [xformers 仓库](https://github.com/facebookresearch/xformers)，找到的安装命令是：

```shell
# [linux & win] cuda 12.6 version
pip3 install -U xformers --index-url https://download.pytorch.org/whl/cu126
```

但是很遗憾我在我的 powershell 里面执行还是报错

```
Defaulting to user installation because normal site-packages is not writeable
Looking in indexes: https://download.pytorch.org/whl/cu126
ERROR: Could not find a version that satisfies the requirement xformers (from versions: none)
ERROR: No matching distribution found for xformers
```

facebook 搞什么啊，为啥 pytorch 都安装成功了，xformers 就是失败？心态有点崩了，一行代码都还没写时间尽花在配置环境上了。

### 尝试切换到 wsl 里面运行

所以目前是我在 windows 下使用 python 3.13 根本没法安装 unsloth，也不知道是啥错，没功夫去看 xformers 的代码，我只能选择切换到 wsl 里面再试一遍。

我的 wsl 里面安装的是 ubuntu 24.04 系统，python 版本是 3.12，直接执行：

```shell
pip3 install torch torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu126
```

准备一次性把 pytorch 和 xformers 都安装到我的家目录去，这样不用每次切换新项目都安装一遍。但是又遇到 ubuntu 的限制，ubuntu 不允许使用 pip 安装全局的库，只允许每个项目使用一套依赖。好吧，那只能再安装一次：

```shell
mkdir ai-finetune
cd ai-finetune
python -m venv .venv

source .venv/bin/activate

pip3 install torch torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu126
```

到此终于安装完成了 pytorch 和 xformers

接下来继续安装 unsloth

```shell
pip install unsloth
```

终于成功了，花了大半天功夫终于把AI训练的环境配置好，终于可以开始写代码了。
