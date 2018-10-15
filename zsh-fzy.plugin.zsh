#
# zsh-fzy.plugin.zsh
# Copyright (C) 2018 Adrian Perez <aperez@igalia.com>
#
# Distributed under terms of the MIT license.
#

ZSH_FZY_TMUX="${0:A:h}/fzy-tmux"
ZSH_FZY=$(command -v fzy)
if [[ -z ${ZSH_FZY} ]] ; then
    echo 'fzy is not installed. See https://github.com/jhawthorn/fzy'
    return 1
fi


function __fzy_cmd
{
	emulate -L zsh

	local widget=$1
	shift

	local -a args=( )
	local value
	if zstyle -s ":fzy:${widget}" prompt value ; then
		args+=( -p "${value}" )
	else
		args+=( -p "${widget} >> " )
	fi
	if zstyle -s ":fzy:${widget}" lines value ; then
		args+=( -l "${value}" )
	fi
	if zstyle -t ":fzy:${widget}" show-scores ; then
		args+=( -s )
	fi

	if zstyle -t :fzy:tmux enabled && [[ -n ${TMUX} ]] ; then
		"${ZSH_FZY_TMUX}" -- "${args[@]}" "$@"
	else
		"${ZSH_FZY}" "${args[@]}" "$@"
	fi
}

function __fzy_fsel
{
	command fd -L . | __fzy_cmd file | while read -r item; do
	    print -n "${(q)item}"
	done
	print
}

function fzy-file-widget
{
	emulate -L zsh
	LBUFFER="${LBUFFER}$(__fzy_fsel)"
	zle redisplay
}

function fzy-cd-widget
{
	emulate -L zsh
	cd "${$(command fd -L -t d | __fzy_cmd cd):-.}"
	zle reset-prompt
}

function fzy-history-widget
{
	emulate -L zsh
	local S=$(fc -l -n -r 1 | __fzy_cmd history -q "${LBUFFER//$/\\$}")
	if [[ -n $S ]] ; then
		LBUFFER=$S
	fi
	zle redisplay
}

zle -N fzy-file-widget
zle -N fzy-cd-widget
zle -N fzy-history-widget
