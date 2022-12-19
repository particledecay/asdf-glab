#!/bin/bash
# Compares two dot-delimited decimal-element version numbers a and b that may
# also have arbitrary string suffixes. Compatible with semantic versioning, but
# not as strict: comparisons of non-semver strings may have unexpected
# behavior.
#
# Returns:
# 1 if a<b
# 2 if equal
# 3 if a>b
compare_versions() {
  local LC_ALL=C

  # Optimization
  if [[ $1 == "$2" ]]; then
    return 2
  fi

  # Compare numeric release versions. Supports an arbitrary number of numeric
  # elements (i.e., not just X.Y.Z) in which unspecified indices are regarded
  # as 0.
  local aver=${1%%[^0-9.]*} bver=${2%%[^0-9.]*}
  local arem=${1#$aver} brem=${2#$bver}
  local IFS=.
  # shellcheck disable=SC2206
  local i a=($aver) b=($bver)
  for ((i = 0; i < ${#a[@]} || i < ${#b[@]}; i++)); do
    if ((10#${a[i]:-0} < 10#${b[i]:-0})); then
      return 1
    elif ((10#${a[i]:-0} > 10#${b[i]:-0})); then
      return 3
    fi
  done

  # Remove build metadata before remaining comparison
  arem=${arem%%+*}
  brem=${brem%%+*}

  # Prelease (w/remainder) always older than release (no remainder)
  if [ -n "$arem" ] && [ -z "$brem" ]; then
    return 1
  elif [ -z "$arem" ] && [ -n "$brem" ]; then
    return 3
  fi

  # Otherwise, split by periods and compare individual elements either
  # numerically or lexicographically
  # shellcheck disable=SC2206
  local a=(${arem#-}) b=(${brem#-})
  for ((i = 0; i < ${#a[@]} && i < ${#b[@]}; i++)); do
    local anns=${a[i]#${a[i]%%[^0-9]*}} bnns=${b[i]#${b[i]%%[^0-9]*}}
    if [ -z "$anns$bnns" ]; then
      # Both numeric
      if ((10#${a[i]:-0} < 10#${b[i]:-0})); then
        return 1
      elif ((10#${a[i]:-0} > 10#${b[i]:-0})); then
        return 3
      fi
    elif [ -z "$anns" ]; then
      # Numeric comes before non-numeric
      return 1
    elif [ -z "$bnns" ]; then
      # Numeric comes before non-numeric
      return 3
    else
      # Compare lexicographically
      if [[ ${a[i]} < ${b[i]} ]]; then
        return 1
      elif [[ ${a[i]} > ${b[i]} ]]; then
        return 3
      fi
    fi
  done

  # Fewer elements is earlier
  if ((${#a[@]} < ${#b[@]})); then
    return 1
  elif ((${#a[@]} > ${#b[@]})); then
    return 3
  fi

  # Must be equal!
  return 2
}
