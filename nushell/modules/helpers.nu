
export def contains [value: string] {
    $in != null and ($in | str contains -i $value)
}

export def first-if-one [] {
    if ($in | length) == 1 {
        $in | first
    } else {
        $in
    }
}

