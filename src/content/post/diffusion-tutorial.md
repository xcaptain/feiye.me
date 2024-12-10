---
title: "用diffusion生成图片"
publishDate: "06 Dec 2024"
description: "最近对AI生成图片比较感兴趣，先是玩了一下 facefusion，然后又试验了 flux 模型的文生图，后来又想学 ComfyUI，最后又回归原点来到了 diffuser"
tags: ["AI", "art", "huggingface"]
---

最近几个月做了一些 AI 生成图片的功能，最早是调用 cloudflare 的 workers-ai 模型，这个很简单，会调用接口就能创作图片，后来发现cloudflare模型有限，而且性能都一般，比如说
我想换脸，就没法调用了，所以自己封装了一个 facefusion 模型来做换脸。后来朋友叫我做虚拟试衣，说在跨境电商方面很火，又研究各种 ComfyUI 工作流。网上发布AI生图的自媒体博主，
很多都不是程序员出生，自己看了一些教程，照着做了学会了就发视频出来教别人，但是他们也许也不知道这背后的原理是什么。我也不懂，但是我想尝试搞懂为什么几个工作流组合一下就能生成精美的图片。

AI 这块更新太快，名词太多，技术也太多，要从头明白文生图，图片重绘，各种参数是什么原理，也需要从命令行自己调试一遍代码开始。

## Diffusers

网上大家都用 stability webUI 或者是 ComfyUI来本地生图，这种图形化界面不适合理解原理，还是回到底层库 [diffusers](https://github.com/huggingface/diffusers) 看看。

官方的快速开始只有几行代码。

```python
from diffusers import DiffusionPipeline
import torch

pipeline = DiffusionPipeline.from_pretrained("stable-diffusion-v1-5/stable-diffusion-v1-5", torch_dtype=torch.float16)
pipeline.to("cuda")
pipeline("An image of a squirrel in Picasso style").images[0]
```

本地创建个新项目照着做就是，不过因为中国的网络连 huggingface 比较不稳定，还需要设置一下镜像，参考：[https://cloud.tencent.com.cn/developer/article/2454491](https://cloud.tencent.com.cn/developer/article/2454491)

我是 windows，所以只要：

```shell
pip install -U huggingface_hub

hx $PROFILE

# 加上
$env:HF_ENDPOINT = "https://hf-mirror.com"
```

然后重新加载 powershell 就行了，测试一下速度：

```shell
huggingface-cli.exe download stable-diffusion-v1-5/stable-diffusion-v1-5
```

能跑到 10MB 每秒，比翻墙下载快多了，模型默认是保存在 `~/.cache/huggingface/hub` 下，全局保存还挺好，不用浪费硬盘。

