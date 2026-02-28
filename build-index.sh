#!/usr/bin/env bash
set -euo pipefail

LECTURES_DIR="lectures"
OUTPUT_DIR="./"
OUTPUT_FILE="$OUTPUT_DIR/index.md"
COURSE_INDEX="$LECTURES_DIR/index"

mkdir -p "$OUTPUT_DIR"

{
cat <<'HTMLHEAD'
# Courses, Lectures and Materials
HTMLHEAD

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip blank lines
    [[ -z "$line" ]] && continue

    # Parse "course-id : Course Pretty Name"
    course_id="${line%% : *}"
    course_name="${line#* : }"

    course_dir="$LECTURES_DIR/$course_id"
    lecture_index="$course_dir/course-index"

    if [[ ! -f "$lecture_index" ]]; then
        echo "Warning: no course-index for $course_id, skipping" >&2
        continue
    fi

    echo "## $course_name"
    echo ""

    cnt=0
    while IFS= read -r lline || [[ -n "$lline" ]]; do
        [[ -z "$lline" ]] && continue

        # Parse "lecture-slug -> Lecture Pretty Name"
        slug="${lline%% -> *}"
        lecture_name="${lline#* -> }"

        pdf="$course_dir/$slug.pdf"
        handout="$course_dir/$slug--handout.pdf"

        cnt=$((cnt + 1))
        echo "### $(printf "%03d" $cnt) - $lecture_name"

        if [[ -f "$pdf" ]]; then
            echo " - <a href=\"$pdf\">Slides</a>"
        fi

        if [[ -f "$handout" ]]; then
            echo " - <a href=\"$handout\">Handout</a>"
        fi

        echo ""
    done < "$lecture_index"

done < "$COURSE_INDEX"

cat <<'HTMLFOOT'
HTMLFOOT
} > "$OUTPUT_FILE"

echo "Built $OUTPUT_FILE"
