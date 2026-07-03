# Video Learning Workbench — Claude 工作说明

这是一个本地视频学习工作台:把 X(Twitter)/ YouTube 等视频转成**烧录了中文硬字幕**的 mp4,把网页文章转成中文 HTML,也可以把博主视频做成基于真实语音转写的深度拉片。**会持续处理很多条。**

这工具现在有三条轨:**视频→中文硬字幕 mp4**,**网页文章→中文 HTML**,和 **视频→深度拉片报告**。

## 触发方式
- 用户说“接管这个项目 / 新 session / 换设备继续” → 先跑 `bin/resume-device.sh`,确认当前设备依赖、模型和本地目录可用;缺东西再跑 `bin/setup.sh`。
- 发一条 **X / YouTube 视频链接** → 走视频流程,给烧好中文硬字幕的成片。
- 发一条 **网页文章链接** → 走网页流程,给中文 HTML(+ Markdown)。
- 发一条 **视频链接并说拉片/拆解/节奏/文案分析** → 走拉片流程,给基于真实语音转写的中文拉片报告。
一条龙跑完,不用等他再说别的。

## 完整流程(逐条执行)
1. **下载+转写**:`bin/1-fetch.sh "<链接>" <slug> [语言]`
   - yt-dlp 下载视频 + ffmpeg 抽 16k 音频 + whisper.cpp(large-v3-turbo,Mac 走 Metal)转写
   - **语言**默认 `en`;非英文视频传第三参数,如 `auto`(自动识别)/ `hi`(印地语)/ `ja`(日语)。`transcribe.sh` 同理:`bin/transcribe.sh <slug> [语言]`
   - 产出 `out.nosync/<slug>/en.srt`(无论源语言都叫 en.srt,即"源字幕")
   - 长视频耗时,放后台跑(run_in_background)
   - **YouTube 下不了时**(PO token 墙,尤其代理网络):让用户把视频放到 `out.nosync/<slug>/video.mp4`,改用 `bin/transcribe.sh <slug>`(跳过下载,直接转写),其余步骤相同
2. **你亲自翻译**(不要求用户配置付费翻译 API,且质量优先):
   - 读 `glossary.md` 术语表,把 `en.srt` 译成中文 `out.nosync/<slug>/zh.srt`
   - **时间轴和编号原样保留**,只替换文本行;不要增删、合并、拆分或重排字幕块
   - 顺手**纠正 whisper 听错的术语**(如把 Claw→Claude、Cloud Code→Claude Code、solid model→Sonnet model);改了哪些要在回复里说明
   - 新术语随手补进 `glossary.md`,越攒越准
3. **烧字幕**:`bin/2-burn.sh <slug>` → `out.nosync/<slug>/<slug>.zh.mp4`(仅中文硬字幕)
   - 它会先校验 `en.srt` / `zh.srt` 编号和时间码是否完全一致;不一致会拒绝烧录,必须先修 `zh.srt`。
   - 它会**自动按视频朝向把 zh.srt 拆短**(竖屏每行≤14、横屏≤26 全角,避免一屏太长挡画面)再烧录,**不用再手动拆短**。
   - (要手动微调可单独跑 `python3 bin/resplit-srt.py <zh.srt> <out.srt> <宽度>`)
4. **验收**:抽 2-3 个不同时间点,同时核对音频/原片可见字幕/中文字幕是否对齐;确认字幕在安全区内、术语正确,再把成片路径给用户。
5. **清理省磁盘(默认做,不用问)**:成片抽帧验收无误后,**默认直接** `bin/clean.sh <slug>` 删原始 video.mp4(只留成片 + 字幕),不再征求确认。`audio.wav` 在转写后已自动删。

