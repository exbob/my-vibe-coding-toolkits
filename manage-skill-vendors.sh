#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THIRDPART_DIR="${ROOT_DIR}/thirdpart/skills"
SOURCES_FILE="${ROOT_DIR}/thirdpart/skills.sources.tsv"

usage() {
  cat <<'EOF'
用法:
  manage-skill-vendors.sh add <name> <repo_url> [branch]
  manage-skill-vendors.sh update [name]
  manage-skill-vendors.sh list

说明:
  - add: 添加一个 skill 仓库到 thirdpart/skills/<name>
  - update: 手动更新全部或指定 name 的仓库
  - list: 查看已记录仓库来源
EOF
}

ensure_layout() {
  mkdir -p "${THIRDPART_DIR}"
  if [[ ! -f "${SOURCES_FILE}" ]]; then
    printf "name\trepo_url\tbranch\tlast_commit\tupdated_at\n" > "${SOURCES_FILE}"
  fi
}

ensure_gh_repo() {
  local repo_url="$1"
  if [[ "${repo_url}" != git@github.com:* && "${repo_url}" != https://github.com/* ]]; then
    echo "错误: 当前仅支持 GitHub 仓库 URL: ${repo_url}" >&2
    exit 1
  fi
}

exists_in_sources() {
  local name="$1"
  awk -F $'\t' -v n="${name}" 'NR>1 && $1==n { found=1 } END { exit found?0:1 }' "${SOURCES_FILE}"
}

get_field() {
  local name="$1"
  local field_idx="$2"
  awk -F $'\t' -v n="${name}" -v idx="${field_idx}" 'NR>1 && $1==n { print $idx; exit }' "${SOURCES_FILE}"
}

replace_record() {
  local name="$1"
  local repo_url="$2"
  local branch="$3"
  local commit="$4"
  local updated_at="$5"
  local tmp
  tmp="$(mktemp)"
  awk -F $'\t' -v OFS=$'\t' -v n="${name}" '
    NR==1 { print; next }
    $1!=n { print }
  ' "${SOURCES_FILE}" > "${tmp}"
  printf "%s\t%s\t%s\t%s\t%s\n" "${name}" "${repo_url}" "${branch}" "${commit}" "${updated_at}" >> "${tmp}"
  mv "${tmp}" "${SOURCES_FILE}"
}

sync_repo() {
  local name="$1"
  local repo_url="$2"
  local branch="$3"

  local dst="${THIRDPART_DIR}/${name}"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  # Under `set -u`, RETURN trap may execute after local vars are out of scope.
  # Use a safe expansion and clear trap explicitly at function end.
  trap 'rm -rf "${tmp_dir:-}"' RETURN

  git clone --depth 1 --branch "${branch}" "${repo_url}" "${tmp_dir}/repo"
  local commit
  commit="$(git -C "${tmp_dir}/repo" rev-parse HEAD)"

  rm -rf "${dst}"
  mkdir -p "${dst}"
  rsync -a --delete --exclude ".git" "${tmp_dir}/repo/" "${dst}/"

  local updated_at
  updated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  replace_record "${name}" "${repo_url}" "${branch}" "${commit}" "${updated_at}"

  echo "已同步: ${name}"
  echo "  repo:   ${repo_url}"
  echo "  branch: ${branch}"
  echo "  commit: ${commit}"
  echo "  path:   thirdpart/skills/${name}"
  trap - RETURN
}

add_repo() {
  local name="${1:-}"
  local repo_url="${2:-}"
  local branch="${3:-main}"
  if [[ -z "${name}" || -z "${repo_url}" ]]; then
    usage
    exit 1
  fi
  ensure_gh_repo "${repo_url}"
  if exists_in_sources "${name}"; then
    echo "错误: ${name} 已存在。请使用 update ${name}" >&2
    exit 1
  fi
  sync_repo "${name}" "${repo_url}" "${branch}"
}

update_repo() {
  local name="${1:-}"
  if [[ -z "${name}" ]]; then
    local total
    total="$(awk 'NR>1 { c++ } END { print c+0 }' "${SOURCES_FILE}")"
    if [[ "${total}" -eq 0 ]]; then
      echo "没有可更新的仓库。"
      exit 0
    fi
    while IFS=$'\t' read -r n repo_url branch _ _; do
      [[ "${n}" == "name" ]] && continue
      sync_repo "${n}" "${repo_url}" "${branch}"
    done < "${SOURCES_FILE}"
  else
    if ! exists_in_sources "${name}"; then
      echo "错误: 未找到 ${name}" >&2
      exit 1
    fi
    local repo_url
    local branch
    repo_url="$(get_field "${name}" 2)"
    branch="$(get_field "${name}" 3)"
    sync_repo "${name}" "${repo_url}" "${branch}"
  fi
}

list_repos() {
  if [[ ! -s "${SOURCES_FILE}" ]]; then
    echo "暂无记录。"
    exit 0
  fi
  column -t -s $'\t' "${SOURCES_FILE}"
}

main() {
  ensure_layout
  local cmd="${1:-}"
  case "${cmd}" in
    add)
      shift
      add_repo "$@"
      ;;
    update)
      shift
      update_repo "${1:-}"
      ;;
    list)
      list_repos
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
