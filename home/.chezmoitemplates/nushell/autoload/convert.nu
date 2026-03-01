def "nu-complete convert image format" [] {
    [ "avif","heif","jpg","png","gif" ]
}

# Windows having \ in path, the glob command may fail
# Replace \ by /, and remove the last one
def replace-slash []: string -> string {
    $in | str replace -a '\' '/' | str replace -r '/$' ''
}

# Convert images with ImageMagick
def convert-images [
    dir: path,
    --format: string@"nu-complete convert image format" # Image format to convert to
    --quality: int # Quality of the export
    --delete-original(-d) # Delete original file
] {
    let dir = $dir | replace-slash
    let $format = ($format | default "avif")
    let $quality = ($quality | default 90)

    glob --no-symlink --no-dir ($"($dir)/**/*") | where { |file|
        let ext: string = ($file | path parse | get extension | str downcase)
        $ext in ["jpg" "jpeg" "png" "webp" "heic" "heif" "bmp" "tif"]
    } | each { |file|
        let parsed: record = ($file | path parse | select parent stem)
        let out: string = [$parsed.parent $"($parsed.stem).($format)"] | path join

        let input_size = ls $file | first | get size
        mut output_size: filesize = 0b
        let message: string = try {
            ^magick $file -quality $quality $out
            $output_size = ls $out | first | get size

            if ($delete_original and ($out | path exists)) {
                rm $file
            }
            "✔️"
        } catch { |err|
            print -e $"Échec de conversion de ($file | path relative-to $env.PWD) : ($err.msg)"
            $"❌ ($err.msg)"
        }

        { input: ($file | path relative-to $env.PWD), input_size: $input_size, output: ($out | path relative-to $env.PWD), output_size: $output_size, message: $message }
    }
}

def "nu-complete convert audio format" [] {
    [ "mp3","opus","wav" ]
}

def "nu-complete audio bitrate" [] {
    [ "32k", "64k","96k","128k" ]
}

# Convert audio with FFmpeg
def convert-audio [
    dir: path,
    --format: string@"nu-complete convert audio format" # Audio format to convert to
    --audio-bitrate: string@"nu-complete audio bitrate" # Audio bitrate (default: 96k)
    --delete-original(-d) # Delete original file
] {
    let dir = $dir | replace-slash
    let $format = ($format | default "opus")
    let audio_bitrate = ($audio_bitrate | default "96k")

    glob --no-symlink --no-dir ($"($dir)/**/*") | where { |file|
        let ext: string = ($file | path parse | get extension | str downcase)
        $ext in ["mp3" "wav"]
    } | each { |file|
        let parsed: record = ($file | path parse | select parent stem)
        let out: string = [$parsed.parent $"($parsed.stem).($format)"] | path join

        let input_size = ls $file | first | get size
        mut output_size: filesize = 0b
        let message: string = try {
            ^ffmpeg -hide_banner -n -i $file -b:a $audio_bitrate $out
            $output_size = ls $out | first | get size

            if ($delete_original and ($out | path exists)) {
                rm $file
            }
            "✔️"
        } catch { |err|
            print -e $"Échec de conversion de ($file | path relative-to $env.PWD) : ($err.msg)"
            $"❌ ($err.msg)"
        }

        { input: ($file | path relative-to $env.PWD), input_size: $input_size, output: ($out | path relative-to $env.PWD), output_size: $output_size, message: $message }
    }
}



def is-codec [file: path, codec: string] {
    let c = ( ^ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $file | str trim )
    $c == $codec
}

def "nu-complete transcode h265 preset" [] {
    [ "veryfast","faster","fast","medium","slow","slower","veryslow" ]
}