## 网页翻译流程(图文 → 中文 HTML)
1. **抓取**:`bin/web-fetch.sh "<网页链接>" <slug>` → curl 抓正文 + html2text 转 `out.nosync/<slug>/en.md` + 提取图片 URL 到 `images.txt`。
2. **你亲自翻译**:读 `glossary.md`,把 `en.md` 正文译成中文 `out.nosync/<slug>/zh.md`,**保留 markdown 结构和图片(`![](远程URL)`)**,跳过导航/页脚等页面杂项,顶部加一行原文出处。术语同样对照 glossary。
3. **渲染**:`bin/web-render.sh <slug>` → 用 python markdown + 内置 CSS 出自包含网页 `out.nosync/<slug>/<slug>.zh.html`(+ 保留 zh.md)。图片用远程 URL,浏览器打开即看。
4. **验收**:确认 HTML 标题/小节/图片齐全、术语正确,把路径给用户。
- 说明:网页翻译默认交付本地 `zh.md` / HTML;如用户需要进飞书,可手动导入飞书文档,不把网页流程绑定到飞书 API。

## 深度拉片流程(视频 → 真实语音文案 + 中文分析)
目标:学习其他博主的拍摄、剪辑、文案和节奏。**绝不能只靠平台字幕、标题、简介或画面猜口播**;必须从视频真实音频转写出文案。

1. **下载+真实转写**:和视频流程相同,先跑 `bin/1-fetch.sh "<链接>" <slug> [语言]`。
   - YouTube/IG 下不了时,让用户把视频放到 `out.nosync/<slug>/video.mp4`,跑 `bin/transcribe.sh <slug> [语言]`。
   - 必须产出 `out.nosync/<slug>/en.srt`;这是拉片文案的唯一可信来源。
2. **准备拉片素材包**:`bin/3-lapian.sh <slug> [抽帧间隔秒|auto]`
   - 默认 `auto`:短视频约每 2 秒抽一帧,中视频约 5 秒,长视频约 10 秒;产出 `out.nosync/<slug>/lapian/frames/` 和 `frames.md`。
   - 把 Whisper 的 `en.srt` 转成 `lapian/speech.en.md`、`speech.raw.txt`、`speech.segments.tsv`。
   - 创建 `lapian/speech.zh.md` 中文翻译模板和 `lapian/lapian.md` 拉片报告模板。
3. **你亲自翻译真实文案**:
   - 读 `glossary.md` 和 `lapian/speech.en.md`,逐段翻译成 `lapian/speech.zh.md`。
   - 时间段标题必须保留;听不清的术语保留英文并标注不确定,不要补剧情。
   - 顺手纠正 whisper 听错术语,并在回复里说明。
4. **你亲自写拉片报告**:
   - 读 `speech.en.md` / `speech.zh.md` / `frames.md`,填写 `lapian/lapian.md`。
   - 必须包含:一句话定位、真实口播文案、时间轴拉片、可复用拍法总结、术语和听写修正。
   - 时间轴表里的"真实口播"只能来自 `speech.en.md`,不能来自平台字幕或猜测。
   - 时间轴拉片优先可读:段落功能要带阶段标签(如开头/备料/制作/收尾),对应画面写成短动作链,结论写"为什么有效",建议写成"下次怎么拍"的直白提醒。
   - 飞书表格交付固定使用一个“视频深度拉片库”文档,不要每条视频新建一个文档;每条新拉片新增一个 sheet,并用真实选题名命名 sheet(中文 + 必要原名,如`塞内加尔洋葱炖鸡｜Poulet Yassa`)。
   - 每个视频 sheet 内部保持精简模板:顶部合并标题只写真实选题名,字段为`时间码 / 阶段/功能 / 中文文案 / 对应画面 / 为什么有效 / 下次怎么拍`;不要为同一视频保留旧版本 sheet、隐藏 sheet、英文副标题或冗余字段。
   - 忽略平台残留:从 Instagram / TikTok / YouTube Shorts 等下载得到的水印、平台图标、账号浮层、下载器烧录 UI,默认不作为原片镜头、品牌收口或剪辑设计分析;除非它明显是创作者主动做进原片的内容。
   - 总结部分优先写成用户下次能直接照着拍的提醒、步骤和检查清单;不要为了显得专业堆抽象概念、复杂术语或难懂公式。
5. **渲染**:`bin/lapian-render.sh <slug>` → `out.nosync/<slug>/lapian/lapian.html`。
   - 如果用户给了飞书拉片库链接或明确要求写入飞书,优先在现有拉片库里新增一个选题 sheet;否则交付 `lapian.md` / `lapian.html`。
