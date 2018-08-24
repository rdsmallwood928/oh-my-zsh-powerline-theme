# FreeAgent puts the powerline style in zsh !
#
# export base03='\033[0;30;40m'
base02='\033[1;30;40m'
base01='\033[0;32;40m'
base00='\033[0;33;40m'
base0='\033[0;34;40m'
base1='\033[0;36;40m'
base2='\033[0;37;40m'
base3='\033[1;37;40m'
yellow='\033[1;33;40m'
orange='\033[0;31;40m'
red='\033[1;31;40m'
magenta='\033[1;35;40m'
violet='\033[0;35;40m'
blue='\033[1;34;40m'
cyan='\033[1;36;40m'
green='\033[1;32;40m'
reset='\033[0m'
test_color='\${wrap}0;35;4${end_wrap}'

__promptline_vcs_branch ()
{
    local branch;
    local branch_symbol=" ";
    if hash git 2> /dev/null; then
        if branch=$( { git symbolic-ref --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null ); then
            branch=${branch##*/};
            printf "%s" "${branch_symbol}${branch:-unknown}";
            return;
        fi;
    fi;
    return 1
}

__promptline_cwd ()
{
    local dir_limit="3";
    local truncation="⋯";
    local first_char;
    local part_count=0;
    local formatted_cwd="";
    local dir_sep="  ";
    local cwd;
    if [[ "${PLATFORM}" == 'darwin' ]]; then
        cwd="${PWD/#$HOME/\~}";
    else
        cwd="${PWD/#$HOME/~}";
    fi;
    [[ -n ${ZSH_VERSION-} ]] && first_char="$cwd[1,1]" || first_char=${cwd::1};
    cwd="${cwd#\~}";
    while [[ "$cwd" == */* && "$cwd" != "/" ]]; do
        [[ $part_count -eq $dir_limit ]] && first_char="$first_char$dir_sep$truncation" && break;
        local part="${cwd##*/}";
        cwd="${cwd%/*}";
        formatted_cwd="$dir_sep$part$formatted_cwd";
        part_count=$((part_count+1));
    done;
    printf "%s" "$first_char$formatted_cwd"
}

__promptline_git_status ()
{
    [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] || return 1;
    local added_symbol="●";
    local unmerged_symbol="✖";
    local modified_symbol="✚";
    local clean_symbol="✔";
    local has_untracked_files_symbol="…";
    local ahead_symbol="↑";
    local behind_symbol="↓";
    local unmerged_count=0;
    local modified_count=0;
    local has_untracked_files=0;
    local added_count=0;
    local is_clean="";
    local black_fg="${wrap}38;5;0${end_wrap}";
    local red_fg="${wrap}38;5;1${end_wrap}";
    local green_fg="${wrap}38;5;2${end_wrap}";
    local yellow_fg='${wrap}0;35;4${end_wrap}';
    local blue_fg="${wrap}38;5;4${end_wrap}";
    local magenta_fg="${wrap}38;5;5${end_wrap}";
    local cyan_fg="${wrap}38;5;6${end_wrap}";
    local white_fg="${wrap}38;5;7${end_wrap}";
    set -- $(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null);
    local behind_count=$1;
    local ahead_count=$2;
    while read line; do
        case "$line" in
            M*)
                modified_count=$(( $modified_count + 1 ))
            ;;
            U*)
                unmerged_count=$(( $unmerged_count + 1 ))
            ;;
        esac;
    done < <(git diff --name-status);
    while read line; do
        case "$line" in
            *)
                added_count=$(( $added_count + 1 ))
            ;;
        esac;
    done < <(git diff --name-status --cached);
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        has_untracked_files=1;
    fi;
    if [ $(( unmerged_count + modified_count + has_untracked_files + added_count )) -eq 0 ]; then
        is_clean=1;
    fi;
    local leading_whitespace="";
    [[ $ahead_count -gt 0 ]] && {
        printf "%s" "%F{cyan_fg}$leading_whitespace$ahead_symbol$ahead_count$x_fg";
        leading_whitespace=" "
    };
    [[ $behind_count -gt 0 ]] && {
        printf "%s" "%F{magenta_fg}$leading_whitespace$behind_symbol$behind_count$x_fg";
        leading_whitespace=" "
    };
    [[ $modified_count -gt 0 ]] && {
        printf "%s" "%F{yellow_fg}$leading_whitespace$modified_symbol$modified_count$x_fg";
        leading_whitespace=" "
    };
    [[ $unmerged_count -gt 0 ]] && {
        printf "%s" "%F{magenta_fg}$leading_whitespace$unmerged_symbol$unmerged_count$x_fg";
        leading_whitespace=" "
    };
    [[ $added_count -gt 0 ]] && {
        printf "%s" "%F{blue_fg}$leading_whitespace$added_symbol$added_count$x_fg";
        leading_whitespace=" "
    };
    [[ $has_untracked_files -gt 0 ]] && {
        printf "%s" "%F{yellow_fg}$leading_whitespace$has_untracked_files_symbol$x_fg";
        leading_whitespace=" "
    };
    [[ $is_clean -gt 0 ]] && {
        printf "%s" "$leading_whitespace%F{green_fg}$clean_symbol$x_fg";
        leading_whitespace=" "
    }
}