# Transcode videos to h265 with FFmpeg
def transcode-hevc_qsv [
    dir: path,
    --preset: string@"nu-complete transcode h265 preset" # Transcoding speed
    --delete-original(-d) # Delete original file
] {
    let dir = $dir | replace-slash
    let $preset = ($preset | default "medium")

    glob --no-symlink --no-dir ($"($dir)/**/*") | where { |f|
        let ext = ($f | path parse | get extension | str downcase)
        $ext in ["mp4" "mkv" "avi" "mpg" "mts" "m2ts"]
    } | each { |file|
        if (is-codec $file "hevc") {
            print $"Déjà en H.265, ignoré: ($file)"
        } else {
            let parsed: record = ($file | path parse | select parent stem)
            let out: string = [$parsed.parent $"($parsed.stem)_hevc.mp4"] | path join
            print $"Conversion de ($file | path relative-to $env.PWD) -> ($out | path relative-to $env.PWD)"

            try {
                ^ffmpeg -hide_banner -n -i $file -c:v hevc_qsv -scenario archive -preset $preset -c:a libopus -b:a 96k -vbr constrained $out
                #^ffmpeg -hide_banner -n -i $f.name -c:v libx265 -preset $preset -c:a libopus -b:a 96k -vbr constrained $out
                if ($delete_original and ($out | path exists)) {
                    rm $file
                }
            } catch { |err|
                print $"Échec du transcodage: ($file | path relative-to $env.PWD) : ($err.msg)"
            }
        }
    } | ignore
}

# Transcode videos to av1 with FFmpeg
def transcode-av1_amf [
    dir: path,
    --delete-original(-d) # Delete original file
] {
    let dir = $dir | replace-slash

    glob --no-symlink --no-dir ($"($dir)/**/*") | where { |f|
        let ext = ($f | path parse | get extension | str downcase)
        $ext in ["mp4" "mkv" "avi" "mpg" "mts" "m2ts"]
    } | each { |f|
        if (is-codec $f "av1") {
            print $"Déjà en AV1, ignoré: ($f | path relative-to $env.PWD)"
        } else {
            let parsed: record = ($f | path parse | select parent stem)
            let out: string = [$parsed.parent $"($parsed.stem)_av1.mp4"] | path join
            print $"Conversion de ($f | path relative-to $env.PWD) -> ($out | path relative-to $env.PWD)"

            try {
                ^ffmpeg -hide_banner -n -i $f -c:v av1_amf -quality high_quality -rc hqvbr -qvbr_quality_level 1 -c:a libopus -b:a 96k -vbr constrained $out
                if ($delete_original and ($out | path exists)) {
                    rm $f
                }
            } catch { |err|
                print $"Échec du transcodage: ($f | path relative-to $env.PWD) : ($err.msg)"
            }
        }
    } | ignore
}

# Transcode videos to av1 with FFmpeg
def transcode-av1_aom [
    dir: path,
    --crf: int # Quality level (default: 23)
    --cpu-used: int # Number of cpu to use
    --audio-bitrate: string@"nu-complete audio bitrate" # Audio bitrate (default: 96k)
    --delete-original(-d) # Delete original file
] {
    let dir = $dir | replace-slash
    let crf = ($crf | default 23)
    let cpu_used = ($cpu_used | default (sys cpu | length) | [$in, 8] | math min)
    let audio_bitrate = ($audio_bitrate | default "96k")

    glob --no-symlink --no-dir ($"($dir)/**/*") | where { |f|
        let ext = ($f | path parse | get extension | str downcase)
        $ext in ["mp4" "mkv" "avi" "mpg" "mts" "m2ts"]
    } | each { |f|
        if (is-codec $f "av1") {
            print $"Déjà en AV1, ignoré: ($f | path relative-to $env.PWD)"
        } else {
            let parsed: record = ($f | path parse | select parent stem)
            let out: string = [$parsed.parent $"($parsed.stem)_av1.mp4"] | path join
            print $"Conversion de ($f | path relative-to $env.PWD) -> ($out | path relative-to $env.PWD)"

            try {
                ^ffmpeg -hide_banner -n -i $f -c:v libaom-av1 -cpu-used $cpu_used -crf $crf -c:a libopus -b:a $audio_bitrate -vbr constrained $out
                if ($delete_original and ($out | path exists)) {
                    rm $f
                }
            } catch { |err|
                print $"Échec du transcodage: ($f | path relative-to $env.PWD) : ($err.msg)"
            }
        }
    } | ignore
}
