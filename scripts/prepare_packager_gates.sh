#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REF_NAME="${1:-${GITHUB_REF_NAME:-}}"

if [ -z "$REF_NAME" ]; then
	REF_NAME="$(git -C "$ROOT_DIR" describe --tags --always 2>/dev/null || true)"
fi

ref_lower="$(printf '%s' "$REF_NAME" | tr '[:upper:]' '[:lower:]')"
if [[ "$ref_lower" == *beta* ]]; then
	export EQOL_PACKAGER_BETA=1
	build_label="beta"
else
	export EQOL_PACKAGER_BETA=0
	build_label="non-beta"
fi

plain_filter='
my $is_beta = ($ENV{"EQOL_PACKAGER_BETA"} || "") eq "1";

if ($is_beta) {
	s/^[ \t]*(?:\#\@(?:eqol-)?beta\@|<!--\@(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*(?:\#\@end-(?:eqol-)?beta\@|<!--\@end-(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*(?:\#\@non-(?:eqol-)?beta\@|<!--\@non-(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z).*?^[ \t]*(?:\#\@end-non-(?:eqol-)?beta\@|<!--\@end-non-(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z)//msg;
} else {
	s/^[ \t]*(?:\#\@(?:eqol-)?beta\@|<!--\@(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z).*?^[ \t]*(?:\#\@end-(?:eqol-)?beta\@|<!--\@end-(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z)//msg;
	s/^[ \t]*(?:\#\@non-(?:eqol-)?beta\@|<!--\@non-(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*(?:\#\@end-non-(?:eqol-)?beta\@|<!--\@end-non-(?:eqol-)?beta\@-->)[^\r\n]*(?:\r?\n|\z)//mg;
}
'

lua_filter='
my $is_beta = ($ENV{"EQOL_PACKAGER_BETA"} || "") eq "1";

if ($is_beta) {
	s/^[ \t]*--\@(?:eqol-)?beta\@[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*--\@end-(?:eqol-)?beta\@[^\r\n]*(?:\r?\n|\z)//mg;
	s/^([ \t]*)--\@non-(?:eqol-)?beta\@[^\r\n]*/$1--[===[@non-eqol-beta/mg;
	s/^([ \t]*)--\@end-non-(?:eqol-)?beta\@[^\r\n]*/$1--@end-non-eqol-beta]===]/mg;
} else {
	s/^([ \t]*)--\@(?:eqol-)?beta\@[^\r\n]*/$1--[===[@eqol-beta/mg;
	s/^([ \t]*)--\@end-(?:eqol-)?beta\@[^\r\n]*/$1--@end-eqol-beta]===]/mg;
	s/^[ \t]*--\@non-(?:eqol-)?beta\@[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*--\@end-non-(?:eqol-)?beta\@[^\r\n]*(?:\r?\n|\z)//mg;
}
'

xml_filter='
my $is_beta = ($ENV{"EQOL_PACKAGER_BETA"} || "") eq "1";

if ($is_beta) {
	s/^[ \t]*<!--\@(?:eqol-)?beta\@-->[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*<!--\@end-(?:eqol-)?beta\@-->[^\r\n]*(?:\r?\n|\z)//mg;
	s/^([ \t]*)<!--\@non-(?:eqol-)?beta\@-->[^\r\n]*/$1<!--@non-eqol-beta/mg;
	s/^([ \t]*)<!--\@end-non-(?:eqol-)?beta\@-->[^\r\n]*/$1@end-non-eqol-beta@-->/mg;
} else {
	s/^([ \t]*)<!--\@(?:eqol-)?beta\@-->[^\r\n]*/$1<!--@eqol-beta/mg;
	s/^([ \t]*)<!--\@end-(?:eqol-)?beta\@-->[^\r\n]*/$1@end-eqol-beta@-->/mg;
	s/^[ \t]*<!--\@non-(?:eqol-)?beta\@-->[^\r\n]*(?:\r?\n|\z)//mg;
	s/^[ \t]*<!--\@end-non-(?:eqol-)?beta\@-->[^\r\n]*(?:\r?\n|\z)//mg;
}
'

process_file() {
	local file="$1"
	case "$file" in
		*.toc | *.md | *.txt)
			perl -0pi -e "$plain_filter" "$ROOT_DIR/$file"
			;;
		*.lua)
			perl -0pi -e "$lua_filter" "$ROOT_DIR/$file"
			;;
		*.xml)
			perl -0pi -e "$xml_filter" "$ROOT_DIR/$file"
			;;
	esac
}

while IFS= read -r -d '' file; do
	process_file "$file"
done < <(git -C "$ROOT_DIR" ls-files -z '*.toc' '*.md' '*.txt' '*.lua' '*.xml')

echo "Prepared ${build_label} packager gates for ref '${REF_NAME:-unknown}'."
