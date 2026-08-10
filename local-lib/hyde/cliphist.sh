#!/usr/bin/env bash
pkill -u "$USER" rofi && exit 0
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"
cache_dir="${HYDE_CACHE_HOME:-$HOME/.cache/hyde}"
favorites_file="$cache_dir/landing/cliphist_favorites"
[ -f "$HOME/.cliphist_favorites" ] && favorites_file="$HOME/.cliphist_favorites"
cliphist_style="${ROFI_CLIPHIST_STYLE:-clipboard}"

# Override get_rofi_pos to fix fractional scaling bug (e.g., scale 1.3333334)
# HyDE's original version strips the dot from scale causing monRes to become 0
# Also avoids negative offsets which can cause parse errors in some rofi versions
get_rofi_pos() {
    [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]] || return 1
    local curPos_x curPos_y
    read -r curPos_x curPos_y < <(hyprctl cursorpos -j | jq -r '.x,.y')
    local mon_width mon_height mon_scale mon_x mon_y
    read -r mon_width mon_height mon_scale mon_x mon_y < <(
        hyprctl -j monitors | jq -r '.[] | select(.focused==true) | "\(.width) \(.height) \(.scale) \(.x) \(.y)"'
    )
    local off_left off_top off_right off_bottom
    read -r off_left off_top off_right off_bottom < <(
        hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .reserved | join(" ")'
    )
    # Use awk for correct floating-point scale handling
    mon_width=$(awk "BEGIN {printf \"%d\", $mon_width * 100 / ($mon_scale * 100)}")
    mon_height=$(awk "BEGIN {printf \"%d\", $mon_height * 100 / ($mon_scale * 100)}")
    curPos_x=$((curPos_x - mon_x))
    curPos_y=$((curPos_y - mon_y))
    # Use center anchor with positive offsets to avoid negative value parse errors
    local x_off y_off
    x_off=$((curPos_x - mon_width / 2))
    y_off=$((curPos_y - mon_height / 2))
    echo "window{location:center;anchor:center;x-offset:${x_off}px;y-offset:${y_off}px;}"
}

# Migrate old format (plain base64) to new format (normal:base64 or sensitive:base64)
migrate_favorites_format() {
    if [ ! -f "$favorites_file" ] || [ ! -s "$favorites_file" ]; then
        return
    fi
    local tmp_file
    tmp_file=$(mktemp)
    local needs_migration=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^(normal:|sensitive:) ]]; then
            echo "$line" >>"$tmp_file"
        else
            echo "normal:$line" >>"$tmp_file"
            needs_migration=true
        fi
    done <"$favorites_file"
    if [ "$needs_migration" = true ]; then
        mv "$tmp_file" "$favorites_file"
        notify-send "Favorites migrated to new format."
    else
        rm -f "$tmp_file"
    fi
}

