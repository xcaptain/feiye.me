---
title: "用 kokoro-tts 模型构建一个chrome扩展"
publishDate: "20 Jan 2025"
description: "上周看到几个youtube博主评测了kokoro tts 模型，在本地转语音挺强大的，产生了一个点子把 kokoro-tts 集成到 chrome 插件里"
tags: ["kokoro", "chrome"]
---

kokoro 是一个强大的本地文本转语音模型，不需要调用昂贵的接口，在本地就能将文本转换为语音。

## 评测 kokoro 模型

### kokoro-js

这是一个js的库，使用这个库可以在浏览器内实现文本转语音

### kokoro-onnx

这是一个python库，通过python命令行实现文本转语音，目前这个库的速度大概是js版本的5倍

## 点子

既然 kokoro 模型能在浏览器内运行，那么能不能打包成一个扩展程序呢？目前AI文本转语音接口的价格都还比较贵，比如说 ElevenLabs 的接口，一个月11美金才支持生成100分钟的音频，这个价格对我来说还是太贵了。我想将网页转为音频，然后丢到一个RSS服务器上让用户自己通过podcast客户端订阅，如果接口价格太贵，我可能还没收获几个客户，就被tts接口给弄亏本了。如果在浏览器内执行 tts，就算转一个网页5分钟，也是能接受的。

这个点子对我来说是可以实现的，但是第一步我要先学会写 chrome 扩展，以前从没写过，所以要从头学起。

## 学习写chrome扩展

chrome 扩展就是一个单页面应用，但是提供了一些方法来访问当前 tab 的dom。虽然马斯克讲究目标驱动，但是对于一个新手来说还是要学习基本的知识，先花一两天看看教程，做做练习还是很有必要的，不能一上来脑子里啥都还不懂就对着google或者AI去写项目。

这里我将记录一下我把官方的教程看完后的体会

### 01-hello-world

