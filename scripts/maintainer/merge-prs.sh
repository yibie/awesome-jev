#!/usr/bin/env bash
# merge-prs.sh — 依次合并 awesome-jev 的贡献者 PR。
#
# 用法:
#   scripts/maintainer/merge-prs.sh 84 85 86     # 指定 PR 号
#   scripts/maintainer/merge-prs.sh              # 默认处理全部 open PR
#
# 为什么需要脚本：每个 PR 都要改 README.md 里【相邻的计数行】，第二个 PR 起必然冲突；
# 而且 README.md 是生成物，不能手工解冲突。手工 rebase 十几个 PR 不现实。
#
# 踩过的坑（改动前请先读）:
#   1. fork 仓库名不统一（awesome-jev / awesome-jev-yibie / yibie_awesome-jev / awesome-jev-1），
#      必须用 headRepository.nameWithOwner，不能拼 /awesome-jev。
#   2. rebase 前必须先把本地 main 拉到 origin/main，否则会 rebase 到过期基线，
#      推回 fork 后 PR 依然显示 CONFLICTING。
#   3. 一个 PR 可能有多个提交（先加条目、再改措辞），会产生【多轮】冲突；
#      只解一轮会让 `rebase --continue` 失败。必须循环处理。
#   4. `grep -qF "$line"` 中条目以 "- [" 开头，会被当成选项 → 必须写 `grep -qF -- "$line"`。
#   5. 【最隐蔽】rebase 之后、合并之前，main 可能又被别的 PR 推进了。此时我们推上去的
#      分支相对新 main 会【少掉那条刚合并的条目】—— 等于撤销别人的合并，GitHub 因此拒绝合并。
#      修法：合并失败就重新同步 main，把整个 rebase+push+merge 再走一轮（最多 3 轮）。
#   6. 批量跑几十个 PR 时 `gh` 偶发返回空（限流或瞬时故障），脚本里 `2>/dev/null` 会把原因藏掉。
#      失败项直接重跑本脚本即可，不要以为是权限问题。
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT" || exit 1

# 本脚本在同步 main 时会 `git reset --hard`，未提交的改动会被静默抹掉。
if [ -n "$(git status --porcelain)" ]; then
  echo "✗ 工作区有未提交改动 —— 本脚本同步 main 时会 git reset --hard，会丢失它们。"
  echo "  请先提交或 git stash，再跑本脚本。"
  exit 1
fi