# Obfuscate content: show first 3 chars + bullets
obfuscate_content() {
    local content="$1"
    local len=${#content}
    if [ "$len" -le 3 ]; then
        printf '••••••••'
    else
        local prefix="${content:0:3}"
        printf '%s••••••••' "$prefix"
    fi
}

# Parse favorites file and return arrays: favorite_flags, favorite_data
parse_favorites() {
    favorite_flags=()
    favorite_data=()
    if [ ! -f "$favorites_file" ] || [ ! -s "$favorites_file" ]; then
        return 1
    fi
    while IFS= read -r line; do
        if [[ "$line" =~ ^sensitive:(.+) ]]; then
            favorite_flags+=("sensitive")
            favorite_data+=("${BASH_REMATCH[1]}")
        elif [[ "$line" =~ ^normal:(.+) ]]; then
            favorite_flags+=("normal")
            favorite_data+=("${BASH_REMATCH[1]}")
        else
            # Fallback for untagged lines
            favorite_flags+=("normal")
            favorite_data+=("$line")
        fi
    done <"$favorites_file"
    return 0
}

# Toggle sensitive flag for a favorite
toggle_sensitive() {
    parse_favorites || {
        notify-send "No favorites."
        return
    }
    local count=${#favorite_data[@]}
    if [ "$count" -eq 0 ]; then
        notify-send "No favorites."
        return
    fi
    local display_lines=()
    for ((i = 0; i < count; i++)); do
        local decoded
        decoded=$(echo "${favorite_data[$i]}" | base64 --decode)
        local single_line
        single_line=$(echo "$decoded" | tr '\n' ' ')
        local flag="${favorite_flags[$i]}"
        local icon=""
        if [ "$flag" = "normal" ]; then
            icon=""
        else
            single_line=$(obfuscate_content "$single_line")
        fi
        display_lines+=("$icon $single_line")
    done
    local selected
    selected=$(printf "%s\n" "${display_lines[@]}" | run_rofi " Toggle Sensitive (/)") || exit 0
    if [ -n "$selected" ]; then
        local idx=-1
        for ((i = 0; i < count; i++)); do
            if [ "${display_lines[$i]}" = "$selected" ]; then
                idx=$i
                break
            fi
        done
        if [ "$idx" -ge 0 ]; then
            local new_flag="sensitive"
            [ "${favorite_flags[$idx]}" = "sensitive" ] && new_flag="normal"
            local tmp_file
            tmp_file=$(mktemp)
            for ((i = 0; i < count; i++)); do
                if [ "$i" -eq "$idx" ]; then
                    echo "${new_flag}:${favorite_data[$i]}" >>"$tmp_file"
                else
                    echo "${favorite_flags[$i]}:${favorite_data[$i]}" >>"$tmp_file"
                fi
            done
            mv "$tmp_file" "$favorites_file"
            local status_msg="marked as sensitive "
            [ "$new_flag" = "normal" ] && status_msg="marked as normal "
            notify-send "Favorite $status_msg"
        fi
    fi
}

# Edit a favorite with modal
edit_favorite() {
    parse_favorites || {
        notify-send "No favorites to edit."
        return
    }
    local count=${#favorite_data[@]}
    if [ "$count" -eq 0 ]; then
        notify-send "No favorites to edit."
        return
    fi
    local display_lines=()
    for ((i = 0; i < count; i++)); do
        local decoded
        decoded=$(echo "${favorite_data[$i]}" | base64 --decode)
        local single_line
        single_line=$(echo "$decoded" | tr '\n' ' ')
        local flag="${favorite_flags[$i]}"
        if [ "$flag" = "sensitive" ]; then
            single_line=$(obfuscate_content "$single_line")
        fi
        display_lines+=("$single_line")
    done
    local selected
    selected=$(printf "%s\n" "${display_lines[@]}" | run_rofi " Edit Favorite") || exit 0
    if [ -n "$selected" ]; then
        local idx=-1
        for ((i = 0; i < count; i++)); do
            if [ "${display_lines[$i]}" = "$selected" ]; then
                idx=$i
                break
            fi
        done
        if [ "$idx" -ge 0 ]; then
            local original_content
            original_content=$(echo "${favorite_data[$idx]}" | base64 --decode)
            local flag="${favorite_flags[$idx]}"
            if [ "$flag" = "sensitive" ]; then
                edit_sensitive_warning "$idx" "$original_content"
            else
                edit_direct "$idx" "$original_content"
            fi
        fi
    fi
}

# Edit sensitive item with warning modal
edit_sensitive_warning() {
    local idx="$1"
    local current_content="$2"
    local obfuscated
    obfuscated=$(obfuscate_content "$current_content")
    local action
    action=$(echo -e " Edit Anyway (Show Content)\n Edit (Keep Hidden)\n Cancel" |
        run_rofi " Sensitive Content: $obfuscated") || return
    case "$action" in
    " Edit Anyway (Show Content)")
        edit_direct "$idx" "$current_content"
        ;;
    " Edit (Keep Hidden)")
        edit_hidden "$idx" "$current_content"
        ;;
    *)
        return
        ;;
    esac
}

# Edit non-sensitive item directly (full content visible)
edit_direct() {
    local idx="$1"
    local current_content="$2"
    # Create a temporary file with current content for editing
    local tmp_edit
    tmp_edit=$(mktemp)
    echo "$current_content" >"$tmp_edit"
    # Use rofi to select action
    local action
    action=$(echo -e " Edit Content\n Cancel" | run_rofi " Edit: $current_content") || {
        rm -f "$tmp_edit"
        return
    }
    case "$action" in
    " Edit Content")
        # Open text editor via rofi menu
        local new_content
        new_content=$(echo "" | rofi -dmenu -p "Enter new content" \
            -theme "$cliphist_style" \
            -theme-str "$font_override" \
            -theme-str "$r_override" \
            -theme-str "$rofi_position")
        if [ -n "$new_content" ]; then
            save_favorite "$idx" "$new_content"
        fi
        ;;
    esac
    rm -f "$tmp_edit"
}