[官方教程](https://developer.chrome.com/docs/extensions/get-started/tutorial/hello-world)

这是第一篇教程，教大家做一个 hello world 的插件，点击插件按钮会出现一个最简单的popup网页。
在这篇文章中，介绍了最基础的插件的知识。

清单文件 `manifest.json` 定义了插件的基本信息。必填 `manifest_version`, `name`, `version` 字段，剩下一些按需求选填。

这里因为是点击插件图标展示一个网页，所以 action 是一个网页

```json
{
    "action": {
        "default_popup": "hello.html",
        "default_icon": "hello_extensions.png"
    }
}
```

在这个 `hello.html` 里面还可以引入js文件，这个js是在插件上执行的，而不是在网页上执行的。

### 02-reading-time

[官方教程](https://developer.chrome.com/docs/extensions/get-started/tutorial/scripts-on-every-tab)

在这个教程中，我们实现了一个文章阅读时间统计的功能，并且把这个时间信息插入到标题下方了，在这里我们学到了插件如何通过 `content script` 来修改网页内容。

```json
{
  "content_scripts": [
    {
      "js": ["scripts/content.js"],
      "matches": [
        "https://developer.chrome.com/docs/extensions/*",
        "https://developer.chrome.com/docs/webstore/*"
      ]
    }
  ]
}
```

这个 `content script` 的意思是，在匹配到的网页下会执行这个 `content.js` 文件。我们都知道网页上的js是在浏览器构造好DOM后执行的，那么这个`content.js` 文件既然作用在当前网页的DOM上，是插入到DOM里了吗？答案是否定的，这个 `content script` 的执行环境跟网页里js的执行环境是独立的，这样避免了跟当前网页里的js产生冲突。

这个`content.js` 脚本的作用就是操作当前网页DOM，我们不需要它返回值，只需要用到它的副作用。据我自己测试发现，这个 `content.js` 只在网页加载进来后执行一次，要再执行一次就要刷新页面。

### 03-focus-mode

[官方教程](https://developer.chrome.com/docs/extensions/get-started/tutorial/scripts-activetab)

这个插件的作用是，点开后会修改当前网页的样式，让网页更简洁更专注。从这里开始学到了更多复杂的概念。

service worker:

这是插件的工作进程。跟网页的工作进程类似，我们都知道浏览器执行的js脚本是单线程的，如果页面上有一个js函数执行时间很长，占用的计算资源很多，可能就会抢占其它js函数被执行的机会，导致页面出现卡顿。为了解决这个单线程导致UI卡顿的问题，出现了 service worker 的概念，service worker 在另一个线程被执行，这样即使那个线程被阻塞，也不阻塞我们看到的网页UI，对于复杂计算很适合放这里执行。

```json
{
    "background": {
        "service_worker": "background.js"
    }
}
```

既然这个 `background.js` 是在后台执行的，那么什么时候执行的呢？这就看自己编写的代码了。可以定义事件处理函数，让插件安装完成后执行，也可以定义事件处理函数，当插件被点击后执行。为了避免后台脚本出现死循环一直执行，或者默默占用巨量资源，chrome定义了一个安全机制，就是这个后台调度执行不是连续的，可能30s后就被终止，也可能5分钟后被终止，具体看 service worker lifetime 那块的文档，因此我们设计代码时，可别放一个要执行好几分钟的函数进去，不然很可能每次都执行不完就被杀死。

action:

在第一个教程中介绍了 action 可以是一个 `hello.html`，在这里 action 变成了一段代码，点击icon的时候，不再弹出一个html窗口了，而是触发后台代码的执行

activeTab permission:

既然点击插件就触发代码执行，那么这些代码是在哪个tab上执行的呢？这里是通过定义权限，让这个插件仅仅在当前tab上执行，这样可以提高安全性，毕竟用户不会希望点击一个按钮，没打开的tab的数据也被插件访问到了。

```json
{
  "permissions": ["activeTab"],
}
```

scripting permission:

在 02 的教程中提到了可以用 content script 来修改当前网页的内容，但是这种方式要刷新页面才能生效，在这个教程中，不定义 content script 而是点击插件按钮后，触发一段js执行，然后修改当前网页DOM，所以需要给插件分配在网页上执行脚本的权限。

setBadgeText 保存状态：

这里介绍了一个最简单的办法就是通过设置插件的徽标文字来保存状态，这样脚本才知道点击插件图标是应该进入 focus mode 还是退出 focus mode

鼠标快捷键：

这个 `background.js` 现在定义的是点击插件图标触发执行，但是可以定义快捷键，模拟鼠标点击的操作。

```json
{
  "commands": {
    "_execute_action": {
      "suggested_key": {
        "default": "Ctrl+B",
        "mac": "Command+B"
      }
    }
  }
}
```

### 04-quick-api-reference

[官方教程](https://developer.chrome.com/docs/extensions/get-started/tutorial/service-worker-events)

这又是个更复杂的教程，涉及到了更多概念。在这个插件中，我们实现了一个 omnibox，让用户在地址栏里输入指定关键词进入 omnibox，然后按照建议打开对应的文档页面，然后在这个新打开的文档页又通过 content script 进行修改，在执行过程中，通过给 service worker 发消息进行交互，拿到一条随机的tip，插入到网页中。

omnibox：

之前教程讲的都是要点击一下插件按钮激活插件，这个插件是通过在浏览器地址栏输入特定关键词，进入插件的omnibox，根据程序，返回一系列 suggestions，点击某个suggestion后进入回调，这里是新标签打开网页。

```js
const URL_CHROME_EXTENSIONS_DOC =
    'https://developer.chrome.com/docs/extensions/reference/';
const NUMBER_OF_PREVIOUS_SEARCHES = 4;

// Display the suggestions after user starts typing
chrome.omnibox.onInputChanged.addListener(async (input, suggest) => {
    await chrome.omnibox.setDefaultSuggestion({
        description: 'Enter a Chrome API or choose from past searches'
    });
    const { apiSuggestions } = await chrome.storage.local.get('apiSuggestions');
    const suggestions = apiSuggestions.map((api) => {
        return { content: api, description: `Open chrome.${api} API` };
    });
    suggest(suggestions);
});

// Open the reference page of the chosen API
chrome.omnibox.onInputEntered.addListener((input) => {
    chrome.tabs.create({ url: URL_CHROME_EXTENSIONS_DOC + input });
    // Save the latest keyword
    updateHistory(input);
});

async function updateHistory(input) {
    const { apiSuggestions } = await chrome.storage.local.get('apiSuggestions');
    apiSuggestions.unshift(input);
    apiSuggestions.splice(NUMBER_OF_PREVIOUS_SEARCHES);
    return chrome.storage.local.set({ apiSuggestions });
}
```

输入关键字 `api` 激活插件，输入过程中，触发 `onInputChanged` 事件回调，在按下回车键时触发 `onInputEntered` 事件回调。

content.js 调用 service worker:

新标签页打开文档后，会执行 `content.js` 代码，修改当前DOM，这个教程是加了一个叫 `tip` 的按钮，点击后会展示一个 popover 然后在里面随即展示一条 tip，这就涉及到如何在 content js 里面取tip，可以直接发fetch请求去拿，但是也可以发消息从 service worker 去取。这里是通过后者实现的

```js
const { tip } = await chrome.runtime.sendMessage({ greeting: 'tip' });
```

后台这里定义了事件处理程序

```js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.greeting === 'tip') {
        chrome.storage.local.get('tip').then(sendResponse);
        return true;
    }
});
```

### 05-tab-manager

[官方教程](https://developer.chrome.com/docs/extensions/get-started/tutorial/popup-tabs-manager)

在这个教程中，做了一个能管理tab的插件，又回到了 action 是一个html的状态，但是提供了一系列api去操作tab。在之前的教程中，我们知道插件中有3种js执行环境

1. content script: 在当前网页上执行
2. background.js: 在浏览器后台执行，但是可以通过activeTab 访问到当前网页数据
3. popup.js: 在插件内执行，window对象是自身，但是也能访问 chrome 对象

## 规划我的 kokoro tts chrome extension

chrome官方提供的插件开发的教程照着做了一遍，现在对如何做已经有一个基本的印象了，接下来就是想想该如何实现我这个点子。我希望做一个浏览器插件，首先会进行google oauth 登录获取身份，然后点击插件按钮会把当前网页内容提取出来，交给 kokoro-tts 在后台执行，
得到网页的audio后，调用接口把音频提交到服务器上，服务器提供一个 RSS 链接可以被任何设备订阅。

要完成上面这些目标需要实现：

1. popup.html: 检测当前url是否已经保存到服务器
2. background.js: 调用 kokoro.js 运行模型推理生成语音
3. background.js: 通过 alarm 定时检测本地是否有没转完成的文本，对于无法转换的，及时上报服务器
