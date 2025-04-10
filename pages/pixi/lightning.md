## 雷电

> 来源 https://codepen.io/akm2/pen/kXJvKV

### 1. 通过控制点形成光滑曲线
catmullRom 插值算法
```ts
export function catmullRom(p0: number, p1: number, p2: number, p3: number, t: number) {
  const v0 = (p2 - p0) * 0.5
  const v1 = (p3 - p1) * 0.5
  return (2 * p1 - 2 * p2 + v0 + v1) * t * t * t
    + (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t * t + v0 * t + p1
}
```
该算法需要4个控制点,最后会得到一段从p1到p2的曲线,t的取值为0-1,
一般输入的是一组控制点,这个时候可以在首尾的地方重复首尾的点来得到完整的点,通过控制segementNum的数目来确定最后得到的一段segement

### 2. 2D噪音
可以选择simplex-noise来直接引入2d噪音,关于噪音的参数与值.举例2d噪音.噪音的结果可以想象为一张黑白像素分布均匀且连续的图像(雪花图),像素的黑白值就是噪音值,在2d坐标中,x与y坐标分别对应了要映射的特征值

**noise2d**
```ts
import { createNoise2D } from 'simplex-noise'
const noise2d = createNoise2D()
```
**fbm**
fbm是通过噪音的叠加来呈现更多的细节 https://thebookofshaders.com/13/?lan=ch
```ts
export function fbm2D(x: number, y: number, fbmOptions: { octaves: number, lacunarity: number, gain: number, amplitude: number, frequency: number }) {
  const { octaves, lacunarity, gain, amplitude, frequency } = fbmOptions

  let fre = frequency
  let amp = amplitude

  let res = 0

  for (let i = 0; i < octaves; i++) {
    res += amp * noise2d(fre * x, fre * y)
    fre *= lacunarity
    amp *= gain
  }

  return res
}
```
有了噪音后,就可以对之前的catmullRom得到的光滑曲线做噪音处理
- 当前点,下一个点形成一个向量
- 使用噪音产生向正方向与反方向的扰动
- 最后与原始坐标相加,得到噪音处理后的坐标

**noise正反方向的扰动**
```ts
av = lightningLen * 0.1 * noise2d(base - offset, offset) * amp
const ax = av * cos(angle - PI / 2)
const ay = av * sin(angle - PI / 2)
bv = lightningLen * 0.1 * noise2d(base + offset, offset) * amp
const bx = bv * cos(angle + PI / 2)
const by = bv * sin(angle + PI / 2)
```
noise的第一个参数分别加减了offset代表了两个方向的扰动, 第二个参数可以取固定值,但是这里只是为了尽量多的变化.
angle为当前向量的角度,所以扰动的正反方向,分别对应垂直该向量的两个方向(分别是减去90度和加上90度)

```ts
const m = Math.sin(i / len * Math.PI)

const x = p.x + (ax + bx) * m
const y = p.y + (ay + by) * m
```
m使用sin函数定义域范围在0-PI,值域范围在0-1,使得越靠近points的首尾元素,噪音扰动的影响越低

### 3.最短路径优化
噪音处理后的点虽然具有一定的连续性,但是最后得到的结果,也就是线条,在某些地方,可能会出现绕圈打结的现象,依次找出连续点的最短路径来优化这个问题

### 4.雷电模型
一共有两个模型
```ts
const modelParam1 = { segementNum: 8, noiseBase: 10, amp: 0.7, speed: 0.01 }
const modelParam2 = { segementNum: 16, noiseBase: 60, amp: 0.5, speed: 0.03 }
```
主模型, catmullrom切段少(细节少), 振幅大,速度(频率)较低
副模型, catmullrom切段多(细节多), 振幅小,速度(频率)较高

多模型叠加的效果优于单一模型

### 5.主要流程总结(loop动画的单一过程)
1. 控制点输入
1. 主模型对控制点处理:
    - catmullrom光滑曲线插值
    - noise处理
    - 最短路径优化
    - 得到点
1. 副模型对得到的点进一步细化
    - catmullrom
    - noise
    - shortest
    - points
1. draw