# Edit sensitive item with hidden content
edit_hidden() {
    local idx="$1"
    local current_content="$2"
    local obfuscated
    obfuscated=$(obfuscate_content "$current_content")
    # Use rofi to select action
    local action
    action=$(echo -e " Edit Content\n Cancel" | run_rofi " Edit: $obfuscated") || return
    case "$action" in
    " Edit Content")
        # Open text editor via rofi menu
        local new_content
        new_content=$(echo "" | rofi -dmenu -p "Enter new content (will be saved as-is)" \
            -theme "$cliphist_style" \
            -theme-str "$font_override" \
            -theme-str "$r_override" \
            -theme-str "$rofi_position")
        if [ -n "$new_content" ]; then
            save_favorite "$idx" "$new_content"
        fi
        ;;
    esac
}

# Save favorite to file
save_favorite() {
    local idx="$1"
    local new_content="$2"
    local encoded
    encoded=$(echo -n "$new_content" | base64 -w 0)
    local tmp_file
    tmp_file=$(mktemp)
    local line_num=0
    while IFS= read -r line; do
        if [ "$line_num" -eq "$idx" ]; then
            echo "${favorite_flags[$idx]}:$encoded" >>"$tmp_file"
        else
            echo "$line" >>"$tmp_file"
        fi
        line_num=$((line_num + 1))
    done <"$favorites_file"
    mv "$tmp_file" "$favorites_file"
    notify-send "Favorite updated."
}