if [ "$POWERLINE_DATE_FORMAT" = "" ]; then
  POWERLINE_DATE_FORMAT=%D{%Y-%m-%d}
fi

if [ "$POWERLINE_RIGHT_B" = "" ]; then
  POWERLINE_RIGHT_B=%D{%H:%M:%S}
elif [ "$POWERLINE_RIGHT_B" = "none" ]; then
  POWERLINE_RIGHT_B=""
fi

if [ "$POWERLINE_RIGHT_A" = "mixed" ]; then
  POWERLINE_RIGHT_A=%(?."$POWERLINE_DATE_FORMAT".%F{red}✘ %?)
elif [ "$POWERLINE_RIGHT_A" = "exit-status" ]; then
  POWERLINE_RIGHT_A=%(?.%F{green}✔ %?.%F{red}✘ %?)
elif [ "$POWERLINE_RIGHT_A" = "exit-status-on-fail" ]; then
  POWERLINE_RIGHT_A=%(?..%F{red}✘ %?)
elif [ "$POWERLINE_RIGHT_A" = "date" ]; then
  POWERLINE_RIGHT_A="$POWERLINE_DATE_FORMAT"
fi

if [ "$POWERLINE_SHORT_HOST_NAME" = "" ]; then
    POWERLINE_HOST_NAME="%M"
else
    POWERLINE_HOST_NAME="%m"
fi

if [ "$POWERLINE_HIDE_USER_NAME" = "" ] && [ "$POWERLINE_HIDE_HOST_NAME" = "" ]; then
    POWERLINE_USER_NAME="%n@$POWERLINE_HOST_NAME"
elif [ "$POWERLINE_HIDE_USER_NAME" != "" ] && [ "$POWERLINE_HIDE_HOST_NAME" = "" ]; then
    POWERLINE_USER_NAME="$POWERLINE_HOST_NAME"
elif [ "$POWERLINE_HIDE_USER_NAME" = "" ] && [ "$POWERLINE_HIDE_HOST_NAME" != "" ]; then
    POWERLINE_USER_NAME="%n"
else
    POWERLINE_USER_NAME=""
fi

if [ "$POWERLINE_PATH" = "full" ]; then
  POWERLINE_PATH="%1~"
elif [ "$POWERLINE_PATH" = "short" ]; then
  POWERLINE_PATH="%~"
else
  POWERLINE_PATH="%d"
fi

if [ "$POWERLINE_CUSTOM_CURRENT_PATH" != "" ]; then
  POWERLINE_CURRENT_PATH="$POWERLINE_CUSTOM_CURRENT_PATH"
fi

if [ "$POWERLINE_GIT_CLEAN" = "" ]; then
  POWERLINE_GIT_CLEAN="%F{green}✔"
fi

if [ "$POWERLINE_GIT_DIRTY" = "" ]; then
  POWERLINE_GIT_DIRTY="✘"
fi

if [ "$POWERLINE_GIT_ADDED" = "" ]; then
  POWERLINE_GIT_ADDED="%F{green}✚%F{black}"
fi

if [ "$POWERLINE_GIT_MODIFIED" = "" ]; then
  POWERLINE_GIT_MODIFIED="%F{blue}✹%F{black}"
fi

if [ "$POWERLINE_GIT_DELETED" = "" ]; then
  POWERLINE_GIT_DELETED="%F{red}✖%F{black}"
fi

if [ "$POWERLINE_GIT_UNTRACKED" = "" ]; then
  POWERLINE_GIT_UNTRACKED="%F{yellow}✭%F{black}"
fi

if [ "$POWERLINE_GIT_RENAMED" = "" ]; then
  POWERLINE_GIT_RENAMED="➜"
fi

if [ "$POWERLINE_GIT_UNMERGED" = "" ]; then
  POWERLINE_GIT_UNMERGED="═"
fi

if [ "$POWERLINE_RIGHT_A_COLOR_FRONT" = "" ]; then
  POWERLINE_RIGHT_A_COLOR_FRONT="white"
fi

if [ "$POWERLINE_RIGHT_A_COLOR_BACK" = "" ]; then
  POWERLINE_RIGHT_A_COLOR_BACK="black"
fi

ZSH_THEME_GIT_PROMPT_PREFIX=" \ue0a0 "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=" $POWERLINE_GIT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN=" $POWERLINE_GIT_CLEAN"

