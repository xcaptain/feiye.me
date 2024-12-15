---
title: "自学神经网络"
publishDate: "08 Dec 2024"
description: "上周又看了几页深度学习方面的书，对于神经网络、大模型啥的理解又更深了点，这里记录一下"
tags: ["AI", "ML"]
draft: true
---

机器学习、深度学习、神经网络，这些的用途大家都知道了，识别图片、换装、生成文字、翻译、写作、生成图片等等。这些技术最底层的就是神经网络

## 神经网络

人脑为什么能识别猫狗呢？是因为有几亿个神经元在协同工作。第一个神经元识别到了第一个像素，第二个神经元识别到了一块猫的特征，最后一个神经元给出了最终分类，是猫，然后我们就知道了这是一只猫。

这个模式迁移到计算机上，就是输入一张图给AI，AI自动分类为猫、狗。

简化到最基础的步骤就是有一个神经元，接收一个输入，然后会给出一个输出。

这种一个输入到一个输出，在数学里叫函数，所以神经元就是一个函数，输入是x，输出是y，y=f(x)。

人脑神经元运行的函数我们不可知，但是我们可以给AI里的神经元预设好函数，给定了函数，设置好默认的超参数，然后就是训练得到最符合训练结果的参数。


## 神经网络的训练

教材都是从 MNIST 数据集说起的，让 AI 去识别手写数字。这个数据集有 60000 张训练图片，10000 张测试图片，每张图片是 28x28 的灰度图，每个像素值是 0-255 之间的整数。

在10多年前这个任务还是很困难的，但是现在已经很简单了，叫 AI 写一段代码，用很少的行数就写出来了。如下：

```python
import tensorflow as tf
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten
from tensorflow.keras.utils import to_categorical

# 加载MNIST数据集
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# 预处理数据
x_train = x_train.reshape((x_train.shape[0], 28, 28, 1)).astype('float32') / 255
x_test = x_test.reshape((x_test.shape[0], 28, 28, 1)).astype('float32') / 255
y_train = to_categorical(y_train, 10)
y_test = to_categorical(y_test, 10)

# 构建模型
model = Sequential([
    Flatten(input_shape=(28, 28, 1)),
    Dense(128, activation='relu'),
    Dense(64, activation='relu'),
    Dense(10, activation='softmax')
])

# 编译模型
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# 训练模型
model.fit(x_train, y_train, epochs=10, batch_size=32, validation_data=(x_test, y_test))

# 评估模型
loss, accuracy = model.evaluate(x_test, y_test)
print(f'Test accuracy: {accuracy}')

# 识别图片
import numpy as np
import matplotlib.pyplot as plt

def predict_image(image):
    image = image.reshape(1, 28, 28, 1).astype('float32') / 255
    prediction = model.predict(image)
    return np.argmax(prediction)

# 测试识别一张图片
image_index = 0
plt.imshow(x_test[image_index].reshape(28, 28), cmap='gray')
plt.show()
print(f'Predicted label: {predict_image(x_test[image_index])}')
```

这里面隐藏了很多细节，比如说加载数据，在这里就是一行调用 `mnist.load_data()` 就可以了，但是实际上这个函数里面做了很多事情，比如说下载数据、解压数据、加载数据、预处理数据等等。

构建模型这里也是一行代码，用了 `Sequential` 这个类，这个类是一个容器，可以把神经网络的层放进去，然后按顺序执行。

第一个参数 `Flatten` 是一个层，这个层的作用是把输入的图片展平，比如说 28x28 的图片展平成 784 的一维向量。
第二个参数 `Dense(128, activation='relu')` 是一个全连接层，这个层的作用是把输入的数据和权重相乘，然后加上偏置，再通过激活函数，得到输出。activation=relu 是一个激活函数，这个函数的作用是把输入的数据变成非线性的，这样神经网络才能学习到更复杂的模式。
第三个参数 `Dense` 又是一个全连接层，64 个神经元，激活函数是 relu。
第四个参数 `Dense` 又是一个全连接层，10 个神经元，激活函数是 softmax，这个函数的作用是把输出的值变成概率，比如说输出是 [0.1, 0.2, 0.7]，那么这个值就是 70% 的概率是这个类别。

编译模型这里也是一行代码，用了 `model.compile()` 这个函数，这个函数的作用是把模型编译成可以运行的代码，比如说把模型的结构、损失函数、优化器、评估指标等等都编译好。编译的结果是一个可以运行的模型，这个模型可以用 `model.fit()` 函数来训练。一般保存为 `model.h5` 文件，这样下次就不用重新训练了。

训练完要评估训练结果，用预先规划好的测试集来评估模型的性能，这里用了 `model.evaluate()` 函数，这个函数的作用是用测试集来评估模型的性能，比如说准确率、损失值等等。

## 用神经网络训练 MNIST 数据集的数学解释

在数学上，用 `x` 来表示输入的图片，因为所有图片都是 28x28 的灰度图，所以 `x` 是一个 784 的一维向量，每个元素是 0-255 之间的整数。

用 $ y = y(x) $ 来表示神经网络的输出，因为输出是一个 10 维的向量，每个元素是 0-1 之间的浮点数，表示这个图片属于这个类别的概率。

我们再定义一个代价函数

$$
C(w, b) = \frac{1}{2n} \sum_{x} \| y(x) - a(x) \|^2
$$

这个函数是经典的最小二乘法函数，训练的过程就是找到最小的代价函数，也就是找到最好的权重 $ w $ 和偏置 $ b $，使得代价函数最小。

因为 $x$ 是一个 784 纬的向量，所以 $C(w, b)$ 也是 784 纬的，这种函数在数学上叫做多元函数，求解这种函数的最小值，一般用梯度下降法。

一元函数找最小值这个我们知道，这种函数在平面直角坐标系就能画出来，就是寻找导数为 0 的点。
二元函数找最小值稍微更复杂点，这个函数图像在三维坐标系中画出来是一个曲面，要找最小值就是找曲面上的最低点，跟一元函数类似，不过是2个方向的导数都为 0。
多元函数更复杂，不能像一元、二元函数那样画出图来，但是求解方法是一样的，就是寻找到各个方向上，导数为 0 的点。

但是在实际中，不一定有导数为0的点，所以只能不断尝试去逼近。