6. **验收**:
   - 抽查 `speech.en.md` 是否来自真实 `en.srt`。
   - 抽查 2-3 个时间点:口播、中文意思、画面帧是否对得上。
   - 最后把 `lapian.md` / `lapian.html` 路径给用户。

## 字幕设定
仅中文(非双语)、白字黑边、PingFang SC。竖屏字幕默认缩小并上移到底部安全区,避免贴近进度条或平台 UI。样式在 `bin/2-burn.sh` 的 force_style 里。

## 硬性规则
- **严禁编造**:翻译逐句对照原文;听不清/拿不准的术语保留英文,不硬译、不脑补剧情。
- **拉片严禁偷懒**:必须用 Whisper 从 `video.mp4` 真实音频生成的 `en.srt` 提取文案;平台字幕/简介/标题只能辅助理解,不能当真实口播。
- **先回答再动手**:用户问问题时先回答,再执行。
- 报错先读后改,输出根因再动手,别"猜原因→直接改→祈祷生效"。

## 脚本结构
- 共享逻辑(项目路径、模型、ffmpeg 定位、whisper 提示词、转写核心 `transcribe_to_srt`)集中在 **`bin/_lib.sh`**,三个脚本都 `source` 它。**改 ffmpeg/提示词/转写参数,只动 `_lib.sh` 一处。** 特定题材专有词可临时用 `WHISPER_PROMPT_EXTRA` 补充。
- `1-fetch.sh`(下载→转写)和 `transcribe.sh`(本地文件→转写)都调用 `_lib.sh` 的同一个转写核心,不重复。
- `doctor.sh` 只检测环境,不修改系统;`setup.sh` 负责安装依赖、下载模型并调用 `doctor.sh`;`install-skill.sh` 把 `skills/video-learning-workbench` 安装到本机 Codex skills 目录。

## 开源 / Skill 化边界
- 本仓库可作为开源工具本体 + Codex Skill 发布;Skill 放在 `skills/video-learning-workbench/`,只负责调度流程,真实执行仍走 `bin/` 脚本。
- 不提交 `models.nosync/`、`out.nosync/`、`glossary.md`、本地视频/音频/字幕/成片、飞书个人链接或 token。公开仓库只带 `glossary.example.md`。
- 飞书写入是可选能力;没有 `lark-cli` 或授权时,拉片照常输出本地 `lapian.md` / `lapian.html`。

## 关键环境坑(已踩过)
- 烧字幕需要 **libass**。系统的 `/opt/homebrew/bin/ffmpeg`(精简版 `ffmpeg` formula)**不含 libass**,必须用 **`ffmpeg-full`**(keg-only)。`_lib.sh` 已用 `brew --prefix ffmpeg-full` 动态定位。
- **YouTube 需要 PO token**(2025-2026 起):本机直接 yt-dlp 可能下不了,尤其在代理网络下。降级方案:让用户在浏览器里下好 mp4,放到 `out.nosync/<slug>/video.mp4`,再跑 `bin/transcribe.sh <slug>`。X 通常可直接 `1-fetch.sh`。
- 模型与成片放在 **`.nosync` 目录**(`models.nosync/`、`out.nosync/`),避免同步大文件;只同步或提交轻量工具本体。

## 多设备
- 本项目通过 iCloud 同步轻量文件:脚本、规则、README、术语表模板等;另一台设备打开同一个 iCloud 项目目录即可接管。
- **每次换设备 / 新 session 先跑 `bin/resume-device.sh`**:它会初始化本机目录并检查依赖、模型、飞书可选能力。
- 如果 `resume-device.sh` 提示缺依赖或模型,再跑 `bin/setup.sh`;这是每台 Mac 各自需要做一次的本机配置。
- `models.nosync/` 和 `out.nosync/` 是每台设备本地目录,不会通过 iCloud 同步;不要期待另一台设备自动拥有模型、原片、成片或中间字幕。
- 不要在两台设备上同时处理同一个 slug / 输出目录,避免 iCloud 或本地输出冲突。
- 另一台设备不是依赖 Skill 接管;新 session 在本项目目录里读取 `AGENTS.md` / `CLAUDE.md` 后即可按这些规则执行。

## 后续可选升级
要无人值守批量翻译时,可改用本机 Ollama(拉中文强模型)替代"你来翻"这步;脚本可预留切换点。