ZSH_THEME_GIT_PROMPT_ADDED=" $POWERLINE_GIT_ADDED"
ZSH_THEME_GIT_PROMPT_MODIFIED=" $POWERLINE_GIT_MODIFIED"
ZSH_THEME_GIT_PROMPT_DELETED=" $POWERLINE_GIT_DELETED"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" $POWERLINE_GIT_UNTRACKED"
ZSH_THEME_GIT_PROMPT_RENAMED=" $POWERLINE_GIT_RENAMED"
ZSH_THEME_GIT_PROMPT_UNMERGED=" $POWERLINE_GIT_UNMERGED"
ZSH_THEME_GIT_PROMPT_AHEAD=" ⬆"
ZSH_THEME_GIT_PROMPT_BEHIND=" ⬇"
ZSH_THEME_GIT_PROMPT_DIVERGED=" ⬍"

# if [ "$(git_prompt_info)" = "" ]; then
   # POWERLINE_GIT_INFO_LEFT=""
   # POWERLINE_GIT_INFO_RIGHT=""
# else
    if [ "$POWERLINE_SHOW_GIT_ON_RIGHT" = "" ]; then
        if [ "$POWERLINE_HIDE_GIT_PROMPT_STATUS" = "" ]; then
            POWERLINE_GIT_INFO_LEFT=" %F{blue}%K{$base03}"$'\ue0b0'"%F{gray}%K{$base03}"$' $(__promptline_vcs_branch) $(__promptline_git_status)%F{$base03}'
        else
            POWERLINE_GIT_INFO_LEFT=" %F{blue}%K{white}"$'\ue0b0'"%F{white}%F{black}%K{white}"$'$(git_prompt_info)%F{white}'
        fi
        POWERLINE_GIT_INFO_RIGHT=""
    else
        POWERLINE_GIT_INFO_LEFT=""
        if [ "$POWERLINE_HIDE_GIT_PROMPT_STATUS" = "" ]; then
            POWERLINE_GIT_INFO_RIGHT="%F{white}"$'\ue0b2'"%F{black}%K{white}"$'$(git_prompt_info)$(git_prompt_status)'" %K{white}"
        else
            POWERLINE_GIT_INFO_RIGHT="%F{white}"$'\ue0b2'"%F{black}%K{white}"$'$(git_prompt_info)'" %K{white}"
        fi
    fi
# fi

if [ $(id -u) -eq 0 ]; then
    POWERLINE_SEC1_BG=%K{red}
    POWERLINE_SEC1_FG=%F{red}
else
    POWERLINE_SEC1_BG=%K{214}
    POWERLINE_SEC1_FG=%F{214}
fi
POWERLINE_SEC1_TXT=%F{black}
if [ "$POWERLINE_DETECT_SSH" != "" ]; then
  if [ -n "$SSH_CLIENT" ]; then
    POWERLINE_SEC1_BG=%K{red}
    POWERLINE_SEC1_FG=%F{red}
    POWERLINE_SEC1_TXT=%F{white}
  fi
fi

if [ "$VIRTUAL_ENV" != "" ] && [ "$POWERLINE_HIDE_VIRTUAL_ENV" = "" ]; then
    VENV_NAME=$(basename "$VIRTUAL_ENV")
    VENV_STATUS="($POWERLINE_SEC1_TXT$VENV_NAME)"
else
    VENV_STATUS=""
fi

PROMPT="$POWERLINE_SEC1_BG$POWERLINE_SEC1_TXT $POWERLINE_USER_NAME $VENV_STATUS%k%f$POWERLINE_SEC1_FG%K{242}"$'\ue0b0'"%k%f%F{white}%K{242} "'$(__promptline_cwd)'"%F{242} %k"$'\ue0b0'"%f "

if [ "$POWERLINE_NO_BLANK_LINE" = "" ]; then
    PROMPT="
"$PROMPT
fi


if [ "$POWERLINE_MULTILINE" != "" ]; then
    PROMPT=$PROMPT"
%K{blue}%F{white} %n"$POWERLINE_GIT_INFO_LEFT" %k"$'\ue0b0'"%f "

fi

if [ "$POWERLINE_DISABLE_RPROMPT" = "" ]; then
    if [ "$POWERLINE_RIGHT_A" = "" ]; then
        RPROMPT="$POWERLINE_GIT_INFO_RIGHT%F{white}"$'\ue0b2'"%k%F{black}%K{white} $POWERLINE_RIGHT_B %f%k"
    elif [ "$POWERLINE_RIGHT_B" = "" ]; then
        RPROMPT="$POWERLINE_GIT_INFO_RIGHT%F{white}"$'\ue0b2'"%k%F{$POWERLINE_RIGHT_A_COLOR_FRONT}%K{$POWERLINE_RIGHT_A_COLOR_BACK} $POWERLINE_RIGHT_A %f%k"
    else
        RPROMPT="$POWERLINE_GIT_INFO_RIGHT%F{white}"$'\ue0b2'"%k%F{black}%K{white} $POWERLINE_RIGHT_B %f%F{$POWERLINE_RIGHT_A_COLOR_BACK}"$'\ue0b2'"%f%k%K{$POWERLINE_RIGHT_A_COLOR_BACK}%F{$POWERLINE_RIGHT_A_COLOR_FRONT} $POWERLINE_RIGHT_A %f%k"
    fi
fi