process_deletion() {
    while IFS= read -r line; do
        echo "$line"
        if [[ $line == ":w:i:p:e:"* ]]; then
            "$0" --wipe
            break
        elif [[ $line == ":b:a:r:"* ]]; then
            "$0" --delete
            break
        elif [ -n "$line" ]; then
            cliphist delete <<<"$line"
            notify-send "Deleted" "$line"
        fi
    done
    exit 0
}
process_selections() {
    mapfile -t lines
    total_lines=${#lines[@]}
    handle_special_commands "${lines[@]}"
    local output=""
    for ((i = 0; i < total_lines; i++)); do
        local line="${lines[$i]}"
        local decoded_line
        decoded_line="$(echo -e "$line\t" | cliphist decode)"
        if [ $i -lt $((total_lines - 1)) ]; then
            printf -v output '%s%s\n' "$output" "$decoded_line"
        else
            printf -v output '%s%s' "$output" "$decoded_line"
        fi
    done
    echo -n "$output"
}
handle_special_commands() {
    local lines=("$@")
    case "${lines[0]}" in
    ":d:e:l:e:t:e:"*) exec "$0" --delete exit 0 ;;
    ":w:i:p:e:"*) exec "$0" --wipe exit 0 ;;
    ":b:a:r:"* | *":c:o:p:y:"*) exec "$0" --copy exit 0 ;;
    ":f:a:v:"*) exec "$0" --favorites exit 0 ;;
    ":i:m:g:") exec "$0" --image-history ;;
    ":o:p:t:"*) exec "$0" exit 0 ;;
    ":o:c:r:"*) exec "$0" --scan-image ;;
    esac
}
check_content() {
    local line
    read -r line
    if [[ $line == *"[[ binary data"* ]]; then
        cliphist decode <<<"$line" | wl-copy
        local img_idx
        img_idx=$(awk -F '\t' '{print $1}' <<<"$line")
        local temp_preview="$XDG_RUNTIME_DIR/hyde/pastebin-preview_$img_idx"
        wl-paste >"$temp_preview"
        notify-send -a "Pastebin:" "Preview: $img_idx" -i "$temp_preview" -t 2000
        return 1
    fi
}
run_rofi() {
    local placeholder="$1"
    shift
    rofi -dmenu \
        -theme-str "entry { placeholder: \"$placeholder\";}" \
        -theme-str "$font_override" \
        -theme-str "$r_override" \
        -theme-str "$rofi_position" \
        -theme "$cliphist_style" \
        -kb-custom-1 "Alt+c" \
        -kb-custom-2 "Alt+d" \
        -kb-custom-3 "Alt+n" \
        -kb-custom-4 "Alt+w" \
        -kb-custom-5 "Alt+o" \
        -kb-custom-6 "Alt+v" \
        -kb-custom-7 "Alt+s" \
        "$@"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        case "$exit_code" in
        10) printf ":c:o:p:y:" ;;
        11) printf ":d:e:l:e:t:e:" ;;
        12) printf ":f:a:v:" ;;
        13) printf ":w:i:p:e:" ;;
        14) printf ":o:p:t:" ;;
        15) printf ":i:m:g:" ;;
        16) printf ":o:c:r:" ;;
        esac
    fi
}
setup_rofi_config() {
    local font_scale="$ROFI_CLIPHIST_SCALE"
    [[ $font_scale =~ ^[0-9]+$ ]] || font_scale=${ROFI_SCALE:-10}
    local font_name=${ROFI_CLIPHIST_FONT:-$ROFI_FONT}
    font_name=${font_name:-$(get_hyprConf "MENU_FONT")}
    font_name=${font_name:-$(get_hyprConf "FONT")}
    font_override="* {font: \"${font_name:-"JetBrainsMono Nerd Font"} $font_scale\";}"
    local hypr_border=${hypr_border:-"$(hyprctl -j getoption decoration:rounding | jq '.int')"}
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$((hypr_border == 0 ? 5 : hypr_border))
    rofi_position=$(get_rofi_pos)
    local hypr_width=${hypr_width:-"$(hyprctl -j getoption general:border_size | jq '.int')"}
    r_override="window{border:${hypr_width}px;border-radius:${wind_border}px;}wallbox{border-radius:${elem_border}px;} element{border-radius:${elem_border}px;}"
}
ensure_favorites_dir() {
    local dir
    dir=$(dirname "$favorites_file")
    [ -d "$dir" ] || mkdir -p "$dir"
}
prepare_favorites_for_display() {
    parse_favorites || return 1
    decoded_lines=()
    for ((i = 0; i < ${#favorite_data[@]}; i++)); do
        local decoded
        decoded=$(echo "${favorite_data[$i]}" | base64 --decode)
        local single_line
        single_line=$(echo "$decoded" | tr '\n' ' ')
        if [ "${favorite_flags[$i]}" = "sensitive" ]; then
            single_line=$(obfuscate_content "$single_line")
        fi
        decoded_lines+=("$single_line")
    done
    return 0
}
cliphist_cmd() {
    if [[ $CLIPHIST_IMAGE_HISTORY != true ]]; then
        echo -e ":f:a:v:\t Favorites"
        echo -e ":o:p:t:\t Options"
        cliphist list
    else
        HYDE_CLIPHIST_IMAGE_ONLY=true cliphist.image.py
    fi
}
show_history() {
    local selected_item
    rofi_args=("  History..." -multi-select -i -display-columns 2 -selected-row 2)
    if [[ $CLIPHIST_IMAGE_HISTORY == true ]]; then
        rofi_args=("  Image History | Alt+S to Scan" -display-columns 2
            -show-icons -eh 3
            -theme-str 'listview { lines: 4; columns: 2; }'
            -theme-str 'element { enabled: true; orientation: vertical; spacing: 0%; padding: 0%; cursor: pointer; background-color: transparent; text-color: @main-fg; horizontal-align: 0.5; }'
            -theme-str 'element-text { enabled: false;}'
            -theme-str 'element-icon {size: 8%; spacing: 0%; padding: 0%; cursor: inherit; background-color: transparent; }'
            -theme-str 'element selected.normal { background-color: @select-bg; text-color: @select-fg; }')
    fi

    selected_item=$(cliphist_cmd | run_rofi "${rofi_args[@]}")
    echo "${?}"
    echo "$selected_item"
    [ -n "$selected_item" ] || exit 0
    handle_special_commands "${selected_item##*$'\n'}"
    if echo -e "$selected_item" | check_content; then
        process_selections <<<"$selected_item" | wl-copy
        paste_string "$@"
        echo -e "$selected_item\t" | cliphist delete
    else
        paste_string "$@"
        exit 0
    fi
}

delete_items() {
    local selected_item
    selected_item="$(cliphist list | run_rofi "  Delete" -multi-select -i -display-columns 2)"
    handle_special_commands "${selected_item##*$'\n'}"
    process_deletion <<<"$selected_item"
}
view_favorites() {
    prepare_favorites_for_display || {
        notify-send "No favorites."
        return
    }
    local selected_item
    selected_item=$(printf "%s\n" "${decoded_lines[@]}" | run_rofi " View Favorites") || exit 0
    if [ -n "$selected_item" ]; then
        handle_special_commands "${selected_item##*$'\n'}"
        local index
        index=$(printf "%s\n" "${decoded_lines[@]}" | grep -nxF "$selected_item" | cut -d: -f1)
        if [ -n "$index" ]; then
            local idx=$((index - 1))
            local selected_encoded_favorite="${favorite_data[$idx]}"
            local flag="${favorite_flags[$idx]}"
            local content
            content=$(echo "$selected_encoded_favorite" | base64 --decode)
            echo "$content" | wl-copy
            # If sensitive, remove from clipboard history for security
            if [ "$flag" = "sensitive" ]; then
                # Small delay to ensure wl-copy is processed by cliphist
                sleep 0.2
                # Find and delete the item from cliphist by matching content
                cliphist list | while IFS= read -r hist_item; do
                    local hist_decoded
                    hist_decoded=$(echo "$hist_item" | cliphist decode)
                    if [ "$hist_decoded" = "$content" ]; then
                        echo "$hist_item" | cliphist delete
                        break
                    fi
                done
                notify-send "Sensitive item copied (not saved to history)."
            else
                notify-send "Copied to clipboard."
            fi
            paste_string "$@"
        else
            notify-send "Error: Selected favorite not found."
        fi
    fi
}
add_to_favorites() {
    ensure_favorites_dir
    local item
    item=$(cliphist list | run_rofi "➕ Add to Favorites...") || exit 0
    if [ -n "$item" ]; then
        local full_item
        full_item=$(echo "$item" | cliphist decode)
        local encoded_item
        encoded_item=$(echo "$full_item" | base64 -w 0)
        # Check if already exists (with any flag)
        if [ -f "$favorites_file" ] && grep -qF "$encoded_item" "$favorites_file"; then
            notify-send "Item is already in favorites."
        else
            echo "normal:$encoded_item" >>"$favorites_file"
            notify-send "Added to favorites."
        fi
    fi
}
delete_from_favorites() {
    parse_favorites || {
        notify-send "No favorites to remove."
        return
    }
    local count=${#favorite_data[@]}
    if [ "$count" -eq 0 ]; then
        notify-send "No favorites to remove."
        return
    fi
    local display_lines=()
    for ((i = 0; i < count; i++)); do
        local decoded
        decoded=$(echo "${favorite_data[$i]}" | base64 --decode)
        local single_line
        single_line=$(echo "$decoded" | tr '\n' ' ')
        local flag="${favorite_flags[$i]}"
        if [ "$flag" = "sensitive" ]; then
            single_line=$(obfuscate_content "$single_line")
        fi
        display_lines+=("$single_line")
    done
    local selected_favorite
    selected_favorite=$(printf "%s\n" "${display_lines[@]}" | run_rofi "➖ Remove from Favorites...") || exit 0
    if [ -n "$selected_favorite" ]; then
        local idx=-1
        for ((i = 0; i < count; i++)); do
            if [ "${display_lines[$i]}" = "$selected_favorite" ]; then
                idx=$i
                break
            fi
        done
        if [ "$idx" -ge 0 ]; then
            local tmp_file
            tmp_file=$(mktemp)
            local line_num=0
            while IFS= read -r line; do
                if [ "$line_num" -ne "$idx" ]; then
                    echo "$line" >>"$tmp_file"
                fi
                line_num=$((line_num + 1))
            done <"$favorites_file"
            mv "$tmp_file" "$favorites_file"
            notify-send "Item removed from favorites."
        else
            notify-send "Error: Selected favorite not found."
        fi
    fi
}
clear_favorites() {
    if [ -f "$favorites_file" ] && [ -s "$favorites_file" ]; then
        local confirm
        confirm=$(echo -e "Yes\nNo" | run_rofi " Clear All Favorites?") || exit 0
        if [ "$confirm" = "Yes" ]; then
            : >"$favorites_file"
            notify-send "All favorites have been deleted."
        fi
    else
        notify-send "No favorites to delete."
    fi
}
manage_favorites() {
    local manage_action
    manage_action=$(echo -e "Add to Favorites\nDelete from Favorites\nClear All Favorites\nToggle Sensitive (/)\nEdit Favorite" | run_rofi " Manage Favorites") || exit 0
    case "$manage_action" in
    "Add to Favorites")
        add_to_favorites
        ;;
    "Delete from Favorites")
        delete_from_favorites
        ;;
    "Clear All Favorites")
        clear_favorites
        ;;
    "Toggle Sensitive (/)")
        toggle_sensitive
        ;;
    "Edit Favorite")
        edit_favorite
        ;;
    *)
        [ -n "$manage_action" ] || return 0
        echo "Invalid action"
        exit 1
        ;;
    esac
}
clear_history() {
    local selected_item
    selected_item=$(echo -e "Yes\nNo" | run_rofi " Clear Clipboard History?")
    handle_special_commands "${selected_item##*$'\n'}"
    if [ "$selected_item" = "Yes" ]; then
        cliphist wipe
        notify-send "Clipboard history cleared."
    fi
}
main_menu_options() {
    cat <<-EOF
		History:::<sub>(Alt+C)</sub>
		Image History:::<sub>(Alt+V)</sub>
		Delete Item:::<sub>(Alt+D)</sub>
		Clear History:::<sub>(Alt+W)</sub>
		View Favorites:::<sub>(Alt+N)</sub>
		Manage Favorites:::<sub>(Alt+O)</sub>
	EOF
}

