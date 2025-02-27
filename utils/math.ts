/**
 *
 * @param v 变化的值
 * @param s1 v范围的起始值
 * @param s2 v范围的终点值
 * @param t1 v映射目标范围的起始值
 * @param t2 v映射目标范围的终点值
 * @returns v映射到t1到t2的值
 */
export function map(v: number, s1: number, s2: number, t1: number, t2: number) {
  if (v <= s1)
    return t1
  if (v >= s2)
    return t2

  return (v - s1) / (s2 - s1) * (t2 - t1) + t1
}
