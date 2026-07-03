#!/usr/bin/env python3
# resplit-srt.py —— 把字幕里的长块按标点拆成短句,按时长比例重新分配时间
# 用法: python3 bin/resplit-srt.py <输入.srt> <输出.srt> [每行最大宽度]
# 目的:避免一屏字幕太长、挡住画面。纯本地处理,不花 token,不改动翻译内容。
import sys, re

MAXW = float(sys.argv[3]) if len(sys.argv) > 3 else 16.0  # 全角字符数,中文≈1、英文/数字≈0.5
SPLIT_AFTER = "，。！？；、：…,!?;:"    # 在这些标点后可断句(含半角,因译文逗号是半角)
STRIP_TAIL  = "，、：；,;:"             # 断行处行尾这些标点去掉更干净

def width(s):
    return sum(1.0 if ord(c) >= 0x1100 else 0.5 for c in s)

def t2ms(t):
    h, m, rest = t.split(":")
    s, ms = rest.split(",")
    return ((int(h)*60 + int(m))*60 + int(s))*1000 + int(ms)

def ms2t(x):
    x = max(0, int(round(x)))
    h, x = divmod(x, 3600000)
    m, x = divmod(x, 60000)
    s, ms = divmod(x, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

def hard_split(atom):
    """单个原子仍超宽(如很长的英文)时,先按空格、再按宽度硬切。
    注意:保留边界空格,避免把 'AI 我们' 拼成 'AI我们'(行内空格不丢)。"""
    if width(atom) <= MAXW:
        return [atom]
    parts, cur = [], ""
    for tok in re.split(r"(\s+)", atom):
        if tok == "":
            continue
        if cur and cur.strip() and width(cur + tok) > MAXW:
            parts.append(cur); cur = tok      # 不 strip,保住 cur 尾部空格
        else:
            cur += tok
    if cur:
        parts.append(cur)
    # 仍有超宽的(无空格长串),按宽度硬切
    out = []
    for p in parts:
        while width(p) > MAXW:
            cut = 1
            while cut < len(p) and width(p[:cut+1]) <= MAXW:
                cut += 1
            out.append(p[:cut]); p = p[cut:]
        if p:
            out.append(p)
    return out

def atomize(text):
    """按标点切成原子(标点跟在前一块)。"""
    atoms, cur = [], ""
    for i, ch in enumerate(text):
        cur += ch
        nxt = text[i+1] if i+1 < len(text) else ""
        # 数字间的半角 , . : 不算断点(避免切坏 1,000 / 3.7 / 3:1)
        if ch in ",.:" and nxt.isdigit():
            continue
        if ch in SPLIT_AFTER:
            atoms.append(cur); cur = ""
    if cur.strip():
        atoms.append(cur)
    # 展开仍超宽的原子
    flat = []
    for a in atoms:
        flat.extend(hard_split(a) if width(a) > MAXW else [a])
    return [a for a in flat if a.strip()]

def pack(atoms):
    """贪心合并原子成不超宽的若干段。"""
    cues, cur = [], ""
    for a in atoms:
        if cur and width(cur + a) > MAXW:
            cues.append(cur); cur = a
        else:
            cur += a
    if cur:
        cues.append(cur)
    # 末段过短则并回上一段
    if len(cues) >= 2 and width(cues[-1]) < 5:
        cues[-2] += cues[-1]; cues.pop()
    return cues

def tidy(s):
    s = s.strip()
    while s and s[-1] in STRIP_TAIL:
        s = s[:-1]
    return s.strip()

def main():
    blocks = re.split(r"\n\s*\n", open(sys.argv[1], encoding="utf-8").read().strip())
    out, idx = [], 1
    for b in blocks:
        lines = [l for l in b.splitlines() if l.strip() != ""]
        if len(lines) < 2:
            continue
        # 找时间行
        ti = next((i for i, l in enumerate(lines) if "-->" in l), None)
        if ti is None:
            continue
        start_s, end_s = [x.strip() for x in lines[ti].split("-->")]
        start, end = t2ms(start_s), t2ms(end_s)
        text = " ".join(lines[ti+1:]).strip()
        if not text:
            continue
        if width(text) <= MAXW:
            cues = [text]
        else:
            cues = pack(atomize(text)) or [text]
        cues = [tidy(c) for c in cues if tidy(c)]
        # 按宽度比例分配时间
        total = sum(width(c) for c in cues) or 1.0
        dur = end - start
        cur = start
        for j, c in enumerate(cues):
            seg_end = end if j == len(cues)-1 else cur + dur*(width(c)/total)
            if seg_end <= cur:
                seg_end = cur + 1
            out.append(f"{idx}\n{ms2t(cur)} --> {ms2t(seg_end)}\n{c}\n")
            idx += 1
            cur = seg_end
    open(sys.argv[2], "w", encoding="utf-8").write("\n".join(out) + "\n")
    print(f"{sys.argv[1]} → {sys.argv[2]}:{len(blocks)} 块 → {idx-1} 条短字幕(每行≤{MAXW}全角)")

if __name__ == "__main__":
    main()