ocr_scan() {

    # shellcheck disable=SC1091
    source "${LIB_DIR}/hyde/shutils/ocr.sh"
    source ${XDG_STATE_HOME}/hyde/config
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/${EUID}}/hyde"
    local image_path="${runtime_dir}/cliphist_ocr.png"
    local index
    index="$(HYDE_CLIPHIST_IMAGE_ONLY=1 "${LIB_DIR}/hyde/cliphist.image.py" | head -n1)"
    [[ -n $index ]] || {
        send_notifs "OCR Error" "No images in clipboard history..." -r 9
        exit 1
    }

    mkdir -p "$runtime_dir"
    cliphist decode "$index" >"${image_path}"
    if [ ! -s "${image_path}" ]; then
        notify-send "OCR Error" "No image data in clipboard -r 9"
        exit 1
    fi
    print_log -g "Scanning ${image_path}"
    send_notifs "OCR" "Scanning latest image from clipboard..." -i "${image_path}" -r 9
    ocr_extract "$image_path"

}

main() {
    setup_rofi_config

    # Migrate favorites to new format if needed
    migrate_favorites_format

    # shellcheck disable=SC1091
    source "${LIB_DIR}/hyde/shutils/argparse.sh"

    argparse_init "$@"
    argparse_program "hyde-shell cliphist"
    argparse_header "HyDE Clipboard Manager"

    argparse "--copy,-c" "ACTION=copy" "Show clipboard history and copy selected item"
    argparse "--delete,-d" "ACTION=delete" "Delete selected item from clipboard history"
    argparse "--favorites,-f" "ACTION=favorites" "View favorite clipboard items"
    argparse "--manage-fav,-mf" "ACTION=manage_fav" "Manage favorite clipboard items"
    argparse "--wipe,-w" "ACTION=wipe" "Clear clipboard history"
    argparse "--image-history,-i" "ACTION=image_history" "Show image history"
    argparse "--scan-image,-sc" "ACTION=ocr_image" "Use tesseract the latest image from clipboard"
    argparse_finalize

    unset CLIPHIST_IMAGE_HISTORY # prevent image history side effects

    if [ -z "$ACTION" ]; then
        # No arguments provided, show menu
        local main_action
        main_action=$(
            main_menu_options | run_rofi " Options (Alt O)" \
                -display-column-separator ":::" \
                -display-columns 1,2 \
                -markup-rows
        )
        handle_special_commands "${main_action##*$'\n'}"

        main_action="${main_action%%:::*}"

        case "$main_action" in
        "History") ACTION=copy ;;
        "Image History") ACTION=image_history ;;
        "Delete Item") ACTION=delete ;;
        "Clear History") ACTION=wipe ;;
        "View Favorites") ACTION=favorites ;;
        "Manage Favorites") ACTION=manage_fav ;;
        *) exit 0 ;;
        esac
    fi

    # Execute the action
    case "$ACTION" in
    copy) show_history "$@" ;;
    delete) delete_items ;;
    favorites) view_favorites "$@" ;;
    manage_fav) manage_favorites ;;
    wipe) clear_history ;;
    image_history) CLIPHIST_IMAGE_HISTORY=true show_history "$@" ;;
    ocr_image) ocr_scan ;;
    esac
}
main "$@"
