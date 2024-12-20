---
title: "部署facefusion服务"
publishDate: "15 Dec 2024"
description: "半个月前开始玩facefusion的，也在服务器上部署过，踩过一些坑，积累了一点经验，这里记录一下"
tags: ["AI", "facefusion", "docker", "github"]
---

facefusion 是一个开源的换脸服务，支持多种模型，效果还不错，我在本地玩过，是一个 gradio 的网页，可以配置各种选项去生成图片。
也有一个命令行接口用来生成图片。整个服务本地跑起来占用的硬盘大概要 20G，最低配置要求必须要2核4G 内存。

## VPS 部署

上周注册了 oracle 云的免费试用，送了 $300 券以及一些永久免费的资格，所以我就打算在上面部署一下 facefusion 试试

操作都很简单，这种方式唯一的问题就是贵，我创建了一个 2C8G 的实例，每天就要2美金的成本，对于一个业余项目来说成本太高了，1C1G的机器
倒是免费，但是根本跑不起来，1G内存连加载模型都失败，就算开启swap，1颗CPU也不能跑出结果来，反正我等了几分钟是没看到结果

## Azure Container Apps 部署

这种方式上容器化按需收费，azure的容器服务很便宜，不用就不产生费用，但是它的 container registry 很贵


| 基本 | 标准 | 高级 |
| ---- | ---- | ---- |
| 每日价格 | $0.167 | $0.667 | $1.667 |
| 包含的存储 (GB) | 10 | 100 | 500 |

所有的模型都下载下来的话，模型就有15G，加上运行时的大小，差不多20G的空间，这时候每天就要付费 $0.67 的存储费用，还是太贵了。


dockerhub 有免费的存储，放这里如何？听起来是不错，但是从 azure 到 dockerhub 去pull镜像，然后再创建容器，这个启动时间应该短不了。

换个思路，github 现在也提供了容器注册表，都是微软的产品，也许物理上会在同一个机房，pull速度也许会快很多，那么试试push 到 ghcr看看效果。

### build docker image

facefusion 提供了官方的 `Dockerfile` 见：[https://github.com/facefusion/facefusion-docker](https://github.com/facefusion/facefusion-docker)

本地构建也很简单

```bash
docker build -f Dockerfile.cpu -t xcaptain/facefusion:v1 .
```

不过这样 build 出来的镜像很大也很慢，会在运行时加载需要的 1G 的模型，启动速度很慢。

为此我做了一些修改：


```txt ins={1-2}
COPY ./predefined-assets .assets
RUN python facefusion.py headless-run --processors face_swapper --face-mask-types box --face-swapper-model inswapper_128  -s ./build_test_once/s-1.jpeg -t ./build_test_once/t-1.jpg -o ./build_test_once/out-1.jpg
```

这样会把预先下载好的模型复制到镜像里的 `.assets` 目录，然后运行一个测试脚本看能否正常运行


### push to ghcr

官方的教程是通过 github actions 来自动推送到 ghcr 的，这里我采用手动推送的方式，虽然我是会员每个月有3000分钟的actions时间，但是没必要，代码不会经常变，手动部署就行。

```shell
docker login ghcr.io -u xxx
```

然后按提示输入密码，我这里用的是一个新创建的 PAT，因为我主账号设置了 `2FA`，不好手动输入密码。

登录上 ghcr 后就是标记镜像然后推送

```shell
docker tag xcaptain/facefusion:v1 ghcr.io/xcaptain/facefusion:v1
docker push ghcr.io/xcaptain/facefusion:v1
```

本地推送的速度还是很慢的，好在 ghcr 不像 dockerhub 一样被屏蔽，直连就行


```log
The push refers to repository [ghcr.io/xcaptain/facefusion]
9f22283c333f: Pushed 
f675b592de6b: Pushed 
e55822eb11b6: Pushed 
622f3858bec1: Pushing [===========>                                       ]  240.1MB/1.091GB
622f3858bec1: Pushing [===========>                                       ]  240.1MB/1.091GB
622f3858bec1: Pushing [================================================>  ]   1.05GB/1.091GB
622f3858bec1: Pushing [================================================>  ]   1.05GB/1.091GB
622f3858bec1: Pushed 
```

### 部署到 Azure Container Apps

这里我用的是 Azure Container Apps，这个服务是一个托管的容器服务，可以直接从 github 仓库拉取镜像，然后部署到容器里，很方便。

1. 创建资源组
2. 创建容器应用环境（CAE）
3. 在CAE里创建容器应用

因为我用的 registry 是 `ghcr.io`，所以选择注册表的时候要手动指定一下。镜像名要带上版本，如：`xcaptain/facefusion:v1`

我在第一次部署的时候遇到坑了，因为我是用 Mac 来构建镜像的，所以默认的平台是 `linux/arm64`，但是现在azure容器只支持
`linux/amd64`, 所以要修改一下build命令重新来一遍

```shell
docker build --platform linux/amd64 -f Dockerfile.cpu -t xcaptain/facefusion:v1 .
```

检查一下是否成功

```shell
docker inspect xcaptain/facefusion:v1 | jq '.[0].Architecture'
```

看到是 `amd64` 就可以再次推送了