PRS=("$@")
if [ ${#PRS[@]} -eq 0 ]; then
  mapfile -t PRS < <(gh pr list --state open --limit 100 --json number -q '.[].number' | sort -n)
fi
[ ${#PRS[@]} -eq 0 ] && { echo "没有 open PR"; exit 0; }

info() { echo "  $*"; }

sync_main() {
  git checkout -q main 2>/dev/null
  git rebase --abort >/dev/null 2>&1
  git checkout -q main 2>/dev/null || return 1
  git fetch -q origin main 2>/dev/null
  git merge -q --ff-only origin/main 2>/dev/null || git reset -q --hard origin/main
}

wait_mergeable() {
  local n="$1" st
  for _ in $(seq 1 10); do
    st=$(gh pr view "$n" --json mergeable -q .mergeable 2>/dev/null)
    [ "$st" = "MERGEABLE" ] && return 0
    sleep 3
  done
  return 1
}

# 安全网：有的 PR 只改分类文件、不碰 README.md，会【干净合并】但把首页计数留在旧值。
sync_readme() {
  git checkout -q main 2>/dev/null
  git fetch -q origin main 2>/dev/null
  git merge -q --ff-only origin/main 2>/dev/null || git reset -q --hard origin/main
  python3 scripts/build-readme.py >/dev/null 2>&1 || return 0
  if [ -n "$(git status --short)" ]; then
    git add -A
    git commit -q -m "chore: rebuild README after PR merge" 2>/dev/null \
      && git push -q origin main 2>/dev/null \
      && info "README 计数已补建并推送"
  fi
}

# 解当前一轮冲突：README 重新生成，分类文件保留 main 侧并补上本 PR 的条目行
# 取 PR 在【指定文件】里新增的条目行。早期版本取全 diff 的第一条再加到每个冲突文件上，
# 结果是多分类 PR 会把同一条复制到多个分类（跨分类重复），甚至把 README 的渲染行
# （带 shields.io badge）写进分类文件。必须按 hunk 归属取。
# 直接合并路径也要先让分支自洽。gh pr merge 之后的合并提交如果 README 落后于分类文件，
# catalog-checks 会在 main 上判它失败（sync_readme 几秒后才补绿），于是每个这类 PR 都在
# main 的历史里留一个红叉。先在分支上补建 README 并推回 fork，合并提交就能落地即绿。
green_branch_first() {
  local n="$1" fork="$2" branch="$3" tmp="tmp-green-$n" remote url
  git fetch -q origin "pull/$n/head:$tmp" 2>/dev/null || { info "· 取不到 PR head"; return 1; }
  git checkout -q "$tmp" 2>/dev/null || { info "· 切换失败"; return 1; }
  python3 scripts/build-readme.py >/dev/null 2>&1 || true
  local ok=0
  if [ -z "$(git status --porcelain)" ]; then
    info "· 分支 README 已是最新，无需预补建"
  else
    git add -A
    git commit -q -m "chore: regenerate README so this branch satisfies catalog-checks" 2>/dev/null
    remote="fork-$(echo "$fork" | tr '/' '-')"
    url="git@github.com:$fork.git"
    git remote get-url "$remote" >/dev/null 2>&1 || git remote add "$remote" "$url"
    git remote set-url "$remote" "$url"
    if git push -q "$remote" "$tmp:$branch" --force-with-lease 2>/dev/null; then
      info "已把 README 补建推回分支（合并提交将落地即绿）"
    else
      # 贡献者没开 maintainerCanModify 时推不回去。此时合并提交必然因 README 落后而变红，
      # 只能合并后在 main 上补（返回值通知调用方走后置补建）。
      info "⚠ README 补建推不回 fork（贡献者未开 maintainer 编辑权限），改为合并后在 main 上补"
      ok=1
    fi
  fi
  git checkout -q main 2>/dev/null
  git branch -q -D "$tmp" 2>/dev/null
  return $ok
}

# 有的 PR 把条目直接写进 README.md。README 是 build-readme.py 的生成物，所以那一行会在
# 下一次重新生成时【静默消失】：合并干净、CI 全绿、条目数不变，条目却没了。
# 以前的处理是「作者改错了文件 → 关掉，我自己在 main 上补」——但那样 PR 在贡献者主页上
# 显示为 closed-unmerged（看起来像被拒），而功劳其实是我们代领的。
# 正确做法：在【分支上】补一个 commit 把行搬进分类文件，再走正常合并。
# 分类是编辑判断，脚本不猜：用 RELOCATE_INTO=<分类文件> 指定；没指定就拦下不合并，
# 把行和可选分类打印出来让人来定。
relocate_readme_edits() {
  local n="$1" fork="$2" branch="$3" tmp="tmp-reloc-$n"
  # 已经改了分类文件的 PR 不用管。
  if gh pr view "$n" --json files -q '.files[].path' 2>/dev/null | grep -q '^categories/'; then
    return 0
  fi
  local lines
  lines=$(gh pr diff "$n" 2>/dev/null | awk '
    /^diff --git / { inblk = ($0 ~ /README\.md/); next }
    inblk && /^\+- \[/ { sub(/^\+/, ""); print }
  ')
  [ -z "$lines" ] && return 0

  if [ -z "${RELOCATE_INTO:-}" ]; then
    info "⚠ 这个 PR 把条目写进了 README.md（生成物），改错文件不合并："
    printf '%s\n' "$lines" | sed 's/^/      /'
    info "  → 指定分类后重跑：RELOCATE_INTO=<分类文件> $0 $n"
    info "  → 可选：$(ls categories/*.md | xargs -n1 basename | tr '\n' ' ')"
    return 1
  fi
  [ -f "categories/$RELOCATE_INTO" ] || { info "✗ 分类不存在: categories/$RELOCATE_INTO"; return 1; }

  git fetch -q -f origin "pull/$n/head:$tmp" 2>/dev/null || { info "✗ 取不到 PR head"; return 1; }
  git checkout -q "$tmp" 2>/dev/null || { info "✗ 切换失败"; return 1; }

  # 搬行：去掉 README 渲染出来的 shields.io badge 图片（分类文件要用源码标签形式），
  # 已存在的行不重复加。分隔符先归一化：ENTRY_RE 只认 ` - `，而手写进 README 的行常用
  # `:` 或全角破折号，照搬过去会被 catalog-checks 判为无法解析。
  local moved=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    printf '%s' "$line" | grep -q "img.shields.io" && info "  ⚠ 这一行带渲染 badge，标签已丢失，需人工补回"
    line=$(python3 - "$line" <<'PYNORMSEP'
import re, sys
line = sys.argv[1]
if not line.startswith("- ["):
    print(line); raise SystemExit
link = re.match(r"^(- \[[^\]]+\]\([^)]+\))(\s*`\{[^}]*\}`)?", line)
if not link:
    print(line); raise SystemExit
head, tags = link.group(1), link.group(2) or ""
rest = line[link.end():].lstrip()
m = re.match(r"^[-:\u2014]\s*(.+)$", rest)
if m:
    print(f"{head}{tags} - {m.group(1)}")
else:
    print(f"{head}{tags} - {rest}" if rest else line)
PYNORMSEP
)
    grep -qF -- "$line" "categories/$RELOCATE_INTO" 2>/dev/null && continue
    printf '%s\n' "$line" >> "categories/$RELOCATE_INTO"
    moved=$((moved + 1))
  done <<< "$lines"

  # README 侧的原文要撤掉，否则重新生成前它先漂移一次。
  git checkout -q -- README.md 2>/dev/null || true
  if [ "$moved" -gt 0 ]; then
    python3 scripts/build-readme.py >/dev/null 2>&1 || true
    git add -A
    git commit -q -m "chore: move the entry from README.md into $RELOCATE_INTO

README.md is generated by scripts/build-readme.py, so an entry added there is dropped
by the next build. Moving it into the category file keeps the contribution and lets the
branch pass catalog-checks." 2>/dev/null || true
    local remote="fork-$(echo "$fork" | tr '/' '-')" url="git@github.com:$fork.git"
    git remote get-url "$remote" >/dev/null 2>&1 || git remote add "$remote" "$url"
    git remote set-url "$remote" "$url"
    if git push -q "$remote" "$tmp:$branch" --force-with-lease 2>/dev/null; then
      info "已把条目移入 $RELOCATE_INTO 并推回分支（$moved 行）"
    else
      # 贡献者没开 maintainerCanModify 时推不回分支，无法在 PR 本体上补 commit。
      # 但不能就此把 PR 关掉自己代劳 —— 那会让贡献者的 PR 显示为 closed-unmerged，
      # 而条目的作者变成我。改为本地把它合进来：合并信息用 gh pr merge 同样的
      # "Merge pull request #N from fork/branch"，GitHub 据此把 PR 标记为已合并，
      # 贡献者的 commit 也真的进了 main。条目在合并后从 README 搬进分类文件。
      info "⚠ 推不回 fork（贡献者未开 maintainer 编辑权限），改走本地合并"
      git checkout -q main 2>/dev/null || return 1
      git fetch -q origin main 2>/dev/null
      git merge -q --ff-only origin/main 2>/dev/null || git reset -q --hard origin/main
      if ! git merge --no-ff --no-edit -m "Merge pull request #$n from $fork" "$tmp" >/dev/null 2>&1; then
        info "✗ 本地合并失败（可能冲突）"; git merge --abort >/dev/null 2>&1
        git branch -q -D "$tmp" 2>/dev/null; return 1
      fi
      git checkout -q -- README.md 2>/dev/null || true
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        line=$(python3 - "$line" <<'PYNORMSEP'
import re, sys
line = sys.argv[1]
if not line.startswith("- ["):
    print(line); raise SystemExit
link = re.match(r"^(- \[[^\]]+\]\([^)]+\))(\s*`\{[^}]*\}`)?", line)
if not link:
    print(line); raise SystemExit
head, tags = link.group(1), link.group(2) or ""
rest = line[link.end():].lstrip()
m = re.match(r"^[-:\u2014]\s*(.+)$", rest)
print(f"{head}{tags} - {m.group(1)}" if m else (f"{head}{tags} - {rest}" if rest else line))
PYNORMSEP
)
        grep -qF -- "$line" "categories/$RELOCATE_INTO" 2>/dev/null && continue
        printf '%s\n' "$line" >> "categories/$RELOCATE_INTO"
      done <<< "$lines"
      python3 scripts/build-readme.py >/dev/null 2>&1 || true
      git add -A
      git commit -q -m "chore: rebuild README after #$n" 2>/dev/null || true
      if git push -q origin main 2>/dev/null; then
        info "✓ 已本地合并并推送（#$n 将以已合并状态显示，条目在 $RELOCATE_INTO）"
      else
        info "✗ 推送 main 失败"
      fi
      git branch -q -D "$tmp" 2>/dev/null
      return 1
    fi
  fi
  git checkout -q main 2>/dev/null
  git branch -q -D "$tmp" 2>/dev/null
  return 0
}

added_line_for() {
  local n="$1" target="$2"
  gh pr diff "$n" 2>/dev/null | awk -v tgt="$target" '
    /^diff --git / { inblk = ($0 ~ tgt); next }
    inblk && /^\+- \[/ { sub(/^\+/, ""); print; exit }
  '
}

resolve_round() {
  local n="$1" added conflicted
  conflicted=$(git diff --name-only --diff-filter=U)
  [ -z "$conflicted" ] && return 1
  for f in $conflicted; do
    [ "$f" = "README.md" ] && continue
    git checkout --ours -- "$f" 2>/dev/null
    # 改写类 PR（#203/#204/#201）：hunk 里有被删除的条目行。此时只把新行追加进去会留下
    # 旧行，同一条目就出现两次。先在 --ours 上把旧行替换成新行，替换成功后下面的追加自然
    # 不会再触发（新行已在文件里，grep 命中）。
    if ! git diff --cached --quiet 2>/dev/null; then :; fi
    gh pr diff "$n" 2>/dev/null > "/tmp/merge-prs-diff.$$"
    python3 - "$f" "/tmp/merge-prs-diff.$$" <<'PYEDIT' || true
import re, sys
f, difffile = sys.argv[1], sys.argv[2]
try:
    diff = open(difffile, encoding="utf-8", errors="replace").read()
except OSError:
    sys.exit(0)
old = new = None
for b in re.split(r"^diff --git ", diff, flags=re.M):
    if f not in b.split("\n", 1)[0]:
        continue
    for line in b.split("\n"):
        if line.startswith("-- [") and not line.startswith("--- "):
            old = line[2:]
        elif line.startswith("+- [") and old is not None and new is None:
            new = line[2:]
    break
if old and new:
    t = open(f, encoding="utf-8").read()
    if old in t and new not in t:
        open(f, "w", encoding="utf-8").write(t.replace(old, new, 1))
        print(f"  · 改写已应用: {f}")
PYEDIT
    rm -f "/tmp/merge-prs-diff.$$"
    added=$(added_line_for "$n" "$f")
    if printf '%s' "$added" | grep -q "img.shields.io"; then
      info "  ⚠ $f 取到的是 README 渲染行，已跳过（分类文件必须用源码标签形式）"
      added=""
    fi
    if [ -n "$added" ] && ! grep -qF -- "$added" "$f" 2>/dev/null; then
      printf '%s\n' "$added" >>"$f"
    fi
    git add "$f"
    info "冲突已解: $f"
  done
  python3 scripts/build-readme.py >/dev/null 2>&1 || true
  git add -A
  return 0
}

# rebase 到 main → 推回 fork → 合并。成功返回 0。
rebase_push_merge() {
  local n="$1" fork="$2" branch="$3" round=0 remote url

  git fetch -q -f origin "pull/$n/head:pr$n" || { info "✗ 取不到 PR 分支"; return 1; }
  git checkout -q "pr$n" || { info "✗ 切分支失败"; return 1; }
  git reset -q --hard "pr$n"

  git rebase main >/dev/null 2>&1
  while [ $round -lt 8 ]; do
    [ -z "$(git diff --name-only --diff-filter=U 2>/dev/null)" ] && break
    round=$((round + 1))
    resolve_round "$n" || break
    GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 || true
  done
  if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
    if [ -z "$(git diff --name-only --diff-filter=U 2>/dev/null)" ]; then
      GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 \
        || GIT_EDITOR=true git rebase --skip >/dev/null 2>&1
    fi
  fi
  if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
    info "✗ rebase 未完成"; git rebase --abort >/dev/null 2>&1; return 1
  fi
  info "rebase 完成（${round} 轮冲突）"

  # 让分支自身满足 CI。PR 只改分类文件时 README 会落后于分类文件，直接合并会在 main 上
  # 留下一次失败的漂移检查（catalog-checks.yml），虽然 sync_readme 几秒后能补上，
  # 但每个这类 PR 都会在 main 上留一个红叉。在分支上先补建，合并就能落地即绿。
  python3 scripts/build-readme.py >/dev/null 2>&1 || true
  if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -q -m "chore: regenerate README so this branch satisfies catalog-checks" 2>/dev/null \
      && info "已补建 README 提交（让分支自身通过 CI）"
  fi

  # 条目之间的空行会把 markdown 列表拆成两段（#190 就是这样：贡献者在条目前多留了一行，
  # 渲染成两个列表）。CI 的漂移检查抓不到它，因为重新生成的 README 带着同样的空行。
  python3 - <<'PYNORM'
import glob
for p in glob.glob("categories/*.md"):
    ls = open(p).read().split("\n")
    out = []
    for i, l in enumerate(ls):
        if l.strip() == "":
            prev = next((x for x in reversed(out) if x.strip()), "")
            nxt = next((x for x in ls[i + 1:] if x.strip()), "")
            if prev.startswith("- [") and nxt.startswith("- ["):
                continue
        out.append(l)
    if out != ls:
        open(p, "w").write("\n".join(out))
        print(f"  · 已压掉条目间空行: {p}")
PYNORM
  if ! git diff --quiet -- categories/; then
    git add -A
    git commit -q -m "chore: drop blank lines between entries" 2>/dev/null \
      && info "已压掉条目之间的空行并提交"
  fi

  # 合并前闸门：在分支上跑与 CI 相同的检查。不通过就不合并，留给作者修 ——
  # 否则 main 会变红，再由人工回头修（2026-09-23 的跨分类重复 + 标签错配就是这样发生的）。
  local check_out audit_out
  check_out=$(python3 scripts/build-readme.py 2>&1)
  if printf '%s' "$check_out" | grep -q "duplicate sources"; then
    info "✗ 该 PR 造成跨分类重复，已拦下（不合并）："
    printf '%s\n' "$check_out" | grep -A3 "duplicate sources" | head -5 | sed 's/^/    /'
    return 1
  fi
  audit_out=$(python3 scripts/audit-tags.py categories 2>&1)
  if printf '%s' "$audit_out" | grep -qiE "does not mention|unsupported"; then
    info "✗ 标签与条目文本不一致，已拦下（不合并）："
    printf '%s\n' "$audit_out" | grep -iE "does not mention|unsupported" | head -3 | sed 's/^/    /'
    return 1
  fi

  remote="fork-$(echo "$fork" | tr '/' '-')"
  url="git@github.com:$fork.git"
  git remote get-url "$remote" >/dev/null 2>&1 || git remote add "$remote" "$url"
  git remote set-url "$remote" "$url"
  git fetch -q "$remote" "$branch" 2>/dev/null
  if git push -q --force-with-lease "$remote" "pr$n:$branch" 2>/dev/null \
     || git push -q --force "$remote" "pr$n:$branch" 2>/dev/null; then
    info "已推回 $fork/$branch"
  else
    info "✗ 推送失败（可能无权限或 fork 已删）"; return 1
  fi

  if wait_mergeable "$n"; then
    local merge_err
    merge_err=$(gh pr merge "$n" --merge \
      --subject "Merge pull request #$n from $fork" 2>&1) && {
      info "✓ rebase 后合并"
      return 0
    }
    # 把真实错误露出来。权限类错误（fork PR 改 .github/workflows/ 需要 token 的
    # workflow scope）重试多少轮都不会自愈，必须改走本地 merge + SSH push。
    info "✗ 合并失败：$(echo "$merge_err" | head -2 | tr '\n' ' ')"
    case "$merge_err" in
      *workflow*scope*|*workflows/*)
        info "  → token 无 workflow scope。改走本地合并："
        info "     git fetch -f origin pull/$n/head:pr$n && git merge --no-ff pr$n && git push origin main"
        return 2
        ;;
    esac
  fi
  info "✗ 合并失败（多为 main 又前进了）"
  return 1
}

for n in "${PRS[@]}"; do
  echo "=== PR #$n ==="
  read -r fork branch <<<"$(gh pr view "$n" --json headRepository,headRefName \
      -q '.headRepository.nameWithOwner + " " + .headRefName' 2>/dev/null)"
  if [ -z "${fork:-}" ]; then
    sleep 3
    read -r fork branch <<<"$(gh pr view "$n" --json headRepository,headRefName \
        -q '.headRepository.nameWithOwner + " " + .headRefName' 2>/dev/null)"
  fi
  [ -z "${fork:-}" ] && { info "✗ 取不到 PR 信息（gh 瞬时故障），请重跑本脚本"; continue; }
  info "fork=$fork branch=$branch"

  sync_main || { info "✗ main 同步失败"; continue; }

  # 条目写进 README.md 的 PR 先搬到分类文件，否则合并后会静默丢失。
  mutate=1
  relocate_readme_edits "$n" "$fork" "$branch" || mutate=0
  if [ "$mutate" = 0 ]; then info "已跳过 #$n（未合并）"; continue; fi

  if wait_mergeable "$n"; then
    if green_branch_first "$n" "$fork" "$branch"; then prepped=1; else prepped=0; fi
    if gh pr merge "$n" --merge --subject "Merge pull request #$n from $fork" >/dev/null 2>&1; then
      if [ "$prepped" = 1 ]; then
        info "✓ 直接合并（分支已自洽，合并提交为绿）"
        sync_main
      else
        info "✓ 直接合并（分支未能预补建，随后在 main 上补 README）"
        sync_readme
      fi
      continue
    fi
    info "直接合并失败，转 rebase"
  else
    info "不可直接合并，走 rebase"
  fi

  # 最多 3 轮：每轮重新同步 main，避免推到过期基线而回退别人的合并
  for attempt in 1 2 3; do
    rebase_push_merge "$n" "$fork" "$branch" && { sync_readme; break; }
    [ "$attempt" -lt 3 ] && { info "重试 $attempt/3：重新同步 main"; sync_main; }
  done
done

sync_main
echo ""
echo "=== 收尾 ==="
git log --oneline -1
echo "剩余 open: $(gh pr list --state open --json number -q '[.[].number] | join(",")')"
python3 - <<'PY'
import re
t = open('README.md').read()
seg = t.split('## Current coverage')[1].split('Each entry lives')[0]
print("条目总数:", sum(int(m) for m in re.findall(r'— (\d+) entr', seg)))
PY
